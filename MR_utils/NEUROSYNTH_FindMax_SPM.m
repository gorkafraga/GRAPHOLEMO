clear all
%% Make summary table
diroutput = 'O:\studies\grapholemo\analysis\LEMO_GFG\mri\regions_of_interest';
dirinput = 'O:\studies\grapholemo\analysis\LEMO_GFG\mri\regions_of_interest\neurosynth_images_downloads\';
files = dir([dirinput,'\*.nii']);
files = {files.name};

for f= 1:length(files)
fileinput = files{f};

%map = 'my_file.nii';
%voxthresh = 2.5;
%sizethresh = 10;
%npeaks = 3;

get_cluster_maxima(fileinput,2.5,10,3)








% Convert to table 
resTbl = cell2table(resTbl(2:size(resTbl,1),:),"VariableNames",resTbl(1,:));
%save 
writetable(resTbl,[diroutput, '\resTbl_', strrep(fileinput,'.nii','.xlsx')])
end