clear all
close all
% Create ROIs  Marsbars in your .nii image space
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
diroutput = 'O:\studies\grapholemo\analysis\LEMO_GFG\mri\regions_of_interest\marsbar';
mysamplenifti = 'O:\studies\grapholemo\analysis\LEMO_GFG\mri\1stLevel\FBL_A\1Lv_GLM0_thirds_exMiss\gpl001\beta_0001.nii'; % any 1st level image from my study
 %% 0. Preparation:
% If you haven't done, create the marsbar rois (e.g. postSTG_6mm_*.mat) files (you can use the ones you should already have)
% My list of rois
rois.labels = {
    'LFusi',...
    'RFusi',...
    'LPrecentral',... 
    'RPrecentral',... 
    'LSTG',...
    'RSTG',... 
    'LPutamen',...
    'RPutamen',...
    'LHippocampus',...
    'RHippocampus',... 
    'LCaudate',...
    'RCaudate',...
    'LInsula',...
    'RInsula',...
    'LmidCingulum',...
    'RmidCingulum',...
    'LSupramarginal',...
    'RSupramarginal'
 };
rois.coord = {
    [-44 -58 -14]    
    [44 -58 -14]
    [-46 2 24] 
    [46 2 24] 
    [-52 -22 8] 
    [54	-24	4]    
    [-14 8 -10]
    [26	2 -8]
    [-22 -40 4]
    [22	-32	6] 
    [-12 10 -10]
    [14	10 -10]
    [-38 20	-6]
    [42	18 -6]
    [0 22 38]
    [4 26 40]
    [-62 -44 34]
    [62	-42	34]  
};
 %% Load the volume info from your image space (just pick any of the 1-st level img)
  img = spm_vol(mysamplenifti);
marsbar
%
for i=1:length(rois.labels)
    disp(i)
    %% call Marsbar to define spherical ROIs and save them as mat files
        spheric_roi = maroi_sphere(struct('centre',rois.coord{i}, ...
                                            'radius', 6, ...
                                            'label',rois.labels{i}, ...
                                             'descrip',[rois.labels{i},' (', num2str(rois.coord{i}),')']));

       saveroi(spheric_roi, fullfile(diroutput, ['marsbarROI_', rois.labels{i}, '.mat']));

  
        %% Create a marsbar roi space object and change its fields to your image space
        roi_space = maroi('classdata', 'spacebase');
        roi_space.dim = img.dim;
        roi_space.mat = img.mat;

        % Create the .nii in the correct space
         mars_rois2img({fullfile(diroutput, ['marsbarROI_', rois.labels{i}, '.mat'])},... 
                       fullfile(diroutput, ['marsbarROI_', rois.labels{i}, '.nii']), roi_space);
 end
