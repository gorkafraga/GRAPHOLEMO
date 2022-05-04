
clear batches;
%spm_jobman('initcfg');

taskList = { 'feedback' };
paths.study = 'O:\studies\allread\mri_ph\';
paths.analysis = 'analysis\';
paths.logs = 'logs\';
paths.pps = 'preprocessing\feedback\';

onsets = {};

% create subjects list, i.e. { 'test05','test06', ...}
% i = subject nrs
subjects = {};
excludes = {};
for i=1:17
    sub = sprintf('biokurs19-%02d',i);
    if ~ismember(sub,excludes)
        subjects{end + 1} = sub;
   end    
end
batches = {};
scans = {};
rp = {};
for s=1:length(subjects)
   for b=1:3
        scans{s,b} = spm_select('ExtFPlist',[paths.study paths.pps subjects{s}],sprintf('^s6wua.*block%01d',b),Inf);
        rp{s,b} = spm_select('FPlist',[paths.study paths.pps subjects{s}],sprintf('^rp.*block%01d',b));
        bad_scans{s,b} = spm_select('FPlist',[paths.study paths.pps subjects{s}],sprintf('^bad_scans.*block%01d.*',b));
    end
end

for i=1:length(subjects)
    for t = 1:length(taskList)
        batches{length(taskList)*i+t-1} = create_GLM1(paths,taskList{t},subjects{i},scans(i,:),rp(i,:),bad_scans(i,:));
    end
end

parpool(4);
parfor i=1:length(batches)
    try
        spm_jobman('run',batches{i})
    catch e
        fprintf('%s\tError during analysis of subject %s \n\r',datetime('now'),subjects{i})
    end
end


