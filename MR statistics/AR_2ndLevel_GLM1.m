clear batches;
%spm_jobman('initcfg');


taskList = { 'feedback' };
paths.study = 'O:\studies\allread\mri_ph\';
paths.analysis = 'analysis\';
paths.logs = 'logs\';
paths.pps = 'preprocessing\feedback\';

onsets = {};

% create subjects list, i.e. { 'test05','test06', ...}
% i = subject nrs
subjects = {};
excludes = {};
for i=1:17
    sub = sprintf('biokurs19-%02d',i);
    if ~ismember(sub,excludes)
        subjects{end + 1} = sub;
    end    
end

%cons = {'con_0002.nii', 'con_0003.nii'}; % glm1
%con_names = {'stimulus', 'feedback'}; %glm1

%cons = {'con_0002.nii', 'con_0003.nii', 'con_0004.nii','con_0005.nii'}; % glm2%
%con_names = {'pos larger neg stim', 'neg larger pos stim', 'pos larger neg fb', 'neg larger pos fb'}; %glm2

%cons = {'con_0003.nii','con_0005.nii'}; %glm3
%con_names = {'as_active', 'as _negative'}; %glm3

%cons = {'con_0003.nii'}; %glm4
%con_names = {'as_active'}; %glm4

%cons = {'con_0005.nii'}; %glm5a
%con_names = {'neg PE'}; %glm5a

%cons = {'con_0005.nii'}; %glm5b
%con_names = {'pos PE'}; %glm5b

batches = {};

%% TODO: check if SPM.mat in path exists

% CHANGE L59 and 62 to change which GLM is processed
for i=1:numel(cons)
    matlabbatch{1}.spm.stats.factorial_design.dir = {[paths.study paths.analysis taskList{1} '\2ndlev_GLM1\' con_names{i} '\']};
    matlabbatch{1}.spm.stats.factorial_design.des.t1.scans = {};

    for s=1:length(subjects)
        matlabbatch{1}.spm.stats.factorial_design.des.t1.scans(end+1) = { [paths.study paths.analysis taskList{1} '\1stlev_GLM1\' subjects{s} '\' cons{i} ',1'] };
    end

    matlabbatch{1}.spm.stats.factorial_design.des.t1.scans = matlabbatch{1}.spm.stats.factorial_design.des.t1.scans';

    matlabbatch{1}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
    matlabbatch{1}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
    matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
    matlabbatch{1}.spm.stats.factorial_design.masking.im = 1;
    matlabbatch{1}.spm.stats.factorial_design.masking.em = {[paths.study, 'template\mask.nii,1']};
    matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
    matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
    matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;
    matlabbatch{2}.spm.stats.fmri_est.spmmat(1) = cfg_dep('Factorial design specification: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
    matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
    matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;
    matlabbatch{3}.spm.stats.con.spmmat(1) = cfg_dep('Model estimation: SPM.mat File', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.name = [ 'Positive effect of ' con_names{i} ];
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.weights = 1;
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.consess{2}.tcon.name = [ 'Negative effect of ' con_names{i} ];
    matlabbatch{3}.spm.stats.con.consess{2}.tcon.weights = -1;
    matlabbatch{3}.spm.stats.con.consess{2}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.delete = 0;
    batches{i} = matlabbatch;
end    

%spm_jobman('interactive',batches{2})
%return;
if numel(cons) < 8
    parpool(numel(cons));
else
    parpool(8);
end

parfor i = 1:numel(cons)
    spm_jobman('run',batches{i});
end    
