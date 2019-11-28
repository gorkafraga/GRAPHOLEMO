% Script to create a regressor for bad scans
% Lexi
% Georgette Pleisch & Iliana Karipidis März 15
% aktualisiert März 2018_sd

% Wenn artrepair angewendet wird, wird ein txt file mit den Scans
% geschrieben, die die angegebenen Grenzen überschreiten. Diese Scans
% werden mit diesem Script in einen Regressor umgewandelt, bei dem alle
% guten Scans mit 0 markiert sind und die schlechten mit 1. Im Modell
% können so die schlechten Scans ausgeschlossen werden.

clear all; close all; clc; %clear workspace, clear command window
path = 'O:\studies\allread\mri\preprocessing\eread_ss\epis\'; % Pfad für das txt file für alle subjects

subject = {'AR1004'};%

% subject = {'6001','6006','6007','6010','6012','6015','6018','6019','6021','6025','6030','6031','6033','6036','6038',...
...'6040','6042','6046','6061','6067','6080','6084','6101','6102','6103','6104','6105','6107','6108',...
...'6109','6110','6111','6112','6113','6115','6116','6117','6118','6119','6120','6121'};

art_repaired = 'art_repaired.txt'; % txt file
N_scans=366; %number of dynamic scans

for i=1:length(subject) % loop für die subjects
file_repair = [path subject{i} '\' art_repaired]; % Pfad in den jeweiligen subject Ordner zum txt file
fid = fopen(file_repair); % öffnet das txt file
badscans = textscan(fid,'%n', 366, 'delimiter','\n'); % schreibt die eingetragenen badscans heraus
    fclose(fid); %schliesst das txt file


differences=diff(badscans{1,1}); %für jeden bad scan wird die Differenz zum nächsten berechnet    
gaps=[]; % leerer Vektor in den zusätzliche Positionen von Scans eingeschrieben werden, die benachbarte bad scans haben
    
    for s=1:length(differences)  
        if differences(s,1) == 2 gaps=[gaps badscans{1,1}(s,1)+1]; % bei einer Differenz von 2 den nächsten Scan rausschreiben
        elseif differences(s,1) == 3 gaps=[gaps badscans{1,1}(s,1)+1 badscans{1,1}(s,1)+2]; % bei einer Differenz von 3 den nächsten und übernächsten Scan rausschreiben
        else continue
        end
    end

all_bad=sort([badscans{1,1}' gaps]); %Positionen der markierten Scans aufsteigend sortieren
flag=[];% leerer Vektor für Scans die schliesslich geflaggt werden sollen

%findet alle markierten Scan, die mindestens zwei benachbarte Scans haben,
%die auch markiert sind. Wenn ein Scan keinen oder nur einen benachbarten
%Scan hat der markiert ist, kommt er nicht in den Vektor zum Flaggen
for a=1:length(all_bad)
    if  a<length(all_bad)-1 & all_bad(1,a+1) == all_bad(1,a)+1 & all_bad(1,a+2) == all_bad(1,a)+2
        flag=[flag all_bad(1,a)];
    elseif a>1 & a<length(all_bad) & all_bad(1,a-1) == all_bad(1,a)-1 & all_bad(1,a+1) == all_bad(1,a)+1
        flag=[flag all_bad(1,a)];
    elseif a>2 & all_bad(1,a-1) == all_bad(1,a)-1 & all_bad(1,a-2) == all_bad(1,a)-2
        flag=[flag all_bad(1,a)];
    else
        continue
    end        
end

    
Regr_badscans = zeros(1,N_scans); % vector mit einer Spalte für jeden dynamic scan wird erstellt
%Regr_badscans (1,badscans{1,:})=1; % im vector werden die Positionen mit den badscanns auf 1 gesetzt
Regr_badscans (1,flag)=1; % im vector werden die Positionen zum Flaggen auf 1 gesetzt
Regr_badscans = Regr_badscans.'; % der vector wird transformiert und hat jetzt 189 Zeilen

       if any(Regr_badscans) %falls der Datensatz schlechte files hat
        regressorfile = [path subject{i} '\' subject{i} '_flagscans.mat']; % aus dem vector wird ein mat file erstellt, das als Regressor ins Modell eingelesen werden kann.
        save(fullfile(regressorfile), 'Regr_badscans'); % das mat file wird gespeichert
       else continue
       end
        
end
