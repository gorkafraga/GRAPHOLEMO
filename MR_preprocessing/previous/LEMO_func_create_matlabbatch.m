function [matlabbatch] = LEMO_func_create_matlabbatch(paths_task,currTask,currsubject,anatTemplate)
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
b0Dir =[paths_task,currsubject,'\func\b0\']; %b0Dir =[paths.task,'b0\',currsubject];
epiDir = [paths_task,currsubject,'\func\epis\']; %epiDir = [paths.task,'epis\',currsubject];
t1Dir = [paths_task,currsubject,'\anat\']; %t1Dir = [paths.task,'t1w\',currsubject];

%% Task-specific parameters
%---------------------------------------------------------
b0 = struct(); 
b0.current = cellstr(spm_select('FPList', b0Dir, '^vdm5.*.nii$'));

scansList = [];
if contains(currTask,'fbl','IgnoreCase',true)
    scansList = { cellstr(spm_select('ExtFPList',epiDir, '^mr.*.fbl.*.nii$', Inf)) };
    nslices = 32;
    tr = 1.000; %sec
    blocks = 1;
    timings = [fliplr(round([0:31.25*2:937.5])),fliplr(round([0:31.25*2:937.5]))]; %31.25 because tr/nslices = 1000 ms/32, 937.5 because 1000-31.25*2
    epifactor  = 31; % EPI factor
    scanresolution = 62; % (y value of scan resolution in .par file)
    water_fat_shift_pixel = 12.48; %12.47     
    voxelSize = 3;
    smoothSize = 6; % smoothing factor in mm
  
elseif contains(currTask,'symctrl','IgnoreCase',true)
    scansList = { cellstr(spm_select('ExtFPList', epiDir, '^mr.*.symcontrol.*.nii$', Inf)) };
    nslices = 42;
    tr = 1.250; %sec
    blocks = 1; 
    timings = [fliplr(round([0:29.76*2:1190.48])),fliplr(round([0:29.76*2:1190.48]))]; %1257/42 = 29.76, 1250-29.76*2=1190.48
    epifactor  = 31; % EPI factor
    scanresolution = 62; % (y value of scan resolution in .par file)
    water_fat_shift_pixel = 8.91;  
    voxelSize = 3;
    smoothSize = 6; % smoothing factor in mm  

% elseif contains(currTask,'learn_1')
%     scansList = { cellstr(spm_select('ExtFPList', epiDir, '^mr.*.epi_learn.*.nii$', Inf)) };
%     nslices = 42;
%     tr = 1.330;
%     blocks = 1; 
%     timings = [fliplr(round([0:31.66*2:1298.33])),fliplr(round([0:31.66*2:1298.33]))];
%     epifactor  = 31; % EPI factor
%     scanresolution = 62; % (y value of scan resolution in .par file)
%     water_fat_shift_pixel = 12.47;  
%     voxelSize = 3;
%     smoothSize = 6; % smoothing factor in mm

 
end
    
%% PARALLEL SLICE TIMING CORRECTION
%-----------------------------------
    matlabbatch{1}.spm.temporal.st.scans = scansList;
    matlabbatch{1}.spm.temporal.st.nslices = nslices;
    matlabbatch{1}.spm.temporal.st.so = timings;
    matlabbatch{1}.spm.temporal.st.refslice = matlabbatch{1}.spm.temporal.st.so(ceil(length(matlabbatch{1}.spm.temporal.st.so)/4)); % find middle slice timing. Depends on the multiband factor.
    matlabbatch{1}.spm.temporal.st.tr = tr;
    matlabbatch{1}.spm.temporal.st.ta = 0; %ta= tr - tr/nslices.(time of acquisition of one slice). 0 means that is not used because we use 'timings' in so. 
    matlabbatch{1}.spm.temporal.st.prefix = 'a';

    %% SPATIAL REALIGNMENT  AND WRAP
%-----------------------------------
    matlabbatch{2}.spm.spatial.realignunwarp.data(1).scans(1) = cfg_dep('Slice Timing: Slice Timing Corr. Images (Sess 1)', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('()',{1}, '.','files'));
    matlabbatch{2}.spm.spatial.realignunwarp.data(1).pmscan = b0.current;
    matlabbatch{2}.spm.spatial.realignunwarp.eoptions.quality = 1;
    matlabbatch{2}.spm.spatial.realignunwarp.eoptions.sep = 4;
    matlabbatch{2}.spm.spatial.realignunwarp.eoptions.fwhm = 5;
    matlabbatch{2}.spm.spatial.realignunwarp.eoptions.rtm = 1;
    matlabbatch{2}.spm.spatial.realignunwarp.eoptions.einterp = 7;
    matlabbatch{2}.spm.spatial.realignunwarp.eoptions.ewrap = [0 1 0];
    matlabbatch{2}.spm.spatial.realignunwarp.eoptions.weight = '';
    matlabbatch{2}.spm.spatial.realignunwarp.uweoptions.basfcn = [12 12];
    matlabbatch{2}.spm.spatial.realignunwarp.uweoptions.regorder = 1;
    matlabbatch{2}.spm.spatial.realignunwarp.uweoptions.lambda = 100000;
    matlabbatch{2}.spm.spatial.realignunwarp.uweoptions.jm = 0;
    matlabbatch{2}.spm.spatial.realignunwarp.uweoptions.fot = [4 5];
    matlabbatch{2}.spm.spatial.realignunwarp.uweoptions.sot = [];
    matlabbatch{2}.spm.spatial.realignunwarp.uweoptions.uwfwhm = 4;
    matlabbatch{2}.spm.spatial.realignunwarp.uweoptions.rem = 1;
    matlabbatch{2}.spm.spatial.realignunwarp.uweoptions.noi = 2;
    matlabbatch{2}.spm.spatial.realignunwarp.uweoptions.expround = 'Average';
    matlabbatch{2}.spm.spatial.realignunwarp.uwroptions.uwwhich = [2 1];
    matlabbatch{2}.spm.spatial.realignunwarp.uwroptions.rinterp = 7;
    matlabbatch{2}.spm.spatial.realignunwarp.uwroptions.wrap = [0 1 0];
    matlabbatch{2}.spm.spatial.realignunwarp.uwroptions.mask = 1;
    matlabbatch{2}.spm.spatial.realignunwarp.uwroptions.prefix = 'u';
   %% Segmentation  (time consuming. note if running several task batches in parallel may crash)
    %------------------------------------------------------------------------------------------------ 
   %find tissues
    matlabbatch{3}.spm.spatial.preproc.channel.vols = cellstr(spm_select('FPList',t1Dir, '^mr.*.t1w.*.nii'));
    matlabbatch{3}.spm.spatial.preproc.channel.biasreg = 0.001;
    matlabbatch{3}.spm.spatial.preproc.channel.biasfwhm = 60;
    matlabbatch{3}.spm.spatial.preproc.channel.write = [0 1];
    matlabbatch{3}.spm.spatial.preproc.tissue(1).tpm = { [anatTemplate,',1']};
    matlabbatch{3}.spm.spatial.preproc.tissue(1).ngaus = 1;
    matlabbatch{3}.spm.spatial.preproc.tissue(1).native = [1 1];
    matlabbatch{3}.spm.spatial.preproc.tissue(1).warped = [0 0];
    matlabbatch{3}.spm.spatial.preproc.tissue(2).tpm = { [anatTemplate,',2']};
    matlabbatch{3}.spm.spatial.preproc.tissue(2).ngaus = 1;
    matlabbatch{3}.spm.spatial.preproc.tissue(2).native = [1 1];
    matlabbatch{3}.spm.spatial.preproc.tissue(2).warped = [0 0];
    matlabbatch{3}.spm.spatial.preproc.tissue(3).tpm = { [anatTemplate,',3']};
    matlabbatch{3}.spm.spatial.preproc.tissue(3).ngaus = 2;
    matlabbatch{3}.spm.spatial.preproc.tissue(3).native = [1 0];
    matlabbatch{3}.spm.spatial.preproc.tissue(3).warped = [0 0];
    matlabbatch{3}.spm.spatial.preproc.tissue(4).tpm = {[anatTemplate,',4']};
    matlabbatch{3}.spm.spatial.preproc.tissue(4).ngaus = 3;
    matlabbatch{3}.spm.spatial.preproc.tissue(4).native = [0 0];
    matlabbatch{3}.spm.spatial.preproc.tissue(4).warped = [0 0];
    matlabbatch{3}.spm.spatial.preproc.tissue(5).tpm = {[anatTemplate,',5']};
    matlabbatch{3}.spm.spatial.preproc.tissue(5).ngaus = 4;
    matlabbatch{3}.spm.spatial.preproc.tissue(5).native = [0 0];
    matlabbatch{3}.spm.spatial.preproc.tissue(5).warped = [0 0];
    matlabbatch{3}.spm.spatial.preproc.tissue(6).tpm = {[anatTemplate,',6']}; % ngaus OK **** ? 
    matlabbatch{3}.spm.spatial.preproc.tissue(6).ngaus = 2;
    matlabbatch{3}.spm.spatial.preproc.tissue(6).native = [0 0];
    matlabbatch{3}.spm.spatial.preproc.tissue(6).warped = [0 0];
    matlabbatch{3}.spm.spatial.preproc.warp.mrf = 1;
    matlabbatch{3}.spm.spatial.preproc.warp.cleanup = 1;
    matlabbatch{3}.spm.spatial.preproc.warp.reg = [0 0.001 0.5 0.05 0.2];
    matlabbatch{3}.spm.spatial.preproc.warp.affreg = 'mni';    % MNI here correct ****? 
    matlabbatch{3}.spm.spatial.preproc.warp.fwhm = 0;
    matlabbatch{3}.spm.spatial.preproc.warp.samp = 3;
    matlabbatch{3}.spm.spatial.preproc.warp.write = [0 1];
    
    matlabbatch{4}.cfg_basicio.file_dir.cfg_fileparts.files(1) = cfg_dep('Segment: Bias Corrected (1)', substruct('.','val', '{}',{3}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','channel', '()',{1}, '.','biascorr', '()',{':'}));
    matlabbatch{5}.spm.util.imcalc.input(1) = cfg_dep('Segment: Bias Corrected (1)', substruct('.','val', '{}',{3}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','channel', '()',{1}, '.','biascorr', '()',{':'}));
    matlabbatch{5}.spm.util.imcalc.input(2) = cfg_dep('Segment: c1 Images', substruct('.','val', '{}',{3}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','tiss', '()',{1}, '.','c', '()',{':'}));
    matlabbatch{5}.spm.util.imcalc.input(3) = cfg_dep('Segment: c2 Images', substruct('.','val', '{}',{3}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','tiss', '()',{2}, '.','c', '()',{':'}));
    matlabbatch{5}.spm.util.imcalc.input(4) = cfg_dep('Segment: c3 Images', substruct('.','val', '{}',{3}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','tiss', '()',{3}, '.','c', '()',{':'}));
    matlabbatch{5}.spm.util.imcalc.output = '';
    matlabbatch{5}.spm.util.imcalc.outdir(1) = cfg_dep('Get Pathnames: Directories (unique)', substruct('.','val', '{}',{4}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','up'));
    matlabbatch{5}.spm.util.imcalc.expression = '((i2 + i3 + i4)>0.9) .* i1';
    matlabbatch{5}.spm.util.imcalc.var = struct('name', {}, 'value', {});
    matlabbatch{5}.spm.util.imcalc.options.dmtx = 0;
    matlabbatch{5}.spm.util.imcalc.options.mask = 0;
    matlabbatch{5}.spm.util.imcalc.options.interp = -7;
    matlabbatch{5}.spm.util.imcalc.options.dtype = 16;

    %% CORREGISTRATION 
    %--------------------------
    matlabbatch{6}.spm.spatial.coreg.estimate.ref(1) = cfg_dep('Image Calculator: ImCalc Computed Image: Brain', substruct('.','val', '{}',{5}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','files'));% t1 image as reference
    matlabbatch{6}.spm.spatial.coreg.estimate.source(1) = cfg_dep('Realign & Unwarp: Unwarped Mean Image', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','meanuwr')); %mean functional image as source. Transformation to bring to T1 space. 
    matlabbatch{6}.spm.spatial.coreg.estimate.other(1) = cfg_dep('Realign & Unwarp: Unwarped Images (Sess 1)', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','sess', '()',{1}, '.','uwrfiles')); % all individual volumes to be transformed to t1 spaces
    matlabbatch{6}.spm.spatial.coreg.estimate.eoptions.cost_fun = 'nmi';
    matlabbatch{6}.spm.spatial.coreg.estimate.eoptions.sep = [4 2];
    matlabbatch{6}.spm.spatial.coreg.estimate.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
    matlabbatch{6}.spm.spatial.coreg.estimate.eoptions.fwhm = [7 7];

    %% Normalization and smoothing 
    %(check files after smoothing with mean smooth image!!!. There may be black lines due to problems with the network. Best to have the data stored locally for this step)
    %------------------------------------------------------------------------------------
    matlabbatch{7}.spm.spatial.normalise.write.subj.def(1) = cfg_dep('Segment: Forward Deformations', substruct('.','val', '{}',{3}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','fordef', '()',{':'}));
    matlabbatch{7}.spm.spatial.normalise.write.subj.resample(1) = cfg_dep('Coregister: Estimate: Coregistered Images', substruct('.','val', '{}',{6}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','cfiles'));
    matlabbatch{7}.spm.spatial.normalise.write.woptions.bb = [-90 -126 -72
                                                                91 91 109];  %keep this 'box'  in 2 lines!
    matlabbatch{7}.spm.spatial.normalise.write.woptions.vox = [voxelSize voxelSize voxelSize]; % change this 
    matlabbatch{7}.spm.spatial.normalise.write.woptions.interp = 7;
    matlabbatch{7}.spm.spatial.normalise.write.woptions.prefix = 'w';  
    matlabbatch{8}.spm.spatial.smooth.data(1) = cfg_dep('Normalise: Write: Normalised Images (Subj 1)', substruct('.','val', '{}',{7}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('()',{1}, '.','files'));
    matlabbatch{8}.spm.spatial.smooth.fwhm = [smoothSize smoothSize smoothSize]; 
    matlabbatch{8}.spm.spatial.smooth.dtype = 0;
    matlabbatch{8}.spm.spatial.smooth.im = 0;
    matlabbatch{8}.spm.spatial.smooth.prefix = ['s',num2str(smoothSize)];
    matlabbatch{9}.spm.spatial.normalise.write.subj.def(1) = cfg_dep('Segment: Forward Deformations', substruct('.','val', '{}',{3}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','fordef', '()',{':'}));
    matlabbatch{9}.spm.spatial.normalise.write.subj.resample(1) = cfg_dep('Image Calculator: ImCalc Computed Image: Brain', substruct('.','val', '{}',{5}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','files'));
    matlabbatch{9}.spm.spatial.normalise.write.woptions.bb = [-90 -126 -72
                                                                91 91 109]; %keep this in 2 lines!
    matlabbatch{9}.spm.spatial.normalise.write.woptions.vox = [1 1 1];
    matlabbatch{9}.spm.spatial.normalise.write.woptions.interp = 7;
    matlabbatch{9}.spm.spatial.normalise.write.woptions.prefix = 'w';

    
return;