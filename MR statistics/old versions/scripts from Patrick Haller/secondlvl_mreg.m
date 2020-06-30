clear batches;
%spm_jobman('initcfg');

taskList = { 'feedback' };
paths.study = 'O:\studies\allread\mri_ph\';
paths.analysis = 'analysis\';
paths.logs = 'logs\';
paths.pps = 'preprocessing\feedback\';

subj_params = {};

analysis = "rlddm"
%analysis = "wl"
%analysis = "pswl"

if strcmp(analysis, 'rlddm')
    logfile = ls([paths.study, paths.logs, taskList{1}, '\subj_parameters_final.csv']);
end
if strcmp(analysis, 'wl')
    logfile = ls([paths.study, paths.logs, taskList{1}, '\SLRT_WL.csv']);
end
if strcmp(analysis, 'pswl')
    logfile = ls([paths.study, paths.logs, taskList{1}, '\SLRT_PSWL.csv']);
end

subj_params = fullfile(paths.study,paths.logs,taskList{1},logfile);
fileID = fopen(subj_params);

if strcmp(analysis, 'rlddm')
    content = textscan(fileID,'%s %s %s %s %s %s %s %s %s ','Delimiter',','); % RLDDM PARS
end
if strcmp(analysis, 'wl')
    content = textscan(fileID,'%s %s %s %s ','Delimiter',','); % WL 
end
if strcmp(analysis, 'pswl')
    content = textscan(fileID,'%s %s ','Delimiter',','); % PSWL
end

mreg_params = {};

% extract relevant columns from log file
if strcmp(analysis, 'rlddm')
    mreg_params{1} = str2num(char(content{1}(2:end))); % drift
    mreg_params{2} = str2num(char(content{2}(2:end))); % decision boundary a
    mreg_params{3} = str2num(char(content{3}(2:end))); % tau
    mreg_params{4} = str2num(char(content{4}(2:end))); % eta_pos
    mreg_params{5} = str2num(char(content{5}(2:end))); % eta_neg
    mreg_params{6} = str2num(char(content{6}(2:end))); % learning_score
    mreg_params{7} = str2num(char(content{7}(2:end))); % average_rt
    mreg_params{8} = str2num(char(content{8}(2:end))); % neg_rt
    mreg_params{9} = str2num(char(content{9}(2:end))); % pos_rt
end
if strcmp(analysis, 'wl')
    mreg_params{1} = str2num(char(content{1}(2:end))); % wl_corr
    mreg_params{2}= str2num(char(content{2}(2:end))); % wl_pr
    mreg_params{3} = str2num(char(content{3}(2:end))); % mean(wl_pswl_corr)
    mreg_params{4} = str2num(char(content{4}(2:end))); % mean(wl_pswl_pr)
end
if strcmp(analysis, 'pswl')
    mreg_params{1} = str2num(char(content{1}(2:end))); % psl_corr
    mreg_params{2} = str2num(char(content{2}(2:end))); % pswl_pr
end

% create subjects list, i.e. { 'test05','test06', ...}
% i = subject nrs
subjects = {};

if strcmp(analysis, 'rlddm')
    exclude = {};
end
if strcmp(analysis, 'wl')
    exclude = {'biokurs19-08','biokurs19-14'};
end
if strcmp(analysis, 'pswl')
    exclude = {};
end

for i=1:17
    sub = sprintf('biokurs19-%02d',i);
    if ~ismember(sub,exclude)
        subjects{end + 1} = sub;
    end    
end

if strcmp(analysis, 'rlddm')
    mreg_names = {'v','a','tau','eta_pos','eta_neg','learning_score','average_rt','neg_rt','pos_rt'};
end
if strcmp(analysis, 'wl')
    mreg_names = {'wl_corr','wl_pr','mean_slrt_corr','mean_slrt_pr'};
end
if strcmp(analysis, 'pswl')
    mreg_names = {'pswl_corr','pswl_pr'};
end

batches = {};

for i=1:numel(mreg_names)
    matlabbatch{1}.spm.stats.factorial_design.dir = {[paths.study paths.analysis taskList{1} '\2ndlev_GLM3\as_active_mreg_rlddm\' mreg_names{i} '\']};
    matlabbatch{1}.spm.stats.factorial_design.des.mreg.scans = {};

    for s=1:length(subjects)
        matlabbatch{1}.spm.stats.factorial_design.des.mreg.scans(end+1) = { [paths.study paths.analysis taskList{1} '\1stlev_GLM3\' subjects{s} '\' 'con_0003.nii' ',1'] };
    end

    matlabbatch{1}.spm.stats.factorial_design.des.mreg.scans = matlabbatch{1}.spm.stats.factorial_design.des.mreg.scans';
    
    matlabbatch{1}.spm.stats.factorial_design.des.mreg.mcov.c = mreg_params{i};
    matlabbatch{1}.spm.stats.factorial_design.des.mreg.mcov.cname = mreg_names{i};
    matlabbatch{1}.spm.stats.factorial_design.des.mreg.mcov.iCC = 5;
    matlabbatch{1}.spm.stats.factorial_design.des.mreg.incint = 1;
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
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.name = [ 'Positive effect of ' mreg_names{i} ];
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.weights = [0 1];
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.consess{2}.tcon.name = [ 'Negative effect of ' mreg_names{i} ];
    matlabbatch{3}.spm.stats.con.consess{2}.tcon.weights = [0 -1];
    matlabbatch{3}.spm.stats.con.consess{2}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.delete = 0;
    batches{i} = matlabbatch;
end    

if numel(mreg_names) < 8
    parpool(numel(mreg_names));
else
    parpool(8);
end
parfor i = 1:numel(mreg_names)
    spm_jobman('run',batches{i});
end    
