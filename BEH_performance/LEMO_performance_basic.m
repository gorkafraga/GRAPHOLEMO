clear all
close all
%--------------------------------------------------------------------------------------------------------------
%  Gather performance data from log/txt files
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %G.Fraga Gonzalez(2020)
%--------------------------------------------------------------------------------------------------------------
scripts= ('N:\studies\Grapholemo\Methods\Scripts\grapholemo\MR_statistics');
addpath(scripts)
dirinput = 'O:\studies\grapholemo\LEMO_Pilot\A';
diroutput = 'O:\studies\grapholemo\LEMO_Pilot\gathered\advanced' ;
files = dir([dirinput,'\*.txt']);
selectedFiles = {}; % If selected files = {} a  window for selection will popup

%% If no selected File is specified POPUP to select files
 if isempty(selectedFiles)
    prompttxt = ['Select files from:  ',dirinput];
    [indices, values] = listdlg('PromptString',prompttxt,'ListString', {files.name},'ListSize',[10*length(prompttxt), 100*length({files.name}) ]); % popup       
    selectedFiles = {files(indices).name};
 end

  
%%  loop thru
 for i=1:length(selectedFiles)
    logfile = selectedFiles{i};
    stats ={};
    ncols = 8;
    file2read = dir([dirinput,'\',logfile]);
    if ~isempty(file2read) 
    % read data     
        T = readtable([file2read.folder,'\',file2read.name]);
     % fix those variable names
     fid = fopen([file2read.folder,'\',file2read.name]);
     filehead = textscan(fid, '%s', 'delimiter', '\t','MultipleDelimsAsOne', 1);
     filehead = filehead{1};
     filehead = filehead(1:size(T,2))';
     T.Properties.VariableNames = filehead;
     
            % Gather (if not enought trials in this block fill the stats with NAs)
              if size(T,1) ~= 48 && size(T,1) ~=47 && size(T,1) ~=46
                  disp([file2read.name,' skipped. It had ',num2str(size(T,1)),' trials'])
              else
                  % separate types of trials 
                  Thits =  T(T.fb == 1,:);
                  Terrors = T(T.fb == 0,:);
                  Tmiss = T(T.fb == 2,:);
                  % Add data to the corresponding rows and columns of array
                  dat2add = {numel(Thits.rt),round(mean(Thits.rt),3),round(std(Thits.rt),3),...
                            numel(Terrors.rt),round(mean(Terrors.rt),3),round(std(Terrors.rt),3),numel(Tmiss.rt)};
                  stats(1,1:ncols) = [file2read.name,dat2add];
                  disp(['printing subj ',file2read.name])
              end
    else 
        disp([file2read.name,' is empty'])
    end
    % create header (Note order must be consistent with 'dat2add' variable
    header = {};
    header = [header,strcat(['file'],{'name','N_hits','RT_hits','SD_hits','N_errors','RT_errors','SD_errors','N_miss'})];
    %replace hyphen by "_" to avoid problem with variable names
    header = strrep(header,'-','_');
    
    % Combine in a table
    Tstats = cell2table(stats);
    Tstats.Properties.VariableNames = header;
    
    %save 
    %writetable(Tstats,['Summary_',file2read.name])
    %writetable(Tstats,strrep(['Summary_',file2read.name],'.txt','.xls'))
    cd(diroutput)
    writetable(Tstats,strrep(['Summary_',file2read.name],'.txt','.csv'))
        
 end


