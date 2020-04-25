% Run coregistration estimate and reslice 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Admits input of several subjects and tasks
% REQUIRES:
%       - REF: Scalp stripped T1 (brain). imr_*t1*.nii file from segmentation.
%       - SOURCE: mean epi image after realignmentunwarp: meanuamr_*task*.nii
%       - OTHER:  all volumes of epi after realignemtunwarp: uamr_*task*.nii
% OUTPUT:
%       - multiple preprocessed files (SPM style)
%       - operation log file in txt.
%--------------------------------------------------------------------------
% Gorka Fraga (March 2020)   
clear all %clear matlabbatch batch;
spm_jobman('initcfg');
addpath ('N:\studies\Grapholemo\Methods\Scripts\grapholemo\MR preprocessing\') 
% Inputs setup
%------------------------------
 files = dir('G:\local_prepro\learn_1\epis\AR*');
 files = files(~contains({files.name},'AR1026')); 
 subjects = {files.name};
%subjects =  {'AR1005','AR1016','AR1017','AR1022','AR1025','AR1026','AR1027','AR1028','AR1036','AR1037','AR1038',...
 %    'AR1041','AR1042','AR1043','AR1047','AR1048','AR1052','AR1055','AR1056','AR1062','AR1063','AR1066','AR1068','AR1069'}; %subjects = {'AR1038','AR1042','AR1045','AR1046','AR1048','AR1055','AR1056'}; %subjects = {'AR1002','AR1004','AR1006','AR1007','AR1008','AR1009','AR1011','AR1016','AR1018','AR1021','AR1023','AR1025','AR1031','AR1035','AR1036','AR1038','AR1042','AR1045','AR1046','AR1048','AR1055','AR1056'}; 
tasklist =  {'learn_1','learn_2'}; %Recommended to take one task at a time.  [eread, learn, localizer, symCtrl]   
% PATHS (end character should be \ )
paths.preprocessing = 'G:\local_prepro\';

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
        b0Dir =[paths.task,'b0\',currsubject];
        epiDir = [paths.task,'epis\',currsubject];
        t1Dir = [paths.task,'t1w\',currsubject];

        matlabbatch{1}.spm.spatial.coreg.estwrite.ref =  cellstr(spm_select('ExtFPList',t1Dir, '^immr.*.nii$'));
        matlabbatch{1}.spm.spatial.coreg.estwrite.source = cellstr(spm_select('ExtFPList',epiDir, '^meanuamr.*.nii$')) ;  
        matlabbatch{1}.spm.spatial.coreg.estwrite.other =  {''};% cellstr(spm_select('ExtFPList',epiDir, '^uamr.*.nii$', Inf)) ;   
        matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.cost_fun = 'nmi';
        matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.sep = [4 2];
        matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
        matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.fwhm = [7 7];
        matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.interp = 4;
        matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.wrap = [0 0 0];
        matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.mask = 0;
        matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.prefix = 'Corr';
            
        [batch{i}] =  matlabbatch;
        end
     end
     
%% RUN batch in parallel
%-------------------------------------------------------------------------------------
 if ~isempty(gcp('nocreate'))
            delete(gcp('nocreate'));  
 end
        % if you use parallel for-loop: uncomment (make sure your computers has 8 cores!! If not, change this number to 4 or 2)
        parpool(8);
        parfor i=1:length(subjects)
       % for i=1:length(subjects)  % use this if you deactivate parallel
            spm_jobman('run',batch{i})
            %spm_jobman('interactive',batch{i})           
        end
 end
