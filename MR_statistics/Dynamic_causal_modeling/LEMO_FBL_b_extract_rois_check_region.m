%%%%% CHECK ROIS BOLD ACTIVATIONS %%%%%% 
% - Select subjects
% -  s

%% Select SUBJECTS and BLOCKS from masterfile columns 
masterfile =        'xxxxMaster_file_learning_nf.xlsx';
T =             readtable(masterfile,'sheet','Lists_subsamples'); 
%[indx,tf] =     listdlg('PromptString','Select a list of participants:','ListString', T.Properties.VariableNames); % popup 
%groupName =     T.Properties.VariableNames(indx);
indx = 11;
Tcolumn =       T{:,indx};
subjects =      Tcolumn(~cellfun('isempty',Tcolumn))';

paths.out = 'O:\studies\allread\mri\analyses_NF\rlddm_analyses_NF\RLDDM\mri_analyses\normPerf81\AR_rlddm_v11\1Lv_mopa\1Lv_GLM0_mopa_onesession\';
%%  
rois_name = {'VOI_PUT_masked_1.mat','VOI_PUT_1.mat','VOI_VWFA_1.mat','VOI_PAC_1.mat', 'VOI_STS_1.mat'};

roi_data = [];
coords = []; % for brainnetviewer
for s = 1:numel(subjects)
    for r = 1:numel(rois_name)
        try
            VOI = load([paths.out '\' subjects{s} '\' rois_name{r} ]);
            coords = [coords; VOI.xY.xyz' r 1];
            
            roi_data{s,r} = VOI.xY.s(1)/sum(VOI.xY.s);
            
        catch e
            coords = [coords; nan(1,5)];
            roi_data{s,r} = NaN;
        end    
    end 
end

% preprocess rois
roi_data=cell2table(roi_data);
roi_data.id = subjects';
excludes = roi_data.id(isnan(roi_data.roi_data1) | isnan(roi_data.roi_data3) | isnan(roi_data.roi_data4) | isnan(roi_data.roi_data5)  )';

rois= {};
% preprocess coords and generate node file
writematrix(coords,[paths.out '\output\DCM.ROIs.csv'], 'Delimiter','\t')


return
ve = []; % variance explained & max. parameter
for i = 1:numel(dcms(:,1))
    ve = [ve; dcms{i,1}.diagnostics(1) dcms{i,1}.diagnostics(2)];
end 
ve