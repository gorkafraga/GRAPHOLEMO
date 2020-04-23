%% COUNT FILES MAKE SUMMARY TABLE
%-----------------------------------
clear all
close all
%%inputs 
dirinput= 'O:\studies\allread\mri\raw_OK';
diroutput= 'O:\studies\allread\mri\raw_OK';

folderNames = {'t1w','dti','learn','eread','localizer','symCtrl','audio_test'};
subfolderNames = {'rec_par'}%{'rec_par','nifti','realign_check','logs'};
%% find subjects
subjectFiles = dir([dirinput,'\AR*']);
files = subjectFiles(find(cellfun(@length, {subjectFiles.name})==6));%take only file names with characters
sIDs = {files.name};
 
%%
cd (dirinput)
sTable={};
for i=1:length(sIDs) 
    counter = 1 ;
    for j = 1:length(folderNames)
        for k=1:length(subfolderNames)
           folderContent = dir([sIDs{i},'\',folderNames{j},'\',subfolderNames{k},'\*.par'])
           for l = 1:length(folderContent)
               splitfolder = strsplit(folderContent(l).folder,'\')
               filename = [[splitfolder{end-1},'\',splitfolder{end},'\'] folderContent(l).name];
               sTable{counter,i}= filename;
                counter = counter + 1;
           end 
         end
    end
end
%%
header ={sIDs};
filenamesTable = cell2table(sTable,'VariableNames',sIDs);
%% save
cd(diroutput);
outputfilename = 'Filenames_MR.xls';
if exist(outputfilename,'file') == 0
   writetable(filenamesTable,outputfilename,'WriteVariableNames',true);
else disp('CANNOT SAVE FILE, IT ALREADY EXISTS!!');
end 