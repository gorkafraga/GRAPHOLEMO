%script for analyzing tasks on first level
%Iliana Karipidis, August 2014
%David Willinger, November 2017
%Patrick Haller, May 2018
%--------------------------------------
% Output are files containing the contrasts: 'SPM.m' and e.g., 'spmT_0002.nii' (2 indicates contrast 2)
function matlabbatch = allread_create_glm_learning(paths, task, subject,scans,rp)

    logfiles = ls([paths.study, paths.logs, task '\' subject, '\*.txt']);
    
    stimonsets = {};
    
    for b=1:2
        try
            % get stimulus onsets for each block
            stimonsets{b} = allread_get_fbl_onsets( fullfile(paths.study,paths.logs,task,subject,logfiles(b,:)), subject );
        catch MExc
            fprintf(['ERROR: Logfile processing failed with error: ' MExc.message '\n']);
            matlabbatch = [];
        end
    end

    pathSubject = fullfile(paths.study,paths.analysis,task, subject);
   
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
    matlabbatch{1}.spm.stats.fmri_spec.timing.RT = 1;
    matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = 32;
    matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = 16;
    
    % loop through sessions (=blocks)
    for s=1:2
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).scans = cellstr(scans{s});
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(1).name = 'fb_pos_feedon';
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(1).onset = cell2mat(stimonsets{1,s}(1));
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(1).duration = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(1).tmod = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(1).pmod = struct('name', {}, 'param', {}, 'poly', {});
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(1).orth = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(2).name = 'fb_neg_feedon';
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(2).onset = cell2mat(stimonsets{1,s}(2));
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(2).duration = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(2).tmod = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(2).pmod = struct('name', {}, 'param', {}, 'poly', {});
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(2).orth = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(3).name = 'missed_feedon';
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(3).onset = cell2mat(stimonsets{1,s}(3));
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(3).duration = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(3).tmod = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(3).pmod = struct('name', {}, 'param', {}, 'poly', {});
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(3).orth = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(4).name = 'fb_pos_stimon';
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(4).onset = cell2mat(stimonsets{1,s}(4));
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(4).duration = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(4).tmod = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(4).pmod = struct('name', {}, 'param', {}, 'poly', {});
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(4).orth = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(5).name = 'fb_neg_stimon';
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(5).onset = cell2mat(stimonsets{1,s}(5));
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(5).duration = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(5).tmod = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(5).pmod = struct('name', {}, 'param', {}, 'poly', {});
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(5).orth = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(6).name = 'missed_stimon';
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(6).onset = cell2mat(stimonsets{1,s}(6));
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(6).duration = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(6).tmod = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(6).pmod = struct('name', {}, 'param', {}, 'poly', {});
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(6).orth = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).multi = {''};
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).regress = struct('name', {}, 'val', {});
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).multi_reg = cellstr(rp{s});
    end
    matlabbatch{1}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});
    matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0];
    matlabbatch{1}.spm.stats.fmri_spec.volt = 1;
    matlabbatch{1}.spm.stats.fmri_spec.global = 'None';
    matlabbatch{1}.spm.stats.fmri_spec.mthresh = 0.1;
    matlabbatch{1}.spm.stats.fmri_spec.mask = {''};
    matlabbatch{1}.spm.stats.fmri_spec.cvi = 'AR(1)';
    
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
    
    matlabbatch{3}.spm.stats.con.spmmat(1) = cfg_dep('Model estimation: SPM.mat File', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.name = 'fb feedon pos > neg';
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.weights = [1 -1];
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.sessrep = 'repl';
    
    matlabbatch{3}.spm.stats.con.consess{2}.tcon.name = 'fb feedon neg > pos';
    matlabbatch{3}.spm.stats.con.consess{2}.tcon.weights = [-1 1];
    matlabbatch{3}.spm.stats.con.consess{2}.tcon.sessrep = 'repl';
    
    matlabbatch{3}.spm.stats.con.consess{3}.tcon.name = 'fb stimon pos > neg';
    matlabbatch{3}.spm.stats.con.consess{3}.tcon.weights = [0 0 0 1 -1];
    matlabbatch{3}.spm.stats.con.consess{3}.tcon.sessrep = 'repl';
    
    matlabbatch{3}.spm.stats.con.consess{4}.tcon.name = 'fb stimon neg > pos';
    matlabbatch{3}.spm.stats.con.consess{4}.tcon.weights = [0 0 0 -1 1];
    matlabbatch{3}.spm.stats.con.consess{4}.tcon.sessrep = 'repl';
    
    
end