clear all 
close all
%%%%% EXTRACT ROIS TIME SERIES %%%%%% 
% - Select subjects
% - Define ROI coordinates and labels (well-delimited ROIs may use template masks)
% - Extract time series from first level, specific contrasts

%%  Define subjects
% Select SUBJECTS 
subjects = dir('O:\studies\grapholemo\analysis\LEMO_GFG\mri\1stLevel\FBL_A\1Lv_GLM0_thirds_exMiss\gpl*');
subjects = {subjects.name};
% folder to write out data
paths.data = 'O:\studies\grapholemo\analysis\LEMO_GFG\mri\1stLevel\FBL_A\1Lv_GLM0_thirds_exMiss\';
% folder to get data (onesession GLM)
paths.out= 'O:\studies\grapholemo\analysis\LEMO_GFG\mri\1stLevel\FBL_A\1Lv_GLM0_thirds_exMiss\';
nrun = 1;

%% labels for regions
rois.labels = {
    'LFusi',...
    'RPrecentral',... 
    'RSTG',...
    'LSTG',... 
    'LPutamen',...
    'RPutamen',...
    'LHippocampus',...
    'RHippocampus',... 
    'LCaudate',...
    'RCaudate',...
    'LInsula',...
    'RInsula',...
    'LmidCingulum',...
    'RmidCingulum',...
    'LSupramarginal',...
    'RSupramarginal'
 };

% coordinates [x y z] for each region (in order) 
rois.coord = {
    [-44 -58 -14]    
    [-46 2 24] 
    [54	-24	4]
    [-52 -22 8] 
    [-14 8 -10]
    [26	2 -8]
    [-22 -40 4]
    [22	-32	6] 
    [-12 10 -10]
    [14	10 -10]
    [-38 20	-6]
    [42	18 -6]
    [0 22 38]
    [4 26 40]
    [-62 -44 34]
    [62	-42	34]  
};

% masks for regions (optional), provide empty string ('') if no mask is
% used
rois.mask = {
    '',...
    '',...   
    '',...
    '',...    
    '',...
    '',...
    '',...
    '',...
    '',...
    '',...
    '',...
    '',...
    '',...
    '',...
    '',...
    ''
};

%% We will save all extraction scripts in 'batches' to be able to run them in parallel 
batches = {};
for s = 1:length(subjects)
    for r = 1:length(rois.labels)
        clear matlabbatch
        matlabbatch{1}.spm.util.voi.spmmat = {fullfile(paths.data,subjects{s},'SPM.mat')};
        % # of Effects of interest F-contrast
        matlabbatch{1}.spm.util.voi.adjust = 1;
        % which sessions to extract?
        matlabbatch{1}.spm.util.voi.session = nrun;

        % includes coordinates in names
        % voi_name = [rois.labels{r} '_' num2str(rois.coord{r}(1)) '_' num2str(rois.coord{r}(2)) '_' num2str(rois.coord{r}(3)) ];
        % without coordinates
        voi_name = [rois.labels{r},'_ses',num2str(nrun)];
        
        matlabbatch{1}.spm.util.voi.name = voi_name;
        matlabbatch{1}.spm.util.voi.roi{1}.spm.spmmat = {fullfile(paths.out,subjects{s},'SPM.mat')};
        
        % choose contrast for ROIs
        matlabbatch{1}.spm.util.voi.roi{1}.spm.contrast = 6; % 
        %
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

  
% spm_jobman('interactive',batches{i});
  if isempty(gcp('nocreate'))
      parpool(8);
  end
%  
  parfor i = 1:length(batches)
      spm_jobman('run',batches{i});
  end    
