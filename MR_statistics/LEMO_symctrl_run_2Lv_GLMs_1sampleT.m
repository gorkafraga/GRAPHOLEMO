%--------------------------------------------------------------------------------------------------------------
% SECOND LEVEL ONE SAMPLE T-TESTS 
% .................................... 
% - Reads first level folder based on your selectedGLM. 
% - Creates and run one batch per contrast in your selectedGLM folder
% - Compare Feedback learning part A and B
% - Allows models with computational model parameters as 2nd level regressor ('mopa')
% 
%G.Fraga Gonzalez(2021)
%--------------------------------------------------------------------------------------------------------------
clear 
close all
%Chooice your GLM of interest
selectedGLM = 'GLM0'; %selectedGroup = 'all';
modelversion =   'AR_rlddm_v11';

% set input dir  based on GLM of interest
parentDir = 'O:\studies\grapholemo\analysis\LEMO_GFG\mri\1stLevel\symCtrl_pre';% NO \ as last character 


 % listFolders = dir(strcat(parentDir,'\',selectedGroup,'\1Lv_',selectedGLM,'*'));   
 listFolders = dir(strcat(parentDir,'\1Lv_',selectedGLM,'*'));   
 
 %create input and output dir  
[indx,tf] = listdlg('PromptString','Select source 1st level folder','ListString',{listFolders.name});
dirinput = strcat([listFolders(indx).folder,'\',listFolders(indx).name]) ;
diroutput = strrep(dirinput,['1Lv_',selectedGLM],['2Lv_',selectedGLM]);
diroutput = strrep(diroutput, '1stLevel\symCtrl_pre','2ndLevel_pairedTs\symCtrl_prePost');
mkdir(diroutput)


% Read t-test contrasts for that model 
tmp = dir([dirinput,'\**\spm.mat']);
load([tmp(1).folder,'\',tmp(1).name]); % load first spm file in input directory

contrast=struct();  % gather description and file names of all t-contrasts in that analysis c=1;
c=1;
for i = 1:length(SPM.xCon)
    if contains(SPM.xCon(i).Vcon.fname,'con_00')
        contrast(c).fname = {SPM.xCon(i).Vcon.fname};
        contrast(c).descript = {SPM.xCon(i).Vcon.descrip};
        c= c+1;
    end
end
clear SPM

%% Begin subject loop 
files = dir([dirinput,'\gpl*']);
subjects= {files.name};
%excludedSubj = {'AR1016','AR1022','AR1037'};
%subjects(cell2mat(cellfun(@(c)find(strcmp(c,subjects)),excludedSubj,'UniformOutput',false)))=[]; %find index and exclude subjects
% loop thru contrasts
batches={};
for c = 1: length(contrast) 
    contrastname = strrep(strrep(cell2mat(contrast(c).fname),'.nii',''),'Contrast ','Con');
    % contrastname = strrep(strrep(strrep(strrep(strrep(cell2mat(contrast(c).descript),'Contrast ','con'),': ','_'),' - ','_'),' ',''),'onset','');
    currDiroutput = [diroutput,'\',contrastname];
    mkdir(diroutput) 
    %     matlabbatch{1}.spm.stats.factorial_design.des.t1.scans = {};
        %      % take the con_000* files from each subject
        %     for s=1:length(subjects)
        %         conFile = dir([dirinput, '\' subjects{s} '\'  cell2mat(contrast(c).fname)]) ;
        %         if isempty(conFile)
        %             disp(['Could NOT find ', cell2mat(contrast(c).fname),' in ',subjects{s}]) 
        %         else 
        %           matlabbatch{1}.spm.stats.factorial_design.des.t1.scans(end+1) = {[conFile.folder, '\' conFile.name ',1'] }';
        %         end        
        %     end
        %    matlabbatch{1}.spm.stats.factorial_design.des.t1.scans =    matlabbatch{1}.spm.stats.factorial_design.des.t1.scans';
    matlabbatch{1}.spm.stats.factorial_design.dir = {currDiroutput};

    % Create pairs per subject: 
    for sub = 1:length(subjects)
            matlabbatch{1}.spm.stats.factorial_design.des.pt.pair(sub).scans = {
                                                                           ['O:\studies\grapholemo\analysis\LEMO_GFG\mri\1stLevel\symCtrl_pre\',listFolders(indx).name,'\',subjects{sub},'\',contrastname,'.nii,1']
                                                                            ['O:\studies\grapholemo\analysis\LEMO_GFG\mri\1stLevel\symCtrl_post\',listFolders(indx).name,'\',subjects{sub},'\',contrastname,'.nii,1']
                                                                           };
    end
    matlabbatch{1}.spm.stats.factorial_design.des.pt.gmsca = 0;
    matlabbatch{1}.spm.stats.factorial_design.des.pt.ancova = 0;
    matlabbatch{1}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
    matlabbatch{1}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
    matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
    matlabbatch{1}.spm.stats.factorial_design.masking.im = 1;
    matlabbatch{1}.spm.stats.factorial_design.masking.em =  {''};  
    matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
    matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
    matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;
    % Model estimation
    matlabbatch{2}.spm.stats.fmri_est.spmmat(1) = cfg_dep('Factorial design specification: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
    matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
    matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;
    % Model contrsats
    matlabbatch{3}.spm.stats.con.spmmat(1) = cfg_dep('Model estimation: SPM.mat File', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.name = ['(pre > post) ', cell2mat(contrast(c).descript)];
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.weights = [1 -1];
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.consess{2}.tcon.name = ['(post > pre) ', cell2mat(contrast(c).descript)];
    matlabbatch{3}.spm.stats.con.consess{2}.tcon.weights = [-1 1];
    matlabbatch{3}.spm.stats.con.consess{2}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.delete = 0;
    batches{c} = matlabbatch;

end
   
%%  Run in parallel port  

    %if ~isempty(gcp('nocreate'))
    %        delete(gcp('nocreate'));  
   % end 
   % parpool(8);        
   %parfor i = 1: length(contrast)
   for i = 1: length(contrast)
        spm_jobman('run',batches{i});
        
    end    
%% Save table with contrasts run and subjects
contrast_table = struct2table(contrast);
writetable(contrast_table,[diroutput,'\Codebook_contrasts_from',selectedGLM,'.csv']);
subjects_table = cell2table(subjects');
subjects_table.Properties.VariableNames = {'subjects'};
writetable(subjects_table,[diroutput,'\Subjects_from',selectedGLM,['_n',num2str(length(subjects))],'.csv']);