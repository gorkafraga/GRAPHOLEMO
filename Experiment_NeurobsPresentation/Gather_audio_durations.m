% paths
clear all

diroutput = 'Y:\studies\Grapholemo\Methods\';

 	
%% search files
files_A = dir('Y:\studies\Grapholemo\Methods\Scripts\Experiment_NeurobsPresentation\MR center\UVA_LEMO_version1\Task_A\Stimulus Files\*.wav');
files_B = dir('Y:\studies\Grapholemo\Methods\Scripts\Experiment_NeurobsPresentation\MR center\UVA_LEMO_version1\Task_B\Stimulus Files\*.wav');


%%
% gather audio info in table 
filesInExperiment = ["a_short_2_2.wav","e_short_2_2.wav","t_2_1_loudCheck.wav","l_2_2_loudCheck.wav","b_2_1.wav",...
    "in_short_2_1_loudCheck.wav","k_2_1_loudCheck.wav","z_2_2.wav","w_2_2_loudCheck.wav","u_short_2_1.wav",  "r_2_1.wav",...
    "ach_2_1.wav"];
	

audioTable_A = table();
for i=1:length(files_A)
    
    info = audioinfo(fullfile(files_A(i).folder, files_A(i).name));      
    fileIndex = find(strcmp({files_A(i).name}, filesInExperiment));
    
     if ~isempty(fileIndex)

         % Get audio information for the current file
        info = audioinfo(fullfile(files_A(i).folder, files_A(i).name));
        
        % Convert audio information to a table and append it to audioTable
        audioTable_A = [audioTable_A; struct2table(info, 'AsArray', 1)];
    
     end
     
end
%% 
%%
clear filesInExperiment
filesInExperiment = [ "a_long_2_3_loudCheck.wav","un_short_2_1_loudCheck.wav","e_long_2_2.wav","sche_2_1.wav","st_2_2_loudCheck.wav","wö_2_2_loudCheck.wav",...
	"ki_short_2_1.wav","ka_loudCheck.wav","zi_2_2.wav","schl_2_1.wav","pf_2_1_loudCheck.wav","wa_short_2_2.wav"];
	

% gather audio info in table 
audioTable_B = table();
for i=1:length(files_B)
    
    info = audioinfo(fullfile(files_B(i).folder, files_B(i).name));            
    fileIndex = find(strcmp({files_B(i).name}, filesInExperiment));
    
     if ~isempty(fileIndex)

         % Get audio information for the current file
        info = audioinfo(fullfile(files_B(i).folder, files_B(i).name));
 
        % Convert audio information to a table and append it to audioTable
        audioTable_B = [audioTable_B; struct2table(info, 'AsArray', 1)];
    
     end
     
end 

%%
audioTable = [audioTable_A;audioTable_B];

%%
writetable(audioTable, fullfile(diroutput, 'audio_info.csv'));


