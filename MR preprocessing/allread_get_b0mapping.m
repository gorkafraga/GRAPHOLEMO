function b0mapping = allread_get_b0mapping(subject,epis)
% get_b0mapping Returns the B0 sequence for a given 
% subject for the tasks (in this order: MID_1, MID_2, EDT)
%
%  subject    - Subject for which the B0 MR sequence number is needed. 
%               e.g. 'pmdd-01'
%  b0mapping  - The MR sequence numbers for the corresponding task file
%               e.g. [2 2 11] means 2:MID_1, 2:MID_2, 11:EDT

% Example: b0mapping = get_b0mapping('pmdd-01')
% 
%
%(c) David Willinger
%Last edited: 2018/08/02


     % for each subject
    % check sequence nr for each subject:
    % IMPORTANT: SEQUENCE = eread, learn, localizer, symCtrl
    b0mapping = {[2 5 11 11 ], %AR1002
                 [2 5 9 9], %AR1003
                 [2 6 10 10], %AR1004
                 [2 5 9 9], % AR1005
                 [2 5 10 10], % AR1006
                 [2 5 13 13], % AR1007
                 [3 6 15 15], % AR1008
                 [14 8 13 13], % AR1009
                 [2 9 16 16], %AR1011
                 [2 5 9 9], %AR1012
                 [2 6 10 10], %AR1014
                 [2 5 9 9], %AR1016
                 [2 5 9 9],%AR1018
                 [2 7 15 15],%AR1021
                 [6 12 12 12], %AR1023
                 [10 6 9 9],%AR1025
                 [2 5 9 9], % AR1028
                 [2 5 12 12], % AR1031
                 [2 5 10 10],%AR1035
                 [2 5 13 13], % AR1036
                 [2 5 9 9], % AR1038
                 [2 5 9 9], % AR1042
                 [9 5 9 9],% AR1045
                 [2 5 12 12], % AR1046
                 [2 5 10 10],%AR1048
                 [2 5 10 10],%AR1055
                 [2 6 10 10] % AR1056
             };
    %subjects = {};
    %excludes = {};
    for i=[ 1:length(b0mapping) ]
       sub = sprintf('AR%02d',i);
       if ~any(strcmp(excludes,sub))
           subjects{end + 1} = sub; 
       end    
    end
    %subjects = {'AR1031'};
    allsubjects = {'AR1002','AR1004','AR1006','AR1007','AR1008','AR1011','AR1016','AR1018','AR1021','AR1023','AR1025','AR1028','AR1031','AR1035','AR1036','AR1038','AR1042','AR1045','AR1046','AR1048','AR1055','AR1056'};
    %is this line needed??
    M = containers.Map(allsubjects,b0mapping);
    
    try        
       b0mapping = M(subject);
    catch ME
       switch ME.identifier
            case 'MATLAB:Containers:Map:NoKey'
                errorStruct.message = ['Key not found for subject "' subject '". Have you added it in the file get_b0mapping?']; 
                errorStruct.dentifier = 'get_b0mapping:keyNotFound';
                error(errorStruct);
       return;
    end    

    
    
    tmp_b0 = nan(1,3);
    tasks = {'eread','feedback','implicit','faceloc'};
    
    for i = 1:length(tasks)
        pos = isIn(tasks{i},epis);
        if pos > 0
            tmp_b0(:,pos) = b0mapping(:,i);
        end    
    end
    tmp_b0(isnan(tmp_b0)) = [];
    b0mapping = tmp_b0;
end