clear all
close all
dirin = 'N:\Users\gfraga\_Misc\CHRISTINA\FPVS_redo\b_computed_measures\groupGAs';

%% 
cd(dirin)
condlist = {'CSinFF','PWinFF','WinFF','CSinW','FFinW'};
grouplist = {'poor','typ','all'};
measure='bcAmps'
dirout = ['N:\Users\gfraga\_Misc\CHRISTINA\FPVS_redo\plots\topoplots\',measure];        
mkdir(dirout)
for cc = 1:length(condlist)
    for gg = 1:length(grouplist)
        cd(dirin)
    fileinput = [condlist{cc},'_',measure,'_GA_',grouplist{gg},'.csv'];
    dat = readtable(fileinput,"Delimiter",',',"ReadVariableNames",1,"ReadRowNames",1);
    datarray = table2array(dat);
    %% import to eeglab 
    [ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
    EEG = pop_importdata('dataformat','ascii','nbchan',129,'data',datarray,'srate',512,'pnts',10240,'xmin',0);
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 0,'gui','off'); 
    EEG = eeg_checkset( EEG );
    EEG=pop_chanedit(EEG, 'load',...
        {'N:\Users\gfraga\_Misc\CHRISTINA\FPVS_redo\plots\topoplots\location129channels.ced','filetype','autodetect'});
    eeglab redraw

    %%
     hismap = [0.08627451	0.184313725	0.239215686	;
                    0.164705882	0.192156863	0.525490196	;
                    0.223529412	0.270588235	0.639215686	;
                    0.254901961	0.305882353	0.662745098	;
                    0.384313725	0.380392157	0.71372549	;
                    0.737254902	0.694117647	0.874509804	;
                    1	1	1	;
                    1	1	1	;
                    0.97254902	0.631372549	0.717647059	;
                    0.949019608	0.301960784	0.419607843	;
                    0.933333333	0.149019608	0.215686275	;
                    0.929411765	0.117647059	0.141176471	;
                    0.662745098	0.109803922	0.133333333	;
                    0.282352941	0.078431373	0.090196078	];

    %% Plot bases and harmonics
    freqs2plot = {'base','odd1','odd2','oddSums' }
    for (ff = 1:length(freqs2plot))
        data2use = EEG.data;
        chanlocs = EEG.chanlocs;
        freqs = round(linspace(0,255,length(data2use)),2);
        if contains(freqs2plot{ff},'base')
            baseidx = find(freqs==6);            
        elseif contains(freqs2plot{ff},'odd1')
            baseidx = find(freqs==1.2);
        elseif contains(freqs2plot{ff},'odd2') 
             baseidx = find(freqs==2.42);
         elseif contains(freqs2plot{ff},'oddSums') 
             baseidx = find(ismember(freqs,[1.2, 2.42,3.61, 4.81,7.2 ]));
        end 
        clim = [-0 0.5];
        close gcf
        figure;
        topoplot(sum(data2use(:,baseidx),2),chanlocs,'electrodes', 'on','maplimits',clim,...
                     'headrad', 'rim','intsquare','off','style','fill',...
                     'emarker',{'.','k',20,1}  )
                axis tight 
 % 'colormap',hismap
        colorbarYtick = {num2str(clim(1)),['+',num2str(clim(2))]};
        CB = colorbar('Position',[0.9500 0.1100 0.015 0.1577], 'YTick', [clim(1),(clim(1)+(clim(2)-clim(1))/2),clim(2)],...
            'FontName','Calibri', 'FontSize', 12);
        cbylab = get(CB,'YtickLabel'); 
        cbylab{3,:}=  ['+',num2str(clim(2))];% add + to ylabels in colorbar
        set (CB,'YTickLabel',cbylab); 
        cbpos = get(CB,'Position');
        title([freqs2plot{ff}, ' freq ', strrep(fileinput,'_','-')], 'FontSize',12, 'FontName', 'calibri')
        tit = get(gca,'Title');titpos=get(tit,'Position');
        set(tit,'Position',[titpos(1) titpos(2)+0.01 titpos(3)]);    
        set(gcf, 'Position', get(0,'Screensize')); % Maximize figure
        set(gcf,'Color',[1 1 1] )  % white background   

        % save 
        cd(dirout)
        saveas (gcf,['Plot_',freqs2plot{ff},'_',strrep(fileinput,'.csv','')], 'jpg')
        close gcf
    end
    end
end