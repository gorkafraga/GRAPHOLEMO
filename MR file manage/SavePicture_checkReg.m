%Script to save T1 image of repeated T1 scans
%clear; close all
spm fmri

dirinput= 'O:\studies\allread\mri\analysis_GFG\preprocessing\learn_2\epis';
t1dirinput = 'O:\studies\allread\mri\analysis_GFG\preprocessing\learn_2\t1w'
destinationFolder = 'O:\studies\allread\mri\analysis_GFG\preprocessing\QA_checkReg\learn_2';
%mkdir(destinationFolder)
% find source subject folders
cd (dirinput)
cd (destinationFolder)
%subjects
files=dir([dirinput,'\AR*']);
subject={files.name};
%% FIND NIFTIs from epi and copy them into "realignment_check" folder
for i=1:numel(subject)
  episfiles = dir([dirinput,'\',subject{i},'\Corr*.nii']);
  t1files = dir([t1dirinput,'\',subject{i},'\immr*.nii']);
       for f = 1:length(episfiles)
         copyfile([episfiles(f).folder,'\',episfiles(f).name],[destinationFolder,'\',episfiles(f).name])     
          copyfile([t1files(f).folder,'\',t1files(f).name],[destinationFolder,'\',t1files(f).name])     
       % Check Reg T1 and save figure
            cd (destinationFolder)

 
             %%
         spm_check_registration([destinationFolder,'\',episfiles(f).name],[destinationFolder,'\',t1files(f).name])
         spm_orthviews('Xhairs','on')
         spm_figure('GetWin','Graphics');
          figure(gcf)
        % save plot
          gcf
          saveas(gcf,strrep([destinationFolder,'\',subject{i},'_',episfiles(f).name],'.nii', '.jpg'))
          %saveas(gcf,strrep(['T1',sfiles(f).name],'.nii','.fig'))
        % remove nifti file from realignment check
        tmpfiles = [dir([destinationFolder,'\*.mat']);dir([destinationFolder,'\*.nii']);dir([destinationFolder,'\*.ps'])];
        if ~isempty(tmpfiles)
            cd (destinationFolder)
            cellfun(@delete, {tmpfiles.name})
        end
       end
   
end
