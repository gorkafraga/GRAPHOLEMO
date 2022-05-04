%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Extract beta values from VOIs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
addpath('C:\Users\gfraga\spm12\toolbox\marsbar-0.45')
%% Inputs 
%paths.roi = 'O:\studies\pmdd\mri\template\amygdala\';
paths.roi = 'O:\studies\grapholemo\analysis\LEMO_GFG\mri\regions_of_interest_templates\marsbar\';  %ends with \
%paths.analysis = 'O:\studies\grapholemo\analysis\LEMO_GFG\mri\2ndLevel_pairedTs\2Lv_GLM0_thirds_exMiss\'; % should end with \
paths.analysis = 'O:\studies\grapholemo\analysis\LEMO_GFG\mri\2ndLevel\FeedbackLearning\FBL_B\LEMO_rlddm_v32\2Lv_GLM0_mopa_aspe\'; % should end with \


%subjects
%files = dir('O:\studies\grapholemo\analysis\LEMO_GFG\mri\1stLevel\FBL_B\1Lv_GLM0_thirds_exMiss');% take any first level to detect subjects
files = dir(strrep(strrep(paths.analysis,'2ndLevel','1stLevel'),'2Lv','1Lv'));% take any first level to detect subjects
subjects = {files(contains({files.name},'gpl')).name};

% define output type
output_type_list = {'mean','eigen','median'}; %Choose 'mean', 'median','eigen'  
  
% Find contrasts to loop thru
contrasts = dir([paths.analysis,'\con*']);

%% 
for ot = 1:length(output_type_list) 
        output_type= output_type_list{ot};
       % vois :Use the names of the files in your paths.roi without the extension.
        voi = dir([paths.roi,'*.nii']);
        voi = {voi.name};
        voi = replace(voi,'.nii',''); % remove extension from names
     %% read coords of all vois and save in table
        coordTbl = cell2table(cell(length(voi),2));
        for v = 1:length(voi)
              load([paths.roi,'\',strrep(voi{v},'.nii','.mat')])
              tmp = struct2cell(roi);
              currCoord = tmp(1);
              coordTbl(v,1) = voi(v);
             coordTbl(v,2) = {currCoord};
        end 

           coordTbl.Properties.VariableNames = {'ROI_Label','ROI_Coord'}; 
             mkdir([paths.analysis,'\ROI_',output_type, '\'])
           writetable(coordTbl, [paths.analysis '\ROI_',output_type,'\ROI_coords_',output_type,'.csv']);

      %%
    for cc=1:length(contrasts)
     paths.analysis_current = [contrasts(cc).folder,'\',contrasts(cc).name];

        % call the script and gather betas
        data = LEMO_func_extract_rois(paths, subjects, voi, output_type);

        %% prepare for csv export (= convert in table)

             t = array2table(data);         
             t = [subjects',t];
             t.Properties.VariableNames = ['subject', strcat(strrep(voi,'marsbarROI_',''),['_',strrep(contrasts(cc).name,'_','')])]; 
             writetable(t, [paths.analysis  '\ROI_',output_type,'\ROIs_',output_type,'_',num2str(numel(voi)),'rois_',strrep(contrasts(cc).name,'_',''),'.csv']);

         % Save coordinates      
          % tcords = cell2table(voi');
           % tcords.Properties.VariableNames = {'ROI_Coordinates'}; 
          % writetable(tcords, [paths.analysis  '\ROI\ROI_coords.csv']);


    end 
end