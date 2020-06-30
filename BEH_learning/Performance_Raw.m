%.-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-. 
%
% GATHER RAW PERFORMANCE FROM LEARNING TASK
%
%.-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-. 
% %G.Fraga-Gonzalez(2020)
%------------------------------------------------------------------------- 
clear all
dirinput = 'O:\studies\allread\mri\analysis_GFG\stats\task\logs_raw' ;
diroutput = 'O:\studies\allread\mri\analysis_GFG\stats\task\logs_raw' ;
blocks2read  = {'B1','B2','B3','B4','B1-1','B2-2','B3-1','B4-1'};
cd (dirinput)
sfiles = dir([dirinput,'\*AR*']);
subjects = unique({sfiles.name});
% LOOP THRU SUBJECTS AND BLOCKS 
stats ={};
ncols = 8;
for i = 1:length(subjects) 
    for ii=1:length(blocks2read)
        file2read = dir([dirinput,'\*',subjects{i},'\*',blocks2read{ii},'.txt']);
        % read data 
        if ~isempty(file2read) 
        T = readtable([file2read.folder,'\',file2read.name]);
            % Gather (if not enought trials in this block fill the stats with NAs)
              if size(T,1) ~= 40 && size(T,1) ~=39 && size(T,1) ~=38
                  disp([file2read.name,' skipped. It had ',num2str(size(T,1)),' trials'])
              else
                  % separate types of trials 
                  Thits =  T(T.fb == 1,:);
                  Terrors = T(T.fb == 0,:);
                  Tmiss = T(T.fb == 2,:);
                  % Add data to the corresponding rows and columns of array
                  dat2add = {numel(Thits.rt),round(mean(Thits.rt),3),round(std(Thits.rt),3),...
                            numel(Terrors.rt),round(mean(Terrors.rt),3),round(std(Terrors.rt),3),numel(Tmiss.rt)};
                  stats(i,1:ncols,ii) = [file2read.name,dat2add];
                  disp(['printing subj ', num2str(i),' block ',num2str(ii)])
               end
        else 
            disp([file2read.name,' is empty'])
        end
    end
end
stats = reshape(stats,size(stats,1),size(stats,2)*size(stats,3)); % Reshape to a 2 dimensions array 
% create header (Note order must be consistent with 'dat2add' variable
header = {};
for k = 1:length(blocks2read)
    header = [header,strcat([blocks2read{k},'_'],{'file','N_hits','RT_hits','SD_hits','N_errors','RT_errors','SD_errors','N_miss'})];
    %replace hyphen by "_" to avoid problem with variable names
    header = strrep(header,'-','_');
end
% Combine in a table
Tstats = cell2table(stats);
Tstats.Properties.VariableNames = header;

%save 
cd(diroutput)
writetable(Tstats,'_Performance_raw_stats.xlsx')
