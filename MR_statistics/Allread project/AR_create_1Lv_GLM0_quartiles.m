function [matlabbatch] =  AR_create_1Lv_GLM0_quartiles(pathSubject,scans,onsets,nsessions)
    if nargin < 1
        sprintf('No paths provided!');
        return;
    else
    end  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%% BATCH FOR 1st LEVEL %%%%%%%%
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
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(1).name = 'stim_quart1';
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(1).onset = onsets(s).stimOnset_quartile1;
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(1).duration = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(1).tmod = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(1).pmod = struct('name', {}, 'param', {}, 'poly', {});
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(1).orth = 0;
        % onsets2 
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(2).name = 'stim_quart2';
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(2).onset = onsets(s).stimOnset_quartile2;
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(2).duration = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(2).tmod = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(2).pmod = struct('name', {}, 'param', {}, 'poly', {});
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(2).orth = 0;
        % onsets3 
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(3).name = 'stim_quart3';
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(3).onset = onsets(s).stimOnset_quartile3;
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(3).duration = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(3).tmod = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(3).pmod = struct('name', {}, 'param', {}, 'poly', {});
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(3).orth = 0;
        % onsets4
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(4).name = 'stim_quart4';
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(4).onset = onsets(s).stimOnset_quartile4;
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(4).duration = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(4).tmod = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(4).pmod = struct('name', {}, 'param', {}, 'poly', {});
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(4).orth = 0;    
        % onsets5
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(5).name = 'fb_quart1';
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(5).onset = onsets(s).feedbackOnset_quartile1;
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(5).duration = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(5).tmod = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(5).pmod = struct('name', {}, 'param', {}, 'poly', {});
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(5).orth = 0;
        % onsets6 
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(6).name = 'fb_quart2';
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(6).onset = onsets(s).feedbackOnset_quartile2;
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(6).duration = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(6).tmod = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(6).pmod = struct('name', {}, 'param', {}, 'poly', {});
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(6).orth = 0;
        % onsets7 
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(7).name = 'fb_quart3';
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(7).onset = onsets(s).feedbackOnset_quartile3;
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(7).duration = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(7).tmod = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(7).pmod = struct('name', {}, 'param', {}, 'poly', {});
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(7).orth = 0;
        % onsets8
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(8).name = 'fb_quart4';
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(8).onset = onsets(s).feedbackOnset_quartile4;
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(8).duration = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(8).tmod = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(8).pmod = struct('name', {}, 'param', {}, 'poly', {});
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(8).orth = 0;
         
        % Multiregressors
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
    %fcontrast 1 
    matlabbatch{3}.spm.stats.con.consess{1}.fcon.name = 'Effects of interest';
    matlabbatch{3}.spm.stats.con.consess{1}.fcon.weights = eye(4);
    matlabbatch{3}.spm.stats.con.consess{1}.fcon.sessrep = 'repl';
    %t-contrasts 1 
    matlabbatch{3}.spm.stats.con.consess{2}.tcon.name = 'stim quart1';
    matlabbatch{3}.spm.stats.con.consess{2}.tcon.weights = [1 0 0 0 0 0 0 0];
    matlabbatch{3}.spm.stats.con.consess{2}.tcon.sessrep = 'repl';
    %t-contrasts 2
    matlabbatch{3}.spm.stats.con.consess{3}.tcon.name = 'stim quart1 > quart4';
    matlabbatch{3}.spm.stats.con.consess{3}.tcon.weights = [1 0 0 -1 0 0 0 0];
    matlabbatch{3}.spm.stats.con.consess{3}.tcon.sessrep = 'repl';
    %t-contrasts 3
    matlabbatch{3}.spm.stats.con.consess{4}.tcon.name = 'stim quart4> quart1';
    matlabbatch{3}.spm.stats.con.consess{4}.tcon.weights = [-1 0 0 1 0 0 0 0];
    matlabbatch{3}.spm.stats.con.consess{4}.tcon.sessrep = 'repl';
    %t-contrasts 4 
    matlabbatch{3}.spm.stats.con.consess{5}.tcon.name = 'fb quart1';
    matlabbatch{3}.spm.stats.con.consess{5}.tcon.weights = [0 0 0 0 1 0 0 0];
    matlabbatch{3}.spm.stats.con.consess{5}.tcon.sessrep = 'repl';
    %t-contrasts 5 
    matlabbatch{3}.spm.stats.con.consess{6}.tcon.name = 'fb quart1 > quart4';
    matlabbatch{3}.spm.stats.con.consess{6}.tcon.weights = [0 0 0 0 1 0 0 -1];
    matlabbatch{3}.spm.stats.con.consess{6}.tcon.sessrep = 'repl';
    %t-contrasts 6
    matlabbatch{3}.spm.stats.con.consess{7}.tcon.name =  'fb quart4 > quart1';
    matlabbatch{3}.spm.stats.con.consess{7}.tcon.weights = [0 0 0 0 -1 0 0 1];
    matlabbatch{3}.spm.stats.con.consess{7}.tcon.sessrep = 'repl';
    
    % print some output pictures %%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % design matrix
    matlabbatch{4}.spm.stats.review.spmmat(1) = cfg_dep('fMRI model specification: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
    matlabbatch{4}.spm.stats.review.display.matrix = 1;
    matlabbatch{4}.spm.stats.review.print = 'jpg';
    matlabbatch{4}.spm.stats.results.units = 1;
    matlabbatch{4}.spm.stats.results.export{1}.ps = false;
    matlabbatch{4}.spm.stats.results.export{2}.jpg = true;
     
    disp('batch created')
 end
 