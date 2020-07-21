%--------------------------------------------------------------------------------------------------------------
% CHECK LOG files 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% - Make summary table of stimuli presented , times,etc to verify the
% design was correctly implemented
%--------------------------------------------------------------------------------------------------------------
clear all
close all

dirinput = 'O:\studies\allread\mri\raw_OK\';
diroutput =  'N:\Developmental_Neuroimaging\Troubleshooting\MR tasks';
cd (diroutput)
files = dir([dirinput,'/**/symCtrl/logs/*ImpSymb*.log']);
files = files(~contains({files.name},'B0.log'));

dat2save = {};

%% Loop thru files
for f = 1:length(files)
   fileinput = files(f);
   
   % open file read data 
   fileID = fopen([fileinput.folder '\' fileinput.name]);
   filedat = textscan(fileID,'%s %s %s %s %s %s %s %s %s %s %s %s %s', 'headerlines', 5 ,'delimiter','\t');
   fclose(fileID);
  
 % if (length(filedat{1})  == 1045)
    
       eventCodes = filedat{4};
      %get indexes of each stimuli
       isis= find(strcmp(eventCodes,'40'));

       let = find(strcmp(eventCodes,'60'));
       targ_let= find(strcmp(eventCodes,'65'));

       ffl= find(strcmp(eventCodes,'70'));
       targ_ffl=find(strcmp(eventCodes,'75'));

       fff = find(strcmp(eventCodes,'80'));
       targ_fff = find(strcmp(eventCodes,'85'));

       ffn = find(strcmp(eventCodes,'90'));
       targ_ffn=find(strcmp(eventCodes,'95'));

       % Counts
       counts = [length(let),length(ffl),length(fff),length(ffn),...
                        length(targ_let),length(targ_ffl),length(targ_fff),length(targ_ffn),length(isis)];
                    
       % Durations
       durations = filedat{8};
    if isempty(find(counts));
        minDur= zeros(1,9);
        maxDur= zeros(1,9);
        meanDur=[0];
    else
        
       minDur = [min(str2num((cell2mat(durations(let))))),...
                 min(str2num((cell2mat(durations(ffl))))),...
                 min(str2num((cell2mat(durations(fff))))),...
                 min(str2num((cell2mat(durations(ffn))))),...
                 min(str2num((cell2mat(durations(targ_let))))),...
                 min(str2num((cell2mat(durations(targ_ffl))))),...
                 min(str2num((cell2mat(durations(targ_fff))))),...
                 min(str2num((cell2mat(durations(targ_ffn))))),...
                 min(str2num((cell2mat(durations(isis)))))];

        maxDur = [max(str2num((cell2mat(durations(let))))),...
                 max(str2num((cell2mat(durations(ffl))))),...
                 max(str2num((cell2mat(durations(fff))))),...
                 max(str2num((cell2mat(durations(ffn))))),...
                 max(str2num((cell2mat(durations(targ_let))))),...
                 max(str2num((cell2mat(durations(targ_ffl))))),...
                 max(str2num((cell2mat(durations(targ_fff))))),...
                 max(str2num((cell2mat(durations(targ_ffn))))),...
                 max(str2num((cell2mat(durations(isis)))))];    

          meanDur = mean(str2num((cell2mat(durations(isis))))) ;
    end 

         % combine
         dat2save = [dat2save;[fileinput.name,num2cell(counts),num2cell(minDur),num2cell(maxDur),sprintf('%.2f',round(meanDur,2))]];          
%  else %sprintf(['skipping ',fileinput.name])
 % end
 end
      % combine in table
    header = {'file','nLET_e60', 'nFFLearn_e70','nFFfam_e80','nFFnew_e90',...
            'nTargetLET', 'nTargetFFLearn','nTargetFFfam','nTargetFFnew','nIsis',...
            'minDur_LET', 'minDur_FFLearn','minDur_FFfam','minDur_FFnew','minDur_Isis',...
            'minDur_targLET', 'minDur_targFFLearn','minDur_targFFfam','minDur_targFFnew',...            
            'maxDur_LET', 'maxDur_FFLearn','maxDur_FFfam','maxDur_FFnew','maxDur_Isis',...
            'maxDur_targLET', 'maxDur_targFFLearn','maxDur_targFFfam','maxDur_targFFnew','meanDur_targIsis'};
    
        
    table2save = cell2table(dat2save,'VariableNames',header);
    cd(diroutput)
    writetable(table2save,'Table_symCtrl_files.xlsx');