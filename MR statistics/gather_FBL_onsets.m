function [onsets] = gather_FBL_onsets(logfiles,pathlogs)
onsets={};
for i=1:size(logfiles,1)
    logfile = logfiles(i,:);
    currLog = readtable([pathlogs,'\',logfile]);
    % Change units to seconds. Remove missing responses
    onsets(i).stimOnset = currLog.stimOnset/1000;
    onsets(i).feedbackOnset = currLog.feedbackOnset/1000;
    onsets(i).respOnset = currLog.respOnset(find(currLog.respOnset~=0))/1000;
   
    % Separate stimuli onset for correct and incorrect trials
     onsets(i).stimOnset_pos = currLog.stimOnset(find(currLog.fb ==1))/1000;
     onsets(i).stimOnset_neg = currLog.stimOnset(find(currLog.fb ==0))/1000;
     
    % Separate feedbackOnset for correct and incorrect trials
    onsets(i).fbOnset_pos = currLog.feedbackOnset(find(currLog.fb ==1))/1000;
    onsets(i).fbOnset_neg = currLog.feedbackOnset(find(currLog.fb ==0))/1000;
      
    %add session info(= actual block number, not necessarily block id)
    currLog.session = repmat(i,size(currLog,1),1);
  end