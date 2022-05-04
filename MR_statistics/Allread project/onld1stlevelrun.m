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
masterfile = 'O:\studies\allread\mri\analysis_GFG\Allread_MasterFile_GFG.xlsx'; % for reading subjects
%Chooice your GLM of interest
selectedGLM = 'GLM1';
% Specifies the folders assigned to each GLM 
diroutputChoices = containers.Map({'GLM0','GLM1','GLM1_pm1a','GLM2','GLMDUMMY'},...
        {'O:\studies\allread\mri\analysis_GFG\stats\mri\1Lv_GLM0',... 
        'O:\studies\allread\mri\analysis_GFG\stats\mri\1Lv_GLM1',...
        'O:\studies\allread\mri\analysis_GFG\stats\mri\1Lv_GLM1_pm1a',...
        'O:\studies\allread\mri\analysis_GFG\stats\mri\1Lv_GLM2',...
         'O:\studies\allread\mri\analysis_GFG\stats\mri\GLMDUMMY' });
     
% Set up directories and some variables 
paths.analysis =  diroutputChoices(selectedGLM);  
addpath ('N:\studies\Grapholemo\Methods\Scripts\grapholemo\MR statistics');% set path to this script and associated functions
paths.mri = 'G:\preprocessing';% 
paths.logs = 'O:\studies\allread\mri\analysis_GFG\stats\task\logs_raw'; % here the selected files for this analysis, suffix was fixed when needed so all end in  _bX.txt
%nscans = 273;

%% Begin subject selection
T = readtable(masterfile,'sheet','Lists_subsamples'); 
[indx,tf] = listdlg('PromptString','Select a list of participants:','ListString', T.Properties.VariableNames); % popup 
if (isempty(indx))
    groupName = 'manual';
    files = dir([dirinput,'\AR*']);
    subjects= {files.name};
    %subjects = subjects(~contains(subjects,'AR1025'));
    %excludedSubj = {'AR1025'};
    %subjects(cell2mat(cellfun(@(c)find(strcmp(c,subjects)),excludedSubj,'UniformOutput',false)))=[]; %find index and exclude subjects
else 
    groupName = T.Properties.VariableNames(indx);
    Tcolumn = T{:,indx};
    subjects = Tcolumn(~cellfun('isempty',Tcolumn))'
end

% Find index of selected blocks for selected subjects
TT = readtable(masterfile,'sheet','MR_Learn_QA');
[indx2,tf2]= listdlg('PromptString','Choose variable with block selection','ListString', TT.Properties.VariableNames); % popup 
blocks2use = table2cell(TT(contains(TT.subjID,subjects),indx2));

% Add grouping info to output path and create output path
paths.analysis = strcat(paths.analysis,'_',cell2mat(groupName));
mkdir(paths.analysis)
cd (paths.analysis)

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
   %Gather onsets from log files. Times need to be in seconds
    for b = 1:nsessions
      logfilesTMP = dir([paths.logs,'\',subject,'\*FeedLearn*','b',currBlocks{b},'.txt']);
      logfiles(b) = {logfilesTMP.name}  ;       
    end
    currPathLogs = [paths.logs,'\',subject];
    [onsets,params] = AR_gather_onsets(logfiles,currPathLogs);
        
    % find SCANS matching with log files
    fprintf(logfileID,strcat(['[[',subject,']]\r\n'])); 
    for j = 1:length(logfiles)
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
               Regr_badscans = zeros(nscans,1);   
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
  % First check whether you can run this subject...
  if (nsessions == 1 )
         disp(['><((((^>  Skipping ',subject,'! Only one Log file found.']) 
        fclose( 'all' );
         cd ..
         rmdir(pathSubject,'s') % delete
  elseif (find(cellfun(@isempty,{onsets.fbOnset_neg})))
         disp(['><((((^>~ Skipping ',subject,'! No negative feedback found in at least one session.'])
         fclose( 'all' ); 
         cd ..
         rmdir(pathSubject,'s') % delete
  else 
      
  % If subject OK, run selected GLM
      if strcmp('GLM0',selectedGLM)
        matlabbatch = AR_create_1Lv_GLM0(pathSubject,scans,onsets,nsessions);
        
      elseif   strcmp('GLM1',selectedGLM)
         matlabbatch = AR_create_1Lv_GLM1(pathSubject,scans,onsets,nsessions);
         
      elseif  strcmp('GLM1_pm1a',selectedGLM)
         matlabbatch = AR_create_1Lv_GLM1_pm1a(pathSubject,scans,onsets,params,nsessions);
         
      elseif   strcmp('GLM2',selectedGLM)
         matlabbatch = AR_create_1Lv_GLM2(pathSubject,scans,onsets,nsessions);
      end

      disp(['_m_d[^_^]b_m Start running ',selectedGLM, ' for ',subject,'...'])
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      spm_jobman('run',matlabbatch);
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      movefile(ls('*_001.jpg'),strrep(ls('*_001.jpg'),'_001.jpg','_design.jpg'))
      clear matlabbatch
      fclose(logfileID);
      disp('done.')
      clear scans
  end
end

