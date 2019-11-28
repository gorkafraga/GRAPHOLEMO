%script for analyzing tasks on first level
%Iliana Karipidis, August 2014
%David Willinger, November 2017
%Patrick Haller, May 2018
%--------------------------------------
% Output are files containing the contrasts: 'SPM.m' and e.g., 'spmT_0002.nii' (2 indicates contrast 2)
function matlabbatch = allread_create_glm_symCtrl(paths, task, subject)

    logfiles = ls([paths.study, paths.logs, task '\' subject, '\*.log'])

    
    stimonsets = {};

    %logfile = {subject '-MRI_ImpSymbControl_cbFont3_B0.log'}
    fileID = fopen([paths.study, paths.logs, task '\' subject, '\', logfiles]);
    old_format = {'AR1003', 'AR1005', 'AR1009','AR1012','AR1014'};

    if any(strcmp(subject,old_format))
        content = textscan(fileID,'%s %s %s %s %s %s %s %s %s %s %s %s %s', 'headerlines', 5 ,'delimiter','\t');
        fclose(fileID);
    end

    %matlabbatch = [];

    idx_scanonset = find(strcmp(content{4},'199'));
    idx_scanonset = idx_scanonset(2); 
    
    onsets.words = cellfun(@str2num,(content{5}(strcmp(content{4},'60'))   ))./10000 - cellfun(@str2num,(content{5}(idx_scanonset)))./10000;
    onsets.faces = cellfun(@str2num,(content{5}(strcmp(content{4},'70'))))./10000 - cellfun(@str2num,(content{5}(idx_scanonset)))./10000;
    onsets.targets = cellfun(@str2num,(content{5}(strcmp(content{4},'65') | strcmp(content{4},'75'))))./10000 - cellfun(@str2num,(content{5}(idx_scanonset)))./10000;

    pathSubject = fullfile(paths.study,paths.analysis,task, subject);
    
    
    scans = spm_select('ExtFPlist',[paths.study paths.pps subject],'^s6wua.*',Inf);
    rp = spm_select('FPlist',[paths.study paths.pps subject],'^rp.*');

   
    if ~isdir(pathSubject)
        mkdir(pathSubject);
    end
        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%% SPECIFY 1ST LEVEL %%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    pathSubject = fullfile(paths.study,paths.analysis,task, subject);
    % define subject path
    matlabbatch{1}.spm.stats.fmri_spec.dir = cellstr(pathSubject);
    matlabbatch{1}.spm.stats.fmri_spec.timing.units = 'secs';
    matlabbatch{1}.spm.stats.fmri_spec.timing.RT = 1.250;
    matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = 32;
    matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = 16;
    
    % loop through sessions (=blocks)
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).scans = cellstr(scans);
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(1).name = 'words';
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(1).onset = onsets.words;
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(1).duration = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(1).tmod = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(1).pmod = struct('name', {}, 'param', {}, 'poly', {});
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(1).orth = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(2).name = 'faces';
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(2).onset = onsets.faces;
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(2).duration = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(2).tmod = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(2).pmod = struct('name', {}, 'param', {}, 'poly', {});
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(2).orth = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(3).name = 'targets';
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(3).onset = onsets.targets;
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(3).duration = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(3).tmod = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(3).pmod = struct('name', {}, 'param', {}, 'poly', {});
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(3).orth = 0;
        
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).multi = {''};
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).regress = struct('name', {}, 'val', {});
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).multi_reg = cellstr(rp);

        matlabbatch{1}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});
        matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0];
        matlabbatch{1}.spm.stats.fmri_spec.volt = 1;
        matlabbatch{1}.spm.stats.fmri_spec.global = 'None';
        matlabbatch{1}.spm.stats.fmri_spec.mthresh = 0.1;
        matlabbatch{1}.spm.stats.fmri_spec.mask = {''};
        matlabbatch{1}.spm.stats.fmri_spec.cvi = 'AR(1)';
    
           %save batch
        pathAnalysis = fullfile(paths.study,paths.analysis,task,subject);   
        if ~isdir(pathAnalysis)
            mkdir(pathAnalysis);         
        end
        
        if exist([pathAnalysis '\SPM.mat'],'file')
           delete ([pathAnalysis '\SPM.mat']);
        end

        
        %save(fullfile(pathAnalysis, [task '.mat']),'matlabbatch');
        %save(fullfile(pathAnalysis, ['.mat']),'matlabbatch');

    
         %%
    %%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%% ESTIMATE %%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%

    matlabbatch{2}.spm.stats.fmri_est.spmmat(1) = cfg_dep('fMRI model specification: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
    matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
    matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;
    
        %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%% CONTRASTS %%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
%     matlabbatch{3}.spm.stats.con.spmmat(1) = cfg_dep('Model estimation: SPM.mat File', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
%     matlabbatch{3}.spm.stats.con.consess{1}.tcon.name = 'FF learned > Letter';
%     matlabbatch{3}.spm.stats.con.consess{1}.tcon.weights = [-1 1 0 0 0];
%     matlabbatch{3}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
%     
%     matlabbatch{3}.spm.stats.con.consess{2}.tcon.name = 'FF learned > FF familiar';
%     matlabbatch{3}.spm.stats.con.consess{2}.tcon.weights = [0 1 -1 0 0];
%     matlabbatch{3}.spm.stats.con.consess{2}.tcon.sessrep = 'none';
%     
%     matlabbatch{3}.spm.stats.con.consess{3}.tcon.name = 'FF learned > FF new';
%     matlabbatch{3}.spm.stats.con.consess{3}.tcon.weights = [0 1 0 -1 0];
%     matlabbatch{3}.spm.stats.con.consess{3}.tcon.sessrep = 'none';
%     
%     matlabbatch{3}.spm.stats.con.consess{4}.tcon.name = 'Letter > FF familiar';
%     matlabbatch{3}.spm.stats.con.consess{4}.tcon.weights = [1 0 -1 0 0];
%     matlabbatch{3}.spm.stats.con.consess{4}.tcon.sessrep = 'none';
%     
%     matlabbatch{3}.spm.stats.con.consess{5}.tcon.name = 'Letter > FF new';
%     matlabbatch{3}.spm.stats.con.consess{5}.tcon.weights = [1 0 0 -1 0];
%     matlabbatch{3}.spm.stats.con.consess{5}.tcon.sessrep = 'none';
%     
%     matlabbatch{3}.spm.stats.con.consess{6}.tcon.name = 'FF learned > Baseline';
%     matlabbatch{3}.spm.stats.con.consess{6}.tcon.weights = [0 1 0 0 0];
%     matlabbatch{3}.spm.stats.con.consess{6}.tcon.sessrep = 'none';
%     
%     matlabbatch{3}.spm.stats.con.consess{7}.tcon.name = 'Letter > Baseline';
%     matlabbatch{3}.spm.stats.con.consess{7}.tcon.weights = [1 0 0 0 0];
%     matlabbatch{3}.spm.stats.con.consess{7}.tcon.sessrep = 'none';
%     
%     matlabbatch{3}.spm.stats.con.consess{8}.tcon.name = 'FFfamiliar > Baseline';
%     matlabbatch{3}.spm.stats.con.consess{8}.tcon.weights = [0 0 1 0 0];
%     matlabbatch{3}.spm.stats.con.consess{8}.tcon.sessrep = 'none';
%     
%     matlabbatch{3}.spm.stats.con.consess{9}.tcon.name = 'FFnew > Baseline';
%     matlabbatch{3}.spm.stats.con.consess{9}.tcon.weights = [0 0 0 1 0];
%     matlabbatch{3}.spm.stats.con.consess{9}.tcon.sessrep = 'none';

matlabbatch{3}.spm.stats.con.spmmat(1) = cfg_dep('Model estimation: SPM.mat File', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.name = 'Words > Faces';
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.weights = [1 -1 0];
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
    
    matlabbatch{3}.spm.stats.con.consess{2}.tcon.name = 'Faces > Words';
    matlabbatch{3}.spm.stats.con.consess{2}.tcon.weights = [-1 1 0];
    matlabbatch{3}.spm.stats.con.consess{2}.tcon.sessrep = 'none';
    
    matlabbatch{3}.spm.stats.con.consess{3}.tcon.name = 'Words > Baseline';
    matlabbatch{3}.spm.stats.con.consess{3}.tcon.weights = [1 0 0 ];
    matlabbatch{3}.spm.stats.con.consess{3}.tcon.sessrep = 'none';
    
    matlabbatch{3}.spm.stats.con.consess{4}.tcon.name = 'Faces > Baseline';
    matlabbatch{3}.spm.stats.con.consess{4}.tcon.weights = [0 1 0];
    matlabbatch{3}.spm.stats.con.consess{4}.tcon.sessrep = 'none';

end    
    