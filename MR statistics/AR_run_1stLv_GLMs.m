%--------------------------------------------------------------------------------------------------------------
%  RUN FIRST LEVEL ANALYSIS 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% script for analyzing tasks on first level
% - Requires 'AR_gather_onsets" to gather onset info
% - Requires 'AR_create_1stLevel_GLM1/2' to create the matlabbatch
% - Output dir and specific GLM function defined in variable "chooseGLM" 
% I. Karipidis (2014), D. Willinger (Nov 2017), P. Haller (May 2018),
%G.Fraga Gonzalez(2020)
%--------------------------------------------------------------------------------------------------------------
clear all
close all
% Set up directories and some variables 
chooseGLM = 21;
disp('_m_d[^_^]b_m Running GLM2..........') 

if chooseGLM==1
    paths.analysis =  'O:\studies\allread\mri\analysis_GFG\stats\1stLevel_GLM1\learn_12';
elseif  chooseGLM==11
     paths.analysis = 'O:\studies\allread\mri\analysis_GFG\stats\1stLevel_GLM1pm\learn_12';
elseif  chooseGLM==2
     paths.analysis = 'O:\studies\allread\mri\analysis_GFG\stats\1stLevel_GLM2\learn_12';
elseif  chooseGLM==21
     paths.analysis = 'O:\studies\allread\mri\analysis_GFG\stats\1stLevel_GLM2pm\learn_12';
else 
    disp('Specify your GLM!')
    return
end
addpath ('N:\studies\Grapholemo\Methods\Scripts\grapholemo\MR statistics');
paths.mri = 'O:\studies\allread\mri\analysis_GFG\preprocessing';% This should have subfolders learn_1 and learn_2
paths.logs = 'O:\studies\allread\mri\analysis_GFG\stats\task_logs'; % here the selected files for this analysis, suffix was fixed when needed so all end in  _bX.txt
nscans = 273;
nsessions = 2;
% Just some input for ploting some results
pthresh = 0.0001;
nvoxels = 10;
pcorr = 'none'; % 'none', 'FWE';
cd (paths.analysis)

%% Begin subject loop
% subjects = {'AR1005'};
files = dir([paths.logs,'\AR*']);
subjects= {files.name};
subjects = {'AR1005'};
%spm fmri
spm('defaults','fMRI')
for i =1:length(subjects)
    subject = subjects{i}; 
    pathSubject = fullfile(paths.analysis,'\',subject); %output path
    if ~isdir(pathSubject)
        mkdir(pathSubject);
    end
    cd(pathSubject)
    logfileID = fopen('LOG_firstLevel.txt','w');

   %% PREPARE INPUTS 
   %Gather onsets from log files. Times need to be in seconds
    logfilesTMP = dir([paths.logs,'\',subject,'\*FeedLearn*.txt']);
    logfiles = {logfilesTMP.name}  ;  
    currPathLogs = [paths.logs,'\',subject];
    [onsets,params] = AR_gather_onsets(logfiles,currPathLogs);
  
    % find SCANS matching with log files
    fprintf(logfileID,strcat(['[[',subject,']]\r\n'])); 
    for j = 1:length(logfiles)
          %take a pattern from logfile that can identify its corresponding mr file
          logfilesChar = logfiles{j};
          patternId = logfilesChar(end-6:end-4); % block id is used to find correct mr file
          mrfilename = dir([paths.mri,'\**\epis\',subject,'\ART\vs6wuamr*',patternId,'*.nii']);
          % select scans 
          scans{j} =  cellstr(spm_select('ExtFPList',mrfilename.folder, mrfilename.name, Inf))  ;
          % Read the corresponding RP file
          rpfile = dir([paths.mri,'\**\epis\',subject,'\rp_amr*',patternId,'*.txt']);

          formatSpec = '%16f%16f%16f%16f%16f%16f%[^\n\r]';
          fileID = fopen([rpfile.folder,'\',rpfile.name],'r');
          rpdat = textscan(fileID, formatSpec, 'Delimiter', '', 'WhiteSpace', '', 'TextType', 'string',  'ReturnOnError', false);
          fclose(fileID);

          mrfilenameSplit = split(mrfilename.folder,'\');
          sessionID  =  mrfilenameSplit{find(contains(mrfilenameSplit,'learn'))};
          % Read flagged bad scans (if file found) 
           badscans = dir([paths.mri,'\',sessionID,'\epis\',subject,'\ART\*flagscans.mat']);
           if ~isempty(badscans) % If it doesn't find a flagscan file it will use zeroes
               load([badscans.folder,'\',badscans.name]);  % load variable Regr_badscans from file
               logInfBadscans = [badscans.folder,'\',badscans.name];  
          else 
               Regr_badscans = zeros(nscans,1);   
               disp(['Could not find bad scans for ',subject,'!']);
               logInfBadscans ='No bad scans file'; 
          end
          % Merge RP and Flagscans and save table in txt 
          multireg =  [rpdat{1},rpdat{2},rpdat{3},rpdat{4},rpdat{5},rpdat{6},Regr_badscans];
          writetable(cell2table(num2cell(multireg)),[pathSubject,'\multiReg_',num2str(j),'.txt'],'WriteVariableNames',false)

         %Write log 
         fprintf(logfileID,strcat(['...',strrep([mrfilename.folder,'\',mrfilename.name],'\','\\'),'\r\n'])); 
         fprintf(logfileID,strcat(['...',strrep([paths.logs,'\',logfiles{j}],'\','\\'),'\r\n'])); 
         fprintf(logfileID,strcat(['...',strrep(logInfBadscans,'\','\\'),'\r\n'])); 
         fprintf(logfileID,strcat(['...',strrep([rpfile.folder,'\',rpfile.name],'\','\\'),'\r\n\r\n']));
    end
    
    
  %% CALL MATLABBATCH CREATOR AND RUN
  if ((chooseGLM == 2 || chooseGLM==21) && (isempty(onsets(1).fbOnset_neg) || isempty(onsets(2).fbOnset_neg)))
     disp(['><((((^>  Skipping ',subject,'! No negative feedback found in at least one session.'])            
  else
      if chooseGLM ==1 
        matlabbatch = AR_create_1stLevel_GLM1(pathSubject,scans,onsets,nsessions,pcorr,pthresh,nvoxels);
      elseif   chooseGLM ==2 
         matlabbatch = AR_create_1stLevel_GLM2(pathSubject,scans,onsets,nsessions,pcorr,pthresh,nvoxels);
      elseif  chooseGLM==21
         matlabbatch = AR_create_1stLevel_GLM2pm(pathSubject,scans,onsets,params,nsessions,pcorr,pthresh,nvoxels);
      end

      spm_jobman('run',matlabbatch);
      movefile(ls('*_001.jpg'),strrep(ls('*_001.jpg'),'_001.jpg','_design.jpg'))
      clear matlabbatch
      fclose(logfileID);
  end
end

