sps%--------------------------------------------------------------------------------------------------------------
%  RUN FIRST LEVEL ANALYSIS 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% script for analyzing tasks on first level
% - Requires 'AR_gather_onsets" to gather onset info
% - Requires 'AR_create_1stLevel_GLM1/2' to create the matlabbatch
% - Output dir and specific GLM function defined in variable "chooseGLM" 
% I. Karipidis (2014), D. Willinger (Nov 2017), P. Haller (May 2018),
%G.Fraga Gonzalez(2020)
%--------------------------------------------------------------------------------------------------------------
%clear all
%close all

%Choose your GLM of interest
selectedGLM = 'GLM0_mopa';
%Specifies the folders assigned to each GLM 

 diroutputChoices = containers.Map({'GLM0','GLM1','GLM1_pm1a','GLM0_halfs','GLM0_quartiles','GLM0_positiv_first10_last10','GLM0_thirds','GLM0_mopa'},...
        {'O:\studies\allread\mri\analyses_NF\mri_analyses_NF\first_level_NF\1Lv_GLM0',... 
        'O:\studies\allread\mri\analyses_NF\mri_analyses_NF\first_level_NF\1Lv_GLM1',...
        'O:\studies\allread\mri\analyses_NF\mri_analyses_NF\first_level_NF\1Lv_GLM1_pm1a',...
        'O:\studies\allread\mri\analyses_NF\mri_analyses_NF\first_level_NF\1Lv_GLM0_halfs',...
        'O:\studies\allread\mri\analyses_NF\mri_analyses_NF\first_level_NF\1Lv_GLM0_quartiles',...
        'O:\studies\allread\mri\analyses_NF\mri_analyses_NF\first_level_NF\GLM0_positiv_first10_last10',...
        'O:\studies\allread\mri\analyses_NF\mri_analyses_NF\first_level_NF\1Lv_GLM0_thirds',...
        'O:\studies\allread\mri\analyses_NF\mri_analyses_NF\first_level_NF\_scripts\model_based\test'});   
    
% Set up directories and some variables 
paths.analysis =  diroutputChoices(selectedGLM);  
addpath ('N:\Users\dwillinger\scripts\ARmodel_ph\scripts');% set path to this script and associated functions
paths.mri = 'O:\studies\allread\mri\analyses_NF\preprocessing_NF\version_september_2020\fbtask_selected_12';% This should have subfolders learn_1 and learn_2
paths.logs = 'N:\Users\dwillinger\scripts\ARmodel_ph\data\data_verygoodperf_20'; % here the selected files for this analysis, suffix was fixed when needed so all end in  _bX.txt
modeloutputfile = 'N:\Users\dwillinger\scripts\ARmodel_ph\data\data_verygoodperf_20\outputs\Parameters_perTrial.csv' 
nscans = 273;
% nscans = 267; %for AR1071
%nscans = 275; %for 1012

mkdir(paths.analysis)
cd (paths.analysis)
%% Begin subject loop

%files = dir([paths.logs,'\AR*']);
%subjects= {files.name};
% subjects = {'AR1071'}; 
% subjects = {'AR1012'};
% subjects = {'AR1093'}; excluded: index exceeds the number of array elements?
subjects = {'AR1004','AR1015','AR1019','AR1021','AR1024','AR1027','AR1029','AR1034','AR1041','AR1042','AR1043','AR1060','AR1063','AR1064','AR1068','AR1081','AR1082','AR1085','AR1099','AR1102'};
%subjects = {'AR1027','AR1029','AR1034','AR1041','AR1042','AR1043','AR1060','AR1063','AR1064','AR1068','AR1081','AR1082','AR1085','AR1099','AR1102'};
%subjects = {'AR1027'};
%subjects = {'AR1003','AR1059','AR1062','AR1066'};%subjects = {'AR1004','AR1021'}; 

%subjects = subjects(~contains(subjects,'AR1025'));
% excludedSubj = {'AR1017','AR1021','AR1062','AR1066', 'AR1012'};
% subjects(cell2mat(cellfun(@(c)find(strcmp(c,subjects)),excludedSubj,'UniformOutput',false)))=[]; %find index and exclude subjects
 
spm('defaults','fMRI')
for i = 1:length(subjects)
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
    nsessions = length(logfiles);
    currPathLogs = [paths.logs,'\',subject];
    [onsets,params] = AR_gather_onsets(logfiles,currPathLogs);
       
    % find SCANS matching with log files
    fprintf(logfileID,strcat(['[[',subject,']]\r\n'])); 
    modeloutput = [];
    for j = 1:length(logfiles)
          %take a pattern from logfile that can identify its corresponding mr file
          logfilesChar = logfiles{j};
          patternId = logfilesChar(end-6:end-4); % block id is used to find correct mr file
          mrfilename = dir([paths.mri,'\**\epis\',subject,'\ART\vs6wuamr*',patternId,'*.nii']);
          
         % Read table with model output 
         if  strcmp('GLM0_mopa',selectedGLM)
            T = readtable(modeloutputfile);
            T = T(contains(T.subjID,subject),:);
           % modeloutput{j} = T(find(T.block==str2num(strrep(patternId,'_B',''))),:);        
            modeloutput{j} = T(find(T.block==j),:);        
         end

         
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
%   if (nsessions == 1 )
%          disp(['><((((^>  Skipping ',subject,'! Only one Log file found.']) 
%         fclose( 'all' );
%          cd ..
%          rmdir(pathSubject,'s') % delete
%   else
 if strcmp('GLM0',selectedGLM)
        matlabbatch = AR_create_1Lv_GLM0(pathSubject,scans,onsets,nsessions);

 elseif strcmp('GLM0_halfs',selectedGLM)
        matlabbatch = AR_create_1Lv_GLM0_halfs(pathSubject,scans,onsets,nsessions);    

 elseif  strcmp('GLM0_thirds',selectedGLM)
         matlabbatch = AR_create_1Lv_GLM0_thirds(pathSubject,scans,onsets,nsessions);

 elseif  strcmp('GLM0_quartiles',selectedGLM)
         matlabbatch = AR_create_1Lv_GLM0_quartiles(pathSubject,scans,onsets,nsessions);

elseif strcmp('GLM0_mopa',selectedGLM)
         matlabbatch = AR_create_1Lv_GLM0_mopa(pathSubject,modeloutput,scans,onsets,nsessions);
else 
         % If using other GLM than 0 , do stuff only if subject did NOT have 0 negative feedback trials
         if (find(cellfun(@isempty,{onsets.fbOnset_neg})))
                 disp(['><((((^>~ Skipping ',subject,'! No negative feedback found in at least one session.'])
                 fclose( 'all' ); 
                 cd ..
                 rmdir(pathSubject,'s') % delete
         else 
                     if   strcmp('GLM1',selectedGLM)
                         matlabbatch = AR_create_1Lv_GLM1(pathSubject,scans,onsets,nsessions);

                      elseif  strcmp('GLM0_positiv_first10_last10',selectedGLM)
                         matlabbatch = AR_create_1Lv_GLM0_positiv_first10_last10(pathSubject,scans,onsets,nsessions);

                      elseif  strcmp('GLM1_pm1a',selectedGLM)
                         matlabbatch = AR_create_1Lv_GLM1_pm1a(pathSubject,scans,onsets,params,nsessions);    

                      elseif   strcmp('GLM2',selectedGLM)
                         matlabbatch = AR_create_1Lv_GLM2(pathSubject,scans,onsets,nsessions);
                     
                 
                     end  
         end 

 end
 
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 % Once the batch is created, RUN it 
   disp(['_m_d[^_^]b_m Start running ',selectedGLM, ' for ',subject,'...'])
   spm_jobman('run',matlabbatch);
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  movefile(ls('*_001.jpg'),strrep(ls('*_001.jpg'),'_001.jpg','_design.jpg'))
  clear matlabbatch
  fclose(logfileID);
  disp('done.')
  clear scans
  
end

