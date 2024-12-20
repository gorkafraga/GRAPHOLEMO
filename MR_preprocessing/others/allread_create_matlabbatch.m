function [matlabbatch] = allread_create_matlabbatch(current_paths,tasklist)
% bio_create_matlabbatch This is the preprocessing pipeline for the MR
% sequence (TR=1000ms). It will create a matlabbatch file that can be
% executed with the Batch Editor / spm_jobman. 
%
%-----------------------------------------------------------------------
%   Example: create_matlabbatch_newseq( paths )
%
%   create_matlabbatch_newseq( paths, b0mapping )
%   paths             - Struct with different paths 
%   paths.epis        - Paths of all the EPIs that need preprocessing
%   paths.b0          - B0 directory
%   paths.structural  - T1 directory
%  See also bio_preproc_par.m 
%(c) David Willinger
%Last edited: 2018/08/02

if nargin < 1
    sprintf('No paths provided!');
    return;
else
    paths = current_paths;
end

b0 = struct();

for k = 1:numel(tasklist)
    c = [];
    if strcmp(tasklist{k},'eread')
        c = { cellstr(spm_select('ExtFPList', strcat(paths.timepoint,paths.epis{1}), '^mr.*(eread)?\.nii$', Inf)) };
        b0.eread = cellstr(spm_select('FPList', paths.b0, '^vdm5_.*._1_b0_eread.*.nii$'));
        nslices = 32;
        tr = 1.000;
        blocks = 1;
        timings = [fliplr(round([0:31.25*2:937.5])),fliplr(round([0:31.25*2:937.5]))];
        
    elseif strcmp(tasklist{k},'learn')
        for block = 1:4
            tmp_scans = cellstr(spm_select('ExtFPList', strcat(paths.timepoint,paths.epis{1}), ['^mr.*(learn)?b' num2str(block) '\.nii$'], Inf));
            if numel(tmp_scans) > 1
                c =  [c; {tmp_scans}];
            end
        end
        b0.learn = cellstr(spm_select('FPList', paths.b0, '^vdm5_.*._1_b0_learn.*.nii$'));
        nslices = 42;
        tr = 1.330;
        blocks = 2;
        timings = [fliplr(round([0:31.66*2:1298.33])),fliplr(round([0:31.66*2:1298.33]))];
        
    elseif strcmp(tasklist{k},'implicit')
        c = { cellstr(spm_select('ExtFPList', strcat(paths.timepoint,paths.epis{1}), '^mr.*(symctrl)?\.nii$', Inf)) };
        b0.implicit = cellstr(spm_select('FPList', paths.b0, '^vdm5_.*._1_b0_symctrl.*.nii$'));
        nslices = 42;
        tr = 1.250;
        blocks = 1;
        timings = [fliplr(round([0:29.76*2:1220.23])),fliplr(round([0:29.76*2:1220.23]))];  
        
    elseif strcmp(tasklist{k},'faceloc')
        c = { cellstr(spm_select('ExtFPList', strcat(paths.timepoint,paths.epis{1}), '^mr.*(localizer)?\.nii$', Inf)) };
        b0.faceloc = cellstr(spm_select('FPList', paths.b0, '^vdm5_.*._1_b0_symctrl.*.nii$'));
        nslices = 42;
        tr = 1.250;
        blocks = 1;
        timings = [fliplr(round([0:29.76*2:1220.23])),fliplr(round([0:29.76*2:1220.23]))];
        
    end
    
    % create one batch for each task
    matlabbatch{k}.spm.temporal.st.scans = c;
    matlabbatch{k}.spm.temporal.st.nslices = nslices;
    matlabbatch{k}.spm.temporal.st.so = timings;
    matlabbatch{k}.spm.temporal.st.refslice = matlabbatch{k}.spm.temporal.st.so(ceil(length(matlabbatch{k}.spm.temporal.st.so)/4));
    matlabbatch{k}.spm.temporal.st.tr = tr;
    matlabbatch{k}.spm.temporal.st.ta = 0;
    matlabbatch{k}.spm.temporal.st.prefix = 'a';
end
task_order  = tasklist;
if contains(paths.epis,'learn')
    task_order{find(strcmp(tasklist,'learn')==1)} = 'learn1';
    task_order = {task_order{1:find(strcmp(task_order,'learn1')==1)}, 'learn2', task_order{find(strcmp(task_order,'learn1')==1)+1:end}};
end
%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% PARALLEL SLICE TIMING CORRECTION
idx = 1;
% change 1:3 depending on amount of tasks
for i = 1:sum(contains(paths.epis,'eread')+contains(paths.epis,'learn')*2+contains(paths.epis,'implicit')+contains(paths.epis,'faceloc'))
    current_scan = task_order{i};
    if  contains(current_scan,'learn1')
        matlabbatch{2}.spm.spatial.realignunwarp.data(i).scans(1) = cfg_dep('Slice Timing: Slice Timing Corr. Images (Sess 1)', substruct('.','val', '{}',{idx}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('()',{1}, '.','files'));
        matlabbatch{2}.spm.spatial.realignunwarp.data(i).pmscan = b0.learn;
    elseif  contains(current_scan,'learn2')
        matlabbatch{2}.spm.spatial.realignunwarp.data(i).scans(1) = cfg_dep('Slice Timing: Slice Timing Corr. Images (Sess 2)', substruct('.','val', '{}',{idx}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('()',{2}, '.','files'));
        matlabbatch{2}.spm.spatial.realignunwarp.data(i).pmscan = b0.learn;
        idx = idx + 1;
    elseif  contains(current_scan,'implicit')
        matlabbatch{2}.spm.spatial.realignunwarp.data(i).scans(1) = cfg_dep(['Slice Timing: Slice Timing Corr. Images (Sess 1, ' task_order{i} ')'], substruct('.','val', '{}',{idx}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('()',{1}, '.','files'));
        matlabbatch{2}.spm.spatial.realignunwarp.data(i).pmscan = b0.implicit;
        idx = idx + 1;
    elseif contains(current_scan,'eread')
        matlabbatch{2}.spm.spatial.realignunwarp.data(i).scans(1) = cfg_dep(['Slice Timing: Slice Timing Corr. Images (Sess 1, ' task_order{i} ')'], substruct('.','val', '{}',{idx}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('()',{1}, '.','files'));
        matlabbatch{2}.spm.spatial.realignunwarp.data(i).pmscan = b0.eread;
        idx = idx + 1;
    elseif contains(current_scan,'faceloc')
        matlabbatch{2}.spm.spatial.realignunwarp.data(i).scans(1) = cfg_dep(['Slice Timing: Slice Timing Corr. Images (Sess 1, ' task_order{i} ')'], substruct('.','val', '{}',{idx}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('()',{1}, '.','files'));
        matlabbatch{2}.spm.spatial.realignunwarp.data(i).pmscan = b0.faceloc;
        idx = idx + 1;
    else
        fprintf('WARNING: FIELDMAP FOR TASK NOT RECOGNIZED: %s\n',current_scan);
    end
end
%matlabbatch{2}.spm.spatial.realignunwarp.data(2).scans(1) = cfg_dep('Slice Timing: Slice Timing Corr. Images (Sess 2)', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('()',{2}, '.','files'));
%matlabbatch{2}.spm.spatial.realignunwarp.data(2).pmscan = {''};
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
matlabbatch{3}.spm.spatial.preproc.channel.vols = cellstr(spm_select('FPList', paths.structural, '^mr.*t1.*.nii'));
matlabbatch{3}.spm.spatial.preproc.channel.biasreg = 0.001;
matlabbatch{3}.spm.spatial.preproc.channel.biasfwhm = 60;
matlabbatch{3}.spm.spatial.preproc.channel.write = [0 1];
matlabbatch{3}.spm.spatial.preproc.tissue(1).tpm = { 'O:\studies\allread\mri\Template_KiGa_T2_T3\TPM_Age7.1526.nii,1' };
matlabbatch{3}.spm.spatial.preproc.tissue(1).ngaus = 1;
matlabbatch{3}.spm.spatial.preproc.tissue(1).native = [1 1];
matlabbatch{3}.spm.spatial.preproc.tissue(1).warped = [0 0];
matlabbatch{3}.spm.spatial.preproc.tissue(2).tpm = { 'O:\studies\allread\mri\Template_KiGa_T2_T3\TPM_Age7.1526.nii,2' };
matlabbatch{3}.spm.spatial.preproc.tissue(2).ngaus = 1;
matlabbatch{3}.spm.spatial.preproc.tissue(2).native = [1 1];
matlabbatch{3}.spm.spatial.preproc.tissue(2).warped = [0 0];
matlabbatch{3}.spm.spatial.preproc.tissue(3).tpm = { 'O:\studies\allread\mri\Template_KiGa_T2_T3\TPM_Age7.1526.nii,3'  };
matlabbatch{3}.spm.spatial.preproc.tissue(3).ngaus = 2;
matlabbatch{3}.spm.spatial.preproc.tissue(3).native = [1 0];
matlabbatch{3}.spm.spatial.preproc.tissue(3).warped = [0 0];
matlabbatch{3}.spm.spatial.preproc.tissue(4).tpm = { 'O:\studies\allread\mri\Template_KiGa_T2_T3\TPM_Age7.1526.nii,4'  };
matlabbatch{3}.spm.spatial.preproc.tissue(4).ngaus = 3;
matlabbatch{3}.spm.spatial.preproc.tissue(4).native = [0 0];
matlabbatch{3}.spm.spatial.preproc.tissue(4).warped = [0 0];
matlabbatch{3}.spm.spatial.preproc.tissue(5).tpm = { 'O:\studies\allread\mri\Template_KiGa_T2_T3\TPM_Age7.1526.nii,5' };
matlabbatch{3}.spm.spatial.preproc.tissue(5).ngaus = 4;
matlabbatch{3}.spm.spatial.preproc.tissue(5).native = [0 0];
matlabbatch{3}.spm.spatial.preproc.tissue(5).warped = [0 0];
matlabbatch{3}.spm.spatial.preproc.tissue(6).tpm = {'O:\studies\allread\mri\Template_KiGa_T2_T3\TPM_Age7.1526.nii,6' };
matlabbatch{3}.spm.spatial.preproc.tissue(6).ngaus = 2;
matlabbatch{3}.spm.spatial.preproc.tissue(6).native = [0 0];
matlabbatch{3}.spm.spatial.preproc.tissue(6).warped = [0 0];
matlabbatch{3}.spm.spatial.preproc.warp.mrf = 1;
matlabbatch{3}.spm.spatial.preproc.warp.cleanup = 1;
matlabbatch{3}.spm.spatial.preproc.warp.reg = [0 0.001 0.5 0.05 0.2];
matlabbatch{3}.spm.spatial.preproc.warp.affreg = 'mni';
matlabbatch{3}.spm.spatial.preproc.warp.fwhm = 0;
matlabbatch{3}.spm.spatial.preproc.warp.samp = 3;
matlabbatch{3}.spm.spatial.preproc.warp.write = [0 1];
matlabbatch{4}.cfg_basicio.file_dir.cfg_fileparts.files(1) = cfg_dep('Segment: Bias Corrected (1)', substruct('.','val', '{}',{3}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','channel', '()',{1}, '.','biascorr', '()',{':'}));
matlabbatch{5}.spm.util.imcalc.input(1) = cfg_dep('Segment: Bias Corrected (1)', substruct('.','val', '{}',{3}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','channel', '()',{1}, '.','biascorr', '()',{':'}));
matlabbatch{5}.spm.util.imcalc.input(2) = cfg_dep('Segment: c1 Images', substruct('.','val', '{}',{3}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','tiss', '()',{1}, '.','c', '()',{':'}));
matlabbatch{5}.spm.util.imcalc.input(3) = cfg_dep('Segment: c2 Images', substruct('.','val', '{}',{3}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','tiss', '()',{2}, '.','c', '()',{':'}));
matlabbatch{5}.spm.util.imcalc.input(4) = cfg_dep('Segment: c3 Images', substruct('.','val', '{}',{3}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','tiss', '()',{3}, '.','c', '()',{':'}));
matlabbatch{5}.spm.util.imcalc.output = 'Brain';
matlabbatch{5}.spm.util.imcalc.outdir(1) = cfg_dep('Get Pathnames: Directories (unique)', substruct('.','val', '{}',{4}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','up'));
matlabbatch{5}.spm.util.imcalc.expression = '((i2 + i3 + i4)>0.9) .* i1';
matlabbatch{5}.spm.util.imcalc.var = struct('name', {}, 'value', {});
matlabbatch{5}.spm.util.imcalc.options.dmtx = 0;
matlabbatch{5}.spm.util.imcalc.options.mask = 0;
matlabbatch{5}.spm.util.imcalc.options.interp = -7;
matlabbatch{5}.spm.util.imcalc.options.dtype = 16;
matlabbatch{6}.spm.spatial.coreg.estimate.ref(1) = cfg_dep('Image Calculator: ImCalc Computed Image: Brain', substruct('.','val', '{}',{5}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','files'));
matlabbatch{6}.spm.spatial.coreg.estimate.source(1) = cfg_dep('Realign & Unwarp: Unwarped Mean Image', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','meanuwr'));
% change every time you change tasks!!!
for i = 1:sum(contains(paths.epis,'eread')+contains(paths.epis,'learn')*2+contains(paths.epis,'implicit')+contains(paths.epis,'faceloc'))
    matlabbatch{6}.spm.spatial.coreg.estimate.other(i) = cfg_dep(['Realign & Unwarp: Unwarped Images (Sess ' num2str(i) ')'], substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','sess', '()',{i}, '.','uwrfiles'));
end
%matlabbatch{5}.spm.spatial.coreg.estimate.other(2) = cfg_dep('Realign & Unwarp: Unwarped Images (Sess 2)', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','sess', '()',{2}, '.','uwrfiles'));
matlabbatch{6}.spm.spatial.coreg.estimate.eoptions.cost_fun = 'nmi';
matlabbatch{6}.spm.spatial.coreg.estimate.eoptions.sep = [4 2];
matlabbatch{6}.spm.spatial.coreg.estimate.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
matlabbatch{6}.spm.spatial.coreg.estimate.eoptions.fwhm = [7 7];
matlabbatch{7}.spm.spatial.normalise.write.subj.def(1) = cfg_dep('Segment: Forward Deformations', substruct('.','val', '{}',{3}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','fordef', '()',{':'}));
matlabbatch{7}.spm.spatial.normalise.write.subj.resample(1) = cfg_dep('Coregister: Estimate: Coregistered Images', substruct('.','val', '{}',{6}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','cfiles'));
matlabbatch{7}.spm.spatial.normalise.write.woptions.bb = [-90 -126 -72
                                                           91 91 109];
matlabbatch{7}.spm.spatial.normalise.write.woptions.vox = [3 3 3]; % change this 
matlabbatch{7}.spm.spatial.normalise.write.woptions.interp = 7;
matlabbatch{7}.spm.spatial.normalise.write.woptions.prefix = 'w';
matlabbatch{8}.spm.spatial.smooth.data(1) = cfg_dep('Normalise: Write: Normalised Images (Subj 1)', substruct('.','val', '{}',{7}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('()',{1}, '.','files'));
matlabbatch{8}.spm.spatial.smooth.fwhm = [6 6 6];
matlabbatch{8}.spm.spatial.smooth.dtype = 0;
matlabbatch{8}.spm.spatial.smooth.im = 0;
matlabbatch{8}.spm.spatial.smooth.prefix = 's6';
matlabbatch{9}.spm.spatial.normalise.write.subj.def(1) = cfg_dep('Segment: Forward Deformations', substruct('.','val', '{}',{3}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','fordef', '()',{':'}));
matlabbatch{9}.spm.spatial.normalise.write.subj.resample(1) = cfg_dep('Image Calculator: ImCalc Computed Image: Brain', substruct('.','val', '{}',{5}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','files'));
matlabbatch{9}.spm.spatial.normalise.write.woptions.bb = [-90 -126 -72
                                                           91 91 109];
matlabbatch{9}.spm.spatial.normalise.write.woptions.vox = [1 1 1];
matlabbatch{9}.spm.spatial.normalise.write.woptions.interp = 7;
matlabbatch{9}.spm.spatial.normalise.write.woptions.prefix = 'w';

return;