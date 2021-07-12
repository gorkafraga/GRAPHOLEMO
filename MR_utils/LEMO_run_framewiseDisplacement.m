clear  
close all
scripts= ('N:\studies\Grapholemo\Methods\Scripts\grapholemo\MR_utils');
addpath(scripts)
%--------------------------------------------------------------------------------------------------------------
%  RUN FRAMEWISE DISPLACEMENT FUNCTIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%- Requires functions bramila_framewiseDisplacement and bramila_detrend
%- Creates struct array 'cfg' with realignment parameters (input for bramilas function)
% 
%--------------------------------------------------------------------------------------------------------------
%  
dirinput      = 'O:\studies\grapholemo\analysis\LEMO_GFG\mri\preprocessing\symCtrl_post'; % no \ at the end. Basic parent dir of a task
subjects      = {'gpl001','gpl002','gpl003','gpl004','gpl005','gpl006','gpl007','gpl008','gpl009','gpl010','gpl011','gpl012','gpl013','gpl015','gpl017','gpl019','gpl024','gpl025','gpl014','gpl021'};
subjects      = {'gpl020','gpl026'};

%% Subject loop
for i = 1:length(subjects)
  files = dir([dirinput,'\',subjects{i},'\**\rp*']); 
     
  
  for rp = 1:length(files)
     
      rpfile = files(rp);
       
      % create input file for function
       cfg.motionparam = [rpfile.folder,'\',rpfile.name];
       cfg.prepro_suite = 'spm';
       cfg.radius = 50;
       
       [fwd,rms]=bramila_framewiseDisplacement(cfg);
       subplot(2,1,1)
       plot(fwd)
       subplot(2,1,2)
       plot(rms)
       
       % save 
       saveas(gcf,strrep(strrep([rpfile.folder,'\',rpfile.name],'.txt','.jpg'),'rp_a','FramewiseDisp_'));
       writematrix(fwd,strrep(strrep([rpfile.folder,'\',rpfile.name],'.txt','.csv'),'rp_a','FramewiseDisp_'))
       %find index of bad scans
       badScans_idx = find(fwd>1);
       if ~isempty(badScans_idx)
           writematrix(badScans_idx,strrep(strrep([rpfile.folder,'\',rpfile.name],'.txt','_badScansIdx.csv'),'rp_a','FramewiseDisp_'))
       end
  end
       
end


