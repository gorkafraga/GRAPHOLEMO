%Save screenshot of T1 image     0_0 (or any other)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 % - Makes temporary copy of nifti in your output folder
% - Saves image as jpg
% - You should create a new folder just for this output: 
% !!!! ACHTUNG!!! deletes all .nii, .ps and .mat files in your output folder!

clear; close all
dirinput= 'G:\GRAPHOLEMO\lemo_preproc';
destinationFolder = 'G:\GRAPHOLEMO\lemo_preproc\QA_T1';
mkdir(destinationFolder)
%file pattern search
subjects = {'gpl006','gpl007','gpl008','gpl009'};

%% Make a temporal copy of the T1 niftis before plotting
spm fmri
for s = 1:length(subjects)
    currsubject= subjects{s};
    file = dir([dirinput,'\fbl_a\**\im',currsubject,'*T1w.nii']); %choose im*T1w.nii for skull-striped image. Choose wim*T1w.nii as pattern for normalized, 

   copyfile([file.folder,'\',file.name],[destinationFolder,'\',file.name])     
       % Check Reg T1 and save figure
        cd (destinationFolder)
        spm_check_registration([destinationFolder,'\',file.name]);
        spm_orthviews('Xhairs','on') ; %set to off if you don't cross
        % RUN, bring Picture to front
         spm_figure('GetWin','Graphics');
         figure(gcf)
        % save plot
          gcf
          saveas(gcf,strrep(file.name,'.nii', '.jpg'))
        % remove nifti file from output folder!!!!!!
        tmpfiles = [dir([destinationFolder,'\*.mat']);dir([destinationFolder,'\*.nii']);dir([destinationFolder,'\*.ps'])];
        if ~isempty(tmpfiles)
            cd (destinationFolder)
            cellfun(@delete, {tmpfiles.name})
        end
end
   
close all
