function [matlabbatch] =  AR_create_1Lev_GLM2(pathSubject,scans,onsets,nsessions,pcorr,pthresh,nvoxels)
    if nargin < 1
        sprintf('No paths provided!');
        return;
    else
    end  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%% BATCH FOR 2nd LEVEL %%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    matlabbatch=[];
    matlabbatch{1}.spm.stats.fmri_spec.dir = cellstr(pathSubject);
    matlabbatch{1}.spm.stats.fmri_spec.timing.units = 'secs';
    matlabbatch{1}.spm.stats.fmri_spec.timing.RT = 1.33;
    matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = 42;
    matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = 21;

    % loop through sessions (= blocks)
    for s=1:nsessions
        %Scans
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).scans =  scans{s}; 
        % onsets1 
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(1).name = 'stimOnset_pos';
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(1).onset = onsets(s).stimOnset_pos;
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(1).duration = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(1).tmod = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(1).pmod = struct('name', {}, 'param', {}, 'poly', {});
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(1).orth = 0;
        % onsets2 
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(2).name = 'stimOnset_neg';
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(2).onset = onsets(s).stimOnset_neg;
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(2).duration = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(2).tmod = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(2).pmod = struct('name', {}, 'param', {}, 'poly', {});
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(2).orth = 0;
        % onsets3 
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(3).name = 'fbOnset_pos';
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(3).onset = onsets(s).fbOnset_pos;
        matlabbatch{1}.spm.stats.fmsri_spec.sess(s).cond(3).duration = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(3).tmod = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(3).pmod = struct('name', {}, 'param', {}, 'poly', {});
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(3).orth = 0;
        % onsets4
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(4).name = 'fbOnset_neg';
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(4).onset = onsets(s).fbOnset_neg;
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(4).duration = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(4).tmod = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(4).pmod = struct('name', {}, 'param', {}, 'poly', {});
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(4).orth = 0;    
        %Multiregressors
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).multi = {''};
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).regress = struct('name', {}, 'val', {});
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).multi_reg = cellstr([pathSubject,'\multiReg_',num2str(s),'.txt']);
     end
    % Continue Batch
    matlabbatch{1}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});
    matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0]; % Correct dimensions?
    matlabbatch{1}.spm.stats.fmri_spec.volt = 1;
    matlabbatch{1}.spm.stats.fmri_spec.global = 'None';
    matlabbatch{1}.spm.stats.fmri_spec.mthresh = 0.1;
    matlabbatch{1}.spm.stats.fmri_spec.mask = {''};
    matlabbatch{1}.spm.stats.fmri_spec.cvi = 'AR(1)';

    % ESTIMATE  %%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    matlabbatch{2}.spm.stats.fmri_est.spmmat(1) = cfg_dep('fMRI model specification: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
    matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
    matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;
    
    % CONTRASTS %%%%%%%%
    %%%%%%%%%%%%%%%%%%%% 
    matlabbatch{3}.spm.stats.con.spmmat(1) = cfg_dep('Model estimation: SPM.mat File', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
    %fcontrast
    matlabbatch{3}.spm.stats.con.consess{1}.fcon.name = 'Effects of interest';
    matlabbatch{3}.spm.stats.con.consess{1}.fcon.weights = eye(4);
    matlabbatch{3}.spm.stats.con.consess{1}.fcon.sessrep = 'repl';
    %t-contrasts 1 
    matlabbatch{3}.spm.stats.con.consess{2}.tcon.name = 'pos > neg stimulus';
    matlabbatch{3}.spm.stats.con.consess{2}.tcon.weights = [1 -1 0 0];
    matlabbatch{3}.spm.stats.con.consess{2}.tcon.sessrep = 'repl';
    %t-contrasts 2 
    matlabbatch{3}.spm.stats.con.consess{3}.tcon.name = 'neg > pos stimulus';
    matlabbatch{3}.spm.stats.con.consess{3}.tcon.weights = [-1 1 0 0];
    matlabbatch{3}.spm.stats.con.consess{3}.tcon.sessrep = 'repl';
    %t-contrasts 3
    matlabbatch{3}.spm.stats.con.consess{4}.tcon.name = 'pos > neg feedback';
    matlabbatch{3}.spm.stats.con.consess{4}.tcon.weights = [0 0 1 -1];
    matlabbatch{3}.spm.stats.con.consess{4}.tcon.sessrep = 'repl';
    %t-contrasts 4
    matlabbatch{3}.spm.stats.con.consess{5}.tcon.name = 'neg > pos feedback';
    matlabbatch{3}.spm.stats.con.consess{5}.tcon.weights = [0 0 -1 1];
    matlabbatch{3}.spm.stats.con.consess{5}.tcon.sessrep = 'repl';
   
    % print some output pictures %%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % design matrix
    matlabbatch{4}.spm.stats.review.spmmat(1) = cfg_dep('fMRI model specification: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
    matlabbatch{4}.spm.stats.review.display.matrix = 1;
    matlabbatch{4}.spm.stats.review.print = 'jpg';
    % print some  results 
    matlabbatch{5}.spm.stats.results.spmmat(1) = cfg_dep('fMRI model specification: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
    matlabbatch{5}.spm.stats.results.conspec(1).titlestr = '';
    matlabbatch{5}.spm.stats.results.conspec(1).contrasts = 2;
    matlabbatch{5}.spm.stats.results.conspec(1).threshdesc = pcorr;
    matlabbatch{5}.spm.stats.results.conspec(1).thresh = pthresh;
    matlabbatch{5}.spm.stats.results.conspec(1).extent = nvoxels;
    %matlabbatch{5}.spm.stats.results.conspec(1).conjunction = 1;
    matlabbatch{5}.spm.stats.results.conspec(1).mask.none = 1;
    
    matlabbatch{5}.spm.stats.results.conspec(2).titlestr = '';
    matlabbatch{5}.spm.stats.results.conspec(2).contrasts = 3;
    matlabbatch{5}.spm.stats.results.conspec(2).threshdesc = pcorr;
    matlabbatch{5}.spm.stats.results.conspec(2).thresh = pthresh;
    matlabbatch{5}.spm.stats.results.conspec(2).extent = nvoxels;
    %matlabbatch{5}.spm.stats.results.conspec(2).conjunction = 1;
    matlabbatch{5}.spm.stats.results.conspec(2).mask.none = 1;
    
     matlabbatch{5}.spm.stats.results.conspec(3).titlestr = '';
    matlabbatch{5}.spm.stats.results.conspec(3).contrasts = 4;
    matlabbatch{5}.spm.stats.results.conspec(3).threshdesc = pcorr;
    matlabbatch{5}.spm.stats.results.conspec(3).thresh = pthresh;
    matlabbatch{5}.spm.stats.results.conspec(3).extent = nvoxels;
    %matlabbatch{5}.spm.stats.results.conspec(3).conjunction = 1;
    matlabbatch{5}.spm.stats.results.conspec(3).mask.none = 1;
    
    matlabbatch{5}.spm.stats.results.conspec(4).titlestr = '';
    matlabbatch{5}.spm.stats.results.conspec(4).contrasts = 5;
    matlabbatch{5}.spm.stats.results.conspec(4).threshdesc = pcorr;
    matlabbatch{5}.spm.stats.results.conspec(4).thresh = pthresh;
    matlabbatch{5}.spm.stats.results.conspec(4).extent = nvoxels;
    %matlabbatch{5}.spm.stats.results.conspec(4).conjunction = 1;
    matlabbatch{5}.spm.stats.results.conspec(4).mask.none = 1;
    
    matlabbatch{5}.spm.stats.results.units = 1;
    matlabbatch{5}.spm.stats.results.export{1}.ps = false;
    matlabbatch{5}.spm.stats.results.export{2}.jpg = true;
     
 end
 