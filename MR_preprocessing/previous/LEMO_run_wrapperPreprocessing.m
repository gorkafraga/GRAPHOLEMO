% A wrapper script for preprocessing using  MATLAB parallel toolbox.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Admits input of several subjects and tasks
% REQUIRES:
%       -  folder name as input of 'currTask' variables
%       - T1 image (1 file) stored in separate folder named "T1w".
%       - Subjects at the last level of the directory
% OUTPUT:
%       - multiple preprocessed files (SPM style)
%       - operation log file in txt.
%--------------------------------------------------------------------------
% Last version: Gorka Fraga (March 2020) adapted from original by David Willinger 
clear all %clear matlabbatch batch;
spm_jobman('initcfg');
addpath ('O:\studies\grapholemo\LEMO_VG\mri\scripts_preprocessing') 
tic 
%% Inputs setup
%------------------------------
subjects = {'g003'}; 
Task =  {'FBL2_A'}; %Only ONE at a time. 
runlist= {'run1','run2'}; % list of runs, leave it empty  {} if you are not processing FBL task or you have no runs 
anatTemplate = 'O:\studies\grapholemo\LEMO_VG\mri\scripts_preprocessing\TPM.nii'; % Called by 'LEMO_create_fieldmap.m'
% PATHS (end character should be \ )
paths.preprocessing = 'O:\studies\grapholemo\LEMO_GFG\preprocessing\';

%% BEGIN TASK LOOP
currTask = Task{1};
cd (paths.preprocessing)
if (contains(runlist,'run')) % if there are runs add the paths of each run to your paths_task 
    for r=1:length(runlist)
         listpaths_task{r} = [paths.preprocessing,currTask,'\',runlist{r},'\'];
    end
else
    listpaths_task = [paths.preprocessing,currTask,'\'];
end

for t=1:length(listpaths_task)
    paths_task = listpaths_task{t};
    %empty batch for all subjects
    batch = cell(length(subjects));
    for i=1:length(subjects)   
        currsubject = subjects{i};
        if  isempty(dir([paths_task,currsubject]))
            disp(['Cannot find ',currsubject,' folder in ',paths_task,' \n'])
            doNotRun =1;
        else 
        doNotRun =0;
        %%% Call CREATE FIELDMAP. Preprocess b0, creates vdm5 
        %------------------------------
         LEMO_func_create_fieldmap(currsubject,paths_task,currTask,anatTemplate);

        %%% Create PREPROCESSING batch
        %------------------------------ 
        [batch{i}] = LEMO_func_create_matlabbatch(paths_task,currTask,currsubject,anatTemplate);
        end
    end
     
%% RUN batch in parallel
%-------------------------------------------------------------------------------------
 if ~isempty(gcp('nocreate'))
            delete(gcp('nocreate'));  
 end
  if  doNotRun==0 
        % if you use parallel for-loop: uncomment (make sure your computers has 8 cores!! If not, change this number to 4 or 2)
        parpool(4);
        parfor i=1:length(subjects)
       % for i=1:length(subjects)  % use this if you deactivate parallel
            %spm_jobman('run',batch{i})
           try
              data_out{i} =  spm_jobman('run',batch{i})
                %spm_jobman('interactive',batch{i})
           catch
                data_out{i} = disp('error during preprocessing - check the batch')
           end    
        end
  end
 save([paths.preprocessing,['Batch_',currTask,'_',datestr(now,'mmddyyyy-HHMM'),'.mat']],'batch')
end
toc