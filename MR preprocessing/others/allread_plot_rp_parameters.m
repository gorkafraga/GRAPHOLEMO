% See Hauser et al., 2015: Cognitive flexibility in adolescence: Neural and
% behavioral mechanisms of reward prediction error processing in adaptive
% decision making during development
% 
% " We additionally entered several regressors-of-no-interest into the GLM
% to improve model validity: choice values (value of chosen object) as
% parametric modulator at cue presentation, realignment-derived movement
% parameters, scan-to-scan movements greater than 1 mm, and cardiac
% pulsations "

% set threshold in [mm]
thresh = 1;

% methods: 'haus' or 'fd'
method = 'fd';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
subs = {};
%subjects = {'AR1031'};
subjects = {'AR1002','AR1003','AR1004','AR1005','AR1006','AR1007','AR1008','AR1009','AR1011','AR1012','AR1014','AR1016','AR1018','AR1023','AR1028','AR1031','AR1036','AR1038','AR1042','AR1046','AR1056'};
path = 'O:\studies\allread\mri\preprocessing\eread\';
% create subjects list
excludes = {};
subs = subjects;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%55
% rps .. raw realignment parameters
% drps ..scan-to-scan
% correction_needed .. vector with bad scans
rps = {};
drps = {};
fd = {};
correction_needed = {};
for i = 1:length(subs)
   sub_path = fullfile(path, subs{i});
   rpfile = ls ([ sub_path '\rp*_eread*.txt' ]);
   
   rps{i} = load(fullfile(sub_path,rpfile)); 
   drps{i} = diff([0 0 0 0 0 0; rps{i}]);
   
   % claculate framewise displacement
   cfg.motionparam = fullfile(sub_path,rpfile);
   cfg.prepro_suite = 'spm';
   cfg.radius = 40;
   
   fd{i} = bramila_framewiseDisplacement(cfg);
   
   % define which scans need a 
   % exceeding threshold in any direction 
   
   if strcmp(method,'haus')    
       % Method 1 as used in Hauser ?
       correction_needed{i} = (sum(drps{i}' > thresh)' > 0);
   elseif strcmp(method,'fd')    
       % Method 2 as used in Siegel et al., Statistical Improvements in Functional Magnetic Resonance Imaging Analyses Produced by Censoring High-Motion Data Points
       correction_needed{i} = (fd{i} > thresh);
   else
        disp([method ' is not a valid method.']);
        return
   end    
end 

% write out data
percentage_censored = [];
for i = 1:length(subs)
    bad_scans = correction_needed{i};
    fileID = fopen([ fullfile(path, subs{i}) '\bad_scans_eread_thr' num2str(thresh) 'mm.txt'],'wt');
    fprintf(fileID,'%i\n',bad_scans);
    fclose(fileID);
    
    percentage_censored = [percentage_censored; sum(bad_scans)/335];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PLOTTING
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
% plot raw rps movement
try close(213); end;
figure (213); hold on;

for i = 1:length(subs)
    subplot(5,5,i); hold on;
    plot(rps{i});
    % add correction needed
    stem(correction_needed{i},'Marker','none','LineWidth',0.1);
    ylim([-2 2]);
end    

% plot scan-to-scan movement
try close(214); end;
figure (214); hold on;
for i = 1:length(subs)
    subplot(5,5,i);
    plot(drps{i});
    ylim([-2 2]);
    line([0,335],[thresh,thresh],'Color','r');
    line([0,335],[-thresh,-thresh],'Color','r');
end    

% plot FD
try close(215); end;
figure (215); hold on;
for i = 1:length(subs)
    subplot(5,5,i);
    plot(fd{i});
    ylim([-2 2]);
    line([0,335],[thresh,thresh],'Color','r');
    line([0,335],[-thresh,-thresh],'Color','r');
end    
