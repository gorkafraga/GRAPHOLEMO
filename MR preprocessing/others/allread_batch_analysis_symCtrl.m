
    clear batches;
    %spm_jobman('initcfg');
    
    
    taskList = { 'symCtrl\TaskDesign_FilterChecks8s_New' };
    paths.study = 'O:\studies\allread\mri\';
    paths.analysis = 'analysis\';
    paths.logs = 'logs\';
    paths.pps = 'preprocessing\symCtrl\';
    
    stimonsets = {};
    
    %'AR1003','AR1005','AR1009',
    subjects = {'AR1014'};    
    scans = {};
    rp = {};
    scans = spm_select('ExtFPlist',[paths.study paths.pps subjects{1}],sprintf('^s6wua.*b%01d'),Inf);
    rp = spm_select('FPlist',[paths.study paths.pps subjects{1}],sprintf('^rp.*b%01d'));
    
    
    for i=1:length(subjects)
        for t = 1:length(taskList)
            batches{length(taskList)*i+t-1} = allread_create_glm_symCtrl(paths,taskList{t},subjects{i});
        end
    end

%parpool(8);    
return
    
parfor i=1:length(batches)
    spm_jobman('run',batches{i});
end    
