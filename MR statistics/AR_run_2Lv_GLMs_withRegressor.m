matlabbatch{1}.spm.stats.factorial_design.dir = {'O:\studies\allread\mri\analysis_GFG\stats\mri\2Lv_GLM1_regre'};
%%
matlabbatch{1}.spm.stats.factorial_design.des.mreg.scans = {
                                                            'O:\studies\allread\mri\analysis_GFG\stats\mri\1Lv_GLM1\learn_12\AR1005\con_0002.nii,1'
                                                            'O:\studies\allread\mri\analysis_GFG\stats\mri\1Lv_GLM1\learn_12\AR1016\con_0002.nii,1'
                                                            'O:\studies\allread\mri\analysis_GFG\stats\mri\1Lv_GLM1\learn_12\AR1022\con_0002.nii,1'
                                                            'O:\studies\allread\mri\analysis_GFG\stats\mri\1Lv_GLM1\learn_12\AR1026\con_0002.nii,1'
                                                            'O:\studies\allread\mri\analysis_GFG\stats\mri\1Lv_GLM1\learn_12\AR1027\con_0002.nii,1'
                                                            'O:\studies\allread\mri\analysis_GFG\stats\mri\1Lv_GLM1\learn_12\AR1028\con_0002.nii,1'
                                                            'O:\studies\allread\mri\analysis_GFG\stats\mri\1Lv_GLM1\learn_12\AR1036\con_0002.nii,1'
                                                            'O:\studies\allread\mri\analysis_GFG\stats\mri\1Lv_GLM1\learn_12\AR1038\con_0002.nii,1'
                                                            'O:\studies\allread\mri\analysis_GFG\stats\mri\1Lv_GLM1\learn_12\AR1041\con_0002.nii,1'
                                                            'O:\studies\allread\mri\analysis_GFG\stats\mri\1Lv_GLM1\learn_12\AR1042\con_0002.nii,1'
                                                            'O:\studies\allread\mri\analysis_GFG\stats\mri\1Lv_GLM1\learn_12\AR1043\con_0002.nii,1'
                                                            'O:\studies\allread\mri\analysis_GFG\stats\mri\1Lv_GLM1\learn_12\AR1047\con_0002.nii,1'
                                                            'O:\studies\allread\mri\analysis_GFG\stats\mri\1Lv_GLM1\learn_12\AR1048\con_0002.nii,1'
                                                            'O:\studies\allread\mri\analysis_GFG\stats\mri\1Lv_GLM1\learn_12\AR1052\con_0002.nii,1'
                                                            'O:\studies\allread\mri\analysis_GFG\stats\mri\1Lv_GLM1\learn_12\AR1055\con_0002.nii,1'
                                                            'O:\studies\allread\mri\analysis_GFG\stats\mri\1Lv_GLM1\learn_12\AR1056\con_0002.nii,1'
                                                            'O:\studies\allread\mri\analysis_GFG\stats\mri\1Lv_GLM1\learn_12\AR1063\con_0002.nii,1'
                                                            'O:\studies\allread\mri\analysis_GFG\stats\mri\1Lv_GLM1\learn_12\AR1068\con_0002.nii,1'
                                                            'O:\studies\allread\mri\analysis_GFG\stats\mri\1Lv_GLM1\learn_12\AR1069\con_0002.nii,1'
                                                            };
%%
%%
matlabbatch{1}.spm.stats.factorial_design.des.mreg.mcov.c = [9.9
                                                             8.35
                                                             9.1
                                                             7.84
                                                             8.64
                                                             7.89
                                                             7.53
                                                             9
                                                             9.12
                                                             9.74
                                                             8.53
                                                             9.19
                                                             8.57
                                                             8.55
                                                             8.26
                                                             9.8
                                                             8.75
                                                             9.62
                                                             9.6];
%%
matlabbatch{1}.spm.stats.factorial_design.des.mreg.mcov.cname = 'Age';
matlabbatch{1}.spm.stats.factorial_design.des.mreg.mcov.iCC = 1;
matlabbatch{1}.spm.stats.factorial_design.des.mreg.incint = 1;
matlabbatch{1}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
matlabbatch{1}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.im = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.em = {''};
matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;
matlabbatch{2}.spm.stats.fmri_est.spmmat(1) = cfg_dep('Factorial design specification: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;
matlabbatch{3}.spm.stats.con.spmmat(1) = cfg_dep('Model estimation: SPM.mat File', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
matlabbatch{3}.spm.stats.con.consess = {};
matlabbatch{3}.spm.stats.con.delete = 0;