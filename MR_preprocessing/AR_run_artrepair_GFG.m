%% Correct movement outliers using ArtRepair Toolbox
%---------------------------------------------------------------------
% add ArtRepair Toolbox to the toolbox folder of SPM12
% Before running the script define the following in art_global function:
% - line 108: Percent_thresh = 4 (as Özlem et al. 2014, Bertelettia et al.2014, Prado et al. 2014; for 1.5% read Hong et al. 2014)
% - line 111: z_thresh = 9 (very liberal, beacause it is never reported in the literature)
% - line 119: mv_thresh = 1.5; (half of voxel size)
% - line 140 set repair1_flag = 0 to only correct first scan if necessary
%
% Change also threshold for total movement in art_clipmvmt function:
% -  line 26: MVMTTHRESHOLD = 5 (default=3)
%-------------------------------------------------------------------------
clear all
%path to preprocess data / epis . 

preprocessingDir= ['O:\studies\allread\mri\preprocessed_LearningTask\block_1\epis\']; % slash '\' at the end! EPIS directory! not its parent dir 
%subject list
files = dir([preprocessingDir,'AR*'])
%files = files(~contains({files.name},'AR1026')); 
subject = {files.name};
%subject= {'AR1087','AR1089','AR1090','AR1091','AR1092','AR1093','AR1094','AR1097','AR1099','AR1100','AR1102'}
%{'AR1005','AR1016','AR1017','AR1022','AR1025','AR1026','AR1027','AR1028','AR1036','AR1037','AR1038','AR1041','AR1042','AR1043','AR1047','AR1048',...
            %'AR1052','AR1055','AR1056','AR1062',...
          % 'AR1063','AR1066','AR1068','AR1069'};
%subject = {'AR1051','AR1058','AR1059','AR1070','AR1071','AR1075','AR1076','AR1088','AR1098','AR1104','AR1105','AR1107','AR1108'};
subject = {'AR1051'}
cd (preprocessingDir)
%% Loop thru subjects
 for ss = 1:numel(subject)
     %find path to current subject data
      subjectDir = [preprocessingDir, subject{ss}];     
     %find epis to be repared. Accepts several.
     epis = dir([subjectDir,'\s*wuamr*.nii']);
     if~isempty(epis)
         for e = 1:length(epis)

             %select all volumes of epi 
             Images = spm_select('ExtFPList', epis(e).folder,  epis(e).name, Inf);
             %Take txt file with realignment parameters (only one file)
             RealignmentFile =  spm_select('FPList', subjectDir, '^rp_am.*\.txt$'); % common file with realignment parameters

             % ART REPAIR SETTINGS
             HeadMaskType = 4; %auto mask
             RepairType = 1; % ArtifactRepair alone (movement and add margin)
             % if you use RepairType = 2 or 0 movement threshold has to be adjusted in
             % line 147 or 150 of art_global function

             % EXECUTE from our new directory
             cd (preprocessingDir)
             art_global(Images, RealignmentFile, HeadMaskType, RepairType)

            %% Find output of function, add a unique prefix based on source nifti and move to a ART folder
              % new folder
              if RepairType==1 
                newDir = [subjectDir,'\ART\'];
              elseif RepairType==2 
                 newDir = [subjectDir,'\2ART\'];
              end                     
              
              mkdir (newDir);
              % create file identifier
              fileID_split = strsplit(epis(e).name,'_'); 
              fileID = [fileID_split{1},'_',subject{ss}];
              % find new files
              newfiles =  [dir([subjectDir,'\vs*wuamr*.nii']);dir([subjectDir,'\ArtifactMask.nii']);dir([subjectDir,'\art_deweighted.txt']);dir([subjectDir,'\art_repaired.txt'])];
              % Move to new dir, add identifier if needed
              for j = 1:length(newfiles)
                      if contains(newfiles(j).name,'art_deweighted.txt') || contains(newfiles(j).name,'art_repaired.txt')  || contains(newfiles(j).name,'ArtifactMask.nii') 
                          % add file identifier to the files without it
                           movefile([subjectDir,'\',newfiles(j).name],[newDir,fileID,'_',newfiles(j).name]);
                      else
                         movefile(fullfile(newfiles(j).folder, newfiles(j).name),[newDir,newfiles(j).name]);
                     
                      end
                      
              end
            % the figure is always stored in path_data, Add identifier and move to ART folder within subject
             picfile = dir([preprocessingDir,['artglobalepis',subject{ss},'.jpg']]) ;
             if ~isempty(picfile)
                movefile(fullfile(picfile.folder, picfile.name),[newDir,[fileID,'_',picfile.name]]);

             else
               disp([picfile.name,' NOT FOUND!'])
             end
         end
     else
         disp(['Epis not found'])
     end
 end
 