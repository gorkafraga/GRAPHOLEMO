%script for analyzing tasks on first level
%I. Karipidis (2014), D. Willinger (Nov 2017), P. Haller (May 2018),
%G.Fraga Gonzalez(2020)
%--------------------------------------
clear all
close all
%% Set up directories and some variables
addpath ('N:\studies\Grapholemo\Methods\Scripts\grapholemo\MR statistics');
paths.mri = 'O:\studies\allread\mri\analysis_GFG\preprocessing';% This has subfolders learn_1 and learn_2
paths.analysis =  'O:\studies\allread\mri\analysis_GFG\stats\1stLevel_GLM1\learn_12';
paths.logs = 'O:\studies\allread\mri\analysis_GFG\stats\task_logs'; % here the select files for this analysis, suffix was fixed when needed so all end in  _bX.txt
nscans = 273;
nsessions = 2;
% input for plotting results
pthresh = 0.0001;
nvoxels = 10;
pcorr = 'none'; % 'none', 'FWE';
cd (paths.analysis)

%% Begin subject loop
% subjects = {'AR1005'};
files = dir([paths.analysis,'\AR*']);
subjects= {files.name};
subjects = {'AR1005'};
spm fmri
for i = 1:length(subjects)
    subject = subjects{i}; 
    pathSubject = fullfile(paths.analysis,'\',subject); %output path
    if ~isdir(pathSubject)
        mkdir(pathSubject);
    end
    cd(pathSubject)
    logfileID = fopen('LOG_firstLevel.txt','w');

   %% PREPARE INPUTS 
   %Gather onsets from log files. Times need to be in seconds
    logfilesTMP = dir([paths.logs,'\',subject,'\*FeedLearn*.txt']);
    logfiles = {logfilesTMP.name}  ;  
    currPathLogs = [paths.logs,'\',subject];
    onsets = AR_gather_onsets(logfiles,currPathLogs);
  
    % find SCANS matching with log files
    fprintf(logfileID,strcat(['[[',subject,']]\r\n'])); 
    for j = 1:length(logfiles)
          %take a pattern from logfile that can identify its corresponding mr file
          logfilesChar = logfiles{j};
          patternId = logfilesChar(end-6:end-4); % block id is used to find correct mr file
          mrfilename = dir([paths.mri,'\**\epis\',subject,'\ART\vs6wuamr*',patternId,'*.nii']);
          % select scans 
          scans{j} =  cellstr(spm_select('ExtFPList',mrfilename.folder, mrfilename.name, Inf))  ;
          % Read the corresponding RP file
          rpfile = dir([paths.mri,'\**\epis\',subject,'\rp_amr*',patternId,'*.txt']);

          formatSpec = '%16f%16f%16f%16f%16f%16f%[^\n\r]';
          fileID = fopen([rpfile.folder,'\',rpfile.name],'r');
          rpdat = textscan(fileID, formatSpec, 'Delimiter', '', 'WhiteSpace', '', 'TextType', 'string',  'ReturnOnError', false);
          fclose(fileID);

          mrfilenameSplit = split(mrfilename.folder,'\');
          sessionID  =  mrfilenameSplit{find(contains(mrfilenameSplit,'learn'))};
          % Read flagged bad scans (if file found) 
           badscans = dir([paths.mri,'\',sessionID,'\epis\',subject,'\ART\*flagscans.mat']);
           if ~isempty(badscans) % If it doesn't find a flagscan file it will use zeroes
               load([badscans.folder,'\',badscans.name]);  % load variable Regr_badscans from file
               logInfBadscans = [badscans.folder,'\',badscans.name];  
          else 
               Regr_badscans = zeros(nscans,1);   
               disp(['Could not find bad scans for ',subject,'!']);
               logInfBadscans ='No bad scans file'; 
          end
          % Merge RP and Flagscans and save table in txt 
          multireg =  [rpdat{1},rpdat{2},rpdat{3},rpdat{4},rpdat{5},rpdat{6},Regr_badscans];
          writetable(cell2table(num2cell(multireg)),[pathSubject,'\multiReg_',num2str(j),'.txt'],'WriteVariableNames',false)

         %Write log 
         fprintf(logfileID,strcat(['...',strrep([mrfilename.folder,'\',mrfilename.name],'\','\\'),'\r\n'])); 
         fprintf(logfileID,strcat(['...',strrep([paths.logs,'\',logfiles{j}],'\','\\'),'\r\n'])); 
         fprintf(logfileID,strcat(['...',strrep(logInfBadscans,'\','\\'),'\r\n'])); 
         fprintf(logfileID,strcat(['...',strrep([rpfile.folder,'\',rpfile.name],'\','\\'),'\r\n\r\n']));
    end
    
    %% BATCH FOR 1ST LEVEL %%%%%%%%
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
        % onsets 1  
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(1).name = 'stimulus_onset';
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(1).onset = onsets(s).stimOnset;
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(1).duration = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(1).tmod = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(1).pmod = struct('name', {}, 'param', {}, 'poly', {});
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(1).orth = 0;
        % onsets 2 
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(2).name = 'feedback_onset';
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(2).onset = onsets(s).feedbackOnset;
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(2).duration = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(2).tmod = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(2).pmod = struct('name', {}, 'param', {}, 'poly', {});
        matlabbatch{1}.spm.stats.fmri_spec.sess(s).cond(2).orth = 0;
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
    matlabbatch{3}.spm.stats.con.consess{1}.fcon.weights = eye(2);
    matlabbatch{3}.spm.stats.con.consess{1}.fcon.sessrep = 'repl';
    % t-contrast 1
    matlabbatch{3}.spm.stats.con.consess{2}.tcon.name = 'Stimulus onset';
    matlabbatch{3}.spm.stats.con.consess{2}.tcon.weights = [1 0];
    matlabbatch{3}.spm.stats.con.consess{2}.tcon.sessrep = 'repl';
    % t-contrast 2
    matlabbatch{3}.spm.stats.con.consess{3}.tcon.name = 'Feedback onset';
    matlabbatch{3}.spm.stats.con.consess{3}.tcon.weights = [0 1];
    matlabbatch{3}.spm.stats.con.consess{3}.tcon.sessrep = 'repl';
   
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
    matlabbatch{5}.spm.stats.results.units = 1;
    matlabbatch{5}.spm.stats.results.export{1}.ps = false;
    matlabbatch{5}.spm.stats.results.export{2}.jpg = true;
    
  % Run %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  spm_jobman('run',matlabbatch);
  movefile(ls('*_001.jpg'),strrep(ls('*_001.jpg'),'_001.jpg','_design.jpg'))
  %clear matlabbatch
  fclose(logfileID);
end

