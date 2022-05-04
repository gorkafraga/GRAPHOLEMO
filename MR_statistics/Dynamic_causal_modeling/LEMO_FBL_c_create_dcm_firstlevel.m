% 
% Define subjects
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
paths.data =  'O:\studies\allread\mri\analyses_NF\rlddm_analyses_NF\RLDDM\mri_analyses\normPerf81\AR_rlddm_v11\1Lv_mopa\1Lv_GLM0_mopa_onesession\';

% start script
prompt = sprintf('Path is: %s  Are you sure? Y/N [N]: ',paths.data);
str = input(prompt,'s');
if isempty(str) | strcmp(str,'n') | strcmp(str,'no') | strcmp(str,'No')
    str = 'N';
end
if strcmp(str,'N')
    fprintf('Abort.\n');
    return
end

regions = {  'VOI_PUT_masked_1.mat',...
             'VOI_VWFA_1.mat',...
             'VOI_PAC_1.mat',...
             'VOI_STS_1.mat'
             };

batches = {};
for s = 1:numel(subjects)
    clear DCM xY;
    
    subDir = fullfile(paths.data,subjects{s});
    load(fullfile(subDir,'SPM.mat'));
    cd(subDir);
    % Load regions of interest
    %--------------------------------------------------------------------------
    for r = 1:numel(regions)
        % load VOI from _2
        load(fullfile(paths.data,subjects{s},regions{r}),'xY');
        DCM.xY(r) = xY;  
    end
    
    DCM.n = length(DCM.xY);      % number of regions
    DCM.v = length(DCM.xY(1).u); % number of time points    
    DCM.Y.dt  = SPM.xY.RT;
    DCM.Y.X0  = DCM.xY(1).X0;

    for i = 1:DCM.n
        DCM.Y.y(:,i)  = DCM.xY(i).u;
        DCM.Y.name{i} = DCM.xY(i).name;
    end
    
    Y  = DCM.Y; % responses
    v  = DCM.v; % number of scans
    n  = DCM.n;    
    
    DCM.Y.Q    = spm_Ce(ones(1,n)*v);
    
     % Experimental inputs
    %--------------------------------------------------------------------------
    DCM.U.dt   =  SPM.Sess.U(1).dt;
    DCM.U.name = [SPM.Sess.U.name];
    DCM.U.u    = [SPM.Sess.U(1).u(33:end,1) ... % All stimulus cues
                  SPM.Sess.U(1).u(33:end,2) ... % AS
                 % SPM.Sess.U(2).u(33:end,1) ... % All feedback 
                 % SPM.Sess.U(2).u(33:end,2) ... % PE
                  ];
 
    % A-Matrix: fully connected audiovisual regions
    DCM.a = [ 1 0 0 0
              0 1 1 1
              0 1 1 1
              0 1 1 1 ];
    
    % C-Matrix: define inputs in sensory areas + putamen
    % columns = inputs (DCM.U.u); rows = regions
    DCM.c = [0 1  
             1 0 
             1 0 
             0 0 ];
    
    % No linear modulations
    DCM.b  = zeros(n,n,2);
    
    % Non-linear effects
    % 1st region (Putamen, idx 3) modulates sensory regions and integration
    % read: "connection from col index to row idx"
    DCM.d = zeros(n,n,n);
    DCM.d(4,2,1) = 1;
    DCM.d(4,3,1) = 1;
    DCM.d(3,4,1) = 1;
    DCM.d(2,4,1) = 1;
    DCM.d(3,2,1) = 1;
    DCM.d(2,3,1) = 1;
    
    DCM.TE     = 0.035;
    DCM.delays = repmat(SPM.xY.RT/2,DCM.n,1);
    
    DCM.options.nonlinear  = 1; % enable non-linear DCM (with D-matrix)
    DCM.options.two_state  = 0; % enable extended neural model with two possible states
    DCM.options.stochastic = 0; % stochastic DCM (previously used for resting-state, use CSD estimation now instead!)
    DCM.options.nograph    = 1;
    DCM.options.centre     = 1;

    save(fullfile(paths.data,subjects{s},'DCM'),'DCM'); 
end