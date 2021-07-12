%Check registration (normalized epi and normalized skull-stripped T1)
%============================================================================
% - Makes temporary copy of nifti in your output folder
% - Saves image as jpg
% - You should create a new folder just for this output because...
% !!!! ACHTUNG!!! deletes all .nii, .ps and .mat files in your output folder!

clear; close all
dirinput= 'G:\GRAPHOLEMO\lemo_preproc';
destinationFolder = 'G:\GRAPHOLEMO\lemo_preproc\QA_checkReg';
mkdir(destinationFolder)
subjectlist = {'gpl006'};

%% Loop thru subjects, then niftis and do stuff
spm fmri
 for ss= 1:length(subjectlist)
     currSubj = subjectlist{ss};
     t1file = dir([dirinput,'\fbl_b\',currSubj,'\**\wim*_T1w.nii']);
     epifile = dir([dirinput,'\fbl_b\',currSubj,'\**\func\run1\s6wmean*_bold.nii']); %needs to be a mean image or just 1 vol!
    
    if(length(epifile)==1 && length(t1file)==1)
     copyfile([epifile.folder,'\',epifile.name],[destinationFolder,'\',epifile.name])     
     copyfile([t1file.folder,'\',t1file.name],[destinationFolder,'\',t1file.name])     
       
         %Check Reg T1 and save figure
         cd (destinationFolder)    
         spm_check_registration([destinationFolder,'\',epifile.name],[destinationFolder,'\',t1file.name])
         spm_orthviews('Xhairs','on')
         spm_figure('GetWin','Graphics');
         figure(gcf)
        % save plot
          gcf
          saveas(gcf,strrep([destinationFolder,'\',currSubj,'_',epifile.name],'.nii', '.jpg'))
         % remove nifti file from output folder!!!!!!!
        tmpfiles = [dir([destinationFolder,'\*.mat']);dir([destinationFolder,'\*.nii']);dir([destinationFolder,'\*.ps'])];
        if ~isempty(tmpfiles)
            cd (destinationFolder)
            cellfun(@delete, {tmpfiles.name})
        end
    
    else 
    disp('sorry, found too many files. I only accept one epi and one T1')
    end
    
end
close (gcf)