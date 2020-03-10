%script for analyzing tasks on first level
%I. Karipidis (2014), D. Willinger (Nov 2017), P. Haller (May 2018),
%G.Fraga Gonzalez(2020)
%--------------------------------------
clear all
%% Set up directories and some variables
addpath ('\\idnetapp1.uzh.ch\g_kjpd_Data3$\studies\Grapholemo\Methods\Scripts\grapholemo');
paths.mri = '\\kjpd-nas01.d.uzh.ch\BrainMap$\studies\grapholemo\Allread_FBL\Analysis\mri\preprocessing\learn';%only mr files good to analyze here
paths.analysis = '\\kjpd-nas01.d.uzh.ch\BrainMap$\studies\grapholemo\Allread_FBL\Analysis\mri\analysis\learn';
paths.logs = '\\kjpd-nas01.d.uzh.ch\BrainMap$\studies\grapholemo\Allread_FBL\Logs';%copy only logs here
nscans = 273;
subjects = {'AR1005'};
%% Begin subject loop
for i = 1:length(subjects)
    subject = subjects{i};
    %% Gather onsets from log files. Times need to be in seconds
    logfiles = ls([paths.logs,'\',subject,'*.txt']);
    if isempty(logfiles)
        errordlg(['no logfiles found for ', subject,' in ',paths.logs, '!!!']);
        break
    else
    onset_tables= gather_FBL_onsets (logfiles,paths.logs);
    %% find corresponding SCANS
    for j = 1:size(logfiles,1)
      %take a pattern from logfile that can identify its corresponding mr file
      patternId = logfiles(j,end-6:end-4); % block id is used to find correct mr file
     % mrfilename = ls([paths.mri,'\',subject,'\s6wuamr*',patternId,'*.nii']);
      scans(j,:)=ls([paths.mri,'\',subject,'\s6wuamr*',patternId,'*.nii']);
      %scans{j}=cellstr(strcat(repmat(mrfilename,273,1),',',num2str((1:273)'))); % add index of scan
    end
    %% find corresponding rp files (realignment parameters to use as regressor)
    for k = 1:size(logfiles,1)
      %take a pattern from logfile that can identify its corresponding mr file
      patternId = logfiles(k,end-6:end); % block id is used to find correct rp file
      rpfiles(k,:) = ls([paths.mri,'\',subject,'\rp_amr*',patternId]);
    end
    % ORDER of rp files should correspond to sequence order of Log files!
    %% set subject output path
    pathSubject = fullfile(paths.analysis,'\1stlev_GLM1',subject);
    if ~isdir(pathSubject)
        mkdir(pathSubject);
    end
    %%    SPECIFY 1ST LEVEL %%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    matlabbatch=[];
    matlabbatch{1}.spm.stats.fmri_spec.dir = cellstr(pathSubject);
    matlabbatch{1}.spm.stats.fmri_spec.timing.units = 'secs';
    matlabbatch{1}.spm.stats.fmri_spec.timing.RT = 1.33;
    matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = 42;
    matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = 21;

    % loop through sessions (= blocks)
    for s=1:2
        onsets= onset_tables{s};% take onsets for current sessions
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).scans = cellstr(spm_select('ExtFPList', [paths.mri,'\',subject], scans(s,:), 1:nscans));
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(1).name = 'stimulus_onset';
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(1).onset = cell2mat({onsets.stimOnset});
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(1).duration = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(1).tmod = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(1).pmod = struct('name', {}, 'param', {}, 'poly', {});
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(1).orth = 0;

        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(2).name = 'feedback_onset';
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(2).onset = cell2mat({onsets.feedbackOnset});
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(2).duration = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(2).tmod = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(2).pmod = struct('name', {}, 'param', {}, 'poly', {});
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(2).orth = 0;

        matlabbatch{1}.spm.stats.fmri_spec.sess(s).multi = {''};
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).regress = struct('name', {}, 'val', {});
         matlabbatch{1}.spm.stats.fmri_spec.sess(s).multi_reg = cellstr(char([paths.mri,'\',subject,'\',rpfiles(s,:)]));
        %matlabbatch{1}.spm.stats.fmri_spec.sess(s).multi_reg = cellstr(char(rp{s},bad_scans{s}));
    end
    %%
    matlabbatch{1}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});
    matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0];
    matlabbatch{1}.spm.stats.fmri_spec.volt = 1;
    matlabbatch{1}.spm.stats.fmri_spec.global = 'None';
    matlabbatch{1}.spm.stats.fmri_spec.mthresh = 0.1;
    matlabbatch{1}.spm.stats.fmri_spec.mask = {''};
    matlabbatch{1}.spm.stats.fmri_spec.cvi = 'AR(1)';

     %%  ESTIMATE  %%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%

    matlabbatch{2}.spm.stats.fmri_est.spmmat(1) = cfg_dep('fMRI model specification: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
    matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
    matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;

     %% CONTRASTS %%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    matlabbatch{3}.spm.stats.con.spmmat(1) = cfg_dep('Model estimation: SPM.mat File', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));

    matlabbatch{3}.spm.stats.con.consess{1}.fcon.name = 'Effects of interest';
    matlabbatch{3}.spm.stats.con.consess{1}.fcon.weights = eye(2);
    matlabbatch{3}.spm.stats.con.consess{1}.fcon.sessrep = 'repl';

    matlabbatch{3}.spm.stats.con.consess{2}.tcon.name = 'Stimulus onset';
    matlabbatch{3}.spm.stats.con.consess{2}.tcon.weights = [1];
    matlabbatch{3}.spm.stats.con.consess{2}.tcon.sessrep = 'repl';

    matlabbatch{3}.spm.stats.con.consess{3}.tcon.name = 'Feedback onset';
    matlabbatch{3}.spm.stats.con.consess{3}.tcon.weights = [0 1];
    matlabbatch{3}.spm.stats.con.consess{3}.tcon.sessrep = 'repl';
    %end
    %% Run
     spm_jobman('run',matlabbatch);
     %clear matlabbatch
    end
end