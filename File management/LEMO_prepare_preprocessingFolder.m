clear all 
% Copy raw  MRI data to PREPROCESSING folder
%==========================================================================
% - Find niftis and associated logs
% - Copy to preprocessing folder with TASK/Run/subject/data type
% - Rename files so they follow BIDS compact format
sourcePath = 'O:\studies\grapholemo\raw\';
destinationPath = 'G:\GRAPHOLEMO\lemo_preproc';
renameNiftisForPreprocessing = 1;
subject = {'gpl033'};


%recParNames = { 'b0_fbl','fbl_parta','fbl_partb','b0_symctrl','1_symcontrol','t13d','audiotest'};
% clean up last slash if specified
if strcmp(sourcePath(end),'\')  sourcePath= sourcePath(1:end-1); end 
if strcmp(destinationPath(end),'\'); destinationPath= destinationPath(1:end-1); end 
%%  
mkdir(destinationPath)
for s= 1:length(subject)
    currSubj = subject{s};
    niftifiles = dir([sourcePath,'\',currSubj,'\**\*.nii']);
    for ff = 1:length(niftifiles) 
          %feedback learning and b0s
          if ~isempty(strfind(niftifiles(ff).name,'_fbl_a'))
                taskpattern = niftifiles(ff).name(strfind(niftifiles(ff).name,'_fbl'):(strfind(niftifiles(ff).name,'.nii')-1));
                newtaskfolder = 'fbl_a';     
                newname = [upper(currSubj),taskpattern,'_bold.nii'];
                newfoldername = ([destinationPath,'\',newtaskfolder,'\',currSubj,'\func\']);
                mkdir(newfoldername)
                copyfile([niftifiles(ff).folder,'\',niftifiles(ff).name],[newfoldername,newname])

                
          elseif ~isempty(strfind(niftifiles(ff).name,'_fbl_b'))
                taskpattern = niftifiles(ff).name(strfind(niftifiles(ff).name,'_fbl'):(strfind(niftifiles(ff).name,'.nii')-1));
                newtaskfolder = 'fbl_b'; 
                newname = [upper(currSubj),taskpattern,'_bold.nii'];
                newfoldername = ([destinationPath,'\',newtaskfolder,'\',currSubj,'\func\']);
                mkdir(newfoldername)
                copyfile([niftifiles(ff).folder,'\',niftifiles(ff).name],[newfoldername,newname])
                
                                
                       
          elseif ~isempty(strfind(niftifiles(ff).name,'_b0_fbl'))
                taskpattern = niftifiles(ff).name(strfind(niftifiles(ff).name,'_fbl')+4:(strfind(niftifiles(ff).name,'.nii')-1));
                newtaskfolder = 'fbl_a';
                newname = [upper(currSubj),'_fbl_b0_run1',taskpattern,'.nii'];
                newfoldername = ([destinationPath,'\',newtaskfolder,'\',currSubj,'\func\b0\']);
                mkdir(newfoldername)
                copyfile([niftifiles(ff).folder,'\',niftifiles(ff).name],[newfoldername,newname])
                
                newtaskfolder = 'fbl_b';
                newname = [upper(currSubj),'_fbl_b0_run1',taskpattern,'.nii'];
                newfoldername = ([destinationPath,'\',newtaskfolder,'\',currSubj,'\func\b0\']);
                mkdir(newfoldername)
                copyfile([niftifiles(ff).folder,'\',niftifiles(ff).name],[newfoldername,newname])
                
            elseif ~isempty(strfind(niftifiles(ff).name,'_b02_fbl'))
                taskpattern = niftifiles(ff).name(strfind(niftifiles(ff).name,'_fbl')+4:(strfind(niftifiles(ff).name,'.nii')-1));
                newtaskfolder = 'fbl_a';
                newname = [upper(currSubj),'_fbl_b0_run2',taskpattern,'.nii'];
                newfoldername = ([destinationPath,'\',newtaskfolder,'\',currSubj,'\func\b0\']);
                mkdir(newfoldername)
                copyfile([niftifiles(ff).folder,'\',niftifiles(ff).name],[newfoldername,newname])
                
                newtaskfolder = 'fbl_b';
                newname = [upper(currSubj),'_fbl_b0_run2',taskpattern,'.nii'];
                newfoldername = ([destinationPath,'\',newtaskfolder,'\',currSubj,'\func\b0\']);
                mkdir(newfoldername)
                copyfile([niftifiles(ff).folder,'\',niftifiles(ff).name],[newfoldername,newname])
                
                
           %symbol control and b0s      
          elseif ~isempty(strfind(niftifiles(ff).name,'_symctrl_pre'))
              newtaskfolder = 'symCtrl_pre';
                taskpattern = niftifiles(ff).name(strfind(niftifiles(ff).name,'_symctrl'):(strfind(niftifiles(ff).name,'.nii')-1));
                if ~isempty(strfind(niftifiles(ff).name,'_b0_'))
                    newname = [upper(currSubj),strrep(taskpattern,'symctrl_pre','b0_symctrl_pre'),'.nii'];                    
                    newfoldername = ([destinationPath,'\',newtaskfolder,'\',currSubj,'\func\b0\']);
                    mkdir(newfoldername)
                    copyfile([niftifiles(ff).folder,'\',niftifiles(ff).name],[newfoldername,newname])
               elseif ~isempty(strfind(niftifiles(ff).name,'_b02_'))
                    newname = [upper(currSubj),strrep(taskpattern,'symctrl_pre','b02_symctrl_pre'),'.nii'];                    
                    newfoldername = ([destinationPath,'\',newtaskfolder,'\',currSubj,'\func\b0\']);                              
                    mkdir(newfoldername)
                    copyfile([niftifiles(ff).folder,'\',niftifiles(ff).name],[newfoldername,newname])
                else
                    newname = [upper(currSubj),taskpattern,'_bold.nii'];
                    newfoldername = ([destinationPath,'\',newtaskfolder,'\',currSubj,'\func\']);
                    mkdir(newfoldername)
                    copyfile([niftifiles(ff).folder,'\',niftifiles(ff).name],[newfoldername,newname])
                end 
            % symbol control post  
             elseif ~isempty(strfind(niftifiles(ff).name,'_symctrl_post'))
              newtaskfolder = 'symCtrl_post';
                taskpattern = niftifiles(ff).name(strfind(niftifiles(ff).name,'_symctrl'):(strfind(niftifiles(ff).name,'.nii')-1));
                 if ~isempty(strfind(niftifiles(ff).name,'_b0_'))
                    newname = [upper(currSubj),strrep(taskpattern,'symctrl_post','b0_symctrl_post'),'.nii'];                    
                    newfoldername = ([destinationPath,'\',newtaskfolder,'\',currSubj,'\func\b0\']);
                    mkdir(newfoldername)
                    copyfile([niftifiles(ff).folder,'\',niftifiles(ff).name],[newfoldername,newname])
                    
               elseif ~isempty(strfind(niftifiles(ff).name,'_b02_'))
                    newname = [upper(currSubj),strrep(taskpattern,'symctrl_post','b02_symctrl_post'),'.nii'];                    
                    newfoldername = ([destinationPath,'\',newtaskfolder,'\',currSubj,'\func\b0\']);                              
                    mkdir(newfoldername)
                    copyfile([niftifiles(ff).folder,'\',niftifiles(ff).name],[newfoldername,newname])
                else
                    newname = [upper(currSubj),taskpattern,'_bold.nii'];
                    newfoldername = ([destinationPath,'\',newtaskfolder,'\',currSubj,'\func\']);
                    mkdir(newfoldername)
                    copyfile([niftifiles(ff).folder,'\',niftifiles(ff).name],[newfoldername,newname])
                end 
          %structural       
          elseif ~isempty(strfind(niftifiles(ff).name,'_t13d'))
                  newfolder = 'anat';
                  newname = [upper(currSubj),'_T1w.nii'];
                  
                  newfoldername = ([destinationPath,'\fbl_a\',currSubj,'\anat\']);
                  mkdir(newfoldername)
                  copyfile([niftifiles(ff).folder,'\',niftifiles(ff).name],[newfoldername,newname])
                  
                  newfoldername = ([destinationPath,'\fbl_b\',currSubj,'\anat\']);
                  mkdir(newfoldername)
                  copyfile([niftifiles(ff).folder,'\',niftifiles(ff).name],[newfoldername,newname])
                  
                  newfoldername = ([destinationPath,'\symCtrl_pre\',currSubj,'\anat\']);
                  mkdir(newfoldername)
                  copyfile([niftifiles(ff).folder,'\',niftifiles(ff).name],[newfoldername,newname])
                  
                  newfoldername = ([destinationPath,'\symCtrl_post\',currSubj,'\anat\']);
                  mkdir(newfoldername)
                  copyfile([niftifiles(ff).folder,'\',niftifiles(ff).name],[newfoldername,newname])
          end
        disp(newname)
    end
end
 
%% FIND PAR from b0 files
mkdir(destinationPath)
for s= 1:length(subject)
    currSubj = subject{s};
    b0parfiles = dir([sourcePath,'\',currSubj,'\**\*b0*.par']);
    for ff = 1:length(b0parfiles) 
          %feedback learning and b0s
          if  ~isempty(strfind(b0parfiles(ff).name,'_b0_fbl.par'))
                taskpattern = b0parfiles(ff).name;
                newtaskfolder = 'fbl_a';
                newname = strrep(taskpattern,'_b0_fbl','_b0_fbl_run1');
                newfoldername = ([destinationPath,'\',newtaskfolder,'\',currSubj,'\func\b0\']);
                mkdir(newfoldername)
                copyfile([b0parfiles(ff).folder,'\',b0parfiles(ff).name],[newfoldername,newname])
                clear newname
                
                newtaskfolder = 'fbl_b';
                newname = strrep(taskpattern,'_b0_fbl','_b0_fbl_run1');
                newfoldername = ([destinationPath,'\',newtaskfolder,'\',currSubj,'\func\b0\']);
                mkdir(newfoldername)
                copyfile([b0parfiles(ff).folder,'\',b0parfiles(ff).name],[newfoldername,newname])
               clear newname
                
            elseif ~isempty(strfind(b0parfiles(ff).name,'_b02_fbl'))
                 taskpattern = b0parfiles(ff).name;
                newtaskfolder = 'fbl_a';
                newname = strrep(taskpattern,'_b02_fbl','_b0_fbl_run2');
                newfoldername = ([destinationPath,'\',newtaskfolder,'\',currSubj,'\func\b0\']);
                mkdir(newfoldername)
                copyfile([b0parfiles(ff).folder,'\',b0parfiles(ff).name],[newfoldername,newname])
                clear newname
                
                newtaskfolder = 'fbl_b';
                newname = strrep(taskpattern,'_b02_fbl','_b0_fbl_run2');
                newfoldername = ([destinationPath,'\',newtaskfolder,'\',currSubj,'\func\b0\']);
                mkdir(newfoldername)
                copyfile([b0parfiles(ff).folder,'\',b0parfiles(ff).name],[newfoldername,newname])
                clear newname
                
           %symbol control   b0s      
          elseif ~isempty(strfind(b0parfiles(ff).name,'_symctrl_pre'))
              taskpattern = b0parfiles(ff).name;
              newname = b0parfiles(ff).name;
              newtaskfolder = 'symCtrl_pre';
              newfoldername = ([destinationPath,'\',newtaskfolder,'\',currSubj,'\func\b0\']);
              mkdir(newfoldername)
              copyfile([b0parfiles(ff).folder,'\',b0parfiles(ff).name],[newfoldername,newname])
              clear newname
           elseif ~isempty(strfind(b0parfiles(ff).name,'_symctrl_post'))
              taskpattern = b0parfiles(ff).name;
              newname = b0parfiles(ff).name;
              newtaskfolder = 'symCtrl_post';
              newfoldername = ([destinationPath,'\',newtaskfolder,'\',currSubj,'\func\b0\']);
              mkdir(newfoldername)
              copyfile([b0parfiles(ff).folder,'\',b0parfiles(ff).name],[newfoldername,newname])
              clear newname
  
          end
     end
end

%% FIND Logfiles
for s= 1:length(subject)
    currSubj = subject{s};
    logfiles = [dir([sourcePath,'\',currSubj,'\**\',currSubj,'*.log']);dir([sourcePath,'\',currSubj,'\**\',currSubj,'*.txt'])];
    for ff = 1:length(logfiles) 
          %feedback learning and b0s
         if  contains(logfiles(ff).name,'fbl_a',"IgnoreCase",true)
                newtaskfolder = 'fbl_a';
                newfoldername = ([destinationPath,'\',newtaskfolder,'\',currSubj,'\func\']);
               % mkdir(newfoldername)
                copyfile([logfiles(ff).folder,'\',logfiles(ff).name],[newfoldername,logfiles(ff).name])
                clear newname
         elseif contains(logfiles(ff).name,'fbl_b',"IgnoreCase",true)
                newtaskfolder = 'fbl_b';
                newfoldername = ([destinationPath,'\',newtaskfolder,'\',currSubj,'\func\']);
               % mkdir(newfoldername)
                copyfile([logfiles(ff).folder,'\',logfiles(ff).name],[newfoldername,logfiles(ff).name])
                clear newname
         elseif contains(logfiles(ff).name,'symCtrl_pre',"IgnoreCase",true)
                newtaskfolder = 'symCtrl_pre';
                newfoldername = ([destinationPath,'\',newtaskfolder,'\',currSubj,'\func\logs\']);
                mkdir(newfoldername)
                copyfile([logfiles(ff).folder,'\',logfiles(ff).name],[newfoldername,logfiles(ff).name])
                clear newname
         elseif contains(logfiles(ff).name,'symCtrl_post',"IgnoreCase",true)
                newtaskfolder = 'symCtrl_post';
                newfoldername = ([destinationPath,'\',newtaskfolder,'\',currSubj,'\func\logs\']);
                mkdir(newfoldername)
                copyfile([logfiles(ff).folder,'\',logfiles(ff).name],[newfoldername,logfiles(ff).name])
                clear newname
                    
         end
    end
end

