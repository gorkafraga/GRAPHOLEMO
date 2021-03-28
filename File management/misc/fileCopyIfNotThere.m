clear all
block  = 1
list = dir(fullfile(['G:\preprocessing\block_',num2str(block),'\epis\**\**']));
listfiles = list(~[list.isdir]);
count = 0 ;
for ff= 1:length(listfiles)
    
    source = [listfiles(ff).folder,'\',listfiles(ff).name];
    destination = strrep(source,'G:\preprocessing\','O:\studies\allread\mri\preprocessed_LearningTask\');
   
   if isempty(dir(destination))
       count = count + 1 ;
       mkdir(fileparts(destination))
       copyfile(source,destination)
       disp(['copying ', destination])
   end 
end 

 