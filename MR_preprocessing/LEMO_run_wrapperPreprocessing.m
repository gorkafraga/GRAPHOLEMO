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
close all
clear   %clear matlabbatch batch;
spm_jobman('initcfg');  
addpath ('N:\studies\Grapholemo\Methods\Scripts\grapholemo\MR_preprocessing') 
%% Inputs setup
%------------------------------
tic 
subjects = {'gpl006'}; 
Task =  {'fbl_b'}; %Only ONE at a time. 
runlist = {'run1','run2'};%{'run1','run2'}; % list of runs, leave it empty  {} if you are not processing FBL task or you have no runs 
anatTemplate = 'C:\Users\gfraga\spm12\tpm\TPM.nii'; % Called by 'LEMO_create_fieldmap.m'

%PATHS (end character should be \ )
paths.preprocessing = 'G:\GRAPHOLEMO\lemo_preproc\';

%% BEGIN TASK LOOP
currTask = Task{1};
cd (paths.preprocessing)
paths_task = [paths.preprocessing,currTask];

%empty batch for all subjects
batch = cell(length(subjects));
for i=1:length(subjects)   
    currsubject = subjects{i};
    if  isempty(dir([paths_task,'\',currsubject]))
        disp(['Cannot find ',currsubject,' folder in ',paths_task,' \n'])
        doNotRun =1;
    else 
        doNotRun =0;
        
       for t=1:length(runlist)
       currRun = runlist{t};  

            % SET UP MAIN PATHS to files (t1, b0 , epi)
            if contains(currTask,'fbl','IgnoreCase',true)
                b0Dir =[paths_task,'\',currsubject,'\func\',currRun,'\b0\']; 
                epiDir = [paths_task,'\',currsubject,'\func\',currRun,'\'];
                t1Dir = [paths_task,'\',currsubject,'\anat\']; %t1Dir = [paths.task,'t1w\',currsubject];
            elseif contains(currTask,'symctrl','IgnoreCase',true)
                b0Dir =[paths_task,'\',currsubject,'\func\b0\']; 
                epiDir = [paths_task,'\',currsubject,'\func\'];
                t1Dir = [paths_task,'\',currsubject,'\anat\']; %t1Dir = [paths.task,'t1w\',currsubject];
            end
      
            %%% Create and run PREPROCESSING batch
            %------------------------------ 
             %batch = LEMO_func_create_matlabbatch(b0Dir,epiDir,t1Dir,currTask,anatTemplate);
            if isempty(dir([t1Dir,'\im*'])) 
                       LEMO_func_create_fieldmap(b0Dir,epiDir,currTask,anatTemplate);
                       batch = LEMO_func_preproc_segment(b0Dir,epiDir,t1Dir,currTask,anatTemplate);  
            elseif ~isempty(dir([t1Dir,'\im*']))
                       %LEMO_func_create_fieldmap(b0Dir,epiDir,currTask,anatTemplate);
                       batch = LEMO_func_preproc(b0Dir,epiDir,t1Dir,currTask,anatTemplate);  
                       %batch = LEMO_func_coregNormalization(b0Dir,epiDir,t1Dir,currTask,anatTemplate);  
            end
             %spm_jobman('interactive',batch)
             spm_jobman('run',batch)
             clear batch
       end
    end
 end
toc