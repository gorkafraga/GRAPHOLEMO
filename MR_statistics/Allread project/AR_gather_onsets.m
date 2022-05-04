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
        
        %take 10 first and 10 last for positive
        if(find(cellfun(@length,{onsets(i).stimOnset_pos})>20)>0)
           onsets(i).stimOnset_pos_first10 = onsets(i).stimOnset_pos(1:10);
           onsets(i).stimOnset_pos_last10 = onsets(i).stimOnset_pos(end-9:end);
           onsets(i).fbOnset_pos_first10 = onsets(i).fbOnset_pos(1:10);
           onsets(i).fbOnset_pos_last10 = onsets(i).fbOnset_pos(end-9:end);
        end 
        
        % Separate Response for correct and incorrect trials
        onsets(i).respOnset_pos = currLog.respOnset(currLog.fb ==1)/1000;
        onsets(i).respOnset_neg = currLog.respOnset(currLog.fb ==0)/1000;

        %add session info(= actual block number, not necessarily block id)
        currLog.session = repmat(i,size(currLog,1),1);

        % Stim and fb onsets for halfs and quartiles of trials ------------------------------------------------------
        ntrials = height(currLog) ;
        % half
        onsets(i).stimOnset_half1 = onsets(i).stimOnset(1:ntrials/2);
        onsets(i).stimOnset_half2 = onsets(i).stimOnset(1+(ntrials/2):ntrials); % second half
          
        onsets(i).feedbackOnset_half1 = onsets(i).feedbackOnset(1:ntrials/2);
        onsets(i).feedbackOnset_half2 = onsets(i).feedbackOnset(1+(ntrials/2):ntrials); % second half
        %quartiles
        onsets(i).stimOnset_quartile1 = onsets(i).stimOnset(1:ntrials/4); % 1st quartile
        onsets(i).stimOnset_quartile2 = onsets(i).stimOnset(1+(ntrials/4):(ntrials/2)); % 2nd quartile  
        onsets(i).stimOnset_quartile3 = onsets(i).stimOnset(1+(ntrials/2):(ntrials - (ntrials/4)));  % 3rd quartile
        onsets(i).stimOnset_quartile4 = onsets(i).stimOnset(1+(ntrials - (ntrials/4)):ntrials);   % 4th quartile

        onsets(i).feedbackOnset_quartile1 = onsets(i).feedbackOnset(1:ntrials/4); % 1st quartile
        onsets(i).feedbackOnset_quartile2 = onsets(i).feedbackOnset(1+(ntrials/4):(ntrials/2)); % 2nd quartile  
        onsets(i).feedbackOnset_quartile3 = onsets(i).feedbackOnset(1+(ntrials/2):(ntrials - (ntrials/4)));  % 3rd quartile
        onsets(i).feedbackOnset_quartile4 = onsets(i).feedbackOnset(1+(ntrials - (ntrials/4)):ntrials);   % 4th quartile

        %thirds (excluding 1st trial so it's divisible by 3)
        stepsizethirds = (ntrials-1)/3;
        onsets(i).stimOnset_third1 = onsets(i).stimOnset(2:stepsizethirds+1); % 1st third
        onsets(i).stimOnset_third2 = onsets(i).stimOnset(2+stepsizethirds:(1+2*stepsizethirds)); % 2nd third 
        onsets(i).stimOnset_third3 = onsets(i).stimOnset((2+2*stepsizethirds):ntrials);  % 3nd third
        
        
        onsets(i).feedbackOnset_third1 = onsets(i).feedbackOnset(2:stepsizethirds+1); % 1st third
        onsets(i).feedbackOnset_third2 = onsets(i).feedbackOnset(2+stepsizethirds:(1+2*stepsizethirds)); % 2nd third 
        onsets(i).feedbackOnset_third3 = onsets(i).feedbackOnset((2+2*stepsizethirds):ntrials);  % 3nd third
                
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