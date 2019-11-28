% script for correcting movement outliers using ArtRepair Toolbox

% add ArtRepair Toolbox to the toolbox folder of SPM8

% Before running the script define the thresholds to be used in the
% art_global function:

% line 108: Percent_thresh = 4 (as Özlem et al. 2014, Bertelettia et al.
% 2014, Prado et al. 2014; for 1.5% read Hong et al. 2014)

% line 111: z_thresh = 9 (very liberal, beacause it is never reported in
% the literature)

% line 119: mv_thresh = 1.5; (half of voxel size)

% line 140 set repair1_flag = 0 to only correct first scan if necessary

% Change threshold for total movement in art_clipmvmt
% line 26: MVMTTHRESHOLD = 5 (default=3)

%addmargin


%define path to preprocessed data
path_data= 'O:\studies\allread\mri\preprocessing\eread\';

%define subjects
% subjectList = {'AR1002','AR1003','AR1005','AR1006','AR1007','AR1008','AR1012','AR1014','AR1028','AR1031','6001','6002','6006','6007','6010','6012','6015','6018','6019','6021','6025','6030','6031','6033','6036','6038','6040','6042','6046','6054','6061','6067','6080','6084','6101','6102','6103','6104','6105','6107','6108','6109','6110','6112','6115','6117','6118','6123'};

subjectList = {'AR1002'};

n_subj = numel(subjectList);

 for subj = 1:n_subj

 %define path to individual data
 fun_dir = [path_data subjectList{subj}];     
 
 %define input variabcleales for function art_global
 
 %select preprocessed data
 Images = spm_select('ExtFPList', fun_dir, '^swau.*\.nii$', Inf);
 
 %select realignment parameters
 RealignmentFile = spm_select('FPList', fun_dir, '^rp.*\.txt$');

 HeadMaskType = 4; %auto mask
 
 RepairType = 1; % ArtifactRepair alone (movement and add margin)
 
 % if you use RepairType = 2 or 0 movement threshold has to be adjusted in
 % line 147 or 150 of art_global function

%execute function
art_global(Images, RealignmentFile, HeadMaskType, RepairType)

movefile(fullfile(path_data, '*.jpg'),fun_dir);

 end
 