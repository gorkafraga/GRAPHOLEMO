
clear all 
close all
% EXPORT CLUSTERS FROM RESULTS  WITH CLUSTER EXTENSION CORRECTION - 
% you can use output .nii file in mricrogl
%-----------------------------------------------------------------
%%
tasks = {'FBL_A','FBL_B'};
contrasts = {'con_0002','con_0003','con_0004','con_0005','con_0006','con_0007','con_0008','con_0009'};
% table with extensions assigned to each task and contrast (based on inspection of tables)
clusterExtensions =  {'FBL_A','con_0002',68;...
                        'FBL_A','con_0003',84;...
                        'FBL_A','con_0004',72;...
                        'FBL_A','con_0005',54;...
                        'FBL_A','con_0006',227;...
                        'FBL_A','con_0007',83;...
                        'FBL_A','con_0008',51;...
                        'FBL_A','con_0009',280;...
                        'FBL_B','con_0002',0;...
                        'FBL_B','con_0003',67;...
                        'FBL_B','con_0004',127;...
                        'FBL_B','con_0005',279;...
                        'FBL_B','con_0006',73;...
                        'FBL_B','con_0007',1100;...
                        'FBL_B','con_0008',101;...
                        'FBL_B','con_0009',77};
                        

%%
spm fmri
for t=1:length(tasks)
    currtask = tasks{t};
    for c = 1:length(contrasts)
        currcontrasts = contrasts{c};
        currext = cell2mat(clusterExtensions(find(contains(clusterExtensions(:,1),currtask) & contains(clusterExtensions(:,2),currcontrasts)),3));        
            matlabbatch{1}.spm.stats.results.spmmat = {['O:\studies\grapholemo\analysis\LEMO_GFG\mri\2ndLevel\FeedbackLearning\' currtask '\2Lv_GLM0_thirds_exMiss\',currcontrasts,'\SPM.mat']};
            matlabbatch{1}.spm.stats.results.conspec.titlestr = '';
            matlabbatch{1}.spm.stats.results.conspec.contrasts = Inf;
            matlabbatch{1}.spm.stats.results.conspec.threshdesc = 'none';
            matlabbatch{1}.spm.stats.results.conspec.thresh = 0.001;
            matlabbatch{1}.spm.stats.results.conspec.extent = currext;
            matlabbatch{1}.spm.stats.results.conspec.conjunction = 1;
            matlabbatch{1}.spm.stats.results.conspec.mask.none = 1;
            matlabbatch{1}.spm.stats.results.units = 1;
            matlabbatch{1}.spm.stats.results.export{1}.ps = true;
            matlabbatch{1}.spm.stats.results.export{2}.nary.basename = '_threshClusts';
            matlabbatch{1}.spm.stats.results.export{3}.tspm.basename  = 'threshSPM';
            spm_jobman('run',matlabbatch)
            clear matlabbatch
    end
end