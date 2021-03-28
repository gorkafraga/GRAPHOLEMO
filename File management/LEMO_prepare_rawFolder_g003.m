clear all 
% MRI RAW DATA
%==========================================================================
% - Convert to nifti
% - Arrange in folders 
% - Copy and get realignment plots and RP parameters
scriptRec2nifti = 'N:\studies\Grapholemo\Methods\Scripts\grapholemo\MR_utils\rec2nifti.pl';
logSourcePath = 'O:\studies\grapholemo\raw\mrz_transfer\logs';
rawSourcePath = 'O:\studies\grapholemo\raw\mrz_transfer\';
rawDestinationPath = 'O:\studies\grapholemo\raw\';
saverealign=1;
subject = {'g003'};
recParNames = { 'b0_fbl','fbl_parta','fbl2_parta','fbl_partb','b0_symctrl','1_symctrl','t13d','audiotest'};
% clean up last slash if specified
if strcmp(rawDestinationPath(end),'\')  rawDestinationPath= rawDestinationPath(1:end-1);   
end 
if strcmp(rawSourcePath(end),'\')    rawSourcePath= rawSourcePath(1:end-1);
end 
%% COPY into separate folders 
cd(rawDestinationPath);
for s= 1:length(subject)
    currSubj = subject{s};
    files = dir([rawSourcePath,'\*_',currSubj,'_*']);
    for i = 1:length(files)
        %Define destination folders according to file type
        destinationFolder = [rawDestinationPath,'\',currSubj];
            if (contains(recParNames{i},'t13d'))
                  destinationFolder =  [destinationFolder,'\mri\anat\parrec'];    
            elseif (contains(recParNames{i},'audiotest'))
                  destinationFolder =  [destinationFolder,'\mri\func\audiotest\parrec'];    
            elseif (contains(recParNames{i},'b0_'))
                  destinationFolder =  [destinationFolder,'\mri\func\b0\parrec'];
            elseif (contains(recParNames{i},'fbl_parta'))
                   destinationFolder =  [destinationFolder,'\mri\func\FBL_partA\parrec'];
            elseif (contains(recParNames{i},'fbl2_parta'))
                   destinationFolder =  [destinationFolder,'\mri\func\FBL2_partA\parrec'];
            elseif (contains(recParNames{i},'fbl_partb'))
                   destinationFolder =  [destinationFolder,'\mri\func\FBL_partB\parrec'];
            elseif (contains(recParNames{i},'1_symctrl'))
                   destinationFolder =  [destinationFolder,'\mri\func\symcontrol\parrec'];
            end                  
                  
             % Find files in source and copy to destination
              sfiles = [dir([rawSourcePath,'\*_',currSubj,'_*',recParNames{i},'*.par']);dir([rawSourcePath,'\*_',currSubj,'_*',recParNames{i},'*.rec'])];  
               if ~isempty(sfiles)
                    mkdir(destinationFolder);
                    for ii = 1:length({sfiles.name})
                      copyfile([sfiles(ii).folder,'\',sfiles(ii).name],[destinationFolder,'\',sfiles(ii).name]); %
                      disp(['copied ',sfiles(ii).name, ' to ',destinationFolder]) 
                    end
               end 
    end
end
%% FIND .REC and convert to nifti, save in 'nifti' folder   
for s= 1:length(subject)
    currSubj = subject{s};
    files = dir([rawDestinationPath,'\',currSubj,'\**\*.rec']);
  for f = 1:length({files.name})
      % Find the recs and convert to nifti 
      cd (files(f).folder)
      perl(scriptRec2nifti,'-s',[files(f).folder,'\',files(f).name])
  end  
  %Move niftis to nifti folder
  niftifiles = dir([rawDestinationPath,'\',currSubj,'\**\*.nii']);
  for ff = 1:length(niftifiles) 
      %Move niftis to nifti folder
       niftifolder = strrep(niftifiles(ff).folder,'parrec','nifti');
       mkdir(niftifolder)
       movefile([niftifiles(ff).folder,'\',niftifiles(ff).name],niftifolder);
  end
                                  
end
%% COPY LOG FILES
cd(logSourcePath);
for s= 1:length(subject)
    currSubj = subject{s};
    files = [dir([logSourcePath,'\',currSubj,'*.txt']);dir([logSourcePath,'\',currSubj,'*.log'])];
    for i = 1:length(files)
        %Define destination folders according to file type
        destinationFolder = [rawDestinationPath,'\',currSubj];
            foundMatchingDestination = 1;
            if (~isempty(regexpi(files(i).name,'.FBL_A.')))
                  destinationFolder =  [destinationFolder,'\mri\func\FBL_partA\logs'];    
            elseif (~isempty(regexpi(files(i).name,'.FBL._A.')))
                   destinationFolder =  [destinationFolder,'\mri\func\FBL_partA\logs'];    
            elseif (~isempty(regexpi(files(i).name,'.FBL_B.')))
                   destinationFolder =  [destinationFolder,'\mri\func\FBL_partB\logs'];    
            elseif (~isempty(regexpi(files(i).name,'.FBL._B.')))
                   destinationFolder =  [destinationFolder,'\mri\func\FBL_partB\logs'];    
            elseif (~isempty(regexpi(files(i).name,'.symctrl.')))
                   destinationFolder =  [destinationFolder,'\mri\func\symcontrol\logs'];
            else
                foundMatchingDestination=0;
            end
                            
            if (foundMatchingDestination ==1)
                mkdir(destinationFolder);
                copyfile([files(i).folder,'\',files(i).name],[destinationFolder,'\',files(i).name]); %
                disp(['copied ',files(i).name, ' to ',destinationFolder]) 
            else
                 disp(['Skipped. did not know where to copy ',files(i).name]) 

            end
            
    end
end


%% DO realignment in niftis (copy, realign this copy, delete copy)
if saverealign ==1
  for s= 1:length(subject)
          currSubj = subject{s};
           niftis = [dir([rawDestinationPath,'\',currSubj,'\**\nifti\*1_sym*']);dir([rawDestinationPath,'\',currSubj,'\**\nifti\*1_fbl*'])];

        for f = 1:length({niftis.name})
               destinationFolder = strrep(niftis(f).folder,'nifti','realign_check');
               mkdir(destinationFolder)
               copyfile([niftis(f).folder,'\',niftis(f).name],[destinationFolder,'\',niftis(f).name])     
               % Do realignment and save plots
                cd (destinationFolder)
                nVols = length(spm_vol([destinationFolder,'\',niftis(f).name])); % See how many volumes this file has 
                volseq = 1:nVols;
                listVols = cellstr(strcat(repmat(niftis(f).name,nVols,1),',',arrayfun(@(volseq) sprintf('%02d',volseq),volseq,'un',0)')); %This list has one column and as many rows as volumes, each has the file name and the volume index separated by comma
                %prepare batch
                matlabbatch{1}.spm.spatial.realign.estimate.data = { listVols}'; % uses the list of volumes as input
                matlabbatch{1}.spm.spatial.realign.estimate.eoptions.quality = 0.9;
                matlabbatch{1}.spm.spatial.realign.estimate.eoptions.sep = 4;
                matlabbatch{1}.spm.spatial.realign.estimate.eoptions.fwhm = 5;
                matlabbatch{1}.spm.spatial.realign.estimate.eoptions.rtm = 1;
                matlabbatch{1}.spm.spatial.realign.estimate.eoptions.interp = 2;
                matlabbatch{1}.spm.spatial.realign.estimate.eoptions.wrap = [0 0 0];
                matlabbatch{1}.spm.spatial.realign.estimate.eoptions.weight = '';

                % RUN batch
                 spm_jobman('run',matlabbatch);
                clear matlabbatch
                %Bring figure to the front
                spm_figure('GetWin','Graphics'); 
                figure(gcf)
                % save plot
                gcf
                saveas(gcf,strrep(['FIG_',num2str(nVols),'vols_',niftis(f).name],'.nii','.jpg'))
                % remove nifti file from realignment check
                tmpfiles = [dir([destinationFolder,'\*.mat']);dir([destinationFolder,'\*.nii']);dir([destinationFolder,'\*.ps'])];
                if ~isempty(tmpfiles)
                    cd (destinationFolder)
                    cellfun(@delete, {tmpfiles.name})
                end
        end
  end
        else
end