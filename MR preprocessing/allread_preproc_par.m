% preproc_par A wrapper script for preprocessing using the MATLAB
% parallel toolbox.
%
% Inputs needed:
%  subjects         - Subjects to preprocess
%  useB0            - Flag whether B0 fieldmap should be used for unwarping
%  paths.epis       - Path of EPIs
%  paths.structural - Path of structural image (T1)
%  paths.b0         - Path of B0 images
%
% 
% IMPORTANT
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

% create subjects list
%subjects = {'AR1031'};
subjects = {'AR1002','AR1004','AR1006','AR1007','AR1008','AR1011','AR1016','AR1018','AR1021','AR1023','AR1025','AR1028','AR1031','AR1035','AR1036','AR1038','AR1042','AR1045','AR1046','AR1048','AR1055','AR1056'};
 % Use Fieldmap information? 0 = No, 1 = Yes
useB0              = 1;

% Paths
paths.timepoint     = 'O:\studies\allread\mri\preprocessing\';
paths.epis          =  {'learn'}; % [eread, learn, localizer, symCtrl]
paths.b0            = 'O:\studies\allread\mri\preprocessing\b0\';
paths.structural    = 'O:\studies\allread\mri\preprocessing\t1\';

tasklist            =  {'learn'}; % [eread, learn, localizer, symCtrl]


batch = cell(length(subjects));
for i=1:length(subjects)
    current_paths.timepoint  = fullfile(paths.timepoint);
    current_paths.epis       = fullfile(paths.epis,subjects(i));
    current_paths.structural = fullfile(paths.structural,subjects(i));
    current_b0               = allread_get_b0mapping(subjects{i},paths.epis);
    
    if useB0
        current_paths.b0     = fullfile(paths.b0,subjects(i));
        for j = 1:length(current_paths.epis)
            create_simple_fieldmap(current_paths.b0,current_paths.epis(j));
            %allread_create_fieldmap(current_paths.b0,current_paths.epis(j),current_b0(j));
        end
    else
        current_paths.b0 = {''};
    end
    batch{i} = allread_create_matlabbatch(current_paths,tasklist);
    %batch{i} = allread_create_matlabbatch(current_paths);
end

%if ~isempty(gcp('nocreate'))
%    delete(gcp('nocreate'));  
%end
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