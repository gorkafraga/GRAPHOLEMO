%% Define directories
scriptRec2nifti = 'N:\studies\Grapholemo\Methods\Scripts\grapholemo\MR_utils\rec2nifti.pl';
sourcefolder = 'N:\studies\Grapholemo\Recruitment\Incidental finding'
sourcefilename = [dir([sourcefolder,'\*_t13d*.rec']),dir([sourcefolder,'/*b0*.rec']),dir([sourcefolder,'/*uvalemosoft*.rec'])];
destinationfolder = sourcefolder; 

%% Go to destination folder and run perlscript on each file
cd (destinationfolder)
for f=1:length(sourcefilename)
    perl(scriptRec2nifti,'-s',[sourcefilename(f).folder,'\',sourcefilename(f).name]) % call perl script to convert to nifti
end

% Move or copy file into the destination 
%copyfile(strrep(sourcefilename,'.rec','.nii'),destinationfolder)
%movefile(strrep(sourcefilename,'.rec','.nii'),destinationfolder)
