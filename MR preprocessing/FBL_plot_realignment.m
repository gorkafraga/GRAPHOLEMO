clear all
close all
spm fmri

dirinput= 'O:\studies\grapholemo\Allread_FBL\Analysis\mri\preprocessing\learn\';
sIDs = {'AR1055','AR1056'};
for i=1:length(sIDs)
    currSubj = sIDs{i};
    currDir = ['O:\studies\grapholemo\Allread_FBL\Analysis\mri\preprocessing\learn\',currSubj];% go current subject directory 
    diroutput =['O:\studies\grapholemo\Allread_FBL\Analysis\mri\preprocessing\learn_checkRealign\',currSubj];
    mkdir(diroutput)% create output directory for this subject if nonexistent
    cd (currDir)
    files = dir('mr*epi*.nii');%search for all epis 
    
    for ii=1:length(files) 
        currFile = files(ii).name;
        nVols = length(spm_vol(currFile)); % See how many volumes this file has 
        listVols = cellstr(strcat(repmat(currFile,nVols,1),',',num2str((1:nVols)'))); %This list has one column and as many rows as volumes, each has the file name and the volume index separated by comma
        %%
        matlabbatch{1}.spm.spatial.realign.estimate.data = { listVols}'; % uses the list of volumes as input
        matlabbatch{1}.spm.spatial.realign.estimate.eoptions.quality = 0.9;
        matlabbatch{1}.spm.spatial.realign.estimate.eoptions.sep = 4;
        matlabbatch{1}.spm.spatial.realign.estimate.eoptions.fwhm = 5;
        matlabbatch{1}.spm.spatial.realign.estimate.eoptions.rtm = 1;
        matlabbatch{1}.spm.spatial.realign.estimate.eoptions.interp = 2;
        matlabbatch{1}.spm.spatial.realign.estimate.eoptions.wrap = [0 0 0];
        matlabbatch{1}.spm.spatial.realign.estimate.eoptions.weight = '';

        %% RUN
        spm_jobman('run',matlabbatch);
        clear matlabbatch
        %% save plot
        cd (diroutput)
        saveas(gcf,strrep(['FIG_',num2str(nVols),'vols_',currFile],'.nii','.jpg'))
        cd(currDir)
        
    end
    cd (dirinput)
end