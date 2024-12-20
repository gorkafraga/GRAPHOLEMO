%--------------------------------------------------------------------------------------------------------------
%  _____                    ___                _     _                              _ 
% |  __ \                  |__ \              | |   | |                            | |
% | |__) |  _   _   _ __      ) |  _ __     __| |   | |        ___  __   __   ___  | |
% |  _  /  | | | | | '_ \    / /  | '_ \   / _` |   | |       / _ \ \ \ / /  / _ \ | |
% | | \ \  | |_| | | | | |  / /_  | | | | | (_| |   | |____  |  __/  \ V /  |  __/ | |
% |_|  \_\  \__,_| |_| |_| |____| |_| |_|  \__,_|   |______|  \___|   \_/    \___| |_|
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% - Reads first level folder based on your selectedGLM. 
% - Creates and run one batch per contrast in your selectedGLM folder
% - Uses explicit mask  binary mask, skull-stripped brain from anat template)
%G.Fraga Gonzalez(2020)
%--------------------------------------------------------------------------------------------------------------
clear all
close all
%Chooice your GLM of interest
selectedGLM = 'GLM1';
% set input dir  based on GLM of interest
dirinput = ['O:\studies\allread\mri\analyses_EH\02_first_level\first_level_17con','\GLM1']
diroutput = 'O:\studies\allread\mri\analyses_EH\2ndLevel_Gorka'

%mkdir(diroutput)
tablepath='O:\studies\allread\mri\analyses_EH\03_second_level\2ndLv_Groups\2ndLv_Groups_SLRT_WISC.xlsx'; %where is your Excel-Sheet and how is it called?
sheetname='2ndLv_Groups_July'; %name your sheet, and then change the name here!
column_subj='SubjectID'; %name of column with subject list; careful! This takes all subjects into account that are in the list!
column_SLRT='SLRT_II_MEAN_W_PW'; %name of column with data that you want to base your groups on,eg mean SLRT words and pseudowords, SLRT words raw, SLS raw....
T=readtable(tablepath,'Sheet',sheetname); 
subject_position_p=T.(column_SLRT)<=16;
subject_p=(num2cell(T.(column_subj)(subject_position_p)))';
subject_position_n=T.(column_SLRT)>=30;
subject_n=(num2cell(T.(column_subj)(subject_position_n)))'
 

% Read t-test contrasts for that model 
tmp = dir([dirinput,'\**\spm.mat']);
load([tmp(1).folder,'\',tmp(1).name]); % load first spm file in input directory

contrast=struct();  % gather description and file names of all t-contrasts in that analysis c=1;
c=1;
for i = 1:length(SPM.xCon)
    if contains(SPM.xCon(i).Vcon.fname,'con_00')
        contrast(c).fname = {SPM.xCon(i).Vcon.fname};
        contrast(c).descript = {SPM.xCon(i).Vcon.descrip};
        c= c+1;
    end
end
clear SPM

%% Begin subject loop 
files = dir([dirinput,'\AR*']);
%subjects= {files.name};
subjects = strcat('AR',cellfun(@num2str, subject_n, 'UniformOutput', 0));
%selected = strcat('AR',cellfun(@num2str, subject_n, 'UniformOutput', 0))
%excludedSubj = {'AR1016','AR1022','AR1037'};
%subjects(cell2mat(cellfun(@(c)find(strcmp(c,subjects)),excludedSubj,'UniformOutput',false)))=[]; %find index and exclude subjects

%% loop thru contrasts
batches={};
for c = 1: length(contrast) 
        
    currDiroutput = [diroutput,'\',strrep(strrep(cell2mat(contrast(c).fname),'.nii',''),'con_','from_1Lv_con')];
    %mkdir(diroutput)
    matlabbatch{1}.spm.stats.factorial_design.dir = {currDiroutput};
    matlabbatch{1}.spm.stats.factorial_design.des.t1.scans = {};
   
    % take the con_000* files from each subject
    for s=1:length(subjects)
        conFile = dir([dirinput, '\' subjects{s} '\'  cell2mat(contrast(c).fname)]) ;
        if isempty(conFile)
            disp(['Could NOT find ', cell2mat(contrast(c).fname),' in ',subjects{s}]) 
        else 
          matlabbatch{1}.spm.stats.factorial_design.des.t1.scans(end+1) = {[conFile.folder, '\' conFile.name ',1'] }';
        end        
    end
   matlabbatch{1}.spm.stats.factorial_design.des.t1.scans =    matlabbatch{1}.spm.stats.factorial_design.des.t1.scans';
    % continue design specs
    matlabbatch{1}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
    matlabbatch{1}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
    matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
    matlabbatch{1}.spm.stats.factorial_design.masking.im = 1;
    matlabbatch{1}.spm.stats.factorial_design.masking.em =  {'O:\studies\allread\mri\analysis_GFG\anatomical_templates\from_TOM8\mask_thr01_vols123.nii,1'};  
    matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
    matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
    matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;
    % Model estimation
    matlabbatch{2}.spm.stats.fmri_est.spmmat(1) = cfg_dep('Factorial design specification: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
    matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
    matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;
    % Model contrsats
    matlabbatch{3}.spm.stats.con.spmmat(1) = cfg_dep('Model estimation: SPM.mat File', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.name = cell2mat(contrast(c).descript);
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.weights = 1;
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.delete = 0;
    batches{c} = matlabbatch;

end
   
%%  Run in parallel port  

    if ~isempty(gcp('nocreate'))
            delete(gcp('nocreate'));  
    end 
    parpool(8);        
    parfor i = 1: length(contrast)
        spm_jobman('run',batches{i});
        
    end    
%% Save table with contrasts run and subjects
contrast_table = struct2table(contrast);
 
writetable(contrast_table,[diroutput,'\Codebook_contrasts_from',selectedGLM,'.csv']);
subjects_table = cell2table(subjects');
subjects_table.Properties.VariableNames = {'subjects'};
writetable(subjects_table,[diroutput,'\Subjects_from',selectedGLM,['_n',num2str(length(subjects))],'.csv']);