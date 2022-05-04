subjects = {};
excludes = {'test23'};
for i=[ 5:27]
    sub = sprintf('test%02d',i);
    if ~any(strcmp(excludes,sub))
        subjects{end + 1} = sub; 
    end    
end
subjects{end + 1} = 'test99';
for i=[ 1:10]
    sub = sprintf('biokurs18-%02d',i);
    if ~any(strcmp(excludes,sub))
        subjects{end + 1} = sub; 
    end    
end
paths.data = 'O:\studies\pmdd\mri\analysis\dcm.sub\';
rois_coord = {
      [-3 50 -2],
      [21 -10 -14],
      [47 30 8]
};
rois_names = {
     'ACC',...
     'AMY',...
     'IFG'
};

batches = {};
for s = 1:length(subjects)
    for r = 1:length(rois_names)
        clear matlabbatch
        matlabbatch{1}.spm.util.voi.spmmat = {fullfile(paths.data,subjects{s},'SPM.mat')};
        matlabbatch{1}.spm.util.voi.adjust = 1;
        matlabbatch{1}.spm.util.voi.session = 1;

        voi_name = [rois_names{r} '_' num2str(rois_coord{r}(1)) '_' num2str(rois_coord{r}(2)) '_' num2str(rois_coord{r}(3)) ];

        matlabbatch{1}.spm.util.voi.name = voi_name;
        matlabbatch{1}.spm.util.voi.roi{1}.spm.spmmat = {fullfile(paths.data,subjects{s},'SPM.mat')};
        if r == 1
            matlabbatch{1}.spm.util.voi.roi{1}.spm.contrast = 2; 
        else
            matlabbatch{1}.spm.util.voi.roi{1}.spm.contrast = 7;
        end    
        matlabbatch{1}.spm.util.voi.roi{1}.spm.conjunction = 1;
        matlabbatch{1}.spm.util.voi.roi{1}.spm.threshdesc = 'none';
        matlabbatch{1}.spm.util.voi.roi{1}.spm.thresh = 0.05;
        matlabbatch{1}.spm.util.voi.roi{1}.spm.extent = 0;
        matlabbatch{1}.spm.util.voi.roi{1}.spm.mask = struct('contrast', {}, 'thresh', {}, 'mtype', {});
        matlabbatch{1}.spm.util.voi.roi{2}.sphere.centre = rois_coord{r};
        matlabbatch{1}.spm.util.voi.roi{2}.sphere.radius = 12;
        matlabbatch{1}.spm.util.voi.roi{2}.sphere.move.fixed = 1;
        matlabbatch{1}.spm.util.voi.roi{3}.sphere.centre = [0 0 0];
        matlabbatch{1}.spm.util.voi.roi{3}.sphere.radius = 6;
        matlabbatch{1}.spm.util.voi.roi{3}.sphere.move.local.spm = 1;
        matlabbatch{1}.spm.util.voi.roi{3}.sphere.move.local.mask = 'i2';
        matlabbatch{1}.spm.util.voi.expression = 'i1&i3';
        batches{s*length(rois_coord)+r-length(rois_coord)} = matlabbatch;
    end     
end
if isempty(gcp('nocreate'))
    parpool(8);
end
parfor i = 1:length(batches)
    spm_jobman('run',batches{i});
end    