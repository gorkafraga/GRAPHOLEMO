%   2n level analysis with regressor  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% - Reads first level folder based on your selectedGLM. 
% - MANUAL INPUT OF REGRESSOR VECTOR
% - Creates and run one batch per contrast in your selectedGLM folder
% - Uses explicit mask  binary mask, skull-stripped brain from anat template)
%G.Fraga Gonzalez(2020)
clear all
close all
readRegreFromTable = 1; % set as 0 if you want to input your vector manually
%Choose your base GLM 
selectedGLM = 'GLM0';
% Choose your regression (must be the column name in your master file)
regressor_name = 'rias_nix_pr';
% set input dir  based on GLM of interest
mymaster = 'O:\studies\grapholemo\analysis\LEMO_VG\LEMO_Master_VG.xlsx';
parentDir = 'O:\studies\grapholemo\analysis\LEMO_VG\mri\1stLevel\FBL_A'; 

listFolders = dir(strcat(parentDir,'\1Lv_',selectedGLM,'*'));
[indx,tf] = listdlg('PromptString','Select source 1st level folder','ListString',{listFolders.name});
dirinput = strcat([listFolders(indx).folder,'\',listFolders(indx).name]) ;
selectedGLM = listFolders(indx).name;
%%
% POP UP Input vector with regressor
prompt = {'Enter contrast weights:'};
dlgtitle = 'Input'; dims = [1 100];
definput = {'0 1'};
answer = inputdlg(prompt,dlgtitle,dims,definput);
contrastWeights = str2num(answer{1});  
%%
if contrastWeights(2)>0 
    suffixsign = 'Pos';
elseif     contrastWeights(2)<0
    suffixsign= 'Neg'; 
end
% create dir output
diroutput = strrep(strrep(dirinput,[selectedGLM],['2Lv_regre',suffixsign,'_',strrep(selectedGLM,'1Lv_','')]),'1stLevel','2ndLevel');
mkdir(diroutput)

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
 %% Read subject files
files = dir([dirinput,'\GPL*']);
subjects= {files.name};
%subjects =  {'gpl001','gpl002','gpl003','gpl004','gpl005','gpl006','gpl007','gpl008','gpl009', 'gpl010','gpl011','gpl012','gpl013','gpl014','gpl015','gpl017','gpl019','gpl021','gpl023','gpl024'};
%excludedSubj = {'AR1016','AR1022','AR1037'};
%subjects(cell2mat(cellfun(@(c)find(strcmp(c,subjects)),excludedSubj,'UniformOutput',false)))=[]; %find index and exclude subjects
 
%% read Regressor from table 
if readRegreFromTable == 1
    T = readtable(mymaster,'sheet','Cognitive','Range','A1:GD103');
    T = T(find(contains(T.Subj_ID,'gpl')),:); %trim table to take only files with valid subjID and skip remaining rows NAs 
    T.Properties.RowNames= T.Subj_ID;
    regressor = T{subjects,regressor_name};
else
    % Input vector with regressor
    prompt = {'Enter regressor name:','Enter regressor values (space separated)'};
    dlgtitle = 'Input';
    dims = [1 100];
    definput = {'SLRT_words_corr_pr_T1','xxxxx'};
    answer = inputdlg(prompt,dlgtitle,dims,definput);
    regressor = str2num(answer{2})'; 
    regressor_name = answer{1};
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  CREATE MATLABBATCH for each Contrast [checks vector length first!]
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if length(regressor)~= length(subjects)
    disp(['Abort!!! There are ',num2str(length(subjects)),' subjects but regressor length is ',num2str(length(regressor)),'!']) 
else
    
%% loop thru contrasts
batches={};
for c = 1: length(contrast)   
    
    
    currDiroutput = [diroutput,'\',strrep(strrep(cell2mat(contrast(c).fname),'.nii',''),'con_','from_1Lv_con')];
    mkdir(diroutput)
    %specify dir 
    matlabbatch{1}.spm.stats.factorial_design.dir = {currDiroutput};
    
    % take the con_000* files from each subject
    matlabbatch{1}.spm.stats.factorial_design.des.mreg.scans = {};    
    for s=1:length(subjects)
        conFile = dir([dirinput, '\' subjects{s} '\'  cell2mat(contrast(c).fname)]) ;
        if isempty(conFile)
            disp(['Could NOT find ', cell2mat(contrast(c).fname),' in ',subjects{s}]) 
        else 
          matlabbatch{1}.spm.stats.factorial_design.des.mreg.scans(end+1) = {[conFile.folder, '\' conFile.name ',1'] }';
        end        
    end
   matlabbatch{1}.spm.stats.factorial_design.des.mreg.scans =    matlabbatch{1}.spm.stats.factorial_design.des.mreg.scans';
    
   % specify regressor  
    matlabbatch{1}.spm.stats.factorial_design.des.mreg.mcov.c = regressor;
    matlabbatch{1}.spm.stats.factorial_design.des.mreg.mcov.cname = regressor_name;
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
    %specs
    matlabbatch{2}.spm.stats.fmri_est.spmmat(1) = cfg_dep('Factorial design specification: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
    matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
    matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;
    %contrasts
    matlabbatch{3}.spm.stats.con.spmmat(1) = cfg_dep('Model estimation: SPM.mat File', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.name = cell2mat(contrast(c).descript);
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.weights = contrastWeights;
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
       % spm_jobman('interactive',batches{i});       
    end    
 %% Save table with contrasts codebook, subjects and regressor
contrast_table = struct2table(contrast);
writetable(contrast_table,[diroutput,'\Codebook_contrasts_from',selectedGLM,'.csv']);
%
subjects_table = cell2table([subjects',num2cell(regressor)]);
subjects_table.Properties.VariableNames = {'subjects',regressor_name};
writetable(subjects_table,[diroutput,'\Subjects_from',selectedGLM,['_n',num2str(length(subjects))],'.csv']);
end