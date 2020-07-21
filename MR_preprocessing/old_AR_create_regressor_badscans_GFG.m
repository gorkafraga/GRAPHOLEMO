% CREATE A ERGRESSOR WITH BAD SCANS 
%-----------------------------------------------------
% Source: Georgette Pleisch & Iliana Karipidis März 15
% last version March 2020, sd, GFG
% - Reads the output txt file from ARTREPAIR  from artrepair with the index of repaired/detected 
% - Artrepair txt files  are empty if no scan exceeded thresholds set in artrepair scripts
% - Good scans flagged with 0 and bad scans with 1. Scans surrounded by bad scans (with 2 or 1 good scans gap) are also marked as 1.
%  e.g., the sequence [0 0 0 1 0 0 1 0 0 0 1] were 1 = bad scans will be coded:  [0 0 0 1 1 1 1 0 0 0 1] 
% - Output mat file can be used for GLM (1st level ) *_flagscans.mat
% - Another output text file shows percent and count of flagged scans 

clear all; close all;  %clear workspace
epipath = 'O:\studies\allread\mri\analysis_GFG\preprocessing\learn_1\epis\'; % epis parent folder 
%subject =   {'AR1005','AR1016','AR1017','AR1022','AR1025','AR1026','AR1027','AR1028','AR1036','AR1037','AR1038',...
%     'AR1041','AR1042','AR1043','AR1047','AR1048','AR1052','AR1055','AR1056','AR1062','AR1063','AR1066','AR1068','AR1069'};
files = dir([epipath,'\AR*']);
subject= {files.name};
subject={'AR1037'}
N_scans=273; % number of dynamic scans, change this for the different tasks!
%%
for i=1:length(subject) % loop over all subjects
    art_repaired = dir([epipath,subject{i},'\ART\','*art_repaired.txt']); % name of txt file
    
    %  In case multiple art_repair.txt are present in folder. 
     for f = 1:length(art_repaired)   
        file_repair = [epipath,subject{i},'\ART\',art_repaired(f).name]; % Path for the txt file per subject
        path_repair = art_repaired(f).folder;
        fid = fopen(file_repair); % open txt file
        badscans = textscan(fid,'%n', N_scans, 'delimiter','\n'); % take bad scans from txt file
        fclose(fid); %close txt file

        differences=diff(badscans{1,1}); %Get difference between scan positions ( diff is 1 for consecutive scans)          
        
        % Get position of Scans surrounded by bad scans  (Only if there are 2 or less scans between bad scans) 
        gaps=[];  
        for s=1:length(differences) % loop throuh differences between two bad scans position 
                if differences(s,1) == 2 % if the difference to the next bad scan is 2 (not neighboring)...
                    gaps=[gaps badscans{1,1}(s,1)+1]; % ...write the next scan into gaps
                elseif differences(s,1) == 3 %if the difference is 3...
                    gaps=[gaps badscans{1,1}(s,1)+1 badscans{1,1}(s,1)+2]; % ...write the next scan and the one after into gaps
                else continue
                end
        end

        all_bad=sort([badscans{1,1}' gaps]); % sorting the positions of marked scans
      
%          % FLAG only  marked scans with at least two neighboring marked scans(to have blocks of 'bad scans') 
%          % Repaired scans that have no other repaired scans nearby (position + 1 or +2) will NOT be flagged
%            flag=[];
%          for a=1:length(all_bad)
%              if  a<length(all_bad)-1 & all_bad(1,a+1) == all_bad(1,a)+1 & all_bad(1,a+2) == all_bad(1,a)+2 %checking if there are blocks of good scans in the variable all_bad
%                  flag=[flag all_bad(1,a)]; % flag if not interrupted by good scans
%              elseif a>1 & a<length(all_bad) & all_bad(1,a-1) == all_bad(1,a)-1 & all_bad(1,a+1) == all_bad(1,a)+1
%                  flag=[flag all_bad(1,a)];
%              elseif a>2 & all_bad(1,a-1) == all_bad(1,a)-1 & all_bad(1,a-2) == all_bad(1,a)-2
%                  flag=[flag all_bad(1,a)];
%              else
%                  continue
%              end        
%          end
%         
%         %%
%         Regr_badscans = zeros(1,N_scans); 
%         Regr_badscans (1,flag)=1; % set flagged positions to 1
%         Regr_badscans = Regr_badscans.'; % tanspose to vector of 1 column and as many rows as scans (N_scans)
            Regr_badscans = zeros(1,N_scans); 
            Regr_badscans ([badscans{1}',gaps])=1; % set flagged positions to 1
            Regr_badscans = Regr_badscans.'; % tanspose to vector of 1 column and as many rows as scans (N_scans)
    
        if ~isempty(badscans{1})
        %Count repaired scans, flag scans and percentages  
           %countBad = [{sprintf('%.2f',(100*length(badscans{1})/N_scans))},{sprintf('%.2f',(100*length(flag)/N_scans))},length(badscans{1}),length(flag)];
           %countBadTable = cell2table(countBad,'VariableNames',{'percentRepaired','percentFlagged','nRepaired','nFlagged'});      
           countBad = [{sprintf('%.2f',(100*length(badscans{1})/N_scans))},{sprintf('%.2f',(100*length([badscans{1}',gaps])/N_scans))},length(badscans{1}),length([badscans{1}',gaps])];
           countBadTable = cell2table(countBad,'VariableNames',{'percentRepaired','percentFlagged','nRepaired','nFlagged'});      
           countbadfile =  strrep(file_repair,'art_repaired.txt','countBadScans.txt');
           writetable(countBadTable, countbadfile,'delimiter','\t') 
        end 
        %% SAVING 
       if any(Regr_badscans) % if there are bad scans in this subject...
           regressorfile =  strrep(file_repair,'art_repaired.txt','flagscans.mat'); % ...write a mat file from vector, call it flagscans
           save(fullfile(regressorfile), 'Regr_badscans'); % save mat file (can be loaded as regressor in the glm)
           disp (['Flagged bad scans for subject ',subject{i}])
       else
           disp (['No scans were flagged for subject ',subject{i}])
           continue
       end
    end
end
