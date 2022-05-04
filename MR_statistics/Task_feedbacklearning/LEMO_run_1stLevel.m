clear all
close all
scripts= ('N:\studies\Grapholemo\Methods\Scripts\grapholemo\MR_statistics');
addpath('N:\studies\Grapholemo\Methods\Scripts\grapholemo\BEH_performance') % path to function to gather performance
addpath(scripts)
%--------------------------------------------------------------------------------------------------------------
%  RUN FIRST LEVEL ANALYSIS 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% script for analyzing tasks on first level  oseGLM" 
% - POPUPs to confirm master file and manual selection of a subject list
% %G.Fraga Gonzalez(2021)
%--------------------------------------------------------------------------------------------------------------
%% [Edit] folders (no \ at the end) and input task
masterfile      = 'O:\studies\grapholemo\LEMO_GFG\LEMO_Master.xlsx';
path_preproc    = 'O:\studies\grapholemo\analysis\LEMO_GFG\mri\preprocessing'; %PARENT path to your preprocessed data (no \ at the end)
path_logs       = 'O:\studies\grapholemo\analysis\LEMO_GFG\mri\preprocessing'; % here the selected files for this analysis, suffix was fixed when needed so all end in  _bX.txt
taskList        = {'FBL_A','FBL_B'};
%%  POPUP! Select your GLM from 1lv scripts available
GLMs        = dir(strcat([scripts,'\Task_feedbacklearning\LEMO*create_1Lv_*']));
%idx2        = listdlg('PromptString','Select GLM','ListString', {GLMs.name},'SelectionMode','single','listSize',[500 100]); % popup 
%selectedGLM = strrep(strrep(GLMs(idx2).name,'LEMO_func_create_1Lv_',''),'.m','');
%selectedGLMlist = {'GLM0','GLM0_halfs','GLM0_thirds','GLM1'};
selectedGLMlist = {'GLM0_mopa_aspepos'};
 
 for semo=1:length(selectedGLMlist)

selectedGLM = selectedGLMlist{semo};
disp(['Selected 1st Level: ',selectedGLM])

    for t=1:length(taskList)
        % Basic inputs
        path_output     = 'O:\studies\grapholemo\analysis\LEMO_GFG\mri\1stLevel\FeedbackLearning'; % parent of output dir
        task            = taskList{t}; 
        manualScanSelection = 0;nscans = 460; % default = 0 nscans is only used if turned to 1
        runs2use      = {'run1','run2'}; %separated by commas e.g., {'run','run2'} 
       % LIST OF SUBJECTS 
        %subjects        = {'gpl038'};
        subjects = dir([path_preproc,'/',task,'/gpl*']);
        subjects = {subjects.name}; 
      %  subjects = {'gpl014'};
        modelversion =      'LEMO_rlddm_v32';
        modeloutputfile =   ['O:\studies\grapholemo\analysis\LEMO_GFG\beh\modeling\analysis_n39\',lower(task),'\',modelversion,'\Parameters_perTrial.csv'] ;
        % Set up output paths
         if  contains(selectedGLM,'_mopa')
                path_output = strcat(path_output,'\',task,'\',modelversion,'\1Lv_',selectedGLM);
                mkdir(path_output)
         else 
               path_output = strcat(path_output,'\',task,'\1Lv_',selectedGLM);
               mkdir(path_output)
         end

        %% START SUBJECT LOOP
        spm('defaults','fMRI')
        for i = 1:length(subjects)
                subject = subjects{i}; 
                if manualScanSelection == 1
                    path_output=   strrep(path_output,'1Lv_','SelectScans_1Lv_');
                end
                    path_output_subj = fullfile(path_output,'\',subject); %output path for this subject

                %Output path for curr subject
                if ~isfolder(path_output_subj)
                    mkdir(path_output_subj);
                end
                cd(path_output_subj)
                logfileID = fopen('LOG_firstLevel.txt','w');

              %% PREPARE SUBJECT INPUTS 
               currRun = split(runs2use,',');
               nsessions = length(currRun);  
               % ONSETS  % ----------------------------------------------------------------------
               %Gather onsets from log files. Times need to be in seconds
               for b = 1:nsessions 
                      logfilesTMP = dir([path_logs,'\',task,'\',subject,'\func\',currRun{b},'\logs\*.txt']);
                      logfiles(b) = {[logfilesTMP.folder,'\',logfilesTMP.name]} ;                           
               end      
                    [onsets,params] = LEMO_func_gatherOnsets(logfiles,'useLogFiles');  

                 %READ MODEL -------if you chose a model-based 1st level: read table with model output 
                 if  contains(selectedGLM,'_mopa')    
                    for b = 1:nsessions 
                        Tmodel = readtable(modeloutputfile);
                        Tmodel = Tmodel(contains(Tmodel.subjID,subject),:);
                        modeloutput{b} = Tmodel(find(Tmodel.block==b),:); 
                    end
                    % Read onsets from the model output file (overwrite those from log files)
                    clear onsets params
                    [onsets,params] = LEMO_func_gatherOnsets(modeloutput,'useModelOutput');  
  
                 end
                
                % SESSIONS /SCANS----------------------------------------------------------------------
                % find SCANS matching with log files
                fprintf(logfileID,strcat(['[[',subject,']]\r\n'])); 
                
                for j = 1:length(logfiles)     
                 

                      %take  pattern from logfile that can identify its corresponding mr file
                      mrfilename = dir([path_preproc,'\',task,'\',subject,'\func\',currRun{j},'\s*wua*.nii']);

                     % select scans ====> 
                     if manualScanSelection == 1 
                       scans{j} =  cellstr(spm_select('ExtFPList',mrfilename.folder, mrfilename.name, 1:nscans))  ;
                       disp(['Selected ',num2str(nscans),' scans'])
                     elseif manualScanSelection == 0 
                       scans{j} = cellstr(spm_select('ExtFPList',mrfilename.folder, mrfilename.name,Inf)) ;
                     end 


                      % Read the corresponding RP file ====> 
                      rpfile =dir([path_preproc,'\',task,'\',subject,'\func\',currRun{j},'\rp*.txt']);
                      formatSpec = '%16f%16f%16f%16f%16f%16f%[^\n\r]';
                      fileID = fopen([rpfile.folder,'\',rpfile.name],'r');
                      rpdat = textscan(fileID, formatSpec, 'Delimiter', '', 'WhiteSpace', '', 'TextType', 'string',  'ReturnOnError', false);
                      fclose(fileID);

                    % Read flagged bad scans (if file found, else create a vector of zeros) 
                          badscans =  dir([path_preproc,'\',task,'\',subject,'\func\',currRun{j},'\*badScansIdx.csv']);
                           if ~isempty(badscans) % If it doesn't find a flagscan file it will use zeroes
                               Regr_badscans = zeros(length(scans{j}),1);  
                               badScansIndices = table2array(readtable([badscans.folder,'\',badscans.name]));  % read bad scans indices from file
                               Regr_badscans(badScansIndices) = 1;
                               logInfBadscans = [badscans.folder,'\',badscans.name];  
                          else 
                               Regr_badscans = zeros(length(scans{j}),1);  % if no file make a vector of zeros
                               logInfBadscans ='No bad scans file'; 
                           end   
                           if manualScanSelection == 1 
                               Regr_badscans(1:length(scans{j})) = 1;       
                           end 

                     % Merge RP and bad scans and save table in txt 
                      if (length(scans{j})~= length(Regr_badscans))
                          Regr_badscans = Regr_badscans(1:length(scans{j})); % Trim the bad scans regressor if the number of scans doesn't match (regressor was created with 273, if scans n are shorter index of actual bad scans index is still preserved)
                          logInfBadscans = strcat(logInfBadscans,'..(trimmed to match number of scans)');
                          disp('trimming bad scans file to match number of scans')
                      end              
                      multireg =  [rpdat{1},rpdat{2},rpdat{3},rpdat{4},rpdat{5},rpdat{6},Regr_badscans];
                      if manualScanSelection == 1
                        multireg=multireg(1:nscans,:);
                      end 
                      writetable(cell2table(num2cell(multireg)),[path_output_subj,'\multiReg_',num2str(j),'.txt'],'WriteVariableNames',false)   
                 %----------------------------------------------------------------------------------------
                     %Write log 
                     fprintf(logfileID,strcat(['Model output read: ',strrep(modeloutputfile,'\','\\'),'\r\n\r\n'])); 
                     fprintf(logfileID,strcat(['...',strrep([mrfilename.folder,'\',mrfilename.name],'\','\\'),'\r\n'])); 
                     fprintf(logfileID,strcat(['...',strrep([path_logs,'\',logfiles{j}],'\','\\'),'\r\n'])); 
                     fprintf(logfileID,strcat(['...',strrep(logInfBadscans,'\','\\'),'\r\n'])); 
                     fprintf(logfileID,strcat(['...',strrep([rpfile.folder,'\',rpfile.name],'\','\\'),'\r\n\r\n']));

                end
                 clear logfiles
              %% CALL MATLABBATCH CREATOR AND RUN
                %%%
                if strcmp('GLM0',selectedGLM)
                            matlabbatch = LEMO_func_create_1Lv_GLM0(path_output_subj,scans,onsets,nsessions);
                %%%
                elseif   strcmp('GLM1',selectedGLM)
                           if    (find(cellfun(@isempty,{onsets.fbOnset_neg})))
                                 disp(['><((((^>~ Skipping ',subject,'! No negative feedback found in at least one session.'])
                                 fclose( 'all' ); 
                                 cd ..
                                 rmdir(path_output_subj,'s') % delete
                          elseif (find(cellfun(@length,{onsets.fbOnset_neg})<2)>0)
                                 disp(['><((°>  Skipping ',subject,'! less than 2 negative feedback found in at least one session.']);
                                 disp(cellfun(@length,{onsets.fbOnset_neg}));
                                 fclose( 'all' ); 
                                 cd ..
                                 rmdir(path_output_subj,'s') % delete
                          else
                            matlabbatch = LEMO_func_create_1Lv_GLM1(path_output_subj,scans,onsets,nsessions);     
                           end
           
               %%% 
               elseif  strcmp('GLM0_halfs',selectedGLM)
                            matlabbatch = LEMO_func_create_1Lv_GLM0_halfs(path_output_subj,scans,onsets,nsessions);  
                               %%%
               elseif  strcmp('GLM0_thirds',selectedGLM)
                            matlabbatch = LEMO_func_create_1Lv_GLM0_thirds(path_output_subj,scans,onsets,nsessions);   
               %%%     
               elseif  strcmp('GLM0_thirds_exMiss',selectedGLM)
                            matlabbatch = LEMO_func_create_1Lv_GLM0_thirds_exMiss(path_output_subj,scans,onsets,nsessions);   
               %%%            
               elseif  strcmp('GLM1_pm1a',selectedGLM)
                            matlabbatch = LEMO_func_create_1Lv_GLM1_pm1a(path_output_subj,scans,onsets,params,nsessions);      
               %%%
               elseif   strcmp('GLM2',selectedGLM)
                            matlabbatch = LEMO_func_create_1Lv_GLM2(path_output_subj,scans,onsets,nsessions);
                            
               elseif   strcmp('concatGLM0_thirds_exMiss',selectedGLM)
                              matlabbatch = LEMO_func_create_1Lv_concatGLM0_thirds_exMiss(path_output_subj,scans,onsets,nsessions);
                            
               % Model-based 
               elseif strcmp('GLM0_mopa_aspe',selectedGLM)
                         matlabbatch = LEMO_func_create_1Lv_GLM0_mopa_aspe(path_output_subj,modeloutput,scans,onsets,nsessions);
                         
               elseif strcmp('GLM0_mopa_aspepos',selectedGLM)
                         matlabbatch = LEMO_func_create_1Lv_GLM0_mopa_aspepos(path_output_subj,modeloutput,scans,onsets,nsessions);
                  
                         
                elseif strcmp('GLM0_mopa_vpe',selectedGLM)
                         matlabbatch = LEMO_func_create_1Lv_GLM0_mopa_vpe(path_output_subj,modeloutput,scans,onsets,nsessions);
                end

             %% Execute batch
                  disp(['_m_d[^_^]b_m Start running ',selectedGLM, ' for ',subject,'...'])
                  spm_jobman('run',matlabbatch);
                  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                  movefile(ls([path_output,'\',subject,'\*_001.jpg']),strrep(ls('*_001.jpg'),'_001.jpg','_design.jpg'))
                  clear matlabbatch scans  rpdat
                  fclose(logfileID);
                  disp('done.')
                 clear onsets

        end
    end
end
