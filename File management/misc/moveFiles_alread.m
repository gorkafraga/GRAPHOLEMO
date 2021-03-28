clear all 
%% Copy files from Raw/nifti to preprocessing folder 
%==========================================================================
% - copies .nii files from different tasks (epis) , b0 and T1 files 
% - creates directory in the output path (preprocessing path)
% - output directory structure: /preprocessing/(b0,t1 or taskx)/subjectx/files
% - output .xls file with  count of files (saved in main output directory)
rawpath = 'O:\studies\allread\mri\raw\';
%preprocessingpath = 'O:\studies\grapholemo\Allread_FBL\Analysis\mri\preprocessing\';

cd (rawpath)
tasks = {'learn'};
%%
info_epi = {};
info_b0 = {};
info_t1 = {};

subjectFolders = dir('AR*');
for ss = 1:length(subjectFolders)
  for t = 1:length(tasks)  
    %some info tables with the count of files
    info_epi{ss,1} = subjectFolders(ss).name;
    epifiles = dir([subjectFolders(ss).name,'\4_nifti\*epi_',tasks{t},'*']);
    info_epi{ss,1+t} = length(epifiles);
    %EPI files 
    %-------------
    for i = 1:length(epifiles)        
        %copy the file into our path (mkdir creates folder)
        source = [epifiles(i).folder,'\',epifiles(i).name];
        %Specify output path  
        targetpath = [preprocessingpath,tasks{t},'\',subjectFolders(ss).name,'\'];
        mkdir(targetpath)  
        % ! 
        % Copy file only if it is not in there already!
        if exist([targetpath,epifiles(i).name],'file') == 0 
            copyfile(source,targetpath)
            disp(['SAVED file "',epifiles(i).name,'"...in ',targetpath])
        elseif exist([targetpath,epifiles(i).name],'file') == 2
            disp(['File "',epifiles(i).name,'" already exists in ',targetpath])
        end
    end
    
    % B0 files
    %-------------
    b0files = dir([subjectFolders(ss).name,'\4_nifti\*b0_',tasks{t},'*']);
    info_b0{ss,t} = length(b0files);
    for j = 1:length(b0files)
        %copy the file into our path (mkdir creates folder)
        source = [b0files(j).folder,'\',b0files(j).name];
        targetpath = [preprocessingpath,'b0\',subjectFolders(ss).name,'\'];
        mkdir(targetpath)
        % ! 
        % Copy file only if it is not in there already!
        if exist([targetpath,b0files(j).name],'file') == 0 
            copyfile(source,targetpath)
            disp(['SAVED file "',b0files(j).name,'"...in ',targetpath])
        elseif exist([targetpath,b0files(j).name],'file') == 2
            disp(['File "',b0files(j).name,'" already exists in ',targetpath])
        end
        
    end
  end
    %T1 files
    % ----------------
    t1files = dir([subjectFolders(ss).name,'\4_nifti\*_t1_*']);
    info_t1{ss,1} = length(t1files);
    for k = 1:length(t1files)
        %copy the file into our path (mkdir creates folder)
        source = [t1files(k).folder,'\',t1files(k).name];
        targetpath = [preprocessingpath,'t1\',subjectFolders(ss).name,'\'];
        mkdir(targetpath)
             % ! 
        % Copy file only if it is not in there already!
        if exist([targetpath,t1files(k).name],'file') == 0 
            copyfile(source,targetpath)
            disp(['SAVED file "',t1files(k).name,'"...in ',targetpath])
        elseif exist([targetpath,t1files(k).name],'file') == 2
            disp(['File "',t1files(k).name,'" already exists in ',targetpath])
        end
    end
end
info = [info_epi,info_b0,info_t1];
header =['subject',strcat('epi_',tasks),strcat('b0_',tasks),'t1'] ; 
countFiles = [header;info];
% Save log
cd (preprocessingpath)
xlswrite(['Log_files_',datestr(now,'dd-mm-yyyy'),'.xls'],countFiles)
