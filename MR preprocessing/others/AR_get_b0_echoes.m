function [echoes] = AR_get_b0_echoes(currsubject,currTask,b0filepattern)
% RETRIEVE B0 ECHO TIMES FROM THE .PAR FILE
%===========================================================================
if contains(currTask,'learn_') %fix raw folder name for the learning task
    currTask='learn';
end   
% Find par file with the pattern of current b0
parfilefullname = ls(['O:\studies\allread\mri\raw_OK\',currsubject,'\',currTask,'\rec_par\',b0filepattern,'*.par']);
 if size(parfilefullname,1)~= 1 
   fprintf ('Several files found. Something is wrong with your file identifier!ABORT!!!')  
 else
    % read the parfile
    fid = fopen(fullfile(parfilefullname),'rt');
    A = textscan(fid, '%f ', 'delimiter', 'Whitespace','collectoutput',true,'HeaderLines',100);
    format shortg
    echoes = [];
    % find long and short echo times for individual parfile
    shortecho=A{1}(31);
    longecho=A{1}(80);
    if (longecho == shortecho)
        longecho=A{1}(227);
    end     
    echoes = [ echoes; shortecho longecho];
    % done
    fclose(fid);
 end
end

