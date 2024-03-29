clear all
close all
%--------------------------------------------------------------------------------------------------------------
%  RUN FIRST LEVEL ANALYSIS 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% script for analyzing tasks on first level
% - Requires 'AR_gather_onsets" to gather onset info
% - Requires 'AR_create_1stLevel_GLM1*.n' to create the matlabbatch
% - Output dir and specific GLM function defined in variable "chooseGLM" 
% - POPUPs to confirm master file and manual selection of a subject list
% %G.Fraga Gonzalez(2020)
%--------------------------------------------------------------------------------------------------------------
masterfile =        'O:\studies\allread\mri\analysis_GFG\Allread_MasterFile_GFG.xlsx';
paths.mri =         'O:\studies\allread\mri\preprocessed_LearningTask';% 
paths.logs =        'O:\studies\allread\mri\analysis_GFG\stats\task\logs\normperf_72'; % here the selected files for this analysis, suffix was fixed when needed so all end in  _bX.txt
modelversion =       'AR_rlddm_v11';
modeloutputfile =   ['O:\studies\allread\mri\analysis_GFG\stats\task\modelling\RLDDM_fromLocal\GoodPerf_72\outputs\out_',modelversion,'\Parameters_perTrial.csv'] ;

scripts= ('N:\studies\Grapholemo\Methods\Scripts\grapholemo\MR_statistics');
addpath('N:\studies\Grapholemo\Methods\Scripts\grapholemo\BEH_performance') % path to function to gather performance
addpath(scripts)
%% Select GLM from 1lv scripts available

GLMs =  dir(strcat([scripts,'\*create_1Lv_*']));
idx2 =  listdlg('PromptString','Select GLM','ListString', {GLMs.name}); % popup 
selectedGLM =   strrep(strrep(GLMs(idx2).name,'AR_create_1Lv_',''),'.m','');
disp(['Selected 1st Level: ',selectedGLM])

%% POPUP Select SUBJECTS and BLOCKS from masterfile columns 
T =             readtable(masterfile,'sheet','Lists_subsamples'); 
[indx,tf] =     listdlg('PromptString','Select a list of participants:','ListString', T.Properties.VariableNames); % popup 
groupName =     T.Properties.VariableNames(indx);
Tcolumn =       T{:,indx};
subjects =      Tcolumn(~cellfun('isempty',Tcolumn))';
% blocks
T2 =            readtable(masterfile,'sheet','Learn_performance');
allsubs =       T2(:,contains(T2.Properties.VariableNames,'subjID'));
allblocks =     T2(:,contains(T2.Properties.VariableNames,'BlockSelectXerrors'));
blocks =        allblocks(contains(table2array(allsubs),subjects),:);
blocks2use = table2cell(blocks);
summary = [allsubs(contains(table2array(allsubs),subjects),:),blocks];
disp(strcat('[[subject list =  ',groupName,' ]]')) % m_(-.-)_m ..
disp(summary)

% Set up output paths
  if  contains(selectedGLM,'_mopa')
        paths.analysis = strcat('O:\studies\allread\mri\analysis_GFG\stats\mri\',cell2mat(groupName),'\',modelversion,'\1Lv_',selectedGLM);
        mkdir(paths.analysis)
  else 
       paths.analysis = strcat('O:\studies\allread\mri\analysis_GFG\stats\mri\',cell2mat(groupName),'\1Lv_',selectedGLM);
        mkdir(paths.analysis)
  end 
  
%% RUN 
spm('defaults','fMRI')
for i = 1:length(subjects)
    subject = subjects{i}; 
    pathSubject = fullfile(paths.analysis,'\',subject); %output path
    if ~isdir(pathSubject)
        mkdir(pathSubject);
    end
    cd(pathSubject)
    logfileID = fopen('LOG_firstLevel.txt','w');
   % Get block indexes for this subject
    currBlocks = split(blocks2use{i},',');
  %% PREPARE INPUTS 
   nsessions = length(currBlocks);  
   % ONSETS  % ----------------------------------------------------------------------
   %Gather onsets from log files. Times need to be in seconds
   for b = 1:nsessions
      logfilesTMP = dir([paths.logs,'\',subject,'\*FeedLearn*','b',currBlocks{b},'.txt']);
      logfiles(b) = {logfilesTMP.name} ;       
    end
    currPathLogs = [paths.logs,'\',subject];
   % call "gather onsets" and "gather performance" (will  save a table)
    [onsets,params] = AR_gather_onsets(logfiles,currPathLogs);                 % call function  
    AR_function_gather_performance(logfiles,currPathLogs);                              %  call function
     
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
          mrfilename = dir([paths.mri,'\block*\epis\',subject,'\ART\vs6wuamr*',patternId,'*.nii']);
          
          % select scans 
          scans{j} =  cellstr(spm_select('ExtFPList',mrfilename.folder, mrfilename.name, Inf))  ;
          
          % Read the corresponding RP file
          rpfile = dir([paths.mri,'\block*\epis\',subject,'\rp_amr*',patternId,'*.txt']);
          formatSpec = '%16f%16f%16f%16f%16f%16f%[^\n\r]';
          fileID = fopen([rpfile.folder,'\',rpfile.name],'r');
          rpdat = textscan(fileID, formatSpec, 'Delimiter', '', 'WhiteSpace', '', 'TextType', 'string',  'ReturnOnError', false);
          fclose(fileID);
          
          mrfilenameSplit = split(mrfilename.folder,'\');
          sessionID  =  mrfilenameSplit{find(contains(mrfilenameSplit,'block'))};
          % Read flagged bad scans (if file found, else create a vector of zeros) 
           badscans = dir([paths.mri,'\',sessionID,'\epis\',subject,'\ART\*flagscans_inBlock.mat']);
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
          writetable(cell2table(num2cell(multireg)),[pathSubject,'\multiReg_',num2str(j),'.txt'],'WriteVariableNames',false)   
     %----------------------------------------------------------------------------------------
         %Write log 
         fprintf(logfileID,strcat(['Model output read: ',strrep(modeloutputfile,'\','\\'),'\r\n\r\n'])); 
         fprintf(logfileID,strcat(['...',strrep([mrfilename.folder,'\',mrfilename.name],'\','\\'),'\r\n'])); 
         fprintf(logfileID,strcat(['...',strrep([paths.logs,'\',logfiles{j}],'\','\\'),'\r\n'])); 
         fprintf(logfileID,strcat(['...',strrep(logInfBadscans,'\','\\'),'\r\n'])); 
         fprintf(logfileID,strcat(['...',strrep([rpfile.folder,'\',rpfile.name],'\','\\'),'\r\n\r\n']));
        
    end
     clear logfiles
    
  %% CALL MATLABBATCH CREATOR AND RUN
  % First check whether you can run this subject...
  %if (nsessions == 1 )
  %      disp(['><((((^>  Skipping ',subject,'! Only one Log file found.']) 
  %     fclose( 'all' );
  %      cd ..
  %       rmdir(pathSubject,'s') % delete
  %else
  
    %%%
    if strcmp('GLM0',selectedGLM)
                matlabbatch = AR_create_1Lv_GLM0(pathSubject,scans,onsets,nsessions);
    %%%
    elseif   strcmp('GLM1',selectedGLM)
               if    (find(cellfun(@isempty,{onsets.fbOnset_neg})))
                     disp(['><((((^>~ Skipping ',subject,'! No negative feedback found in at least one session.'])
                     fclose( 'all' ); 
                     cd ..
                     rmdir(pathSubject,'s') % delete
              elseif (find(cellfun(@length,{onsets.fbOnset_neg})<2)>0)
                     disp(['><((�>  Skipping ',subject,'! less than 2 negative feedback found in at least one session.']);
                     disp(cellfun(@length,{onsets.fbOnset_neg}));
                     fclose( 'all' ); 
                     cd ..
                     rmdir(pathSubject,'s') % delete
              else
                matlabbatch = AR_create_1Lv_GLM1(pathSubject,scans,onsets,nsessions);     
               end
               
   elseif strcmp('GLM0_mopa',selectedGLM)
             matlabbatch = AR_create_1Lv_GLM0_mopa(pathSubject,modeloutput,scans,onsets,nsessions);
             
    elseif strcmp('GLM0_mopa_vpe',selectedGLM)
             matlabbatch = AR_create_1Lv_GLM0_mopa_vpe(pathSubject,modeloutput,scans,onsets,nsessions);
   %%%
   elseif  strcmp('GLM1_pm1a',selectedGLM)
                matlabbatch = AR_create_1Lv_GLM1_pm1a(pathSubject,scans,onsets,params,nsessions);      
   %%%
   elseif   strcmp('GLM2',selectedGLM)
                matlabbatch = AR_create_1Lv_GLM2(pathSubject,scans,onsets,nsessions);
   end
   %% Execute batch
      disp(['_m_d[^_^]b_m Start running ',selectedGLM, ' for ',subject,'...'])
      spm_jobman('run',matlabbatch);
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      movefile(ls([paths.analysis,'\',subject,'\*_001.jpg']),strrep(ls('*_001.jpg'),'_001.jpg','_design.jpg'))
      clear matlabbatch scans  rpdat
      fclose(logfileID);
      disp('done.')

end


