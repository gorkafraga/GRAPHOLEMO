% A wrapper script for preprocessing using  MATLAB parallel toolbox.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Admits input of several subjects and tasks
% REQUIRES:
%       - b0 files in same folder as epi files.One b0 and epi  per folder
%       - folder name as input of 'tasklist' variables
%       - T1 image (1 file) stored in separate folder named "T1w".
%       - Subjects at the last level of the directory
% OUTPUT:
%       - multiple preprocessed files (SPM style)
%       - operation log file in txt.
%--------------------------------------------------------------------------
% Last version: Gorka Fraga (March 2020) adapted from original by David Willinger 
clear all %clear matlabbatch batch;
spm_jobman('initcfg');
addpath ('N:\studies\Grapholemo\Methods\Scripts\grapholemo\MR preprocessing\') 
%% Inputs setup
%------------------------------
subjects = {'AR1016'}; %subjects = {'AR1038','AR1042','AR1045','AR1046','AR1048','AR1055','AR1056'}; %subjects = {'AR1002','AR1004','AR1006','AR1007','AR1008','AR1009','AR1011','AR1016','AR1018','AR1021','AR1023','AR1025','AR1031','AR1035','AR1036','AR1038','AR1042','AR1045','AR1046','AR1048','AR1055','AR1056'}; 
tasklist =  {'learn_1'}; %Recommended to take one task at a time.  [eread, learn, localizer, symCtrl]   
anatTemplate = 'C:\Users\GFraga\Desktop\home_mri\TPM_Age7.1526.nii'; % Called by 'AR_create_fieldmap.m'
% PATHS (end character should be \ )
paths.preprocessing = 'O:\studies\allread\mri\analysis_GFG\preprocessing\';

%% BEGIN TASK LOOP
cd (paths.preprocessing)
for t=1:length(tasklist)
currTask = tasklist{t};
paths.task = [paths.preprocessing,currTask,'\'];
     %empty batch for all subjects
     batch = cell(length(subjects));
     for i=1:length(subjects)   
        currsubject = subjects{i};
        if  isempty(dir([paths.task,'**\',currsubject]))
            disp(['Cannot find ',currsubject,' folder in ',paths.task,' \n'])
        else 
        %%% Call CREATE FIELDMAP. Preprocess b0, creates vdm5 
        %------------------------------
         AR_create_fieldmap_GFG(currsubject,paths,currTask,anatTemplate);

        %%% Create PREPROCESSING batch
        %------------------------------ 
        [batch{i}] = AR_create_matlabbatch_GFG(paths,currTask,currsubject,anatTemplate);
        end
     end
     
%% RUN batch in parallel
%-------------------------------------------------------------------------------------
 if ~isempty(gcp('nocreate'))
            delete(gcp('nocreate'));  
 end
        % if you use parallel for-loop: uncomment (make sure your computers has 8 cores!! If not, change this number to 4 or 2)
        parpool(4);
        parfor i=1:length(subjects)
       % for i=1:length(subjects)  % use this if you deactivate parallel
            %spm_jobman('run',batch{i})
            spm_jobman('interactive',batch{i})
                  
        end
 save([paths.preprocessing,['Batch_',currTask,'_',datestr(now,'mmddyyyy-HHMM'),'.mat']],'batch')
end
