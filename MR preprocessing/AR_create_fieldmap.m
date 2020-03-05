function AR_create_fieldmap(studyPath,b0Path, epiPath, b0index,T1template)
% create_fieldmap  Creates the vdm5*.nii file (voxel displacement file) for a given fieldmap sequence
% and a given EPI image. If there are more than one b0 images stored, you
% have to provide the mr-sequence number from the scanning session.
% e.g. mr3672_pmdd06_31072018_105457_2_1_wipepi_b0_ec1_typ0.nii has the
% sequence number "2".
%-----------------------------------------------------------------------
% Fieldmap values can be found in N:\Users\dwillinger\fieldmapvalues.xlsx
% Old sequences (Pilot, TR=2000 TE=35ms) 
%  -> Total read out time = 44.03
%
% New sequences (Pilot+PMDD study, TR=1600 TE=35ms) 
%  -> Total read out time = 27.7
%-----------------------------------------------------------------------
%   Example: create_fieldmap( {'b0/subject1/'},{'epi/subject1/'}, 2)
%
%   create_fieldmap( b0Path, epiPath, b0index )
%   b0Path    - Directory of b0-files
%   epiPath   - Directory of EPI-files to be unwarped
%   b0index   - MR-Sequence number of the b0-sequence (usually 2)
%
% Original: (c) David Willinger 2018/08/02
% Adapted by Gorka Fraga Gonzalez (Dec 2019)
    clear matlabbatch
    %studyPath = 'O:\studies\allread\mri\';
    b0Dir = b0Path{1};
    epiDir = [studyPath 'preprocessing\' epiPath{1}];
    endout=regexp(epiDir,filesep,'split');
    subject=endout{end};
    
    overwrite = 0;
    
    if isempty(dir([ b0Dir,['\vdm5*_' num2str(b0index) '_1_*']])) || overwrite
        fprintf ('========================================================================\n');
        fprintf ('Generating fieldmap...');
        fprintf ('B0 directory is %s\n',b0Dir);
        fprintf ('EPI directory is %s\n',epiDir);
        fprintf ('========================================================================\n');

        % determine number of fieldmaps
        % store fieldmap sequence numbers in b0_nos
        pathname = cellstr(spm_select('ExtFPList', b0Dir, ['^mr.*._',num2str(b0index),'_.*.nii$'],1));
         
        n_fieldmaps = length(pathname)/6;
        if n_fieldmaps > 1
            fprintf ('WARNING: %i fieldmaps found in B0 directory \n',n_fieldmaps);
        end 
        pathname = pathname(1:6:end);  
        b0_nos = [];
        for i = 1:n_fieldmaps 
            tmp_path = pathname{i};
            [~,b0name,~] = fileparts(tmp_path);
            b0name_split = strsplit(b0name,'_');
            
            if startsWith(b0name,'mr_ar')
                b0_no = b0name_split(5); b0_no=b0_no{1};
            else
                b0_no = b0name_split(4); b0_no=b0_no{1};
            end
            
            b0_nos = [b0_nos str2num(b0_no)];
        end
        
        if ~exist('b0index','var')
            % no b0index supplied --> use first/only b0map
            if length(b0_nos) > 1
                fprintf ('ERROR: No b0index provided but %i fieldmaps found.\n',n_fieldmaps);
                return;
            elseif length(b0_nos) == 1
                b0index = b0_nos(1); 
            end    
            
        end
        
        % okay, we provided a b0index, now check if we have a sequence
        % number that matches it
        if ~ismember(b0index,b0_nos)
            g = sprintf('%d ', b0_nos);
            fprintf ('ERROR: B0-index %i was not found ( found indices: %s)\n',b0index,g);
            return;
        end
        
        % if we land here, all went well
        
        
        % fill in echoes
        matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj.data.phasemag.shortphase = cellstr(spm_select('FPList', b0Dir, ['^mr.*._' num2str(b0index) '_1_.*.ec1_typ3.*.nii$']));
        matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj.data.phasemag.shortmag = cellstr(spm_select('FPList', b0Dir, ['^mr.*._' num2str(b0index) '_1_.*.ec1_typ0.*.nii$']));
        matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj.data.phasemag.longphase = cellstr(spm_select('FPList', b0Dir, ['^mr.*._' num2str(b0index) '_1_.*.ec2_typ3.*.nii$']));
        matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj.data.phasemag.longmag = cellstr(spm_select('FPList', b0Dir, ['^mr.*._' num2str(b0index) '_1_.*.ec2_typ0.*.nii$']));
        
        %matlabbatch{1}.spm.tools.fieldmap.phasemag.subj.defaults.defaultsfile = {[studyPath '\scripts\pm_defaults_philips.m']};
        
        % determine those echo values for a subject
        %[echoes,subjects,parfiles] = testme(subjects);
        [echoes] = AR_get_b0_echoes(subject,b0index);
        
        echoes
%             if contains(epiDir,[epiDir '\test'])
%               current_subject = epiDir(end-5:end);
%             elseif contains(epiDir,'biokurs')
%               current_subject = epiDir(end-11:end); 
%             elseif contains(epiDir,'\t0')
%               current_subject = epiDir(end-6:end); 
%             end    
        %index_echo = find(strcmp(subjects,current_subject))
        
        % did we find a subject? if not, return with error message
        %if isempty(index_echo)
        %    fprintf ('No subject found: %s\n',current_subject);
        %    return
        %end    
        
        %current_echo = echoes(index_echo,[1 2]);
        current_echo = echoes;
        
        matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.et = current_echo;
        matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.maskbrain = 0;
        matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.blipdir = -1;
        
        disp(['EPIDIR: ' epiDir])
        disp(['Calculating fieldmap for b0index: ' num2str(b0index)])
%         if contains(epiDir,'1_dynamic_edt')
%             matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.tert = 44.035;
%         elseif contains(epiDir,'2_static_edt')
%             matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.tert = 44.035;
%         elseif contains(epiDir,'3_mid')
%             matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.tert = 44.035;
%         elseif contains(epiDir,'5_localizer_edt')
%             matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.tert = 44.035;
%         else
%             matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.tert = 27.7;
%         end
        
        matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.tert = 44.035;
        matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.epifm = 0;
        matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.ajm = 0;
        matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.uflags.method = 'Mark3D';
        matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.uflags.fwhm = 10;
        matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.uflags.pad = 0;
        matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.uflags.ws = 1;
        matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.mflags.template = {T1template};
        matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.mflags.fwhm = 5;
        matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.mflags.nerode = 2;
        matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.mflags.ndilate = 4;
        matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.mflags.thresh = 0.5;
        matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.mflags.reg = 0.02;     
        matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj.session.epi = cellstr(spm_select('ExtFPList', epiDir, '^mr.*.nii$',1));
        matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj.matchvdm = 1;
        matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj.sessname = 'session';
        matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj.writeunwarped = 0;
        matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj.anat = '';
        matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj.matchanat = 0;
        
        %spm_jobman('interactive', matlabbatch);
    else
        fprintf('>> WARNING: Fieldmap (vdm5*%i*.nii) already exists in %s, skipping.\n',b0index,b0Dir);
    end
end