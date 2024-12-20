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
clear 
close all
%Chooice your GLM of interest
selectedGLM = 'GLM0_mopa_aspepos';
%selectedGroup = 'all';
modelversion =   'LEMO_rlddm_v32';

% set input dir  based on GLM of interest
parentDir = 'O:\studies\grapholemo\analysis\LEMO_GFG\mri\1stLevel\FeedbackLearning\FBL_B';% NO \ as last character
 
if  contains(selectedGLM,'_mopa')
    %listFolders = dir(strcat(parentDir,'\',selectedGroup,'\',modelversion,'\1Lv_',selectedGLM,'*'));  
    listFolders = dir(strcat(parentDir,'\',modelversion,'\1Lv_',selectedGLM,'*'));  
else
   % listFolders = dir(strcat(parentDir,'\',selectedGroup,'\1Lv_',selectedGLM,'*'));   
    listFolders = dir(strcat(parentDir,'\1Lv_',selectedGLM,'*'));   
end
%create input and output dir  
[indx,tf] = listdlg('PromptString','Select source 1st level folder','ListString',{listFolders.name});
dirinput = strcat([listFolders(indx).folder,'\',listFolders(indx).name]) ;
diroutput = strrep(dirinput,['1Lv_',selectedGLM],['2Lv_',selectedGLM]);
diroutput = strrep(diroutput, '1stLevel','2ndLevel');
mkdir(diroutput)


% Read t-test contrasts for that model 
tmp = dir([dirinput,'\**\spm.mat']);
load([tmp(1).folder,'\',tmp(1).name]); % load first spm file in input directory

contrast=struct();  % gather description and file names of all t-contrasts in that analysis c=1;
c=1;
for i = 1:length(SPM.xCon)
    if contains(SPM.xCon(i).Vcon.fname,'con_0')
        contrast(c).fname = {SPM.xCon(i).Vcon.fname};
        contrast(c).descript = {SPM.xCon(i).Vcon.descrip};
        c= c+1;
    end
end
clear SPM

%% Begin subject loop 
files = dir([dirinput,'\gpl*']);
subjects= {files.name};
%excludedSubj = {'AR1016','AR1022','AR1037'};
%subjects(cell2mat(cellfun(@(c)find(strcmp(c,subjects)),excludedSubj,'UniformOutput',false)))=[]; %find index and exclude subjects

%% loop thru contrasts
batches={};
for c = 1: length(contrast) 
    contrastname = strrep(strrep(cell2mat(contrast(c).fname),'.nii',''),'Contrast ','Con');
    % contrastname = strrep(strrep(strrep(strrep(strrep(cell2mat(contrast(c).descript),'Contrast ','con'),': ','_'),' - ','_'),' ',''),'onset','');
    currDiroutput = [diroutput,'\',contrastname];
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
    matlabbatch{1}.spm.stats.factorial_design.masking.em =  {''};  
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

    %if ~isempty(gcp('nocreate'))
    %        delete(gcp('nocreate'));  
   % end 
   % parpool(8);        
   %parfor i = 1: length(contrast)
   for i = 1: length(contrast)
        spm_jobman('run',batches{i});
        
    end    
%% Save table with contrasts run and subjects
contrast_table = struct2table(contrast);
writetable(contrast_table,[diroutput,'\Codebook_contrasts_from',selectedGLM,'.csv']);
subjects_table = cell2table(subjects');
subjects_table.Properties.VariableNames = {'subjects'};
writetable(subjects_table,[diroutput,'\Subjects_from',selectedGLM,['_n',num2str(length(subjects))],'.csv']);