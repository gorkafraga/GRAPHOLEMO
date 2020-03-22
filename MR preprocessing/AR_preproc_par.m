% A wrapper script for preprocessing using  MATLAB parallel toolbox.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Admits input of several subjects and tasks
% REQUIRES:
%       - b0 files in same folder as epi files.One b0 and epi  per folder
%       - folder name as input of 'tasklist' variables
%       - T1 image (1 file) stored in separate folder named "T1w".
%       - Subjects at the last level of the directory
% OUTPUT 
%       - multiple preprocessed files (SPM style)
%       - operation log file in txt.
%--------------------------------------------------------------------------
%(c) David Willinger, adapted by Patrick Haller and Gorka Fraga (1-14-2020)
clear matlabbatch batch current_paths paths subjects;
spm_jobman('initcfg');
addpath ('N:\studies\Grapholemo\Methods\Scripts\grapholemo\MR preprocessing\')
%% INPUTS 
subjects = {'AR1003'}; %subjects = {'AR1038','AR1042','AR1045','AR1046','AR1048','AR1055','AR1056'}; 
%subjects = {'AR1002','AR1004','AR1006','AR1007','AR1008','AR1009','AR1011','AR1016','AR1018','AR1021','AR1023','AR1025','AR1031','AR1035','AR1036','AR1038','AR1042','AR1045','AR1046','AR1048','AR1055','AR1056'}; 
%subjects = {'AR1002','AR1004','AR1006','AR1007','AR1008','AR1009','AR1011','AR1016','AR1018','AR1021','AR1023','AR1025','AR1028','AR1031','AR1035','AR1036','AR1038','AR1042','AR1045','AR1046','AR1048','AR1055','AR1056'};
%input task(s)
tasklist            =  {'learn_1'}; % [eread, learn, localizer, symCtrl]
% Anatomical template:    
anatTemplate = 'O:\studies\grapholemo\Allread_FBL\Analysis\mri\Template_KiGa_T2_T3\TPM_Age7.1526.nii'; % Called by 'AR_create_fieldmap.m'
%Paths (end character should be \ )
paths.preprocessing     = 'O:\studies\grapholemo\Allread_FBL\Analysis\mri\preprocessing\';
paths.structural    = 'O:\studies\grapholemo\Allread_FBL\Analysis\mri\preprocessing\t1\';

%% Initialize operation Log file
operationLog = fullfile([studyPath,'preprocessing'], ['Preprocessing_log_',datestr(now,'ddmmyyyy'),'.txt']);
fid = fopen(operationLog,'wt');
msg = 'AR_preproc_par started at ';
fprintf(fid, [msg, datestr(now, 0),'\n']);
%% BEGIN LOOP 1st thru task, 2nd thru subjects
for t=1:length(task)
currTask = tasklist{t};
paths.task = ['O:\studies\grapholemo\Allread_FBL\Analysis\mri\preprocessing\',currTask];
     
    batch = cell(length(subjects));
    for i=1:length(subjects)
         currsubject              = subjects{i};
         fprintf(fid, ['\nBegin ',currsubject]); %log info
         b0files = ls([paths.task,'\',currsubject,'\*_b0_*.nii']);
         %% Do the b0 preprocessing: call CREATE FIELDMAP
          AR_create_fieldmap(paths.preprocessing,paths.task,anatTemplate)
                     fprintf(fid,['\n....AR_create_fieldmap run for task: ',tasklist{j}]);
                end
         % current_paths.timepoint  = fullfile(paths.prep);
            %current_paths.epis       = fullfile(paths.epis,currsubject);
            %current_paths.structural = fullfile(paths.structural,currsubject);
            % Get b0 info (calls other script to find b0 maps) 
           % current_b0               = AR_get_b0(currsubject,paths.epis); 
           % fprintf(fid,['...b0 maps for ',strjoin(tasklist,' and '),'[',num2str(current_b0),'] found']);
         % Create FIELDMAP FILES (loop thru task files)
             % current_paths.b0  = fullfile(paths.b0,subjects(i));
          %for j = 1:length(current_paths.epis) % look thru tasks
                    %create_simple_fieldmap(current_paths.b0,current_paths.epis(j));
                    % b0Path = current_paths.b0;
                     %epiPath = current_paths.epis(j);
                     %b0index = current_b0(j);
                     %AR_create_fieldmap(studyPath,current_paths.b0,current_paths.epis(j),current_b0(j),T1template);
               AR_create_fieldmap(paths.preprocessing,paths.task,anatTemplate)
                     fprintf(fid,['\n....AR_create_fieldmap run for task: ',tasklist{j}]);
                end
         else
            current_paths.b0 = {''};
         end
         [batch{i},batchLog] = AR_create_matlabbatch(current_paths,tasklist);
          fprintf(fid,['\n....batch for ',subjects{i},' created']);

        end
        fclose(fid);
end
%%
if ~isempty(gcp('nocreate'))
    delete(gcp('nocreate'));  
end
% for how many subjects
% if you use parallel for-loop: uncomment (make sure your computers has 8
% cores!! If not, change this number to 4 or 2)
parpool(8);
%for i=1:length(subjects)
parfor i=1:length(subjects)
        try
           % spm_jobman('run',batch{i})
            fprintf(fid,['\n....batch RUN for ',subjects{i},'d[-_-]b\n']);
        catch e
            fprintf('%s\tError during the preprocessing of subject %s \n\r',datetime('now'),subjects{i})
        end
end
