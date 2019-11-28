function [echoes] = get_b0_echoes(subject,b0index)

echoes = [];
%fprintf ([ 'Processing subject ' subjects{s} '\n' ])
parfile = dir( ['O:\studies\allread\mri\raw\' subject  '\3_rec_par\mr*_' num2str(b0index) '_1_*b0*.par'] );
len = length(parfile);

% it is possible, that there is more than one fieldmap in the raw-dir
% then...
if len > 1
    
    % ... find the lower scan-number, i.e. mrXXXX_*
    mr_index = [];
    for i = 1:len
        tmp = parfile(i).name;
        mr_index = [mr_index str2num(tmp(3:6))];
    end
    
    % in some dirs we have two fieldmaps from different scans / new
    % sequences -->  find older fieldmap
    indices = find(mr_index == min(mr_index));
    
    % use fieldmap that is "b0map", when possible
    % b0map has a higher resolution
    % if not available, use "b0" fieldmap, i.e. "just what there is"
    for i=indices
        if contains(parfile(i).name,'b0map')
            tmpparfile = parfile(i).name;
            break
        else
            tmpparfile = parfile(i).name;
        end
    end
    parfile = tmpparfile;
elseif len == 1
    parfile = parfile.name;
else
    fprintf('No fieldmap found for subjects %s\n',subject);
    return
end

% read the parfile
fid = fopen(fullfile('O:\studies\allread\mri\raw\',subject,parfile),'rt');
A = textscan(fid, '%f ', 'delimiter', 'Whitespace','collectoutput',true,'HeaderLines',100);
format shortg

% find long and short echo times for individual parfile
shortecho=A{1}(31);
longecho=A{1}(80);
if (longecho == shortecho)
    longecho=A{1}(227);
end    
%sub = str2num(subjects{s}(5:6));
echoes = [ echoes; shortecho longecho];

% done
fclose(fid);
end

