% A wrapper script for preprocessing using  MATLAB parallel toolbox.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Admits input of several subjects and tasks
% REQUIRES:
%       - b0 files in same folder as epi files.One b0 and epi  per folder
%       - folder name as input of 'tasklist' variables
%       - T1 image (1 file) stored in separate folder named "T1w".
%       - Subjects at the last level of the directory
% OUTPUT:
%       - multiple preprocessed files (SPM style)
%       - operation log file in txt.
%--------------------------------------------------------------------------
% Last version: Gorka Fraga (March 2020) adapted from original by David Willinger 
clear; close all; %clear matlabbatch batch;
spm_jobman('initcfg');
addpath ('N:\studies\Grapholemo\Methods\Scripts\grapholemo\MR_preprocessing') 
%% Inputs setup
%------------------------------
tic
tasklist =  {'block_3'}; %Recommended to take one task at a time.  [eread, learn, localizer, symCtrl]   
anatTemplate = 'G:\preprocessing\anatomical_templates\from_TOM8\TPM_Age8_7.nii'; % Called by 'AR_create_fieldmap.m'
% PATHS (end character should be \ )
paths.preprocessing = 'G:\preprocessing\';
files =  (dir([paths.preprocessing,tasklist{1},'\**\lemo*']));
subjects = unique({files.name});
subjects = {'AR1109'};
%% BEGIN TASK LOOP
cd (paths.preprocessing)
for t=1:length(tasklist)
currTask = tasklist{t};
paths.task = [paths.preprocessing,currTask,'\'];
     %start an empty batch for all subjects
     batch = cell(1,length(subjects));
     for i=1:length(subjects)   
            currsubject = subjects{i};
            if  isempty(dir([paths.task,'**\',currsubject]))
                disp(['Cannot find ',currsubject,' folder in ',paths.task,' \n'])
            else 
            %%% Call CREATE FIELDMAP. Preprocess b0, creates vdm5 
            %------------------------------
            LEMO_func_create_fieldmap_GFG(currsubject,paths,currTask,anatTemplate);

            %%% Create PREPROCESSING batch
            %------------------------------ 
            [batch{i}] = LEMO_func_create_matlabbatch_GFG(paths,currTask,currsubject,anatTemplate);
            end
     end
     
%% RUN batch in parallel
%-------------------------------------------------------------------------------------
 if ~isempty(gcp('nocreate'))
            delete(gcp('nocreate'));  
 end
      % if you use parallel for-loop: uncomment (make sure your computers has 8 cores!! If not, change this number to 4 or 2)
      %  parpool(4);
        %batch =  batch(find(~cellfun(@isempty,batch)));% the batch will be have an empty cell for those subjects where no data was found. Get rid of these
        for ii=1:length(subjects) 
            spm_jobman('run',batch{ii})
        end 
        %parfor i=length(batch) 
        %for i=1:length(subjects)  % use this if you deactivate parallel
         %try
           %     data_out{i} =  spm_jobman('run',batch{i})
         %catch
          %       data_out{i} = disp('error during preprocessing - check the batch')
          %end    
      % end
 %save([paths.preprocessing,['Batch_',currTask,'_',datestr(now,'mmddyyyy-HHMM'),'.mat']],'batch')
clear batch
end
toc
 