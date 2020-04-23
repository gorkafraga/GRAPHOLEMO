
clear all 
tic
rawDir = 'O:\studies\allread\mri\raw_OK\';
preprocessingDir= 'O:\studies\allread\mri\analysis_GFG\preprocessing\';
task = 'learn_2';

subjects = dir([preprocessingDir,task,'\epis\AR*']);
subjects = {subjects.name};


for i = 1:length(subjects) %19
   vp =  subjects{i};
   if ~isdir([rawDir,vp,'\learn'])
       disp([' no learn in ', vp]);
   else
     
    b0file =  dir([preprocessingDir,task,'\b0\',vp,'\*ec1_typ0.nii']);
    name_split = strsplit(b0file.name,'_');
    seqNum =  name_split{find(strcmp(name_split,'b0'))-2};
    fileIDNum = name_split{2};
    
      b02copy = dir([rawDir,vp,'\learn\rec_par\*',fileIDNum,'*_',num2str(seqNum),'_1_b0*.par']) ; 
   
   
   if length(b02copy) > 1
       disp(['failed in ',vp])
   else 
     copyfile([b02copy.folder,'\',b02copy.name],[preprocessingDir,task,'\b0\',vp])
      disp(['copied ',[preprocessingDir,task,'\b0\',vp,'\',b02copy.name,]])
   end
   end
end
toc
 
 