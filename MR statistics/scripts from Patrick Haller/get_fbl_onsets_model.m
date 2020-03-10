function [ onsets, parameters ] = get_fbl_onsets_model( logfile )
fileID = fopen(logfile);
content = textscan(fileID,'%s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s ','Delimiter',',');

% extract relevant columns from log file
blocks = string(content{2}(2:end));

% fb=0 incorrect, fb=1 correct
fb = string(content{9}(2:end));

stimon_mri = str2num(char(content{11}(2:end)))./1000;
respon_mri = str2num(char(content{12}(2:end)))./1000;
feedon_mri = str2num(char(content{13}(2:end)))./1000;

pe_pos = str2num(char(content{14}(2:end)));
pe_neg = str2num(char(content{15}(2:end)));
pe_tot = str2num(char(content{16}(2:end)));
drift = str2num(char(content{20}(2:end)));
as_active = str2num(char(content{17}(2:end)));
as_inactive = str2num(char(content{18}(2:end)));
as_chosen = str2num(char(content{19}(2:end)));

astim = content{6}(2:end);

learned = [];

s = containers.Map;
for i=1:21
    s(num2str(i)) = 0;
end

for i=1:length(astim)
    aud = astim(i);
    aud = cell2mat(aud);
    if strcmp(fb(i),'1')
        s(aud) = s(aud)+1;
    end
    if s(aud) < 5
        learned(i) = 0;
    else
        learned(i) = 1;
    end
end

learned = transpose(learned);
learned = string(learned);

onsets = {};
parameters = {};

cond_names = {'stimon_mri','feedon_mri',...
    'as_active','as_inactive','as_chosen','drift','pe_pos','pe_neg','pe_tot',...
    'stimon_pos','stimon_neg','feedon_pos','feedon_neg',...
    'stimon_not_learned','stimon_learned','feedon_not_learned','feedon_learned',...
    'as_only_active','pe_only_pos','drift_only_neg','pe_only_neg','as_neg'};

for i = 1:length(cond_names)
    for j = 1:length(unique(blocks))
        switch i
            case 1 % stimon
                index = find(strcmp(blocks,string(j)));
                onsets{1,j} = stimon_mri(index);
            case 2 % feedon
                index = find(strcmp(blocks,string(j)));
                onsets{2,j} = feedon_mri(index);
            case 3 % as_active
                index = find(strcmp(blocks,string(j)));
                parameters{1,j} = as_active(index);
            case 4 % as inactive
                index = find(strcmp(blocks,string(j)));
                parameters{2,j} = as_inactive(index);
            case 5 % as_chosen
                index = find(strcmp(blocks,string(j)));
                parameters{3,j} = as_chosen(index);
            case 6 % drift
                index = find(strcmp(blocks,string(j)));
                parameters{4,j} = drift(index);
            case 7 % pe_pos
                index = find(strcmp(blocks,string(j)));
                parameters{5,j} = pe_pos(index);
             case 8 % pe_neg
                index = find(strcmp(blocks,string(j)));
                parameters{6,j} = pe_neg(index);     
             case 9 % pe_tot
                index = find(strcmp(blocks,string(j)));
                parameters{7,j} = pe_tot(index);                    
            case 10  % stimonset + fb
                index = find(strcmp(blocks,string(j))&strcmp(fb,'1'));
                onsets{3,j} = stimon_mri(index);
            case 11 % stimonset - fb
                index = find(strcmp(blocks,string(j))&strcmp(fb,'0'));
                onsets{4,j} = stimon_mri(index);
             case 12 % feedonset + fb
                index = find(strcmp(blocks,string(j))&strcmp(fb,'1'));
                onsets{5,j} = feedon_mri(index);  
             case 13 % feedonset - fb
                index = find(strcmp(blocks,string(j))&strcmp(fb,'0'));
                onsets{6,j} = feedon_mri(index);  
            case 14 % find learned stimuli
                index = find(strcmp(blocks,string(j))&strcmp(learned,'1'));
                onsets{7,j} = stimon_mri(index) ;
            case 15 % find not learned stimuli
                index = find(strcmp(blocks,string(j))&strcmp(learned,'0'));
                onsets{8,j} = stimon_mri(index) ;    
            case 16 % find learned stimuli
                index = find(strcmp(blocks,string(j))&strcmp(learned,'1'));
                onsets{9,j} = stimon_mri(index) ;
            case 17 % find not learned stimuli
                index = find(strcmp(blocks,string(j))&strcmp(learned,'0'));
                onsets{10,j} = stimon_mri(index) ; 
            case 18 % as_active_pos
                index = find(strcmp(blocks,string(j))&strcmp(fb,'1'));
                parameters{8,j} = as_active(index);
            case 19 % as_active_pos
                index = find(strcmp(blocks,string(j))&strcmp(fb,'1'));
                parameters{9,j} = pe_pos(index);
            case 20 % drift_neg
                index = find(strcmp(blocks,string(j))&strcmp(fb,'0'));
                parameters{10,j} = drift(index);
            case 21 % pe_neg
                index = find(strcmp(blocks,string(j))&strcmp(fb,'0'));
                parameters{11,j} = pe_neg(index);
            case 22 % as_neg
                index = find(strcmp(blocks,string(j))&strcmp(fb,'0'));
                parameters{12,j} = as_chosen(index);
        end
    end
end

fclose(fileID);
end