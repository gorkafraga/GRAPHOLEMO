%Script to display subjects with double b0
%clear; close all

dirinput= 'F:\ERead_sd\preprocessing\b0\';
%subjects
d=dir('F:\ERead_sd\preprocessing\epis');
subject_directory=d([d().isdir]==1);
subject_directory=subject_directory(~ismember({subject_directory().name},{'.','..'}));
subject={subject_directory.name};

%% FIND NIFTIs from b0 and copy them into "b0_double" folder, write excel table with doubles
t=1;
for i=1:numel(subject)
  sfiles = dir([dirinput,subject{i},'\*ec1_typ0.nii']);
  if numel(sfiles)>1
      for f = 1:length(sfiles)
       destinationFolder = ['F:\ERead_sd\data_quality\double_b0\',subject{i}];
%        mkdir(destinationFolder)
%        copyfile([sfiles(f).folder,'\',sfiles(f).name],[destinationFolder,'\',sfiles(f).name]) 
       xlswrite('double_b0', subject(i),1,sprintf('A%d',t))
       xlswrite('double_b0', {sfiles.name},1,sprintf('B%d',t))
       if isdir(['F:\ERead_sd\data_quality\realign_check\',subject{i}])
           sfiles_epi=dir(['F:\ERead_sd\data_quality\realign_check\',subject{i},'\*.png']);
           xlswrite('double_b0',{sfiles_epi.name},1,sprintf('D%d',t));
       else
           sfiles_epi=dir(['F:\ERead_sd\preprocessing\epis\',subject{i},'\*.nii']);
           xlswrite('double_b0',{sfiles_epi.name},1,sprintf('D%d',t));           
       end
      end
      t=t+1;
  end
end

if ~strcmp(pwd,'F:\ERead_sd\data_quality\double_b0\')
movefile('double_b0.xls','F:\ERead_sd\data_quality\double_b0\')
end
