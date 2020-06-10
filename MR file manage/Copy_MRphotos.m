clear all 
%% Copy log files from Raw to analysis folder 
%==========================================================================
%  - Select log files based on niftis availabel for preprocessing
rawpath = 'O:\studies\allread\mri\raw_OK\';
logspath = 'O:\studies\grapholemo\Allread_AE\mri\Preprocessing_AE\logs\';
preprocessingpath = 'O:\studies\allread\mri\analysis_GFG\preprocessing\';
cd (rawpath)
tasks = {'learn'};
subjectFolders = dir([preprocessingpath,'\learn_1\epis\AR*']);
%AR1045\learn\logs
%% 
for ss = 1:length(subjectFolders)
  for t = 1:length(tasks)  
    epifiles = [dir([preprocessingpath,[tasks{t} '_1\epis\'],subjectFolders(ss).name,'\mr*epi*.nii']); dir([preprocessingpath,[tasks{t} '_2\epis\'],subjectFolders(ss).name,'\mr*epi*.nii']); dir([preprocessingpath,[tasks{t} '_3\epis\'],subjectFolders(ss).name,'\mr*epi*.nii']); dir([preprocessingpath,[tasks{t} '_4\epis\'],subjectFolders(ss).name,'\mr*epi*.nii'])];
    for i = 1:length(epifiles)
        % find the corresponding logfile
        episplit = strsplit(epifiles(i).name,'_');
        logfile = dir([rawpath,'\',subjectFolders(ss).name,'\',tasks{t},'\logs\*',strrep(episplit{end},'.nii','.txt')])       
        if ~isempty(logfile)
            %copy the file into our path (mkdir creates folder)
            targetpath = [logspath,tasks{t},'\',subjectFolders(ss).name,'\'];
            mkdir(targetpath)
            copyfile([logfile.folder,'\',logfile.name],targetpath)
            disp(['SAVED file "',epifiles(i).name,'"...in ',targetpath])
        end
    end
  end
end 
