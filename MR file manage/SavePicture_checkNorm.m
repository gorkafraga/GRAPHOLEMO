%Script to save T1 image of repeated T1 scans
%clear; close all
spm fmri

dirinput= 'O:\studies\allread\mri\analysis_GFG\preprocessing\learn_2\epis';
t1dirinput = 'O:\studies\allread\mri\analysis_GFG\preprocessing\learn_2\t1w';
destinationFolder = 'O:\studies\allread\mri\analysis_GFG\preprocessing\QA_checkNorm\learn_2';
%mkdir(destinationFolder)
% find source subject folders
cd (dirinput)
%cd (destinationFolder)
%subjects
files=dir([dirinput,'\AR*']);
subject={files.name};
%% FIND NIFTIs from epi and copy them into "realignment_check" folder
for i=1:numel(subject)
  episfiles = dir([dirinput,'\',subject{i},'\wmean*.nii']);
  templateFile = 'O:\studies\allread\mri\analysis_GFG\anatomical_templates\from_TOM8\TPM_Age8_7.nii';
       for f = 1:length(episfiles)
        copyfile([episfiles(f).folder,'\',episfiles(f).name],[destinationFolder,'\',episfiles(f).name])    
        copyfile(templateFile,[destinationFolder,'\','TPM_Age8_7.nii'])    
       % Check Reg T1 and save figure
        cd (destinationFolder)
        mkdir(destinationFolder)
         %%
     spm_check_registration([destinationFolder,'\',episfiles(f).name],'TPM_Age8_7.nii')
     spm_orthviews('Xhairs','on')
 
     spm_figure('GetWin','Graphics');
     figure(gcf)
        % save plot
          gcf
          saveas(gcf,strrep([destinationFolder,'\',subject{i},'_',episfiles(f).name],'.nii', '.jpg'))
           
        % remove nifti file from realignment check
        tmpfiles = [dir([destinationFolder,'\*.mat']);dir([destinationFolder,'\*.nii']);dir([destinationFolder,'\*.ps'])];
        if ~isempty(tmpfiles)
            cd (destinationFolder)
            cellfun(@delete, {tmpfiles.name})
        end
       end
   
end
