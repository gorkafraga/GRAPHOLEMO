clear  
close all
scripts= ('N:\studies\Grapholemo\Methods\Scripts\grapholemo\MR_statistics\SymCtrl');
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
 path_preproc    = 'O:\studies\grapholemo\analysis\LEMO_GFG\mri\preprocessing'; %PARENT path to your preprocessed data (no \ at the end)
path_logs       = 'O:\studies\grapholemo\analysis\LEMO_GFG\mri\preprocessing'; % here the selected files for this analysis, suffix was fixed when needed so all end in  _bX.txt
path_output     = 'O:\studies\grapholemo\analysis\LEMO_GFG\mri\1stLevel'; % parent of output dir
task            = 'symCtrl_pre'; 
manualScanSelection = 0;nscans = 440; % default = 0
%subjects =  {'gpl001','gpl002','gpl003','gpl004','gpl005','gpl006','gpl007','gpl008','gpl009', 'gpl010','gpl011','gpl012','gpl013','gpl015','gpl017','gpl019','gpl024','gpl025','gpl014','gpl021'};
subjects =  {'gpl019'};
%% [don't edit] POPUP! Select your GLM from 1lv scripts available
GLMs        = dir(strcat([scripts,'\LEMO*create_1Lv_*']));
idx2        = listdlg('PromptString','Select GLM','ListString', {GLMs.name},'SelectionMode','single','listSize',[500 100]); % popup 
selectedGLM = strrep(strrep(GLMs(idx2).name,'LEMO_symctrl_func_create_1Lv_',''),'.m','');
disp(['Selected 1st Level: ',selectedGLM])
path_output = strcat(path_output,'\',task,'\1Lv_',selectedGLM);
mkdir(path_output)
   
%% START SUBJECT LOOP 
spm('defaults','fMRI')
for i = 1:length(subjects)
    subject = subjects{i}; 
    if manualScanSelection == 1
        path_output=   strrep(path_output,'1Lv_','SelectScans_1Lv_');
    end
    path_output_subj = fullfile(path_output,'\',subject); %output path for this subject


    if ~isfolder(path_output_subj)
        mkdir(path_output_subj);
    end
    cd(path_output_subj)
    logfileID = fopen('LOG_firstLevel.txt','w');
   
    
  %% PREPARE INPUTS 
   nsessions =1;  
   %Gather onsets from log files. Times needs to be in seconds
    for b = 1:nsessions
      logfilesTMP = dir([path_logs,'\',task,'\',subject,'\func\logs\*.txt']);
      logfiles(b) = {[logfilesTMP.folder,'\',logfilesTMP.name]} ;       
    end
   % call "gather onsets" 
    [onsets] = LEMO_symctrl_func_gatherOnsets(logfiles);                 % call function  
         
    % SESSIONS /SCANS----------------------------------------------------------------------
    % find SCANS matching with log files
    fprintf(logfileID,strcat(['[[',subject,']]\r\n'])); 
    for j = 1:length(logfiles)    
      
         %take  pattern from logfile that can identify its corresponding mr file
          mrfilename = dir([path_preproc,'\',task,'\',subject,'\func\s*wua*.nii']);   
          
         % select scans 
         if manualScanSelection == 1 
           scans{j} =  cellstr(spm_select('ExtFPList',mrfilename.folder, mrfilename.name, 1:nscans))  ;
           disp(['Selected ',num2str(nscans),' scans'])
         elseif manualScanSelection == 0 
           scans{j} = cellstr(spm_select('ExtFPList',mrfilename.folder, mrfilename.name,Inf)) ;
         end 
          
          
          % Read the corresponding RP file
          rpfile =dir([path_preproc,'\',task,'\',subject,'\func\rp*.txt']);
          formatSpec = '%16f%16f%16f%16f%16f%16f%[^\n\r]';
          fileID = fopen([rpfile.folder,'\',rpfile.name],'r');
          rpdat = textscan(fileID, formatSpec, 'Delimiter', '', 'WhiteSpace', '', 'TextType', 'string',  'ReturnOnError', false);
          fclose(fileID);
          
      % Read flagged bad scans (if file found, else create a vector of zeros) 
       badscans =  dir([path_preproc,'\',task,'\',subject,'\func\*badScansIdx.csv']);
       if ~isempty(badscans) % If it doesn't find a flagscan file it will use zeroes
           Regr_badscans = zeros(length(scans{j}),1);  
           badScansIndices = readmatrix([badscans.folder,'\',badscans.name])  % read bad scans indices from file
           Regr_badscans(badScansIndices) = 1;
           logInfBadscans = [badscans.folder,'\',badscans.name];  
      else 
           Regr_badscans = zeros(length(scans{j}),1);  % if no file make a vector of zeros
           logInfBadscans ='No bad scans file'; 
       end   
       if manualScanSelection == 1 
           Regr_badscans(1:length(scans{j})) = 1;       
       end 
          % Merge RP and Flagscans and save table in txt 
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
          fprintf(logfileID,strcat(['...',strrep([mrfilename.folder,'\',mrfilename.name],'\','\\'),'\r\n'])); 
         fprintf(logfileID,strcat(['...',strrep([path_logs,'\',logfiles{j}],'\','\\'),'\r\n'])); 
         fprintf(logfileID,strcat(['...',strrep(logInfBadscans,'\','\\'),'\r\n'])); 
         fprintf(logfileID,strcat(['...',strrep([rpfile.folder,'\',rpfile.name],'\','\\'),'\r\n\r\n']));
        
    end
     clear logfiles
    
  %% CALL MATLABBATCH CREATOR AND RUN
    %%%
    if strcmp('GLM0',selectedGLM)
                matlabbatch = LEMO_symctrl_func_create_1Lv_GLM0(path_output_subj,scans,onsets,nsessions);
      
    end
    
 %% Execute batch
      disp(['_m_d[^_^]b_m Start running ',selectedGLM, ' for ',subject,'...'])
      spm_jobman('run',matlabbatch);
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      movefile(ls([path_output,'\',subject,'\*_001.jpg']),strrep(ls('*_001.jpg'),'_001.jpg','_design.jpg'))
      clear matlabbatch scans  rpdat multireg
      fclose(logfileID);
      disp('done.')

end


