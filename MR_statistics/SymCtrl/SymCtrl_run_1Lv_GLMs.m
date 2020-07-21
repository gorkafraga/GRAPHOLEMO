% --------------------------------------------------------------------------------------
%  __                 _           _         ___            _             _ 
% / _\_   _ _ __ ___ | |__   ___ | |       / __\___  _ __ | |_ _ __ ___ | |
% \ \| | | | '_ ` _ \| '_ \ / _ \| |_____ / /  / _ \| '_ \| __| '__/ _ \| |
% _\ \ |_| | | | | | | |_) | (_) | |_____/ /__| (_) | | | | |_| | | (_) | |
% \__/\__, |_| |_| |_|_.__/ \___/|_|     \____/\___/|_| |_|\__|_|  \___/|_|
%     |___/      
%
% FIRST LEVEL ANALYSIS
% - Gathers onset of relevant stimuli from log files
% - Runs function "create_1stLevel_GLMxXx" with a model specs and contrasts
% - Output saved in folder named as model specified (e.g., 1stLevel_GLM1)
% G.FragaGonzalez(2020)
% --------------------------------------------------------------------------------------
clear all
close all
addpath ('N:\studies\Grapholemo\Methods\Scripts\grapholemo\MR statistics\SymCtrl');% set path to this script and associated functions 
% Set up directories and some variables 
%do NOT use '\' at the end of directories
paths.analysis =  'O:\studies\allread\mri\analyses_EH\02_first_level\GLM1'; %this sets your 
paths.mri = 'O:\studies\allread\mri\analyses_EH\01_preprocessing\symCtrl';% This is your preprocessing  data parent folder
paths.logs = 'O:\studies\allread\mri\analyses_EH\02_first_level\logs'; % Folder with your SELECTED LOG files
nscans = 408;
mkdir(paths.analysis)
cd (paths.analysis)
%%  Find subjects in your LOGS directory  begin subject loop 
files = dir([paths.logs,'\AR*']);
subjects= {files.name};
subjects = {'AR1077'};
% Uncomment the following lines if you want to exclude subjects
%excludedSubj = {'AR1025'};
%subjects(cell2mat(cellfun(@(c)find(strcmp(c,subjects)),excludedSubj,'UniformOutput',false)))=[]; %find index and exclude subjects
spm('defaults','fMRI')
for i = 1:length(subjects)
   currsubject=subjects{i};
     
   %prepare analysis output folder
    pathSubject = fullfile(paths.analysis,'\',currsubject); %output path
    if ~isdir(pathSubject)
        mkdir(pathSubject);
    end
    cd(pathSubject)

    %% PREPARE INPUTS 
    %Gather onsets from log files. Times need to be in seconds
     logfile = dir([paths.logs,'\',currsubject,'\*.log']);
     %read log file data data 
     fileID = fopen([logfile.folder,'\',logfile.name]);
     content = textscan(fileID,'%s %s %s %s %s %s %s %s %s %s %s %s %s', 'headerlines', 5 ,'delimiter','\t');
     fclose(fileID);
     % gather onsets
    onsets = {};
    idx_scanonset = find(strcmp(content{4},'199'));
    idx_scanonset = idx_scanonset(2); 
    onsets.letters = cellfun(@str2num,(content{5}(strcmp(content{4},'60'))   ))./10000 - cellfun(@str2num,(content{5}(idx_scanonset)))./10000;
    onsets.fflearned = cellfun(@str2num,(content{5}(strcmp(content{4},'70'))))./10000 - cellfun(@str2num,(content{5}(idx_scanonset)))./10000;
    onsets.fffam = cellfun(@str2num,(content{5}(strcmp(content{4},'80'))))./10000 - cellfun(@str2num,(content{5}(idx_scanonset)))./10000;
    onsets.ffnew = cellfun(@str2num,(content{5}(strcmp(content{4},'90'))))./10000 - cellfun(@str2num,(content{5}(idx_scanonset)))./10000;
    onsets.targets = cellfun(@str2num,(content{5}(strcmp(content{4},'65') | strcmp(content{4},'75') | strcmp(content{4},'85')| strcmp(content{4},'95'))))./10000 - cellfun(@str2num,(content{5}(idx_scanonset)))./10000;
        
    % SCANS  matching with log files. Assumes there is only with nifti in
    % and that it corresponds to our selected log files!
     mrfilename = dir([paths.mri,'\epis\',currsubject,'\ART\vs6wuamr*.nii']);
     scans =  cellstr(spm_select('ExtFPList',mrfilename.folder, mrfilename.name, Inf))  ;

     % Read the corresponding RP file
      rpfile = dir([paths.mri,'\**\epis\',currsubject,'\rp_amr*.txt']);
      formatSpec = '%16f%16f%16f%16f%16f%16f%[^\n\r]';
      fileID1 = fopen([rpfile.folder,'\',rpfile.name],'r');
      rpdat = textscan(fileID1, formatSpec, 'Delimiter', '', 'WhiteSpace', '', 'TextType', 'string',  'ReturnOnError', false);
      fclose(fileID1);
       
      % Read flagged bad scans (if file found, else create a vector of zeros) 
       badscans = dir([paths.mri,'\epis\',currsubject,'\ART\*flagscans_inBlock.mat']);
       if ~isempty(badscans) % If it doesn't find a flagscan file it will use zeroes
           load([badscans.folder,'\',badscans.name]);  % load variable Regr_badscans from file
           logInfBadscans = [badscans.folder,'\',badscans.name];  
      else 
           Regr_badscans = zeros(nscans,1);   
           logInfBadscans ='No bad scans file'; 
       end
        
        % Merge RP and Flagscans and save table in txt 
         multireg =  [rpdat{1},rpdat{2},rpdat{3},rpdat{4},rpdat{5},rpdat{6},Regr_badscans];
         writetable(cell2table(num2cell(multireg)),[pathSubject,'\multiReg.txt'],'WriteVariableNames',false)
 
   %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%% SPECIFY 1ST LEVEL %%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % define subject path
    matlabbatch{1}.spm.stats.fmri_spec.dir = cellstr(pathSubject);
    matlabbatch{1}.spm.stats.fmri_spec.timing.units = 'secs';
    matlabbatch{1}.spm.stats.fmri_spec.timing.RT = 1.250;
    matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = 42;
    matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = 21;
    % 
    matlabbatch{1}.spm.stats.fmri_spec.sess(1).scans = cellstr(scans);
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

    matlabbatch{1}.spm.stats.fmri_spec.sess(1).multi = {''};
    matlabbatch{1}.spm.stats.fmri_spec.sess(1).regress = struct('name', {}, 'val', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess(1).multi_reg = cellstr([pathSubject,'\multiReg.txt']);

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
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.name = 'FF learned > Letter';
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.weights = [-1 1 0 0 0];
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
    
    matlabbatch{3}.spm.stats.con.consess{2}.tcon.name = 'FF learned > FF familiar';
    matlabbatch{3}.spm.stats.con.consess{2}.tcon.weights = [0 1 -1 0 0];
    matlabbatch{3}.spm.stats.con.consess{2}.tcon.sessrep = 'none';
    
    matlabbatch{3}.spm.stats.con.consess{3}.tcon.name = 'FF learned > FF new';
    matlabbatch{3}.spm.stats.con.consess{3}.tcon.weights = [0 1 0 -1 0];
    matlabbatch{3}.spm.stats.con.consess{3}.tcon.sessrep = 'none';
    
    matlabbatch{3}.spm.stats.con.consess{4}.tcon.name = 'Letter > FF familiar';
    matlabbatch{3}.spm.stats.con.consess{4}.tcon.weights = [1 0 -1 0 0];
    matlabbatch{3}.spm.stats.con.consess{4}.tcon.sessrep = 'none';
    
    matlabbatch{3}.spm.stats.con.consess{5}.tcon.name = 'Letter > FF new';
    matlabbatch{3}.spm.stats.con.consess{5}.tcon.weights = [1 0 0 -1 0];
    matlabbatch{3}.spm.stats.con.consess{5}.tcon.sessrep = 'none';
    
    matlabbatch{3}.spm.stats.con.consess{6}.tcon.name = 'FF learned > Baseline';
    matlabbatch{3}.spm.stats.con.consess{6}.tcon.weights = [0 1 0 0 0];
    matlabbatch{3}.spm.stats.con.consess{6}.tcon.sessrep = 'none';
    
    matlabbatch{3}.spm.stats.con.consess{7}.tcon.name = 'Letter > Baseline';
    matlabbatch{3}.spm.stats.con.consess{7}.tcon.weights = [1 0 0 0 0];
    matlabbatch{3}.spm.stats.con.consess{7}.tcon.sessrep = 'none';
    
    matlabbatch{3}.spm.stats.con.consess{8}.tcon.name = 'FFfamiliar > Baseline';
    matlabbatch{3}.spm.stats.con.consess{8}.tcon.weights = [0 0 1 0 0];
    matlabbatch{3}.spm.stats.con.consess{8}.tcon.sessrep = 'none';
    
    matlabbatch{3}.spm.stats.con.consess{9}.tcon.name = 'FFnew > Baseline';
    matlabbatch{3}.spm.stats.con.consess{9}.tcon.weights = [0 0 0 1 0];
    matlabbatch{3}.spm.stats.con.consess{9}.tcon.sessrep = 'none';

  %% RUN 
    disp(['_m_d[^_^]b_m Start ',currsubject,'...analysis will be saved in ', pathSubject])
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     spm_jobman('run',matlabbatch);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    clear matlabbatch
  
    disp('done.')
    clear scans
end

aaaa
