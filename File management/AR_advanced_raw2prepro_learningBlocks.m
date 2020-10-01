clear all 
tic
%% COPY RAW TO PREPROCESSING FOLDER 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%vv
% - Read masterfile table to check for correct epis and b0s
rawDir = 'O:\studies\allread\mri\raw_OK\';
masterFile = 'O:\studies\allread\mri\analysis_GFG\Allread_MasterFile_GFG.xlsx';
%preprocessingDir = 'O:\studies\allread\mri\Preprocessing_GFG\';
preprocessingDir= 'G:\preprocessing';
mkdir(preprocessingDir);


run = 1;
%% READ DATA QUALITY - DECIDE INCLUSION - COPY FILES
%==========================================================================
dat = readtable(masterFile, 'sheet','MR_Learn_QA');
colIdxs =   {'B1_Inc','B2_Inc','B3_Inc','B4_Inc'};
colIdxsB0 = {'Block1_b0seq','Block2_b0seq','Block3_b0seq','Block4_b0seq'};

%chosenOnes={'AR1021'};
 
rawfolders= dir([rawDir,'AR*']);
subjects = {rawfolders.name};
%subjects = {'AR1051','AR1058','AR1059','AR1070','AR1071','AR1075','AR1076','AR1088','AR1098','AR1104','AR1105','AR1106','AR1107','AR1108'};
subjects = {'AR1098'};
% Loop thru subjects, then thru blocks
for i= 1:length(subjects)
    vpdat =  dat(contains(dat.subjID,subjects(i)),:);
           %countBlocks = 0;
           vp = subjects{i};
            for c = 1:length(colIdxs) 
               currBlockDat = table2array(vpdat(:,colIdxs(c)));
               if ~isnan(currBlockDat)&&  (currBlockDat > 0 )  % If the block inclusion index is larger that 0 go ahead, preprocess that subject
            %       countBlocks = countBlocks + 1;  
                   destinationDir = [preprocessingDir,['\block_',num2str(c)]];
                   %% patterns to find files
                   str = char(colIdxs{c});
                   niftiPattern = str(1,1:2);
                   b0string = char(table2array(vpdat(:,colIdxsB0(c))));
                   b0stringsplit= strsplit(b0string,'_');
              
                  %%find files  
                   %b0
                   if contains(b0string,'eread')
                       b0Pattern = [b0stringsplit{end-1},'_1_b0'];
                       b0file = dir([rawDir,vp,'\learn\nifti\*',b0Pattern,'*.nii']);
                        for iii=1:length(b0file)
                            b0file = dir([rawDir,vp,'\learn\nifti\*',b0Pattern,'*.nii']);
                        end	
                     b0parfile = dir([rawDir,vp,'\learn\rec_par\*',b0Pattern,'*eread*.par']);
                   else 
                     b0Pattern = [b0stringsplit{end},'_1_b0'];
                     b0file = dir([rawDir,vp,'\learn\nifti\*',b0Pattern,'*.nii']);
                     b0parfile = dir([rawDir,vp,'\learn\rec_par\*',b0Pattern,'*.par']);
                   end

                   % T1 - if more than one take the latest
                   t1file =  dir([rawDir,vp,'\t1w\nifti\*t1*.nii']); 
                   if (length(t1file)>1)
                     seqNum=[];
                        for t = 1:length(t1file)
                           name_split = strsplit(t1file(t).name,'_');
                           seqNum = [seqNum str2num(cell2mat({name_split{find(strcmp(name_split,'t1'))-2}}))] ;       
                        end
                      t1file =  dir([rawDir,vp,'\t1w\nifti\*',[num2str(max(seqNum)),'_1_t1'],'*.nii']);        
                   end

                   % epi and par
                     epifile =  dir([rawDir,vp,'\learn\nifti\*epi_learn_',niftiPattern,'.nii']);
                     parfile =  dir([rawDir,vp,'\learn\rec_par\*learn_',niftiPattern,'.par']);

                 %% Copy all the stuff
                 if (length(epifile)==1) && (length(parfile)==1 && run == 1)
                   destinationDir_epis = [destinationDir,'\epis\',vp,'\'];
                   mkdir(destinationDir_epis)
                   copyfile([epifile.folder,'\',epifile.name], [destinationDir_epis,epifile.name])
                   copyfile([parfile.folder,'\',parfile.name], [destinationDir_epis,parfile.name])
                   destinationDir_epis = [destinationDir,'\epis\',vp,'\'];

                   destinationDir_t1 = [destinationDir,'\t1w\',vp,'\'];
                   mkdir(destinationDir_t1)
                   copyfile([t1file.folder,'\',t1file.name], [destinationDir_t1,t1file.name])
                   
                   destinationDir_b0= [destinationDir,'\b0\',vp,'\'];
                   mkdir(destinationDir_b0)
                   copyfile([b0parfile.folder,'\',b0parfile.name], [destinationDir_b0,b0parfile.name])
                       for ii = 1:length(b0file)
                           copyfile([b0file(ii).folder,'\',b0file(ii).name], [destinationDir_b0,b0file(ii).name])
                       end
                        if isempty(dir([destinationDir_b0,'\*.nii']))
                            disp([vp,'No b0 in ',destinationDir_b0])
                        end    
                 else
                     disp([vp,' issues in ',destinationDir]);
                 end
                 clear destinationDir_b0 destinationDir_t1 destinationDir_epis
               end
            end
end
toc
 
 