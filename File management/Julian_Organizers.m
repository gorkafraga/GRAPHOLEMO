allfiles = dir('O:\studies\grapholemo\analysis\LEMO_GFG\mri\1stLevel\**');
%%
allspms = cell(numel(allfiles), 4);
curspm = 1;
for filenr = 1:numel(allfiles)
    if allfiles(filenr).isdir
        continue
    end
    if ~strcmp(allfiles(filenr).name, "SPM.mat")
        continue
    end
    allspms{curspm,4} = allfiles(filenr).folder;
    [filepath,dirname,~] = fileparts(allspms{curspm,4});
    allspms{curspm,3} = dirname;
    [filepath,dirname,~] = fileparts(filepath);
    allspms{curspm,2} = dirname;
    [filepath,dirname,~] = fileparts(filepath);
    allspms{curspm,1} = dirname;
    curspm = curspm + 1;
end
allspms = allspms(1:curspm-1,:);
%allspms = cell2table(allspms);
%%
for i = 1:numel(allspms.allspms1)
    bla = allspms.allspms1(i)
    allspms.allspms1(i) = bla{1,1};
end
curspm{find(strcmp(allspms(:,1), 'FBL_B') & strcmp(allspms(:,2), '1Lv_GLM0_thirds') & strcmp(allspms(:,3), 'gpl021')),4}

allspmsTab = cell2table(allspms)
%%
close gcf
fig = uifigure;
%p = uipanel(fig,'Position',[0 200 1200 2500]);
p = uipanel(fig)
dd = uidropdown(p,'Position',[11 0 240 22],'Items',unique(allspmsTab.allspms1));
cb = uidropdown(p,'Position',[11 30 140 22],'Items',unique(allspmsTab.allspms2));
cb = uidropdown(p,'Position',[11 90 140 22],'Items',unique(allspmsTab.allspms3));
cb = uidropdown(p,'Position',[11 120 140 22],'Items',unique(allspmsTab.allspms4));

p.Scrollable = 'on';
