function [matlabbatch] =  LEMO_func_create_1Lv_GLM0_mopa_vpe(pathSubject,modeloutput,scans,onsets,nsessions)
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
    matlabbatch{1}.spm.stats.fmri_spec.timing.RT = 1;
    matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = 32;
    matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = 16;

    % loop through sessions (= blocks)
    for s=1:nsessions
        %format parameters from table as numeric
        v_hat = modeloutput{s}.v_hat; % transform to double PE values
        PEnum = modeloutput{s}.pe_tot_hat; % transform to double PE values
        %Scans
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).scans =  scans{s};
        % onsets 1 
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(1).name = 'stimulus_onset'; % Remove stimuli with missing responses (pmod must have same length)
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(1).onset = sort([onsets(s).stimOnset_neg;onsets(s).stimOnset_pos],'ascend');
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(1).duration = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(1).tmod = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(1).pmod.name = 'v_hat';
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(1).pmod.param = v_hat-mean(v_hat);% 
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(1).pmod.poly = 1;
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(1).orth = 0;
        % onsets 2 
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(2).name = 'feedback_onset';
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(2).onset = sort([onsets(s).fbOnset_neg;onsets(s).fbOnset_pos],'ascend');  % Here I would need to remove the misssing values (not in model output)
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(2).duration = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(2).tmod = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(2).pmod.name = 'PE';%signed prediction error 
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(2).pmod.param = PEnum-mean(PEnum); %mean centered
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(2).pmod.poly = 1;        
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(2).orth = 0;
        % onsets 3  JUST FEEDBACK TO MISSING TRIALS 
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(3).name = 'missing';
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(3).onset =  sort([onsets(s).stimOnset_miss;onsets(s).fbOnset_miss],'ascend'); % missing resps here;  % Here I would need to remove the misssing values (not in model output)
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(3).duration = 0; 
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(3).tmod = 0;      
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(3).pmod = struct('name', {}, 'param', {}, 'poly', {});
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(3).orth = 0;
    
        % regressors
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).multi = {''};
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).regress = struct('name', {}, 'val', {});
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).multi_reg = cellstr([pathSubject,'\multiReg_',num2str(s),'.txt']);
     end
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
    % f-contrast
    matlabbatch{3}.spm.stats.con.consess{1}.fcon.name = 'Effects of interest';
    if length(onsets(1).fbOnset_miss) == 0 || length(onsets(2).fbOnset_miss) == 0
        matlabbatch{3}.spm.stats.con.consess{1}.fcon.weights = eye(4);% omit last vector in the F contrast if subject doesn't have missing responses (else it will crash)
         disp('eye(4)!')
    else
        matlabbatch{3}.spm.stats.con.consess{1}.fcon.weights = eye(5);
        disp('eye(5)')
    end
    %   matlabbatch{3}.spm.stats.con.consess{1}.fcon.sessrep = 'repl'; 
    % t-contrast 1
    matlabbatch{3}.spm.stats.con.consess{2}.tcon.name = 'Stimulus onset';
    matlabbatch{3}.spm.stats.con.consess{2}.tcon.weights = [1 0 0 0 0];
    matlabbatch{3}.spm.stats.con.consess{2}.tcon.sessrep = 'repl';
    % t-contrast 2
    matlabbatch{3}.spm.stats.con.consess{3}.tcon.name = 'Feedback onset';
    matlabbatch{3}.spm.stats.con.consess{3}.tcon.weights = [0 0 1 0 0];
    matlabbatch{3}.spm.stats.con.consess{3}.tcon.sessrep = 'repl';
   
    % t-contrast 3
    matlabbatch{3}.spm.stats.con.consess{4}.tcon.name = 'Stimulus onset - Feedback onset';
    matlabbatch{3}.spm.stats.con.consess{4}.tcon.weights = [1 0 -1 0 0];
    matlabbatch{3}.spm.stats.con.consess{4}.tcon.sessrep = 'repl';
    
    % t-contrast 4
    matlabbatch{3}.spm.stats.con.consess{5}.tcon.name = 'Feedback onset - Stimulus onset';
    matlabbatch{3}.spm.stats.con.consess{5}.tcon.weights = [-1 0 1 0 0];
    matlabbatch{3}.spm.stats.con.consess{5}.tcon.sessrep = 'repl';
       
    % t-contrasts with parametric modulators
    matlabbatch{3}.spm.stats.con.consess{6}.tcon.name = 'Stim posV';
    matlabbatch{3}.spm.stats.con.consess{6}.tcon.weights = [0 1 0 0 0];
    matlabbatch{3}.spm.stats.con.consess{6}.tcon.sessrep = 'repl';
    
    matlabbatch{3}.spm.stats.con.consess{7}.tcon.name = 'Stim negV';
    matlabbatch{3}.spm.stats.con.consess{7}.tcon.weights = [0 -1 0 0 0];
    matlabbatch{3}.spm.stats.con.consess{7}.tcon.sessrep = 'repl';
    
    matlabbatch{3}.spm.stats.con.consess{8}.tcon.name = 'feedback posPE';
    matlabbatch{3}.spm.stats.con.consess{8}.tcon.weights = [0 0 0 1 0];
    matlabbatch{3}.spm.stats.con.consess{8}.tcon.sessrep = 'repl';

    matlabbatch{3}.spm.stats.con.consess{9}.tcon.name = 'feedback negPE';
    matlabbatch{3}.spm.stats.con.consess{9}.tcon.weights = [0 0 0 -1 0];
   matlabbatch{3}.spm.stats.con.consess{9}.tcon.sessrep = 'repl';

    
    % print some output pictures %%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % design matrix
    matlabbatch{4}.spm.stats.review.spmmat(1) = cfg_dep('fMRI model specification: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
    matlabbatch{4}.spm.stats.review.display.matrix = 1;
    matlabbatch{4}.spm.stats.review.print = 'jpg';
      
end

