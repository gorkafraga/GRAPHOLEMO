function b0mapping = AR_get_b0(subject,epi)
%----------------------------------------------------------------
% Get the b0 values for the current file 
%------------------------------------------------------------
% Adaptation of 'allread_get_b0mapping.m' by G.Fraga Gonzalez 2019 (Original by David Willinger, adapted by P.Haller)
% Inputs: (called by wrapper script)
%   - current subject name 
%   - cell with the names of functional epi files (defined by tasks list)
% Output: corresponding b0map value
%% Info about ALL subjects (irrespective of analysis)
% Three cols, as many rows as subjects. 
% Col 1 has subject code. Cols 2 and 3 contain as many cells as recordings.
% Cells in columns 2 and 3 should have equal lengths. 
% Order: b0 maps in col 3 same order as corresponding tasks in col 2!
info = {'AR1002',{'eread','learn','symctrl'},[2 5 11];
        'AR1003',{'symctrl','learn'},[9 5];
        'AR1004',{'eread','learn','symctrl'},[2 6 10];
        'AR1005',{'symctrl','learn'},[9 5];
        'AR1006',{'eread','learn','symctrl'},[2 5 10];
        'AR1007',{'eread','learn','symctrl'},[2 5 13];
        'AR1008',{'eread','learn','symctrl'},[5 11 2];
        'AR1009',{'eread','learn','learn_2','symctrl'},[2 5 8 13]; % Note this case has 2 different set of files for 'learn'. Only the one matching task lists will be used!
        'AR1011',{'eread','learn','symctrl'},[2 9 16];
        'AR1012',{'eread','learn','symctrl'},[2 5 9];
        'AR1014',{'eread','learn','symctrl'},[2 6 10];
        'AR1015',{'learn'},[5];
        'AR1016',{'eread','learn','symctrl'},[2 5 9];
        'AR1017',{'learn'},[5];
        'AR1018',{'eread','learn','symctrl'},[2 5 9];
        'AR1019',{'learn'},[5];
        'AR1021',{'eread','learn','symctrl'},[2 7 15];
        'AR1023',{'eread','learn'},[6 12]; % Check files. scmr files had different b0!
        'AR1025',{'eread','learn'},[10 6];
        'AR1028',{'learn'},[5];
        'AR1031',{'eread','learn','symctrl'},[2 5 12];
        'AR1034',{'learn'},[5];
        'AR1035',{'eread','learn','symctrl'},[2 5 10];                                
        'AR1036',{'eread','learn','symctrl'},[2 5 13];                                
        'AR1038',{'eread','learn','symctrl'},[2 5 9];                                
        'AR1042',{'eread','learn','symctrl'},[2 5 9];                                
        'AR1045',{'eread','learn'},[9 5];                                
        'AR1046',{'eread','learn','symctrl'},[2 5 12];                                
        'AR1048',{'eread','learn','symctrl'},[2 5 10];      
        'AR1052',{'learn'},[5];
        'AR1053',{'learn'},[5];
        'AR1055',{'eread','learn','symctrl'},[2 5 10];  
        'AR1056',{'eread','learn','symctrl'},[2 6 10];
        };

% Arrange in structural array
S = struct('subjID',info(:,1),'file',info(:,2),'b0maps', info(:,3));

%% Find indices of current subject and tasks in struct array
if ~isempty(find(strcmp(subject,{S.subjID})));
    subidx = find(strcmp(subject,{S.subjID}));
   else
      disp(join(['Cannot find ',subject,' in b0 table !!! [S T O P]']));
      return
end

taskidx=[];
for t = 1:length(epi)
   if ~isempty(find(strcmp(epi(t),S(subidx).file)))
    taskidx(t) = find(strcmp(epi(t),S(subidx).file));
   else
      disp(join(['Cannot find',epi(t),'in',subject,'!!!']));
   end
end
%% Get b0 values
    b0mapping = S(subidx).b0maps(taskidx);
    disp(['"AR_get_b0" run in ',subject,'... b0mapping = [',num2str(b0mapping),']'])
end