clear all
close all
spm fmri
dirinput= 'O:\studies\allread\mri\raw_OK';%no end slash
%% find source subject folders
cd (dirinput)
subjectFiles = dir([dirinput,'\AR*']);
files = subjectFiles(find(cellfun(@length, {subjectFiles.name})==6));%take only file names with characters
sIDs = {files.name};
%% FIND NIFTIs from epi and copy them into "realignment_check" folder
for i=8:13%33:length(sIDs)
  currSubject=sIDs{i};
  sfiles = [dir([dirinput,'\',currSubject,'\**\nifti\*_epi_*.nii']); dir([dirinput,'\',currSubject,'\**\nifti\*1_eread*.nii'])];
  sfiles = sfiles(~contains({sfiles.name},'_audio'));
  if ~isempty(sfiles)
      for f = 1:length(sfiles)
       destinationFolder = strrep(sfiles(f).folder,'nifti','realign_check');
       mkdir(destinationFolder)
       copyfile([sfiles(f).folder,'\',sfiles(f).name],[destinationFolder,'\',sfiles(f).name])     
       %% Do realignment and save plots
        cd (destinationFolder)
        nVols = length(spm_vol([destinationFolder,'\',sfiles(f).name])); % See how many volumes this file has 
        volseq = 1:nVols;
        listVols = cellstr(strcat(repmat(sfiles(f).name,nVols,1),',',arrayfun(@(volseq) sprintf('%02d',volseq),volseq,'un',0)')); %This list has one column and as many rows as volumes, each has the file name and the volume index separated by comma
        %prepare batch
        matlabbatch{1}.spm.spatial.realign.estimate.data = { listVols}'; % uses the list of volumes as input
        matlabbatch{1}.spm.spatial.realign.estimate.eoptions.quality = 0.9;
        matlabbatch{1}.spm.spatial.realign.estimate.eoptions.sep = 4;
        matlabbatch{1}.spm.spatial.realign.estimate.eoptions.fwhm = 5;
        matlabbatch{1}.spm.spatial.realign.estimate.eoptions.rtm = 1;
        matlabbatch{1}.spm.spatial.realign.estimate.eoptions.interp = 2;
        matlabbatch{1}.spm.spatial.realign.estimate.eoptions.wrap = [0 0 0];
        matlabbatch{1}.spm.spatial.realign.estimate.eoptions.weight = '';
        % RUN 
         spm_jobman('run',matlabbatch);
         clear matlabbatch
         figure(gcf)
        % save plot
          gcf
          saveas(gcf,strrep(['FIG_',num2str(nVols),'vols_',sfiles(f).name],'.nii','.jpg'))
        % remove nifti file from realignment check
        tmpfiles = [dir([destinationFolder,'\*.mat']);dir([destinationFolder,'\*.nii']);dir([destinationFolder,'\*.ps'])];
        if ~isempty(tmpfiles)
            cd (destinationFolder)
            cellfun(@delete, {tmpfiles.name})
        end
      end
  end
end
