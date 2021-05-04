function [matlabbatch] = LEMO_func_coregNormalization(b0Dir,epiDir,t1Dir,currTask,anatTemplate)
% MR PREPROCESSING PIPELINE 
% ==============================================================
%creates a matlabbatch file that can be executed with the Batch Editor / spm_jobman. 
%-----------------------------------------------------------------------
% Needs paths to b0, T1 and epi data.
%(c) David Willinger. Gorka Fraga Gonzalez (March 2020)
 % function input check
if nargin < 1
    sprintf('No paths provided!');
    return;
else
end
        if contains(currTask,'fbl','IgnoreCase',true)
            nslices = 32;
            tr = 1.000; %sec
            timings = [fliplr(round([0:31.25*2:937.5])),fliplr(round([0:31.25*2:937.5]))]; %31.25 because tr/nslices = 1000 ms/32, 937.5 because 1000-31.25*2
             voxelSize = 3;
            smoothSize = 6; % smoothing factor in mm

        elseif contains(currTask,'symctrl','IgnoreCase',true)
            nslices = 40;
            tr = 1.250; %sec
            timings = [fliplr(round([0:29.76*2:1190.48])),fliplr(round([0:29.76*2:1190.48]))]; %1257/42 = 29.76, 1250-29.76*2=1190.48
            voxelSize = 3;
            smoothSize = 6; % smoothing factor in mm  

        end
        
    matlabbatch{1}.spm.spatial.coreg.estimate.ref(1) = cellstr(spm_select('FPList', t1Dir, '^im.*.nii$')); 
    matlabbatch{1}.spm.spatial.coreg.estimate.source(1) = cellstr(spm_select('FPList', epiDir, '^meanua.*.nii$')); 
    matlabbatch{1}.spm.spatial.coreg.estimate.other{1} = { cellstr(spm_select('ExtFPList', epiDir,'^ua.*.nii', Inf)) }; 
     
    matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.cost_fun = 'nmi';
    matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.sep = [4 2];
    matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
    matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.fwhm = [7 7];
    %% Normalization and smoothing 
    %(check files after smoothing with mean smooth image!!!. There may be black lines due to problems with the network. Best to have the data stored locally for this step)
    %------------------------------------------------------------------------------------
    matlabbatch{2}.spm.spatial.normalise.write.subj.def(1) = cellstr(spm_select('FPList', t1Dir, '^y_.*.nii$')); %cfg_dep('Segment: Forward Deformations', substruct('.','val', '{}',{3}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','fordef', '()',{':'}));
    matlabbatch{2}.spm.spatial.normalise.write.subj.resample(1) = { cellstr(spm_select('ExtFPList', epiDir,'^ua.*.nii', Inf)) } % cfg_dep('Coregister: Estimate: Coregistered Images', substruct('.','val', '{}',{6}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','cfiles'));
    matlabbatch{2}.spm.spatial.normalise.write.woptions.bb = [-90 -126 -72
                                                                91 91 109];  %keep this 'box'  in 2 lines!
    matlabbatch{2}.spm.spatial.normalise.write.woptions.vox = [voxelSize voxelSize voxelSize]; % change this 
    matlabbatch{2}.spm.spatial.normalise.write.woptions.interp = 7;
    matlabbatch{2}.spm.spatial.normalise.write.woptions.prefix = 'w';  
    matlabbatch{3}.spm.spatial.smooth.data(1) = cfg_dep('Normalise: Write: Normalised Images (Subj 1)', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('()',{1}, '.','files'));
    matlabbatch{3}.spm.spatial.smooth.fwhm = [smoothSize smoothSize smoothSize]; 
    matlabbatch{3}.spm.spatial.smooth.dtype = 0;
    matlabbatch{3}.spm.spatial.smooth.im = 0;
    matlabbatch{3}.spm.spatial.smooth.prefix = ['s',num2str(smoothSize)];
    matlabbatch{4}.spm.spatial.normalise.write.subj.def(1) =cellstr(spm_select('FPList', t1Dir, '^y_.*.nii$'));
    matlabbatch{4}.spm.spatial.normalise.write.subj.resample(1) = cellstr(spm_select('FPList', t1Dir, '^im.*.nii$')); 
    matlabbatch{4}.spm.spatial.normalise.write.woptions.bb = [-90 -126 -72
                                                                91 91 109]; %keep this in 2 lines!
    matlabbatch{4}.spm.spatial.normalise.write.woptions.vox = [1 1 1];
    matlabbatch{4}.spm.spatial.normalise.write.woptions.interp = 7;
    matlabbatch{4}.spm.spatial.normalise.write.woptions.prefix = 'w';

    
return;