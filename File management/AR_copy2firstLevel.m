%% COUNT FILES MAKE SUMMARY TABLE
%-----------------------------------
clear all
close all
%%inputs 
dirinput= ' ';
diroutput= 'O:\studies\allread\mri\analysis_GFG\1stLevel_GLM1\learn_12';

folderNames = {'learn'};
subfolderNames = {'logs'};%{'rec_par','nifti','realign_check','logs'};
% find subjects
subjectFiles = dir([dirinput,'\AR*']);
files = subjectFiles(find(cellfun(@length, {subjectFiles.name})==6));%take only file names with characters
sIDs = {files.name};
 
%%
cd (diroutput)
%sTable={};
for i=1:length(sIDs) 
    counter = 1 ;
    for j = 1:length(folderNames)
        for k=1:length(subfolderNames)
           folderContent = dir([sIDs{i},'\',folderNames{j},'\',subfolderNames{k},'\*.txt']);
           
           destinationFolder = [diroutput,'\logs\',sIDs{i}]
           mkdir(destinationFolder)
           for l = 1:length(folderContent)
                fullfile2copy = [folderContent(l).folder '\' folderContent(l).name];
                copyfile(fullfile2copy,[destinationFolder,'\',folderContent(l).name]) 
           end 
         end
    end
end
%% Do the same with the art_repaired files (not all actually had repaired scans)
clear all
dirinput= 'O:\studies\allread\mri\analysis_GFG\preprocessing';
diroutput= 'O:\studies\allread\mri\analysis_GFG\1st_level_GLM1\learn_12';


folderNames = {'learn_2'};
subfolderNames = {'epis'}%{'rec_par','nifti','realign_check','logs'};

%
cd (diroutput)
%sTable={};
for j = 1:length(folderNames)
    subjectFiles = dir([dirinput,'\',folderNames{j},'\epis\AR*']);
    files = subjectFiles(find(cellfun(@length, {subjectFiles.name})==6));%take only file names with characters
    sIDs = {files.name};
  
    for i=1:length(sIDs) 
         % find subjects
        
 
        for k=1:length(subfolderNames)
           folderContent = dir([dirinput,'\',folderNames{j},'\',subfolderNames{k},'\',sIDs{i},'\ART\vs6wuamr*epi*.nii']);
           
           destinationFolder = [diroutput,'\',sIDs{i}]
           mkdir(destinationFolder)
           for l = 1:length(folderContent)
                fullfile2copy = [folderContent(l).folder '\' folderContent(l).name];
                copyfile(fullfile2copy,[destinationFolder,'\',folderContent(l).name]) 
           end 
         end
    end
end

%% Do the same with the realignment parameter files and bad scan regressors
clear all
dirinput= 'O:\studies\allread\mri\analysis_GFG\preprocessing';
diroutput= 'O:\studies\allread\mri\analysis_GFG\1st_level_GLM1\learn_12';


folderNames = {'learn_1','learn_2'};
subfolderNames = {'epis'}%{'rec_par','nifti','realign_check','logs'};

%
cd (diroutput)
%sTable={};
for j = 1:length(folderNames)
    subjectFiles = dir([dirinput,'\',folderNames{j},'\epis\AR*']);
    files = subjectFiles(find(cellfun(@length, {subjectFiles.name})==6));%take only file names with characters
    sIDs = {files.name};
    sIDs = {'AR1016'}
    for i=1:length(sIDs) 
         % find subjects
        for k=1:length(subfolderNames)
          % folderContent = dir([dirinput,'\',folderNames{j},'\',subfolderNames{k},'\',sIDs{i},'\ART\*flagscans.mat']);
           folderContent = [dir([dirinput,'\',folderNames{j},'\',subfolderNames{k},'\',sIDs{i},'\ART\*flagscans.mat']),dir([dirinput,'\',folderNames{j},'\',subfolderNames{k},'\',sIDs{i},'\rp_amr*.txt'])]
           
           destinationFolder = [diroutput,'\',sIDs{i}]
           mkdir(destinationFolder)
           for l = 1:length(folderContent)
                fullfile2copy = [folderContent(l).folder '\' folderContent(l).name];
                if contains(folderContent(l).name,'.txt')
                    copyfile(fullfile2copy,[destinationFolder,'\',folderContent(l).name]) 
                elseif  contains(folderContent(l).name,'.mat')
                  copyfile(fullfile2copy,[destinationFolder,'\',folderNames{j},'_',folderContent(l).name]) 
                end
           end 
         end
    end
end

%% Do the same with the Realignem files (not all actually had repaired scans)
clear all
dirinput= 'O:\studies\allread\mri\analysis_GFG\1st_level_GLM1\logs';
diroutput= 'O:\studies\allread\mri\analysis_GFG\1st_level_GLM1\learn_12';
subfolderNames = {'epis'}%{'rec_par','nifti','realign_check','logs'};

%
cd (diroutput)
%sTable={};
  files = dir([diroutput,'\AR*']);
%  files = subjectFiles(find(cellfun(@length, {subjectFiles.name})==6));%take only file names with characters
  sIDs = {files.name};
  
 for i=1:length(sIDs) 
         % find subjects
     folderContent =   dir([diroutput,'\',sIDs{i},'\*.nii'])
      for k=1:length(folderContent)
           filenamesplit = strsplit(folderContent(k).name,'_')
           blockPattern = strrep(filenamesplit{end},'.nii','.txt')
           
           destinationFolder = [diroutput,'\',sIDs{i}]
          % mkdir(destinationFolder)
          file2copy =  dir([dirinput,'\',sIDs{i},'\*_',blockPattern])
          copyfile([file2copy.folder,'\',file2copy.name],[destinationFolder,'\',file2copy.name]) 
      end
end

%header ={sIDs};
%filenamesTable = cell2table(sTable,'VariableNames',sIDs);
%%% save
%cd(diroutput);
%outputfilename = 'Filenames_MR.xls';
%if exist(outputfilename,'file') == 0
%   writetable(filenamesTable,outputfilename,'WriteVariableNames',true);
%else disp('CANNOT SAVE FILE, IT ALREADY EXISTS!!');
%end 