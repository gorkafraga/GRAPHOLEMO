function [matlabbatch] =  LEMO_func_create_1Lv_concatGLM0_thirds_exMiss(pathSubject,scans,onsets,nsessions)
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
    matlabbatch{1}.spm.stats.fmri_spec.timing.RT = 1;
    matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = 32;
    matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = 16;

    % loop through sessions (= blocks) ---> Now only 1 session with two Blocks
    for s=1:1  
        %Scans
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).scans =  [scans{1};scans{2}];
        % onsets1 
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(1).name = 'stim_third1';
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(1).onset = sort([onsets(1).stimOnset_third1;[onsets(2).stimOnset_third1+numel(scans{1})*1]],'ascend');
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(1).duration = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(1).tmod = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(1).pmod = struct('name', {}, 'param', {}, 'poly', {});
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(1).orth = 0;
        % onsets2 
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(2).name = 'stim_third2';
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(2).onset =  sort([onsets(1).stimOnset_third2;[onsets(2).stimOnset_third2+numel(scans{1})*1]],'ascend');
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(2).duration = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(2).tmod = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(2).pmod = struct('name', {}, 'param', {}, 'poly', {});
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(2).orth = 0;
        % onsets3 
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(3).name = 'stim_third3';
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(3).onset =  sort([onsets(1).stimOnset_third3;[onsets(2).stimOnset_third3+numel(scans{1})*1]],'ascend');
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(3).duration = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(3).tmod = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(3).pmod = struct('name', {}, 'param', {}, 'poly', {});
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(3).orth = 0;
    
        % onsets4
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(4).name = 'fb_third1';
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(4).onset =  sort([onsets(1).feedbackOnset_third1;[onsets(2).feedbackOnset_third1+numel(scans{1})*1]],'ascend');
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(4).duration = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(4).tmod = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(4).pmod = struct('name', {}, 'param', {}, 'poly', {});
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(4).orth = 0;
        % onsets5
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(5).name = 'fb_third2';
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(5).onset = sort([onsets(1).feedbackOnset_third2;[onsets(2).feedbackOnset_third2+numel(scans{1})*1]],'ascend');
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(5).duration = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(5).tmod = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(5).pmod = struct('name', {}, 'param', {}, 'poly', {});
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(5).orth = 0;
        % onsets6
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(6).name = 'fb_third3';
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(6).onset = sort([onsets(1).feedbackOnset_third3;[onsets(2).feedbackOnset_third3+numel(scans{1})*1]],'ascend');
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(6).duration = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(6).tmod = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(6).pmod = struct('name', {}, 'param', {}, 'poly', {});
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(6).orth = 0;
               
        % onsets : stimuli and feedback onsets for trials with missing(or too late)  responses
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(7).name = 'miss';
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(7).onset =  sort([onsets(1).stimOnset_miss;onsets(1).fbOnset_miss;[onsets(2).stimOnset_miss;onsets(2).fbOnset_miss+numel(scans{1})*1]],'ascend');
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(7).duration = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(7).tmod = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(7).pmod = struct('name', {}, 'param', {}, 'poly', {});
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(7).orth = 0;  
        
        % Multiregressors
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
    matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0]; % Correct dimensions?
    matlabbatch{1}.spm.stats.fmri_spec.volt = 1;
    matlabbatch{1}.spm.stats.fmri_spec.global = 'None';
    matlabbatch{1}.spm.stats.fmri_spec.mthresh = 0.1;
    matlabbatch{1}.spm.stats.fmri_spec.mask = {''};
    matlabbatch{1}.spm.stats.fmri_spec.cvi = 'AR(1)';

    % CONCATENATE
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    matlabbatch{2}.cfg_basicio.run_ops.call_matlab.inputs{1}.anyfile(1) = cfg_dep('fMRI model specification: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
    matlabbatch{2}.cfg_basicio.run_ops.call_matlab.inputs{2}.evaluated = [numel(scans{1}) numel(scans{2})];
    matlabbatch{2}.cfg_basicio.run_ops.call_matlab.outputs = {};
    matlabbatch{2}.cfg_basicio.run_ops.call_matlab.fun = @spm_fmri_concatenate; 
    
    
    % ESTIMATE  %%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    matlabbatch{3}.spm.stats.fmri_est.spmmat(1) = cfg_dep('fMRI model specification: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
    matlabbatch{3}.spm.stats.fmri_est.write_residuals = 0;
    matlabbatch{3}.spm.stats.fmri_est.method.Classical = 1;
    
    % CONTRASTS %%%%%%%%
    %%%%%%%%%%%%%%%%%%%% 
      % CONTRASTS %%%%%%%%
     %%%%%%%%%%%%%%%%%%%% 
     % matlabbatch{4}.spm.stats.con.spmmat(1) = cfg_dep('Model estimation: SPM.mat File', substruct('.','val', '{}',{3}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
     matlabbatch{4}.spm.stats.con.spmmat = {[pathSubject,'\SPM.mat']};
     % f-contrast
     matlabbatch{4}.spm.stats.con.consess{1}.fcon.name = 'Effects of interest'; 
    matlabbatch{4}.spm.stats.con.consess{1}.fcon.weights = eye(6);  
       
     matlabbatch{4}.spm.stats.con.delete = 1;

     %   matlabbatch{4}.spm.stats.con.consess{1}.fcon.sessrep = 'repl'; 

 
    % print some output pictures %%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % design matrix
    matlabbatch{5}.spm.stats.review.spmmat(1) = cfg_dep('fMRI model specification: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
    matlabbatch{5}.spm.stats.review.display.matrix = 1;
    matlabbatch{5}.spm.stats.review.print = 'jpg';
    matlabbatch{5}.spm.stats.results.units = 1;
    matlabbatch{5}.spm.stats.results.export{1}.ps = false;
    matlabbatch{5}.spm.stats.results.export{2}.jpg = true;
     
    disp('batch created')
 end
 