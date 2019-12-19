% preproc_par A wrapper script for preprocessing using the MATLAB
% parallel toolbox.
%% Inputs needed:
%  subjects         - Subjects to preprocess
%  useB0            - Flag whether B0 fieldmap should be used for unwarping
%  paths.epis       - Path of EPIs
%  paths.structural - Path of structural image (T1)
%  paths.b0         - Path of B0 images
%% IMPORTANT
% BEFORE RUNNING THIS SCRIPT CHECK THE create_matlabbatch function BELOW
% IF IT IS THE NEW OR THE OLD SEQUNCE
%
%The matlabbatch "allread_create_matlabbatch.m" has been updated to a child
%template, 
%
%(c) David Willinger, adapted by Patrick Haller
%Last edited: 2019/08/20

clear matlabbatch batch current_paths paths subjects;
spm_jobman('initcfg');
addpath ('N:\studies\Grapholemo\Scripts\grapholemo\MR preprocessing')
%% INPUTS 
% input subjects list
subjects = {'AR1003'};
%subjects = {'AR1002','AR1004','AR1006','AR1007','AR1008','AR1009','AR1011','AR1016','AR1018','AR1021','AR1023','AR1025','AR1028','AR1031','AR1035','AR1036','AR1038','AR1042','AR1045','AR1046','AR1048','AR1055','AR1056'};

% Use Fieldmap information? 0 = No, 1 = Yes
    useB0               = 1;
%input task(s)
    tasklist            =  {'learn'}; % [eread, learn, localizer, symCtrl]
% some files needed    
    T1template = 'O:\studies\grapholemo\Allread_FBL\Analysis\mri\Template_KiGa_T2_T3\TPM_Age7.1526.nii'; % Called by 'AR_create_fieldmap.m'
%Paths (end character should be \ )
    studyPath = 'O:\studies\grapholemo\Allread_FBL\Analysis\mri\'; %main path to this study 
    paths.timepoint     = 'O:\studies\grapholemo\Allread_FBL\Analysis\mri\preprocessing\';
    paths.epis          = tasklist; % [eread, learn, localizer, symCtrl]
    paths.b0            = 'O:\studies\grapholemo\Allread_FBL\Analysis\mri\preprocessing\b0\';
    paths.structural    = 'O:\studies\grapholemo\Allread_FBL\Analysis\mri\preprocessing\t1\';

%% Initialize Script-Log file
FileName = fullfile(studyPath, 'Log.txt');
fid = fopen(FileName,'wt');

msg = 'AR_preproc_par started at ';
fprintf(fid, [msg, datestr(now, 0),'\n']);

    %% Loop through subjects
batch = cell(length(subjects));

for i=1:length(subjects)
    currsubject              = subjects{i};
    current_paths.timepoint  = fullfile(paths.timepoint);
    current_paths.epis       = fullfile(paths.epis,subjects(i));
    current_paths.structural = fullfile(paths.structural,subjects(i));
    fprintf(fid, ['\nBegin ',currsubject]);
    
    % Get b0 info (calls other script to find b0 maps)
    subject=currsubject;
    epi = paths.epis;
    current_b0               = AR_get_b0(subject,epi); 
    fprintf(fid,['...b0 maps for ',strjoin(tasklist,' and '),'[',num2str(current_b0),'] found']);

 % Loop thru task files
 if useB0
        current_paths.b0     = fullfile(paths.b0,subjects(i));
        for j = 1:length(current_paths.epis) % look thru tasks
            %create_simple_fieldmap(current_paths.b0,current_paths.epis(j));
             b0Path = current_paths.b0;
             epiPath = current_paths.epis(j);
             b0index = current_b0(j);
             %AR_create_fieldmap(studyPath,current_paths.b0,current_paths.epis(j),current_b0(j),T1template);
             AR_create_fieldmap(studyPath,b0Path, epiPath, b0index,T1template)
             fprintf(fid,['\n....AR_create_fieldmap run for task:',tasklist{j}]);
        end
 else
    current_paths.b0 = {''};
 end
 batch{i} = AR_create_matlabbatch(current_paths,tasklist);
  fprintf(fid,['\n....batch for ',subjects{i},' created']);

end
fclose(fid);
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
            spm_jobman('run',batch{i})
        catch e
            fprintf('%s\tError during the preprocessing of subject %s \n\r',datetime('now'),subjects{i})
        end
end
