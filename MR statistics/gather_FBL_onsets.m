function [onset_tables] = gather_FBL_onsets(logfiles,pathlogs)
onset_tables={};
for i=1:size(logfiles,1)
    logfile = logfiles(i,:);
    currLog = readtable([pathlogs,'\',logfile]);
    %change time units
    currLog.stimOnset = currLog.stimOnset/1000;
    currLog.respOnset = currLog.respOnset/1000;
    currLog.feedbackOnset = currLog.feedbackOnset/1000;
    % set to missing respOnsets of 0 (missing responses)
    currLog.respOnset(find(currLog.respOnset==0))= NaN;
    
    % Separate stimuli onset for correct and incorrect trials
    currLog.stimOnset_cor = currLog.stimOnset;
    currLog.stimOnset_cor(find(currLog.fb ==0)) = NaN;
    
    currLog.stimOnset_inc = currLog.stimOnset;
    currLog.stimOnset_inc(find(currLog.fb ==1)) = NaN;
    % Separate feedbackOnset for correct and incorrect trials
    currLog.fbOnset_cor = currLog.feedbackOnset;
    currLog.fbOnset_cor(find(currLog.fb ==0)) = NaN;
    
    currLog.fbOnset_inc = currLog.feedbackOnset;
    currLog.fbOnset_inc(find(currLog.fb ==1)) = NaN; 
    
    %add session info(= actual block number, not necessarily block id)
    currLog.session = repmat(i,size(currLog,1),1);
    % add to array of tables
    onset_tables{i} = currLog;%onset info for each session stored in each cell
end