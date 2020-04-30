%--------------------------------------------------------------------------------------------------------------
%  RUN SECOND LEVEL ANALYSIS 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% - Reads first level folder based on your selectedGLM. 
% - Creates and run one batch per contrast in your selectedGLM folder
% - Uses explicit mask  binary mask, skull-stripped brain from anat template)
%G.Fraga Gonzalez(2020)
%--------------------------------------------------------------------------------------------------------------
clear all
close all
%Chooice your GLM of interest
selectedGLM = 'GLM1';

%Specifies the INPUT folders assigned to each GLM 
modelChoice = containers.Map({'GLM0','GLM1','GLM1_pm1a','GLM2'},...
        {'O:\studies\allread\mri\analysis_GFG\stats\mri\1Lv_GLM0\learn_12',... 
        'O:\studies\allread\mri\analysis_GFG\stats\mri\1Lv_GLM1\learn_12',...
        'O:\studies\allread\mri\analysis_GFG\stats\mri\1Lv_GLM1_pm1a\learn_12',...
        'O:\studies\allread\mri\analysis_GFG\stats\mri\1Lv_GLM2\learn_12'} );

% set input dir, create output dir 
dirinput =  modelChoice(selectedGLM); 
diroutput = strrep(dirinput,['1Lv_',selectedGLM],['2Lv_',selectedGLM]);
mkdir(diroutput)

% Read t-test contrasts for that model 
tmp = dir([dirinput,'\**\spm.mat']);
load([tmp(1).folder,'\',tmp(1).name]); % load first spm file in input directory
contrast=struct();  % gather description and file names of all t-contrasts in that analysis 
c=1;
for i = 1:length(SPM.xCon)
    if contains(SPM.xCon(i).Vcon.fname,'con_000')
        contrast(c).fname = {SPM.xCon(i).Vcon.fname};
        contrast(c).descript = {SPM.xCon(i).Vcon.descrip};
        c= c+1;
    end
end
clear SPM

%% Begin subject loop 
files = dir([dirinput,'\AR*']);
subjects= {files.name};
excludedSubj = {'AR1016','AR1037'};
subjects(cell2mat(cellfun(@(c)find(strcmp(c,subjects)),excludedSubj,'UniformOutput',false)))=[]; %find index and exclude subjects

%% loop thru contrasts
batches={};
for c = 1: length(contrast) 
        
    currDiroutput = [diroutput,'\',strrep(strrep(cell2mat(contrast(c).fname),'.nii',''),'con_','from_1Lv_con')];
    mkdir(diroutput)
    
    matlabbatch{1}.spm.stats.factorial_design.dir = {currDiroutput};
    matlabbatch{1}.spm.stats.factorial_design.des.t1.scans = {};
   
    % take the con_000* files from each subject
    for s=1:length(subjects)
        matlabbatch{1}.spm.stats.factorial_design.des.t1.scans(end+1) = {[dirinput, '\' subjects{s} '\'  cell2mat(contrast(c).fname) ',1'] }';
    end
   matlabbatch{1}.spm.stats.factorial_design.des.t1.scans =    matlabbatch{1}.spm.stats.factorial_design.des.t1.scans';
    % continue design specs
    matlabbatch{1}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
    matlabbatch{1}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
    matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
    matlabbatch{1}.spm.stats.factorial_design.masking.im = 1;
    matlabbatch{1}.spm.stats.factorial_design.masking.em =  {'O:\studies\allread\mri\analysis_GFG\anatomical_templates\from_TOM8\mask_thr01_vols123.nii,1'};  
    matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
    matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
    matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;
    % Model estimation
    matlabbatch{2}.spm.stats.fmri_est.spmmat(1) = cfg_dep('Factorial design specification: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
    matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
    matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;
    % Model contrsats
    matlabbatch{3}.spm.stats.con.spmmat(1) = cfg_dep('Model estimation: SPM.mat File', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.name = cell2mat(contrast(c).descript);
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.weights = 1;
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.delete = 0;
    batches{c} = matlabbatch;

end
    %% spm_jobman('interactive',batches{2})
    %return;
    
    if ~isempty(gcp('nocreate'))
            delete(gcp('nocreate'));  
    end

 
    if length(contrast) < 8
        parpool(length(contrast));
    else
        parpool(8);
    end

    parfor i = 1: length(contrast)
        spm_jobman('run',batches{i});
    end    
%% Save table with contrasts run
contrast_table = struct2table(contrast);
writetable(contrast_table,[diroutput,'\contrast_codebook_',selectedGLM,'.csv'])