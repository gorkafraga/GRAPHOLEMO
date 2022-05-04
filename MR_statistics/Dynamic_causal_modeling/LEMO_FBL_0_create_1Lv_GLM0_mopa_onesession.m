function [matlabbatch] =  LEMO_0_create_1Lv_GLM0_mopa_onesession(pathSubject,modeloutput,scans,onsets,nsessions)
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
    matlabbatch{1}.spm.stats.fmri_spec.timing.RT = 1.33;
    matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = 42;
    matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = 21;

    % loop through sessions (= blocks)
    for s=1:1 %nsessions
        %format parameters from table as numeric
        ASnum_s1 = cell2mat(cellfun(@(S) sscanf(S, '%f%f%f%f%f%f%f%f').',modeloutput{1}.as_chosen,'uniform', 0)); % transform to double PE values
        ASnum_s2 = cell2mat(cellfun(@(S) sscanf(S, '%f%f%f%f%f%f%f%f').',modeloutput{2}.as_chosen,'uniform', 0)); % transform to double PE values
        ASnum = [ASnum_s1-mean(ASnum_s1); ASnum_s2-mean(ASnum_s2)];
        
        PEnum_s1 = cell2mat(cellfun(@(S) sscanf(S, '%f%f%f%f%f%f%f%f').',modeloutput{1}.pe_tot_hat,'uniform', 0)); % transform to double PE values
        PEnum_s2 = cell2mat(cellfun(@(S) sscanf(S, '%f%f%f%f%f%f%f%f').',modeloutput{2}.pe_tot_hat,'uniform', 0)); % transform to double PE values
        PEnum = [ PEnum_s1-mean(PEnum_s1); PEnum_s2-mean(PEnum_s2)  ];
        
        %ASnum = modeloutput{s}.as_chosen; % transform to double PE values
        %PEnum = modeloutput{s}.pe_tot_hat; % transform to double PE values
        
        %Scans
        
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).scans =  [ scans{1}; scans{2}] ;
        % onsets 1 
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(1).name = 'stimulus_onset'; % Remove stimuli with missing responses (pmod must have same length)
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(1).onset = sort([[onsets(1).stimOnset_neg;onsets(1).stimOnset_pos]; [onsets(2).stimOnset_neg;onsets(2).stimOnset_pos]+numel(scans{1})*1.33],'ascend')
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(1).duration = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(1).tmod = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(1).pmod.name = 'AS_choice';
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(1).pmod.param = ASnum; % HERE TAKE AS VALUES FOR CHOICE
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(1).pmod.poly = 1;
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(1).orth = 0;
        % onsets 2 
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(2).name = 'feedback_onset';
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(2).onset = sort([[onsets(1).fbOnset_neg;onsets(1).fbOnset_pos]; [onsets(2).fbOnset_neg;onsets(2).fbOnset_pos]+numel(scans{1})*1.33],'ascend') % Here I would need to remove the misssing values (not in model output)
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(2).duration = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(2).tmod = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(2).pmod.name = 'PE';%signed prediction error 
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(2).pmod.param = PEnum; %mean centered
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(2).pmod.poly = 1;        
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(2).orth = 0;
        % onsets 3  JUST FEEDBACK TO MISSING TRIALS 
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(3).name = 'missing';
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(3).onset =  sort([[onsets(1).stimOnset_miss;onsets(1).fbOnset_miss]; [onsets(1).stimOnset_miss;onsets(1).fbOnset_miss]+numel(scans{1})*1.33],'ascend') % missing resps here;  % Here I would need to remove the misssing values (not in model output)
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(3).duration = 0; 
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(3).tmod = 0;      
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(3).pmod = struct('name', {}, 'param', {}, 'poly', {});
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(3).orth = 0;
    
        % regressors
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).multi = {''};
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).regress = struct('name', {}, 'val', {});
        % matlabbatch{1}.spm.stats.fmri_spec.sess(s).multi_reg = cellstr([pathSubject,'\multiReg_',num2str(s),'.txt']);
        
        % read realignment parameters
        realignment_params = [];
       
        for i = 1:2
            realignment_params_file = ls ( [pathSubject,'\multiReg_',num2str(i),'.txt']);           
            fileID = fopen(fullfile(pathSubject,realignment_params_file),'r');
            formatSpec = '%f,%f,%f,%f,%f,%f,%f';
            realignment_params_tmp = fscanf(fileID,formatSpec,[7 Inf]);
            realignment_params_tmp = realignment_params_tmp';
            realignment_params = [ realignment_params; realignment_params_tmp];
            fclose(fileID);
        end
        
        for i = 1:7
                matlabbatch{1}.spm.stats.fmri_spec.sess.regress(i).name = sprintf('R%d',i);
                matlabbatch{1}.spm.stats.fmri_spec.sess.regress(i).val  = realignment_params(:,i);
        end
            
        
        
        matlabbatch{1}.spm.stats.fmri_spec.sess.regress(8).name = 'session overlap';
        matlabbatch{1}.spm.stats.fmri_spec.sess.regress(8).val  = [zeros(1,numel(scans{1})-3) 0 0 1 1 0 0 zeros(1,numel(scans{2})-3) ];
        
     end
    % Continue Batch
    matlabbatch{1}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});
    matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0];
    matlabbatch{1}.spm.stats.fmri_spec.volt = 1;
    matlabbatch{1}.spm.stats.fmri_spec.global = 'None';
    matlabbatch{1}.spm.stats.fmri_spec.mthresh = 0.1;
    matlabbatch{1}.spm.stats.fmri_spec.mask = {''};
    matlabbatch{1}.spm.stats.fmri_spec.cvi = 'AR(1)';
    
    matlabbatch{2}.cfg_basicio.run_ops.call_matlab.inputs{1}.anyfile(1) = cfg_dep('fMRI model specification: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
    matlabbatch{2}.cfg_basicio.run_ops.call_matlab.inputs{2}.evaluated = [numel(scans{1}) numel(scans{2})];
    matlabbatch{2}.cfg_basicio.run_ops.call_matlab.outputs = {};
    matlabbatch{2}.cfg_basicio.run_ops.call_matlab.fun = @spm_fmri_concatenate;

    % ESTIMATE  %%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    % We need to estimate the model to apply the session concatenation!
    matlabbatch{3}.spm.stats.fmri_est.spmmat(1) = cfg_dep('fMRI model specification: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
    matlabbatch{3}.spm.stats.fmri_est.write_residuals = 0;
    matlabbatch{3}.spm.stats.fmri_est.method.Classical = 1;
     
     % CONTRASTS %%%%%%%%
     %%%%%%%%%%%%%%%%%%%% 
     % matlabbatch{4}.spm.stats.con.spmmat(1) = cfg_dep('Model estimation: SPM.mat File', substruct('.','val', '{}',{3}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
     matlabbatch{4}.spm.stats.con.spmmat = {[pathSubject,'\SPM.mat']};
     % f-contrast
     matlabbatch{4}.spm.stats.con.consess{1}.fcon.name = 'Effects of interest';
     if isempty(matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(3).onset)
         matlabbatch{4}.spm.stats.con.consess{1}.fcon.weights = eye(4);% omit last vector in the F contrast if subject doesn't have missing responses (else it will crash)
          disp('eye(4)!!!')
     else
         matlabbatch{4}.spm.stats.con.consess{1}.fcon.weights = eye(5);
         disp('eye(5)')
     end
     matlabbatch{4}.spm.stats.con.delete = 1;

     %   matlabbatch{4}.spm.stats.con.consess{1}.fcon.sessrep = 'repl'; 


    
    % print some output pictures %%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % design matrix
    matlabbatch{5}.spm.stats.review.spmmat(1) = cfg_dep('fMRI model specification: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
    matlabbatch{5}.spm.stats.review.display.matrix = 1;
    matlabbatch{5}.spm.stats.review.print = 'jpg';
      
end

