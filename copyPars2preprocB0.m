
clear all 
tic
rawDir = 'O:\studies\allread\mri\raw_OK\';
preprocessingDir= 'O:\course\biokurs20\MRI\raw_AR_localizer_ready_to preproc\';
task = 'symCtrl';

subjects = dir([preprocessingDir,'localizer\epis\AR*']);
subjects = {subjects.name};

for i = 1:length(subjects) %19
   vp =  subjects{i};
   if ~isdir([rawDir,vp,'\',task])
       disp([' no learn in ', vp]);
   else
     
    b0file =  dir([preprocessingDir,'localizer\b0\',vp,'\*ec1_typ0.nii']);
    name_split = strsplit(b0file.name,'_');
    seqNum =  name_split{find(strcmp(name_split,'b0'))-2};
    %fileIDNum = name_split{2};
    
      b02copy = dir([rawDir,vp,'\symCtrl\rec_par\*_',num2str(seqNum),'_1_b0*.par']) ; 
   
   
   if length(b02copy) > 1
       disp(['failed in ',vp])
   else 
     copyfile([b02copy.folder,'\',b02copy.name],[preprocessingDir,'localizer\b0\',vp])
      disp(['copied ',[preprocessingDir,task,'\b0\',vp,'\',b02copy.name,]])
   end
   end
end
toc
 
 