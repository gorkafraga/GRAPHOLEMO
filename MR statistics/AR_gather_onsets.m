function [onsets,params] = AR_gather_onsets(logfiles,currPathLogs)
onsets={};
params={};

    for i=1:length(logfiles)
        % ONSETS ------------------------------------------
        logfile = logfiles{i};
        currLog = readtable([currPathLogs,'\',logfile]);
        % Change units to seconds. Remove missing responses
        onsets(i).stimOnset = currLog.stimOnset/1000;
        onsets(i).feedbackOnset = currLog.feedbackOnset/1000;
        onsets(i).respOnset = currLog.respOnset(currLog.respOnset~=0)/1000;

        % Separate stimuli onset for correct and incorrect trials
        onsets(i).stimOnset_pos = currLog.stimOnset(currLog.fb ==1)/1000;
        onsets(i).stimOnset_neg = currLog.stimOnset(currLog.fb ==0)/1000;
        onsets(i).stimOnset_miss = currLog.stimOnset(currLog.fb ==2)/1000;
        
        % Separate feedbackOnset for correct and incorrect trials
        onsets(i).fbOnset_pos = currLog.feedbackOnset(currLog.fb ==1)/1000;
        onsets(i).fbOnset_neg = currLog.feedbackOnset(currLog.fb ==0)/1000;
        onsets(i).fbOnset_miss = currLog.feedbackOnset(currLog.fb ==2)/1000;

        % Separate Response for correct and incorrect trials
        onsets(i).respOnset_pos = currLog.respOnset(currLog.fb ==1)/1000;
        onsets(i).respOnset_neg = currLog.respOnset(currLog.fb ==0)/1000;

        %add session info(= actual block number, not necessarily block id)
        currLog.session = repmat(i,size(currLog,1),1);

        % Parametric modulators  ------------------------------------------
        params(i).rt = currLog.rt/1000;
        params(i).rt(currLog.fb==2) = 2.5;
        params(i).missResp = zeros(length(params(i).rt),1);
        params(i).missResp(currLog.fb==2) = 1;
        %params(i).missResp = 1;
        
        %params(i).rt_neg = zeros(length(params(i).rt),1);
        %params(i).rt_neg(currLog.fb==0) = currLog.rt(currLog.fb==0);
        params(i).rt_neg = currLog.rt(currLog.fb==0);
        
        %params(i).rt_pos = zeros(length(params(i).rt),1);
        %params(i).rt_pos(currLog.fb==1) = currLog.rt(currLog.fb==1);
        params(i).rt_pos = currLog.rt(currLog.fb==1);
    end
end