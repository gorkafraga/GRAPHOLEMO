clear all 
%% MRI RAW DATA
%==========================================================================
% - Convert to nifti
% - Arrange in folders 
% - Copy and get realignment plots and RP parameters
scriptRec2nifti = 'N:\studies\Grapholemo\Methods\Scripts\grapholemo\MR_utils\rec2nifti.pl';
rawSourcePath = 'O:\studies\grapholemo\raw\mrz_transfer\';
rawDestinationPath = 'O:\studies\grapholemo\raw\';
saverealign=1;

files = dir([rawSourcePath,'\*.rec']);
selectedFiles = {}; % If selected files = {} a  window for selection will popup (or you can give a filename)
 if isempty(selectedFiles)
     prompttxt = ['Select one or several files from:  ',rawSourcePath];
      %[indices, values] = listdlg('PromptString',prompttxt,'ListString', {files.name});       
     [indices, values] = listdlg('PromptString',prompttxt,'ListString', {files.name},'ListSize',[5*length(prompttxt), 20*length({files.name}) ]); % popup       
     selectedFiles = files(indices);
 end   
%%
for f= 1:length(selectedFiles)
                      
                          perl(scriptRec2nifti,'-s',[selectedFiles(f).folder,'\',selectedFiles(f).name])
                     
end