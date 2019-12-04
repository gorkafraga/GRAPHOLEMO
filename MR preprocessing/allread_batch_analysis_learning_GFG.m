
    clear batches;
    %spm_jobman('initcfg');
    
    
    taskList = { 'feedback' };
    paths.study = 'O:\studies\allread\mri\';
    paths.analysis = 'analysis\';
    paths.logs = 'logs\';
    paths.pps = 'preprocessing\feedback\';
    
    stimonsets = {};
    
    
    subjects = {'AR1005','AR1009','AR1012','AR1014'};

    % create subjects list, i.e. { 'test05','test06', ...}
    % i = subject nrs
    %for i=1:8
    %   sub = sprintf('biokurs19-%02d',i);
    %   subjects{end + 1} = sub; 
    %end    
    
    scans = {};
    rp = {};
    for b=1:2
        scans{b} = spm_select('ExtFPlist',[paths.study paths.pps subjects{1}],sprintf('^s6wua.*b%01d',b),Inf);
        rp{b} = spm_select('FPlist',[paths.study paths.pps subjects{1}],sprintf('^rp.*b%01d',b));
    end
    
    
    for i=1:length(subjects)
        for t = 1:length(taskList)
            batches{length(taskList)*i+t-1} = allread_create_glm_learning(paths,taskList{t},subjects{i},scans,rp);
        end
    end

parpool(8);    
    
parfor i=1: length(batches)
    spm_jobman('run',batches{i});
end    
