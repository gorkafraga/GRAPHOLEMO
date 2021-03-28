clear all 
%% Copy fullpath of specific files to be deleted (does not delete)
%==========================================================================
rawpath = 'O:\studies\allread\raw_data';
diroutput = 'N:\Users\gfraga\0.Misc';
cd (rawpath)
timepoint = {'T1','T2','T3'};

%%
infopaths = struct('timepoint',{},'fullfile',{},'size',{});
 % Loop per time point folder
 for i = 1:length(timepoint) 
infopaths(i).timepoint = timepoint{i};
timepoint_files = dir(timepoint{i});
timepoint_files = {timepoint_files.name};
    
   % Search subfolders of current timepoint folder
    tmpAllFiles = {};
    for j = 1:length(timepoint_files)
            %Only search in subfolders named with 4 characters            
            if (length(timepoint_files{j})==4)
                targetfiles = dir([timepoint{i},'\',timepoint_files{j},'\*\eeg\exported\*.mff']);            
                if ~isempty(targetfiles) 
                    % store file name and path in temporary cell array
                    tmpFullname = {};
                    tmpSize = {};
                    for jj = 1:size(targetfiles,1)
                         tmpFullname{jj} =  [targetfiles(jj).folder,'\',targetfiles(jj).name];
                         tmp = dir([tmpFullname{jj},'\*.bin']);
                         tmpSize{jj} = (tmp.bytes/1024)/1024 ;
                    end
                     tmpAllFiles = [tmpAllFiles;[tmpFullname;tmpSize]'];
                 end
            end     
    end 
   infopaths(i).fullfile = tmpAllFiles(:,1);
   infopaths(i).size = tmpAllFiles(:,2);
 end
%% 
% Save log in XLS
cd (diroutput)
for k = 1:length(infopaths)
    T = [infopaths(k).fullfile,infopaths(k).size];
    xlswrite(['Log_redundant_',timepoint{k},'.xls'],T)
end
    

