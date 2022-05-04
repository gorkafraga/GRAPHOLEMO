clear all
close all
%%  Save pictures of results in multiple slices
% - Uses slice overlays in SPM
% - Manually edit your SPM result files and anatomical image
% - Set up a max t value for the color map. If empty it will be defined by the data
% -  % REQUIRES function 'cell2csv.m' 
task = 'FBL_B' ; 
glmlist = dir(['O:\studies\grapholemo\analysis\LEMO_GFG\mri\2ndLevel\FeedbackLearning\',task,'\LEMO_rlddm_v32\*regreNeg*']); % get a list with all the models with 2nd level regressors (from behavioral tests )
glmlist = {glmlist.name};
%%
for gm = 1:length(glmlist) 

        glmmodel =  glmlist{gm};
        
        addpath ('N:\studies\Grapholemo\Methods\Scripts\grapholemo') % REQUIRES function 'cell2csv.m' 
        templateAnatomy = ['C:\Users\gfraga\spm12\canonical\avg152T1.nii']; %full file path
        dirinput = ['O:\studies\grapholemo\analysis\LEMO_GFG\mri\2ndLevel\FeedbackLearning\',task,'\LEMO_rlddm_v32\', glmmodel ,'\']; % end with \
        correctFWE = 0; 

        if correctFWE == 1 
            diroutput = [dirinput,'\summary_withFWE\'];
        elseif correctFWE==0
            diroutput = [dirinput,'\summary\'];
        end 
        mkdir(diroutput)
        %listContrasts = {'con_0001','con_0002','con_0003','con_0004','con_0005','con_0006','con_0007','con_0008','con_0009','con_0010', 'con_0011', 'con_0012'};
        listContrasts = { 'con_0002','con_0003','con_0004','con_0005','con_0006','con_0007','con_0008','con_0009'};
        for con=1:length(listContrasts)
          if contains(dirinput,'prePost') || contains(dirinput,'paired')
                ncons = 2; 
          else
                ncons =1;
          end

          %%%%%%%%%%%%%%%%%%%%%%%%%%
          for tcon = 1:ncons
            inputcontrast = listContrasts{con} ; %this should be the name of a subfolder of dirinput containing the SPM.mat file
            inputcontrast = strrep(inputcontrast,'_','');
            outputfilename = [inputcontrast,'_',num2str(tcon),'.png'];
             if contains(dirinput,'prePost') && tcon==2
                     outputfilename = [inputcontrast,'_postPre.png'];
             elseif contains(dirinput,'prePost') && tcon==1
                     outputfilename = [inputcontrast,'_prePost.png'];

             end
            tmax = 10; % Type [] to leave empty so it is auto selected 
            if correctFWE == 1
                pCorrection = 'FWE';
                pthresh = 0.05;
                figTitle = [inputcontrast, ' p < ' ,num2str(pthresh),'(correction: ',pCorrection,')'];

            elseif correctFWE==0 
                pCorrection = 'none';%Alternatively use 'FWE' and adjust Thresh 
                pthresh = 0.001;
                figTitle = [inputcontrast, ' p < ' ,num2str(pthresh),'(correction: ',pCorrection,')'];
            end 

            % Load spm results with your thresholds 
            spm('defaults','fmri')
            matlabbatch{1}.spm.stats.results.spmmat = {[dirinput,'from_1Lv_',inputcontrast,'\SPM.mat']};
            matlabbatch{1}.spm.stats.results.conspec.titlestr = '';
            matlabbatch{1}.spm.stats.results.conspec.contrasts = tcon;
            matlabbatch{1}.spm.stats.results.conspec.threshdesc = pCorrection; %Alternatively use 'FWE' and adjust Thresh 
            matlabbatch{1}.spm.stats.results.conspec.thresh = pthresh;
            matlabbatch{1}.spm.stats.results.conspec.extent = 0;
            matlabbatch{1}.spm.stats.results.conspec.conjunction = 1;
            matlabbatch{1}.spm.stats.results.conspec.mask.none = 1;
            matlabbatch{1}.spm.stats.results.units = 1;
            matlabbatch{1}.spm.stats.results.export{1}.ps = true; 
            spm_jobman('run',matlabbatch)
            clear matlabbatch

             % save plot
             spm_figure('GetWin','Graphics');
             figure(gcf)
             gcf
             saveas(gcf,strrep([diroutput,'Results_Glass_',outputfilename],'.png', '.jpg'))
            %% Script to  slice overlay
            % TAKEN FROM: https://github.com/ritcheym/fmri_misc
            % This script saves: 1) a png file showing the image overlay for whatever SPM
            % results file is currently loaded, 2) the corresponding peak table, and 3)
            % the thresholded SPM image.
            % The output filename is automatically generated to include information
            % about the current contrast and threshold. Tested with SPM8.
            %
            % USAGE: call directly from command line while SPM results are loaded
            %
            % Requires: 
            %   - SPM8
            %   - cell2csv: https://www.mathworks.com/matlabcentral/fileexchange/47055-cell-array-to-csv-file--improved-cell2csv-m-
            %
            % Author: Maureen Ritchey, original code: 05-2012, updated 03-2014; merged
            % into a single script 01-2015

            % update with your SPM directory
            spmdir = [fileparts(which('spm')) filesep];
            emptyflag = 0; % flag for noting if results are empty

            % % generate filename
            % filepath = xSPM.swd;
            % filename = [xSPM.title '_' xSPM.STAT '_' xSPM.thresDesc '_k' num2str(xSPM.k)];
            % 
            % % clean up filename
            % filename = strrep(filename,' ','_');
            % filename = strrep(filename,'0.','0-');
            % removechars = {'.nii' '.img' '.' ',' '(' ')' '[' ']' '<' '/' ':'};
            % for i=1:length(removechars)
            %     filename = strrep(filename,removechars{i},'');
            % end

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            % generate SPM table
            TabDat = spm_list('List',xSPM,hReg);

            % get the table information and clean up
            d   = [TabDat.hdr;TabDat.dat];
            xyz = d(4:end,end);
            xyz2 = num2cell([xyz{:}]');

            % check whether there are clusters and if so, write out the results
            if isempty(xyz2)
                %cell2csv([filepath '/' filename '_EMPTY.txt'],d,'\t');
                cell2csv([diroutput,'Results_Table_',strrep(outputfilename,'.png','.txt')], d, '\t');
                emptyflag = 1;

            else
                d(4:end,end:end+2) = xyz2;
                d(3,:)=[];

                % cell2csv from matlab file exchange
                cell2csv([diroutput,'Results_Table_',strrep(outputfilename,'.png','.txt')], d, '\t');
            end

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            if ~emptyflag % run the rest only for non-empty results

                % draw the overlay image
                image = slover(templateAnatomy);
                image = add_spm(image);

                style = hgexport('factorystyle');
                style.Background = 'black';
                style.Format = 'png';



                % Get image, Define slices and perspective and save 
                image = slover(templateAnatomy);
                image = add_spm(image);
                 if ~isempty(tmax)%GFG: user defined max T val for colormap
                    image.img(2).range = [0 tmax];
                end
                image.slices = [-40:4:80]; % these slices work for the above T1; otherwise adjust
                image.transform = 'axial';
                paint(image)
                sgtitle(figTitle)
                hgexport(gcf,[diroutput,'Results_Axial_',outputfilename], style);

                 % Get image, Define slices and perspective and save 
                image = slover(templateAnatomy);
                image = add_spm(image);
                if ~isempty(tmax)%GFG: user defined max T val for colormap
                    image.img(2).range = [0 tmax];
                end
                image.slices = [-85:4:40]; % these slices work for the above T1; otherwise adjust
                image.transform = 'coronal';
                paint(image)
                sgtitle(figTitle)
                hgexport(gcf,[diroutput,'Results_Coronal_',outputfilename], style);


                 %Define slices and perspective and save 
                image = slover(templateAnatomy);
                image = add_spm(image);
                if ~isempty(tmax)%GFG: user defined max T val for colormap
                    image.img(2).range = [0 tmax];
                end
                image.slices = [-60:4:60]; % these slices work for the above T1; otherwise adjust
                image.transform = 'Sagittal';
                paint(image)
                sgtitle(figTitle)
                hgexport(gcf,[diroutput,'Results_Sagittal_',outputfilename], style);

                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                 close all
                % save out the full image
                %spm_write_filtered(xSPM.Z,xSPM.XYZ,SPM.xVol.DIM,SPM.xVol.M,'SPM-filtered',[filename])]);

            end
         end
        end
end