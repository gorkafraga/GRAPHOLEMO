clear  
close all
scripts= ('N:\studies\Grapholemo\Methods\Scripts\grapholemo\MR_statistics');
addpath('N:\studies\Grapholemo\Methods\Scripts\grapholemo\BEH_performance') % path to function to gather performance
addpath(scripts)
%--------------------------------------------------------------------------------------------------------------
%  RUN FIRST LEVEL ANALYSIS 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% script for analyzing tasks on first level
% - Requires 'AR_gather_onsets" to gather onset info
% - Requires 'LEMO_create_1stLevel_GLM1*.n' to create the matlabbatch
% - Output dir and specific GLM function defined in variable "chooseGLM" 
% - POPUPs to confirm master file and manual selection of a subject list
% %G.Fraga Gonzalez(2021)
%--------------------------------------------------------------------------------------------------------------
%% [Edit] folders (no \ at the end) and input task
masterfile      = 'O:\studies\grapholemo\LEMO_GFG\LEMO_Master.xlsx';
path_preproc    = 'O:\studies\grapholemo\LEMO_GFG\preprocessing'; %path to your preprocessed data 
path_logs       = 'O:\studies\grapholemo\LEMO_GFG\preprocessing'; % here the selected files for this analysis, suffix was fixed when needed so all end in  _bX.txt
path_output     = 'O:\studies\grapholemo\LEMO_GFG\analysis'; % parent of output dir
task            = 'FBL_A'; 
blocks2use      = {'1'};
subjects        = {'g002'};
%modelversion =       'AR_rlddm_v11';
%modeloutputfile =   ['O:\studies\allread\mri\analysis_GFG\stats\task\modelling\RLDDM_fromLocal\GoodPerf_72\outputs\out_',modelversion,'\Parameters_perTrial.csv'] ;

%% [don't edit] POPUP! Select your GLM from 1lv scripts available
GLMs        = dir(strcat([scripts,'\LEMO*create_1Lv_*']));
idx2        = listdlg('PromptString','Select GLM','ListString', {GLMs.name},'SelectionMode','single','listSize',[500 100]); % popup 
selectedGLM = strrep(strrep(GLMs(idx2).name,'LEMO_create_1Lv_',''),'.m','');
disp(['Selected 1st Level: ',selectedGLM])

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
    path_output_subj = fullfile(path_output,'\',subject); %output path for this subject
    if ~isfolder(path_output_subj)
        mkdir(path_output_subj);
    end
    cd(path_output_subj)
    logfileID = fopen('LOG_firstLevel.txt','w');
   
    
  %% PREPARE INPUTS 
   currBlocks = split(blocks2use,',');
   nsessions = length(currBlocks);  
   % ONSETS  % ----------------------------------------------------------------------
   %Gather onsets from log files. Times need to be in seconds
   for b = 1:nsessions
      logfilesTMP = dir([path_logs,'\',task,'\Block',currBlocks{b},'\',subject,'\func\logs\*.txt']);
      logfiles(b) = {logfilesTMP.name} ;       
    end
   % call "gather onsets" and "gather performance" (will  save a table)
    [onsets,params] = LEMO_gather_onsets(logfiles,currPathLogs);                 % call function  
    LEMO_function_gather_performance(logfiles,currPathLogs);                              %  call function
     
    % SESSIONS /SCANS----------------------------------------------------------------------
    % find SCANS matching with log files
    fprintf(logfileID,strcat(['[[',subject,']]\r\n'])); 
    for j = 1:length(logfiles)
        
         %-------if you chose a model-based 1st level: read table with model output 
         if  contains(selectedGLM,'_mopa')
            Tmodel = readtable(modeloutputfile);
            Tmodel = Tmodel(contains(Tmodel.subjID,subject),:);
            % modeloutput{j} = T(find(T.block==str2num(strrep(patternId,'_B',''))),:);        
            modeloutput{j} = Tmodel(find(Tmodel.block==j),:);        
         end

          %take a pattern from logfile that can identify its corresponding mr file
          logfilesChar = logfiles{j};
          patternId = logfilesChar(end-6:end-4); % block id is used to find correct mr file
          mrfilename = dir([path_preproc,'\block*\epis\',subject,'\ART\vs6wuamr*',patternId,'*.nii']);
          
          % select scans 
          scans{j} =  cellstr(spm_select('ExtFPList',mrfilename.folder, mrfilename.name, Inf))  ;
          
          % Read the corresponding RP file
          rpfile = dir([path_preproc,'\block*\epis\',subject,'\rp_amr*',patternId,'*.txt']);
          formatSpec = '%16f%16f%16f%16f%16f%16f%[^\n\r]';
          fileID = fopen([rpfile.folder,'\',rpfile.name],'r');
          rpdat = textscan(fileID, formatSpec, 'Delimiter', '', 'WhiteSpace', '', 'TextType', 'string',  'ReturnOnError', false);
          fclose(fileID);
          
          mrfilenameSplit = split(mrfilename.folder,'\');
          sessionID  =  mrfilenameSplit{find(contains(mrfilenameSplit,'block'))};
          % Read flagged bad scans (if file found, else create a vector of zeros) 
           badscans = dir([path_preproc,'\',sessionID,'\epis\',subject,'\ART\*flagscans_inBlock.mat']);
           if ~isempty(badscans) % If it doesn't find a flagscan file it will use zeroes
               load([badscans.folder,'\',badscans.name]);  % load variable Regr_badscans from file
               logInfBadscans = [badscans.folder,'\',badscans.name];  
          else 
               Regr_badscans = zeros(length(scans{j}),1);  % if no file make a vector of zeros
               logInfBadscans ='No bad scans file'; 
           end
          
          % Merge RP and Flagscans and save table in txt 
          if (length(scans{j})~= length(Regr_badscans))
              Regr_badscans = Regr_badscans(1:length(scans{j})); % Trim the bad scans regressor if the number of scans doesn't match (regressor was created with 273, if scans n are shorter index of actual bad scans index is still preserved)
              logInfBadscans = strcat(logInfBadscans,'..(trimmed to match number of scans)');
              disp('trimming bad scans file to match number of scans')
          end              
          multireg =  [rpdat{1},rpdat{2},rpdat{3},rpdat{4},rpdat{5},rpdat{6},Regr_badscans];
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
                matlabbatch = LEMO_create_1Lv_GLM0(path_output_subj,scans,onsets,nsessions);
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
                matlabbatch = LEMO_create_1Lv_GLM1(path_output_subj,scans,onsets,nsessions);     
               end
               
   elseif strcmp('GLM0_mopa',selectedGLM)
             matlabbatch = LEMO_create_1Lv_GLM0_mopa(path_output_subj,modeloutput,scans,onsets,nsessions);
             
    elseif strcmp('GLM0_mopa_vpe',selectedGLM)
             matlabbatch = LEMO_create_1Lv_GLM0_mopa_vpe(path_output_subj,modeloutput,scans,onsets,nsessions);
   %%%
   elseif  strcmp('GLM1_pm1a',selectedGLM)
                matlabbatch = LEMO_create_1Lv_GLM1_pm1a(path_output_subj,scans,onsets,params,nsessions);      
   %%%
   elseif   strcmp('GLM2',selectedGLM)
                matlabbatch = LEMO_create_1Lv_GLM2(path_output_subj,scans,onsets,nsessions);
    end
    
    %% Execute batch
      disp(['_m_d[^_^]b_m Start running ',selectedGLM, ' for ',subject,'...'])
      spm_jobman('run',matlabbatch);
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      movefile(ls([path_output,'\',subject,'\*_001.jpg']),strrep(ls('*_001.jpg'),'_001.jpg','_design.jpg'))
      clear matlabbatch scans  rpdat
      fclose(logfileID);
      disp('done.')

end


