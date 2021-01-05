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
ntrials = 48 ; % expected number of trials
%% If no selected File is specified POPUP to select one or several files
 if isempty(selectedFiles)
    prompttxt = ['Select files from:  ',dirinput];
    [indices, values] = listdlg('PromptString',prompttxt,'ListString', {files.name},'ListSize',[10*length(prompttxt), 100*length({files.name}) ]); % popup       
    selectedFiles = {files(indices).name};
 end  
 
%%  loop thru
 for i=1:length(selectedFiles)
    logfile = selectedFiles{i};
    stats ={}; 
    file2read = dir([dirinput,'\',logfile]);
    if ~isempty(file2read) 
    % read data     
     T = readtable([file2read.folder,'\',file2read.name]);
     % old fix to variable names from previous files (keep commented for now)
     %fid = fopen([file2read.folder,'\',file2read.name]);
     %filehead = textscan(fid, '%s', 'delimiter', '\t','MultipleDelimsAsOne', 1);
     %filehead = filehead{1};
     %filehead = filehead(1:size(T,2))';
     %T.Properties.VariableNames = filehead;

      % Gather (allow files that had 1 or 2 trial less due to interrupted files)
      if size(T,1) ~= ntrials && size(T,1) ~= ntrials-1 && size(T,1) ~= ntrials-2
          disp([file2read.name,' skipped. It had ',num2str(size(T,1)),' trials'])
      else
          
       % Split by feedback type (a longer approach is used instead of 'groupsummary' since not all subjects will have errors)
            Thits =  T(T.fb == 1,:);
            Terrors = T(T.fb == 0,:);
            Tmiss = T(T.fb == 2,:);
            
            % gather in a table 
            myTable  = table({file2read.name(1:(end-7))},numel(Thits.fb),numel(Terrors.fb),numel(Tmiss.fb),round(mean(Thits.rt),3),round(mean(Terrors.rt),3),round(std(Thits.rt),3),round(std(Terrors.rt),3));
            myTable.Properties.VariableNames = {'file','N_hits','N_errors','N_miss','RT_hits','RT_errors','SD_hits','SD_errors'};
            myTable.Properties.VariableNames = strcat('file',[file2read.name(end-5:end-4),'_'], myTable.Properties.VariableNames); %Add block preffix
            disp(['printing subj ',file2read.name])
      end
          
       % Within block quartiles , thirds, halfs, bins
          labelquartiles  = discretize(1:ntrials,4)
          labelthirds  = discretize(1:ntrials,3)
          labelhalfs  = discretize(1:ntrials,2)
          
          
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


