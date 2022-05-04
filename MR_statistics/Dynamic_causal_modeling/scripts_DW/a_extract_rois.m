% Define subjects
%% POPUP Select SUBJECTS and BLOCKS from masterfile columns 
masterfile =    'N:\Users\nfrei\AllRead\Analyses\Master_file_learning_nf.xlsx';
T =             readtable(masterfile,'sheet','Lists_subsamples'); 
%[indx,tf] =     listdlg('PromptString','Select a list of participants:','ListString', T.Properties.VariableNames); % popup 
%groupName =     T.Properties.VariableNames(indx);
indx = 11;
Tcolumn =       T{:,indx};
subjects =      Tcolumn(~cellfun('isempty',Tcolumn))';


% folder to write out data
paths.out = 'O:\studies\allread\mri\analyses_NF\rlddm_analyses_NF\RLDDM\mri_analyses\normPerf81\AR_rlddm_v11\1Lv_mopa\1Lv_GLM0_mopa_onesession\';
paths.data = paths.out;

% folder to get data (onesession GLM)
paths.glm_data = 'O:\studies\allread\mri\analyses_NF\rlddm_analyses_NF\RLDDM\mri_analyses\normPerf81\AR_rlddm_v11\1Lv_mopa\1Lv_GLM0_mopa\';

% labels for regions
rois.labels = {
    'PUT_masked',...
    'VWFA',...
    'PAC',...
    'STS'
};

% coordinates [x y z] for each region (in order)
% come from 2nd-level analysis
rois.coord = {
    [-26 3 1]    
    [-41 -66 -12]
    [-47 -21 6]
    [-65 -24 9]
};

% masks for regions (optional), provide empty string ('') if no mask is
% used
rois.mask = {
    'O:\studies\pmdd\mri\template\atlas\pmdd\rPutamen_LR.nii,1',...
    '',...
    '',...
    ''
};

% We will save all extraction scripts in 'batches' to be able to run them in parallel 
batches = {};


for s = 1:length(subjects)
    for r = 1:length(rois.labels)
        clear matlabbatch
        matlabbatch{1}.spm.util.voi.spmmat = {fullfile(paths.data,subjects{s},'SPM.mat')};
        
        % # of Effects of interest F-contrast
        matlabbatch{1}.spm.util.voi.adjust = 1;
        
        % which sessions to extract?
        matlabbatch{1}.spm.util.voi.session = 1;

        % includes coordinates in names
        % voi_name = [rois.labels{r} '_' num2str(rois.coord{r}(1)) '_' num2str(rois.coord{r}(2)) '_' num2str(rois.coord{r}(3)) ];
        % without coordinates
        voi_name = [rois.labels{r}];
        
        matlabbatch{1}.spm.util.voi.name = voi_name;
        matlabbatch{1}.spm.util.voi.roi{1}.spm.spmmat = {fullfile(paths.glm_data,subjects{s},'SPM.mat')};
        
        % choose contrast for ROIs
        if r == 1
            matlabbatch{1}.spm.util.voi.roi{1}.spm.contrast = 6; % 6 = Stimpos AS 
        else
            matlabbatch{1}.spm.util.voi.roi{1}.spm.contrast = 2; % 2 = stimulus onset
        end
        
        
        matlabbatch{1}.spm.util.voi.roi{1}.spm.conjunction = 1;
        matlabbatch{1}.spm.util.voi.roi{1}.spm.threshdesc = 'none';
        matlabbatch{1}.spm.util.voi.roi{1}.spm.thresh = 0.05;
        matlabbatch{1}.spm.util.voi.roi{1}.spm.extent = 0;
        matlabbatch{1}.spm.util.voi.roi{1}.spm.mask = struct('contrast', {}, 'thresh', {}, 'mtype', {});
        
        if (strcmp(rois.mask{r},''))
                % search sphere, radius = 6mm
                matlabbatch{1}.spm.util.voi.roi{2}.sphere.centre = rois.coord{r};
                matlabbatch{1}.spm.util.voi.roi{2}.sphere.radius = 12; % search sphere
                matlabbatch{1}.spm.util.voi.roi{2}.sphere.move.fixed = 1;
                matlabbatch{1}.spm.util.voi.roi{3}.sphere.centre = [0 0 0];
                matlabbatch{1}.spm.util.voi.roi{3}.sphere.radius = 6; % extraction sphere
                matlabbatch{1}.spm.util.voi.roi{3}.sphere.move.local.spm = 1;
                matlabbatch{1}.spm.util.voi.roi{3}.sphere.move.local.mask = 'i2';
                matlabbatch{1}.spm.util.voi.expression = 'i1&i3';
        else
                % search in anatomical mask
                matlabbatch{1}.spm.util.voi.roi{2}.mask.image = cellstr(rois.mask{r});
                matlabbatch{1}.spm.util.voi.roi{2}.mask.threshold = 0;

                matlabbatch{1}.spm.util.voi.expression = 'i1&i2';
        end

        
        
        batches{s*length(rois.coord)+r-length(rois.coord)} = matlabbatch;
      %  batches{s*length(1)+r-length(1)} = matlabbatch;
    end     
end

return

% spm_jobman('interactive',batches{i});
  if isempty(gcp('nocreate'))
      parpool(8);
  end
%  
  parfor i = 1:length(batches)
      spm_jobman('run',batches{i});
  end    
