block = 4
list = dir(['G:\preprocessing\block_',num2str(block),'\epis\*\*.nii']);
list2 = dir(['O:\studies\allread\mri\preprocessed_LearningTask\block_',num2str(block),'\epis\*\*.nii']);

%% for ss=1:length( unique({list.folder}))
count = 0;
for f=1:length(list)
    
    if (regexp(list(f).name,'^s6wuam*')==1)        
        count= count + 1;
       disp([list(f).folder,' is fine (',num2str(count),')'])
    end
           list(f).subject = list(f).folder((end-5):end);

end
disp(['N=',num2str(length(unique({list.folder})))])
subjects = unique({list.subject});
%% for ss=1:length( unique({list.folder}))
count = 0;
for f=1:length(list2)
    
    if (regexp(list2(f).name,'^s6wuam*')==1)        
        count= count + 1;
       disp([list2(f).folder,' is fine (',num2str(count),')'])
    end
               list2(f).subject = list2(f).folder((end-5):end);

    
end
disp(['N=',num2str(length(unique({list2.folder})))])
subjects2 = unique({list2.subject});
 
%% Copy 
subjects2add = setdiff(subjects, subjects2);
 for i=1:length(subjects2add)
    sourcedir = ['O:\studies\allread\mri\preprocessed_LearningTask\block_',num2str(block),'\T1w\',subjects2add{i}];
    destindir = ['G:\preprocessing\block_',num2str(block),'\T1w\',subjects2add{i}];
%    copyfile(destindir, sourcedir)
    clear destindir sourcedir
    
    sourcedir = ['O:\studies\allread\mri\preprocessed_LearningTask\block_',num2str(block),'\epis\',subjects2add{i}];
    destindir = ['G:\preprocessing\block_',num2str(block),'\epis\',subjects2add{i}];
%    copyfile(destindir, sourcedir)
    clear destindir sourcedir
    
    sourcedir = ['O:\studies\allread\mri\preprocessed_LearningTask\block_',num2str(block),'\b0\',subjects2add{i}];
    destindir = ['G:\preprocessing\block_',num2str(block),'\b0\',subjects2add{i}];
%    copyfile(destindir, sourcedir)
    clear destindir sourcedir
 end
 
 
 %% Check which files are not the same  
files2add = setdiff({list.name}, {list2.name})

  
 
 