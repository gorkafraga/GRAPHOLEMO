function [onsets] = LEMO_symctrl_func_gatherOnsets(logfiles)
onsets={};
 
    for i=1:length(logfiles)
       logfile = logfiles{i};       
       % Read text file as table with variable names      
        opts = detectImportOptions(logfile);        
        opts.VariableNamesLine=1;
        dat= readtable(logfile,opts, 'ReadVariableNames', true);
        % Onsets are in the 7th column. Gather onsets for each condition: 
        onsets.targets = table2array(dat(contains(dat.VstimCaption,'Target','IgnoreCase',true),7))/1000;
        dat_noTargets = dat(~contains(dat.VstimCaption,'Target','IgnoreCase',true),:);
        onsets.fffam = table2array(dat_noTargets(contains(dat_noTargets.Condition,'FFfamiliar'),7))/1000;
        onsets.ffnew = table2array(dat_noTargets(contains(dat_noTargets.Condition,'FFnew'),7))/1000;
        onsets.fflearned = table2array(dat_noTargets(contains(dat_noTargets.Condition,'FFtrained'),7))/1000;
        onsets.letters = table2array(dat_noTargets(contains(dat_noTargets.Condition,'letter'),7))/1000;
         
    end
end