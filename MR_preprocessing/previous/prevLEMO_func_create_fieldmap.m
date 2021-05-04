function LEMO_func_create_fieldmap_GFG(currsubject,paths,currTask,anatTemplate)
    % create_fieldmap  Creates the vdm5*.nii file (voxel displacement file) for
    %a given fieldmap file and a given EPI image. 
    %-----------------------------------------------------------------------
    % IMPORTANT: sequence-specific information required.  
    % Old sequences (Pilot, TR=2000 TE=35ms) 
    %  -> Total read out time = 44.03%
    % New sequences (Pilot+PMDD study, TR=1600 TE=35ms) 
    %  -> Total read out time = 27.7
    %-----------------------------------------------------------------------
    % Adapted by Gorka Fraga Gonzalez, March 2020. Original: (c) David Willinger 2018/08/02. 

    %% inputs setup
    clear matlabbatch   
    b0Dir =[paths.task,'b0\',currsubject];
    epiDir = [paths.task,'epis\',currsubject];
    % work around to find epi filename. Not all our tasks contain 'epi' in the name
    %find all .nii in folder and exclude b0 files
     
 %% BEGIN
    overwrite = 1;
    if ~isempty(dir([ b0Dir,'\vdm5*_1_*'])) && overwrite==0
        fprintf('>> WARNING: Fieldmap (vdm5*%i*.nii) already exists in ', b0Dir,' skipping.\n');
    else 
    fprintf ('========================================================================\n');
    fprintf ('Generating fieldmap...');
    fprintf ('B0 directory is %s\n',b0Dir);
    fprintf ('EPI directory is %s\n',epiDir);
    fprintf ('========================================================================\n');

    fullfilesb0 = cellstr(spm_select('ExtFPList',b0Dir,'^mr.*.b0.*.nii$',1));
    %Check number of b0s. Only one is expected (6 files). IF so, continue and find the sequence number of b0
    n_fieldmaps = length(fullfilesb0)/6;
    if n_fieldmaps ~= 1
        fprintf ('Wrong number of field map files found in B0 directory \n',n_fieldmaps);
    end

    %% RETRIEVE SUBJECT ECHO TIMES
    %---------------------------------
    % Find par file with the pattern of current b0
    parfile = dir([b0Dir,'\*.par']);
     if length(parfile)~= 1 
       fprintf ('Check your par files ABORT!!!')  
     else
        % read the parfile
        fid = fopen(fullfile([parfile.folder,'\',parfile.name]),'rt');
        textFromPar = textscan(fid, '%f ', 'delimiter', 'Whitespace','collectoutput',true,'HeaderLines',100);
        format shortg
        echoes = [];
        % find long and short echo times for individual parfile
        shortecho=textFromPar{1}(31);
        longecho=textFromPar{1}(80);
        if (longecho == shortecho)
            longecho=textFromPar{1}(227);
        end     
        echoes = [ echoes; shortecho longecho];
        % done
        fclose(fid);
     end
     current_echo = echoes;

    
    %% Create batch including the echo information to preprocessing the b0 and create vdm5 file  
    matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj.data.phasemag.shortphase = cellstr(spm_select('FPList', b0Dir, ['^mr.*._','.*.ec1_typ3.*.nii$']));
    matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj.data.phasemag.shortmag = cellstr(spm_select('FPList', b0Dir, ['^mr.*._','.*.ec1_typ0.*.nii$']));
    matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj.data.phasemag.longphase = cellstr(spm_select('FPList', b0Dir, ['^mr.*._','.*.ec2_typ3.*.nii$']));
    matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj.data.phasemag.longmag = cellstr(spm_select('FPList', b0Dir, ['^mr.*._','.*.ec2_typ0.*.nii$']));
    matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.et = current_echo;
    matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.maskbrain = 0;
    matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.blipdir = -1;
    
 %% CALCULATE EPI READOUT TIME 
 % Formulas from: https://support.brainvoyager.com/brainvoyager/functional-analysis-preparation/29-pre-processing/78-epi-distortion-correction-echo-spacing-and-bandwidth
        if strcmp(currTask,'eread')
            epifactor  = 31; % EPI factor
            matrixsize_phase_enc_dir = 62; % nr of echos (y value of scan resolution in .par file)
            water_fat_shift_pixel = 8.90;     
            sensefactor                 = 2;        
        elseif strcmp(currTask,'block_1')             
            epifactor  = 31; % EPI factor
            matrixsize_phase_enc_dir = 62; % nr of echos (y value of scan resolution in .par file)
            water_fat_shift_pixel = 12.47; 
            sensefactor                 = 2;        
        elseif strcmp(currTask,'block_2') 
            epifactor  = 31; % EPI factor
            matrixsize_phase_enc_dir = 62; % nr of echos (y value of scan resolution in .par file)
            water_fat_shift_pixel = 12.47;
            sensefactor                 = 2;   
       elseif strcmp(currTask,'block_3') 
            epifactor  = 31; % EPI factor
            matrixsize_phase_enc_dir = 62; % nr of echos (y value of scan resolution in .par file)
            water_fat_shift_pixel = 12.47;
            sensefactor                 = 2;   
        elseif strcmp(currTask,'block_4')           
            epifactor  = 31; % EPI factor
            matrixsize_phase_enc_dir = 62; % nr of echos (y value of scan resolution in .par file)
            water_fat_shift_pixel = 12.47;   
            sensefactor                 = 2;        
        elseif strcmp(currTask,'symCtrl')              
            epifactor  = 33; % EPI factor
            matrixsize_phase_enc_dir = 66; %nr of echos (y value of scan resolution in .par file)
            water_fat_shift_pixel = 9.68;
            sensefactor                 = 2;        
        elseif strcmp(currTask,'localizer')           
            epifactor  =  33; % EPI factor
            matrixsize_phase_enc_dir = 66; % nr of echos (y value of scan resolution in .par file)
            water_fat_shift_pixel = 9.68; 
            sensefactor                 = 2;        
        end
        
       %FIXED parameters
        resonance_freq_mhz_tesla    = 42.576; % gyromagnetic ratio for proton (1H)
        fieldstrength_tesla         = 3.0;  % magnetic field strength (T)
        water_fat_diff_ppm          = 3.35; % Haacke et al: 3.35ppm. Bernstein et al (pg. 960): Chemical shifts (ppm, using protons in tetramethyl silane Si(CH3)4 as a reference). Protons in lipids ~1.3, protons in water 4.7, difference: 4.7 - 1.3 = 3.4.
        water_fat_shift_hz          = fieldstrength_tesla * water_fat_diff_ppm * resonance_freq_mhz_tesla; % water_fat_shift_hz 3T = 427.8888 Hz?
        %More task-dependent calculations
        echo_train_length           = epifactor + 1;
        %Divide by sense factor (acceleration factor)
        effective_echo_spacing_msec           = ((1000 * water_fat_shift_pixel)/(water_fat_shift_hz * echo_train_length))/sensefactor;
        %finally, calculate readout time (effective echo spacing x  number of scans)    
         total_epi_readout_time = effective_echo_spacing_msec    * matrixsize_phase_enc_dir;
  
 %%
        disp(['EPIDIR: ' epiDir])
        disp('Calculating fieldmap')    
        matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.tert = total_epi_readout_time;
        matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.epifm = 0;
        matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.ajm = 0;
        matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.uflags.method = 'Mark3D';
        matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.uflags.fwhm = 10;
        matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.uflags.pad = 0;
        matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.uflags.ws = 1;
        matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.mflags.template = {anatTemplate};
        matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.mflags.fwhm = 5;
        matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.mflags.nerode = 2;
        matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.mflags.ndilate = 4;
        matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.mflags.thresh = 0.5;
        matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.mflags.reg = 0.02;     
        matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj.session.epi = cellstr(spm_select('ExtFPList', epiDir,'^mr.*.nii',1)); %first volume of epi file. 
        matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj.matchvdm = 1;
        matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj.sessname = 'session';
        matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj.writeunwarped = 0;
        matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj.anat = '';
        matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj.matchanat = 0;

        % RUN BATCH IN SPM
        %============================================================
         spm_jobman('run', matlabbatch);
         fprintf('>> Created Fieldmap (vdm5*%i*.nii)in %s.\n',b0Dir)

    end
end