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
addpath ('O:\studies\grapholemo\LEMO_GFG\mri\scripts_preprocessing') %('O:\studies\grapholemo\Allread_AE\mri\scripts_preprocessing') 
%% Inputs setup
%------------------------------
subjects = {'G003'}; %subjects = {'AR1038','AR1042','AR1045','AR1046','AR1048','AR1055','AR1056'}; %subjects = {'AR1002','AR1004','AR1006','AR1007','AR1008','AR1009','AR1011','AR1016','AR1018','AR1021','AR1023','AR1025','AR1031','AR1035','AR1036','AR1038','AR1042','AR1045','AR1046','AR1048','AR1055','AR1056'}; 
 Task =  {'FBL_A'}; %Only ONE at a time. 
runlist= {'run1','run2'}; % list of runs, leave it empty  {} if you are not processing FBL task or you have no runs 
% PATHS (end character should be \ )
paths.preprocessing = 'O:\studies\grapholemo\LEMO_GFG\preprocessing\'; %'O:\studies\grapholemo\Allread_AE\mri\Preprocessing_AE\';

%% BEGIN TASK LOOP
cd (paths.preprocessing)
currTask = Task{1};
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
        if  isempty(dir([paths_task,currsubject])) %isempty(dir([paths_task,'**\',currsubject]))
            disp(['Cannot find ',currsubject,' folder in ',paths_task,' \n'])
            doNotRun =1;
        else 
        doNotRun =0;
        b0Dir =[paths_task,currsubject,'\func\b0\']; %b0Dir =[paths_task,'b0\',currsubject];
        epiDir = [paths_task,currsubject,'\func\epis\']; %epiDir = [paths_task,'epis\',currsubject];
        t1Dir = [paths_task,currsubject,'\anat\']; %t1Dir = [paths_task,'t1w\',currsubject];
		
        matlabbatch{1}.spm.spatial.coreg.estwrite.ref =  cellstr(spm_select('ExtFPList',t1Dir, '^immr.*.nii$'));
        matlabbatch{1}.spm.spatial.coreg.estwrite.source = cellstr(spm_select('ExtFPList',epiDir, '^meanuamr.*.nii$')) ;
        matlabbatch{1}.spm.spatial.coreg.estwrite.other =   {''};%%cellstr(spm_select('ExtFPList',epiDir, '^uamr.*.nii$', Inf)) ;  
 
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
 if  doNotRun==0 
    % if you use parallel for-loop: uncomment (make sure your computers has 8 cores!! If not, change this number to 4 or 2)
        parpool(4);
        parfor i=1:length(subjects)
       % for i=1:length(subjects)  % use this if you deactivate parallel
            spm_jobman('run',batch{i})
            %spm_jobman('interactive',batch{i})           
        end
 end
end
