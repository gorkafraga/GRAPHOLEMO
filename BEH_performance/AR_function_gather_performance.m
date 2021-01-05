function [stats, Tstats] = AR_function_gather_performance(logfiles,currPathLogs)
stats ={};
ncols = 8;

   for i=1:length(logfiles)
        logfile = logfiles{i};
        file2read = dir([currPathLogs,'\',logfile]);
        % read data 
        if ~isempty(file2read) 
        T = readtable([file2read.folder,'\',file2read.name]);
            % Gather (if not enought trials in this block fill the stats with NAs)
              if size(T,1) ~= 40 && size(T,1) ~=39 && size(T,1) ~=38 && size(T,1) ~=37
                  disp([file2read.name,' skipped. It had ',num2str(size(T,1)),' trials'])
              else
                  % separate types of trials 
                  Thits =  T(T.fb == 1,:);
                  Terrors = T(T.fb == 0,:);
                  Tmiss = T(T.fb == 2,:);
                  % Add data to the corresponding rows and columns of array
                  dat2add = {numel(Thits.rt),round(mean(Thits.rt),3),round(std(Thits.rt),3),...
                            numel(Terrors.rt),round(mean(Terrors.rt),3),round(std(Terrors.rt),3),numel(Tmiss.rt)};
                  stats(1,1:ncols,i) = [file2read.name,dat2add];
                  disp(['printing subj ',file2read.name,' block ',num2str(i)])
               end
        else 
            disp([file2read.name,' is empty'])
        end
   end
stats = reshape(stats,size(stats,1),size(stats,2)*size(stats,3)); % Reshape to a 2 dimensions array 
% create header (Note order must be consistent with 'dat2add' variable
header = {};
for k = 1:length(logfiles)
    
    header = [header,strcat(['file',num2str(k)],{'name','N_hits','RT_hits','SD_hits','N_errors','RT_errors','SD_errors','N_miss'})];
    %replace hyphen by "_" to avoid problem with variable names
    header = strrep(header,'-','_');
end
% Combine in a table
Tstats = cell2table(stats);
Tstats.Properties.VariableNames = header;
%save 
writetable(Tstats,'_Performance_stats.xlsx')
end