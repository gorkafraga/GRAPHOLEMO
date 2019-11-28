function [ onsets ] = allread_get_fbl_onsets( logfile, subject )
    fileID = fopen(logfile);   
    old_format = {'AR1009','AR1012','AR1014'};
    if any(strcmp(subject,old_format))
        content = textscan(fileID,'%s %s %s %s %s %s %s %s %s %s %s %s %s %s %s','Delimiter','\t');
        
        % condition in our case is feedback
        condition = content{8}(2:end);
        stimon_mri = str2num(char(content{13}(2:end)))./1000;
        respon_mri = str2num(char(content{14}(2:end)))./1000;
        feedon_mri = str2num(char(content{15}(2:end)))./1000;
        rt         = str2num(char(content{7}(2:end)))./1000;
        astim      = content{5}(2:end);
    else
        content = textscan(fileID,'%s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s','Delimiter','\t');
        
        % condition in our case is feedback
        condition = content{8}(2:end);
        stimon_mri = str2num(char(content{15}(2:end)))./1000;
        respon_mri = str2num(char(content{16}(2:end)))./1000;
        feedon_mri = str2num(char(content{17}(2:end)))./1000;
        rt         = str2num(char(content{7}(2:end)))./1000;
        astim      = content{5}(2:end);
        
    end
    
    onsets = {};
    cond_names = {'fb_pos_feedon', 'fb_neg_feedon','miss_feedon', 'fb_pos_stimon','fb_neg_stimon','miss_stimon'};
    
    for i = 1:length(cond_names)
        switch i
            case 1
                % find incorrect trials
                index = find(strcmp(condition,'1'));
                onsets{1} = feedon_mri(index) ;
            case 2
                % find correct trials
                index = find(strcmp(condition,'0'));
                onsets{2} = feedon_mri(index) ;
            case 3
                % find missed trials
                index = find(strcmp(condition,'2'));
                onsets{3} = feedon_mri(index) ;
            case 4
                % find incorrect trials
                index = find(strcmp(condition,'1'));
                onsets{4} = stimon_mri(index) ;
            case 5
                % find correct trials
                index = find(strcmp(condition,'0'));
                onsets{5} = stimon_mri(index) ;
            case 6
                % find missed trials
                index = find(strcmp(condition,'2'));
                onsets{6} = stimon_mri(index) ;
        end   
    end   
      
    % convert aStim
    astim = str2num(char(astim));
    
    
    %onsets = vec2mat(str2num(str2mat(onsets{:})),5)'./1000;
    fclose(fileID);
end