clear; close all
% =====================================================================
%  Gather performance data from txt file  %G.Fraga Gonzalez(2020)
% ====================================================================
% - Select one or several files
% - Creates table with accuracy and RT , per block, quartiles,thirds
%%--------------------------------------------------------------------------------------------------------------
scripts= ('N:\studies\Grapholemo\Methods\Scripts\grapholemo\MR_statistics');addpath(scripts)
ntrials = 40 ;   
taskversion = 'fbl_A' ; %FBL_A, FBL_B
blocks  = {'block1','block2'};
 
dirinput    =   ['O:\studies\grapholemo\analysis\LEMO_GFG\mri\preprocessing\',taskversion];
diroutput   =    ['O:\studies\grapholemo\analysis\LEMO_GFG\beh\',taskversion];
 
files= dir([dirinput,'\**\logs\*.txt']);
subjects = strtok({files.name},'-'); % take from file name the subject id
mkdir(diroutput)
% OLD PROMPT- keep commented
%selectedFiles = {}; % If selected files = {} a  window for selection will popup (or you can give a filename)
% if isempty(selectedFiles)
%     prompttxt = ['Select one or several files from:  ',dirinput];
%     [indices, values] = listdlg('PromptString',prompttxt,'ListString', {files.name},'ListSize',[10*length(prompttxt), 100*length({files.name}) ]); % popup       
%     selectedFiles = {files(indices).name};
% end   
 %%  loop thru files
 gathered = {};
 
for i=1:length(subjects)
    subjectTable = {};
  for ii = 1:length(blocks)
     %create headers for this block
     header1 = string(strcat([taskversion,'_'],strcat(blocks{ii},{'_N_hits','_N_errors','_N_miss','_RT_hits','_RT_errors','_SD_hits','_SD_errors'})));
     header2 = string(strcat([taskversion,'_'],[strcat(blocks{ii},'_q',string(1:4),'_N_hits'),strcat(blocks{ii},'_th',string(1:3),'_N_hits'),strcat(blocks{ii},'_h',string(1:2),'_N_hits')]));
     % read data
     logfile = dir([dirinput,'\**\logs\',subjects{i},'*',taskversion,'*',blocks{ii},'.txt']);
     T = {};
     if ~isempty(logfile) 
         % Read file (allow files that had 1 or 2 trial less due to interrupted files)
         T = readtable([logfile.folder,'\',logfile.name]); 
         if(contains(taskversion,'B')) 
             fid = fopen([logfile.folder,'\',logfile.name]);
             filehead = textscan(fid, '%s', 'delimiter', '\t','MultipleDelimsAsOne', 1);
             filehead = filehead{1};
             filehead = filehead(1:size(T,2))';
             T.Properties.VariableNames = filehead;
         end
             if size(T,1) ~= ntrials && size(T,1) ~= ntrials-1 && size(T,1) ~= ntrials-2
                  disp([file2read.name,' skipped. Task must have been interrupted: it had ',num2str(size(T,1)),' trials'])
                  table2save = cell2table(cell(1,length(header1)+length(header2)));
                  table2save.Properties.VariableNames = [header1,header2];
             else

                  % Index of block quartiles , thirds, halfs, bins
                    quartiles  = discretize(1:ntrials,4)';
                    thirds  = discretize(1:ntrials,3)';
                    halfs  = discretize(1:ntrials,2)';            
                    T.quartiles = quartiles(1:size(T,1));% add new column with these indice 
                    T.thirds = thirds(1:size(T,1));
                    T.halfs = halfs(1:size(T,1));

                  % Split by feedback type (a longer approach is used instead of 'groupsummary' since not all subjects will have errors)
                    Thits =  T(T.fb == 1,:);
                    Terrors = T(T.fb == 0,:);
                    Tmiss = T(T.fb == 2,:);

                  % Gather accuracy and RTs of the block
                    myTable  = table(numel(Thits.fb),numel(Terrors.fb),numel(Tmiss.fb),round(mean(Thits.rt),3),round(mean(Terrors.rt),3),round(std(Thits.rt),3),round(std(Terrors.rt),3));
                    myTable.Properties.VariableNames = header1;

                  % Gather accuracy and RTs per quartiles,thirds, halfs
                    binsTable = table(numel(Thits.fb(Thits.quartiles==1)),numel(Thits.fb(Thits.quartiles==2)),numel(Thits.fb(Thits.quartiles==3)),numel(Thits.fb(Thits.quartiles==4)),...
                                        numel(Thits.fb(Thits.thirds==1)),numel(Thits.fb(Thits.thirds==2)),numel(Thits.fb(Thits.thirds==3)),...
                                            numel(Thits.fb(Thits.halfs==1)),numel(Thits.fb(Thits.halfs==2)));
                    binsTable.Properties.VariableNames = header2; 

                  % Merge  
                   table2save = [myTable,binsTable]; 
                   disp(['Created subj ',logfile.name]) 
              end

      else
         disp([ logfile.name,' does not exist or cannot be read'])
         table2save = cell2table(cell(1,length(header1)+length(header2)));
         table2save.Properties.VariableNames = [header1,header2];
     end
      
      subjectTable = [subjectTable,table2save];  
  end
 
%Save individual table   
  writetable(subjectTable, [diroutput,'\Summary_',taskversion,'_',subjects{i},'.csv'])

  if  isempty(gathered) 
        gathered= [gathered;[cell2table(subjects(i)),subjectTable]];
  elseif isempty(find(contains(gathered{:,1},subjects(i)))) %Add subjectoto group array if it is not there already
      % Gather in group table 
        gathered= [gathered;[cell2table(subjects(i)),subjectTable]];     
  end 
end
% save group table
gathered.Properties.VariableNames(1) = {'subject'};
writetable(gathered, [diroutput,'\Summary_task',taskversion,'.csv']);

 



