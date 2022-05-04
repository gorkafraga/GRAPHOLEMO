%% POPUP Select SUBJECTS and BLOCKS from masterfile columns 
masterfile =        'N:\Users\nfrei\AllRead\Analyses\Master_file_learning_nf.xlsx';
T =             readtable(masterfile,'sheet','Lists_subsamples'); 
%[indx,tf] =     listdlg('PromptString','Select a list of participants:','ListString', T.Properties.VariableNames); % popup 
%groupName =     T.Properties.VariableNames(indx);
indx = 11;
Tcolumn =       T{:,indx};
subjects =      Tcolumn(~cellfun('isempty',Tcolumn))';
% only subjects, that are not excluded
subjects = subjects(find(~contains(subjects,excludes)));


% SET PATH
paths.data = 'O:\studies\allread\mri\analyses_NF\rlddm_analyses_NF\RLDDM\mri_analyses\normPerf81\AR_rlddm_v11\1Lv_mopa\1Lv_GLM0_mopa_onesession\';


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FIRST LEVEL ANALYSIS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Load the first-level DCM structures into a struct (GCM) with dimension
% models x subjects


dcms = {};
for s = 1:numel(subjects)
        dcms{s,1} = char(fullfile(paths.data,subjects{s},'DCM.mat'));   
end
GCM = cellstr(dcms);

% Comment this if already estimated, uncomment to estimate 1st level (takes
% some hours)
[GCM,M,PEB,HCM] = spm_dcm_peb_fit(GCM(:,1));

%save ('O:\studies\allread\mri\analyses_NF\rlddm_analyses_NF\RLDDM\mri_analyses\normPerf81\AR_rlddm_v11\1Lv_mopa\1Lv_GLM0_mopa_onesession\HCM.mat','HCM') ;


HCM(:,end) = spm_dcm_fmri_check(HCM(:,end));
ve = []; % variance explained & max. parameter
for i = 1:numel(HCM(:,end))
    ve = [ve; HCM{i,end}.diagnostics(1) HCM{i,end}.diagnostics(2)]
end    


spm_dcm_review(HCM{1,1})
spm_dcm_fmri_check(HCM)



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SECOND LEVEL ANALYSIS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% create PEB model
M = struct();

% Design Matrix
M.X = [ones(length(HCM),1)];

% priors
M.alpha = 1;      % optional scaling to specify M.bC [default = 1]
M.beta  = 16;     % optional scaling to specify M.pC [default = 16]
M.hE    = 0;      % 2nd-level prior expectation of log precisions [default: 0]
M.hC    = 1/16;   % 2nd-level prior covariances of log precisions [default: 1/16]
M.Q     = 'all';  % covariance components: {'single','fields','all','none'}

% 1. option: use BMC to find posterior probabilites
% %% not
% [post,exp_r,xp,pxp,bor] = spm_dcm_bmc(PEBs_A);
% 
% Compare nested PEB models. Decide which connections to switch off based on the 
% structure of each template DCM in the GCM cell array. This should have one row 
% and one column per candidate model (it doesn't need to be estimated).

% Get an existing model. We'll use the first subject's DCM as a template
DCM_full = HCM{1};

% IMPORTANT: If the model has already been estimated, clear out the old priors, or changes to DCM.a,b,c will be ignored
if isfield(DCM_full,'M')
    DCM_full = rmfield(DCM_full ,'M');
end

DCM = {};
DCM{1} = DCM_full;
DCM{2} = DCM_full;
DCM{3} = DCM_full;

DCM{1}.d(4,2,1) = 1;
DCM{1}.d(4,3,1) = 0;
DCM{1}.d(3,4,1) = 0;
DCM{1}.d(2,4,1) = 1;
DCM{1}.d(3,2,1) = 0;
DCM{1}.d(2,3,1) = 0;

DCM{2}.d(4,2,1) = 0;
DCM{2}.d(4,3,1) = 1;
DCM{2}.d(3,4,1) = 1;
DCM{2}.d(2,4,1) = 0;
DCM{2}.d(3,2,1) = 0;
DCM{2}.d(2,3,1) = 0;

DCM{3}.d(4,2,1) = 0;
DCM{3}.d(4,3,1) = 0;
DCM{3}.d(3,4,1) = 0;
DCM{3}.d(2,4,1) = 0;
DCM{3}.d(3,2,1) = 1;
DCM{3}.d(2,3,1) = 1;

PEB_D =  spm_dcm_peb(HCM(:,end), M, {'D'});   % Hierarchical (PEB) inversion of DCMs using BMR and VL
[BMA,BMR] = spm_dcm_peb_bmc(PEB_D, DCM(1:3)); % Hierarchical (PEB) model comparison and averaging (2nd level)
spm_dcm_peb_review(BMA,HCM(:,1));             % Review tool for DCM PEB models


% 2. option: use Bayesian model comparison to reduce the full model on a
% per-connection basis
% Rather than copmaring specific hypotheses, we can prune away
% parameters not contributing to the model evidence (POST-HOC search)ed
% 

% A-Matrix
PEB_A =  spm_dcm_peb(HCM(:,end), M, {'A'}); % Hierarchical (PEB) inversion of DCMs using BMR and VL
BMA_A = spm_dcm_peb_bmc(PEB_A);             % Hierarchical (PEB) model comparison and averaging (2nd level)
spm_dcm_peb_review(BMA_A,HCM(:,end));       % Review tool for DCM PEB models

% D-Matrix
PEB_D =  spm_dcm_peb(HCM(:,end), M, {'D'});
BMA_D = spm_dcm_peb_bmc(PEB_D);
spm_dcm_peb_review(BMA_D,HCM(:,end));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Analysis with covariates
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% get behavioral data
PerfTable =             readtable(masterfile,'sheet','behperfmodelpar'); 
PerfTable(find(contains(PerfTable.subjID,excludes)),:) = []; % remove exluded
PerfTable.reading(PerfTable.reading == 2) = 0;
PerfTable.sex = str2num(cell2mat(PerfTable.sex));
contrast = PerfTable.reading.*2-1;

% New design Matrix
M.X = [ones(length(HCM),1) contrast-mean(contrast) PerfTable.handedness PerfTable.sex];
M.Xnames = {'Overall mean','poor > typical','handedness','sex'};

% repeat D-Matrix
PEB_D =  spm_dcm_peb(HCM(:,end), M, {'D'});
BMA_D = spm_dcm_peb_bmc(PEB_D);
spm_dcm_peb_review(BMA_D,HCM(:,end));

% repeat BMS procedure for commonalities and group effect
[BMA,BMR] = spm_dcm_peb_bmc(PEB_D, DCM(1:3));

% When we find an effect, we can use leave-one-out cross-validation to see
% if the effect is large enough to be meaningful. By default, it will try
% to predict the value of the 2nd column (poor vs typical) of the left out subject.
[qE,qC,Q] = spm_dcm_loo(HCM(:,end),M,{'D(4,2,1)'});

