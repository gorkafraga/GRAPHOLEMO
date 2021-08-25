function [matlabbatch] =  LEMO_symctrl_func_create_1Lv_GLM0(pathSubject,scans,onsets,nsessions)
if nargin < 1
    sprintf('No paths provided!');
    return;
else
end     
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% BATCH FOR 1ST LEVEL %%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    matlabbatch=[];
    matlabbatch{1}.spm.stats.fmri_spec.dir = cellstr(pathSubject);
    matlabbatch{1}.spm.stats.fmri_spec.timing.units = 'secs';
    matlabbatch{1}.spm.stats.fmri_spec.timing.RT = 1.250;
    matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = 40;
    matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = 20;

    % loop through sessions (= blocks)
    for s=1:nsessions
        %Scans
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).scans =  scans{s};
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(1).name = 'letter';
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(1).onset = onsets.letters;
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(1).duration = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(1).tmod = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(1).pmod = struct('name', {}, 'param', {}, 'poly', {});
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(1).orth = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(2).name = 'FFlearned';
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(2).onset = onsets.fflearned;
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(2).duration = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(2).tmod = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(2).pmod = struct('name', {}, 'param', {}, 'poly', {});
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(2).orth = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(3).name = 'FFfamiliar';
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(3).onset = onsets.fffam;
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(3).duration = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(3).tmod = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(3).pmod = struct('name', {}, 'param', {}, 'poly', {});
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(3).orth = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(4).name = 'FFnew';
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(4).onset = onsets.ffnew;
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(4).duration = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(4).tmod = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(4).pmod = struct('name', {}, 'param', {}, 'poly', {});
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(4).orth = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(5).name = 'targets';
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(5).onset = onsets.targets;
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(5).duration = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(5).tmod = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(5).pmod = struct('name', {}, 'param', {}, 'poly', {});
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(5).orth = 0;

       % regressors
       matlabbatch{1}.spm.stats.fmri_spec.sess(1).multi = {''};
       matlabbatch{1}.spm.stats.fmri_spec.sess(1).regress = struct('name', {}, 'val', {});
       matlabbatch{1}.spm.stats.fmri_spec.sess(1).multi_reg = cellstr([pathSubject,'\multiReg_',num2str(s),'.txt']);

        % Continue Batch
       matlabbatch{1}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});
        matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0];
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
        
        matlabbatch{3}.spm.stats.con.consess{1}.tcon.name = 'Letter > FF learned';
        matlabbatch{3}.spm.stats.con.consess{1}.tcon.weights = [1 -1 0 0 0];
        matlabbatch{3}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
        
        matlabbatch{3}.spm.stats.con.consess{2}.tcon.name = 'Letter > FF familiar';
        matlabbatch{3}.spm.stats.con.consess{2}.tcon.weights = [1 0 -1 0 0];
        matlabbatch{3}.spm.stats.con.consess{2}.tcon.sessrep = 'none';

        matlabbatch{3}.spm.stats.con.consess{3}.tcon.name = 'Letter > FF new';
        matlabbatch{3}.spm.stats.con.consess{3}.tcon.weights = [1 0 0 -1 0];
        matlabbatch{3}.spm.stats.con.consess{3}.tcon.sessrep = 'none';
        %       
        matlabbatch{3}.spm.stats.con.consess{4}.tcon.name = 'FF learned > Letter';
        matlabbatch{3}.spm.stats.con.consess{4}.tcon.weights = [-1 1 0 0 0];
        matlabbatch{3}.spm.stats.con.consess{4}.tcon.sessrep = 'none';

        matlabbatch{3}.spm.stats.con.consess{5}.tcon.name = 'FF learned > FF familiar';
        matlabbatch{3}.spm.stats.con.consess{5}.tcon.weights = [0 1 -1 0 0];
        matlabbatch{3}.spm.stats.con.consess{5}.tcon.sessrep = 'none';

        matlabbatch{3}.spm.stats.con.consess{6}.tcon.name = 'FF learned > FF new';
        matlabbatch{3}.spm.stats.con.consess{6}.tcon.weights = [0 1 0 -1 0];
        matlabbatch{3}.spm.stats.con.consess{6}.tcon.sessrep = 'none';
        
        matlabbatch{3}.spm.stats.con.consess{7}.tcon.name = 'FF familiar > letter';
        matlabbatch{3}.spm.stats.con.consess{7}.tcon.weights = [-1 0 1 0 0];
        matlabbatch{3}.spm.stats.con.consess{7}.tcon.sessrep = 'none';
 
        
        matlabbatch{3}.spm.stats.con.consess{8}.tcon.name = 'FF new > letter';
        matlabbatch{3}.spm.stats.con.consess{8}.tcon.weights = [-1 0 0 1 0];
        matlabbatch{3}.spm.stats.con.consess{8}.tcon.sessrep = 'none';
        
        
        
        % baseline contrasts
        matlabbatch{3}.spm.stats.con.consess{9}.tcon.name = 'Letter > Baseline';
        matlabbatch{3}.spm.stats.con.consess{9}.tcon.weights = [1 0 0 0 0];
        matlabbatch{3}.spm.stats.con.consess{9}.tcon.sessrep = 'none';
       
        matlabbatch{3}.spm.stats.con.consess{10}.tcon.name = 'FF learned > Baseline';
        matlabbatch{3}.spm.stats.con.consess{10}.tcon.weights = [0 1 0 0 0];
        matlabbatch{3}.spm.stats.con.consess{10}.tcon.sessrep = 'none';

        matlabbatch{3}.spm.stats.con.consess{11}.tcon.name = 'FFfamiliar > Baseline';
        matlabbatch{3}.spm.stats.con.consess{11}.tcon.weights = [0 0 1 0 0];
        matlabbatch{3}.spm.stats.con.consess{11}.tcon.sessrep = 'none';

        matlabbatch{3}.spm.stats.con.consess{12}.tcon.name = 'FFnew > Baseline';
        matlabbatch{3}.spm.stats.con.consess{12}.tcon.weights = [0 0 0 1 0];
        matlabbatch{3}.spm.stats.con.consess{12}.tcon.sessrep = 'none';


        % print some output pictures %%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % design matrix
        matlabbatch{4}.spm.stats.review.spmmat(1) = cfg_dep('fMRI model specification: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
        matlabbatch{4}.spm.stats.review.display.matrix = 1;
        matlabbatch{4}.spm.stats.review.print = 'jpg';    
   
    end
