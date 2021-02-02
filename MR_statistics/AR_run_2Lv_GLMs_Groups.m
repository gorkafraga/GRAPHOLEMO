clear
close all
% RUN SECOND LEVEL GROUP COMPARISONS
%===================================================================
% - Reads first level folder based on your selectedGLM. 
% - Finds in your master file which group label had each of the first level subjects
% - Creates and run one batch per contrast in your selectedGLM folder
% - Each batch compares the group
% - Uses explicit mask binary mask(skull-stripped brain from anat template)
%G.Fraga Gonzalez(2020)
%--------------------------------------------------------------------------------------------------------------
masterfile =    'O:\studies\allread\mri\analysis_GFG\Allread_MasterFile_GFG.xlsx';
parentDir = 'O:\studies\allread\mri\analysis_GFG\stats\mri';% NO \ as last character
%Chooice your GLM of interest
selectedGLM =   'GLM0_mopa';
selectedGroup = 'GoodPerf_72';
modelversion =  'AR_rlddm_v12';
%PROMPT dialogue showing existing 1st level analysis in your folder 
if  contains(selectedGLM,'_mopa')
    listFolders = dir(strcat(parentDir,'\',selectedGroup,'\',modelversion,'\1Lv_',selectedGLM,'*'));  
else
    listFolders = dir(strcat(parentDir,'\',selectedGroup,'\1Lv_',selectedGLM,'*'));   
end
[indx,tf] = listdlg('PromptString','Select source 1st level folder','ListString',{listFolders.name});

% Use 1st level name to define input and output paths 
dirinput = strcat([listFolders(indx).folder,'\',listFolders(indx).name]) ;
diroutput = strrep(dirinput,['1Lv_',selectedGLM],['2Lv_',selectedGLM,'_Groups']);
mkdir(diroutput)

% Save names of t-test contrasts in an array (structure)
tmp = dir([dirinput,'\**\spm.mat']);
load([tmp(1).folder,'\',tmp(1).name]); % load first spm file in input directory
contrast=struct();  % gather description and file names of all t-contrasts in that analysis c=1;
c=1;
for i = 1:length(SPM.xCon)
    if contains(SPM.xCon(i).Vcon.fname,'con_000')
        contrast(c).fname = {SPM.xCon(i).Vcon.fname};
        contrast(c).descript = {SPM.xCon(i).Vcon.descrip};
        c= c+1;
    end
end
clear SPM

% Find subjects available
files = dir([dirinput,'\AR*']);
subjects= {files.name};
%excludedSubj = {'AR1016','AR1022','AR1037'};
%subjects(cell2mat(cellfun(@(c)find(strcmp(c,subjects)),excludedSubj,'UniformOutput',false)))=[]; %find index and exclude subjects

%% group selection from Master file
masterT =       readtable(masterfile,'sheet','IDs_Demographics');
allsubs =       masterT(:,contains(masterT.Properties.VariableNames,'subjID'));
allgroups =     masterT.groupBySLRT;
groups =        allgroups(contains(table2array(allsubs),subjects),:);
%blocks2use = table2cell(blocks);
typ = subjects(contains(groups,'typical'));
poor = subjects(contains(groups,'poor'));

%T2= readtable(masterfile,'sheet','Cognitive_tests');
%% loop thru contrasts
batches={};
spm('defaults','fMRI')
for c = 1: length(contrast) 
    %contrastname = strrep(strrep(cell2mat(contrast(c).fname),'.nii',''),'Contrast ','Con')
    contrastname = strrep(strrep(strrep(strrep(strrep(cell2mat(contrast(c).descript),'Contrast ','con'),': ','_'),' - ','_'),' ',''),'onset','');  % contrast description with some formatting 
    currDiroutput = [diroutput,'\',contrastname];
    %mkdir(diroutput)
    
   % Model 1: Factorial design specification  -----------------------------------------------------------------------
    matlabbatch{1}.spm.stats.factorial_design.dir = {currDiroutput};
    % Gather the con_000* files from each GROUP
    matlabbatch{1}.spm.stats.factorial_design.des.t2.scans1 = {};
    for s=1:length(typ)
        conFile = dir([dirinput, '\' typ{s} '\'  cell2mat(contrast(c).fname)]) ;
        if isempty(conFile)
            disp(['Could NOT find ', cell2mat(contrast(c).fname),' in ',typ{s}]) 
        else 
         matlabbatch{1}.spm.stats.factorial_design.des.t2.scans1(end+1) = {[conFile.folder, '\' conFile.name ',1'] }';
        end        
    end
    %group2
    matlabbatch{1}.spm.stats.factorial_design.des.t2.scans2 = {};
    for s=1:length(poor)
        conFile = dir([dirinput, '\' poor{s} '\'  cell2mat(contrast(c).fname)]) ;
        if isempty(conFile)
            disp(['Could NOT find ', cell2mat(contrast(c).fname),' in ',poor{s}]) 
        else 
         matlabbatch{1}.spm.stats.factorial_design.des.t2.scans2(end+1) = {[conFile.folder, '\' conFile.name ',1'] }';
        end        
    end
    matlabbatch{1}.spm.stats.factorial_design.des.t2.scans1 =    matlabbatch{1}.spm.stats.factorial_design.des.t2.scans1';
    matlabbatch{1}.spm.stats.factorial_design.des.t2.scans2 =    matlabbatch{1}.spm.stats.factorial_design.des.t2.scans2';
    
    %matlabbatch{1}.spm.stats.factorial_design.dir = '<UNDEFINED>';
        matlabbatch{1}.spm.stats.factorial_design.des.t2.dept = 0;
        matlabbatch{1}.spm.stats.factorial_design.des.t2.variance = 1;
        matlabbatch{1}.spm.stats.factorial_design.des.t2.gmsca = 0;
        matlabbatch{1}.spm.stats.factorial_design.des.t2.ancova = 0;
        matlabbatch{1}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
        matlabbatch{1}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
        matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
        matlabbatch{1}.spm.stats.factorial_design.masking.im = 1;
        matlabbatch{1}.spm.stats.factorial_design.masking.em =  {'O:\studies\allread\mri\analysis_GFG\anatomical_templates\from_TOM8\mask_thr01_vols123.nii,1'};  
        matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
        matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
        matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;
        
       % Module 2: model estimation
        matlabbatch{2}.spm.stats.fmri_est.spmmat(1) = cfg_dep('Factorial design specification: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
        matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
        matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;
        
       %Module 3: model contrasts
       matlabbatch{3}.spm.stats.con.spmmat(1) = cfg_dep('Model estimation: SPM.mat File', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
      matlabbatch{3}.spm.stats.con.consess{1}.tcon.name = 'typ-poor';
        matlabbatch{3}.spm.stats.con.consess{1}.tcon.weights = [1 -1];
        matlabbatch{3}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
        matlabbatch{3}.spm.stats.con.consess{2}.tcon.name = 'poor-typ';
        matlabbatch{3}.spm.stats.con.consess{2}.tcon.weights = [-1 1];
        matlabbatch{3}.spm.stats.con.consess{2}.tcon.sessrep = 'none';
        matlabbatch{3}.spm.stats.con.delete = 0;
       % matlabbatch{3}.spm.stats.con.consess{1}.tcon.name = cell2mat(contrast(c).descript);
      % matlabbatch{3}.spm.stats.con.consess{1}.tcon.weights = 1;
      % matlabbatch{3}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
    
       % Save batch for this contrast
        batches{c} = matlabbatch; 
end
%%  Run batch  (some parallel port settings may be commented)
    %if ~isempty(gcp('nocreate'))
    %        delete(gcp('nocreate'));  
    % end 
    % parpool(8);        
   %parfor i = 1: length(contrast)
   for i = 1: length(contrast)
        spm_jobman('run',batches{i});
        %spm_jobman('interactive',batches{i});
        
    end    
%% Save table with contrasts run and subjects
contrast_table = struct2table(contrast);
writetable(contrast_table,[diroutput,'\Codebook_contrasts_from',selectedGLM,'.csv']);
subjects_table = cell2table(subjects');
subjects_table.Properties.VariableNames = {'subjects'};
writetable(subjects_table,[diroutput,'\Subjects_from',selectedGLM,['_n',num2str(length(subjects))],'.csv']);