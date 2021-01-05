clear all
block  = 1
list = dir(['G:\preprocessing\block_',num2str(block),'\epis\*\*']);
subjects = unique(cellfun(@(x) x((end-5):end), {list.folder}, 'UniformOutput', false))

for ss=1:length(subjects) % loop thru subjects 
  subjdata  = list(find(~cellfun(@isempty,regexp({list.folder},subjects{ss}))));
  count = 0;  
     
        if isempty(find((~cellfun(@isempty,regexp({subjdata.name},'^Corr*.*.nii')))))
            disp([subjects{ss},' is missing Corr'])
        end
        
        if isempty(find((~cellfun(@isempty,regexp({subjdata.name},'ART')))))
            disp([subjects{ss},' (',num2str(ss),') is missing ART'])
        end 
     
end


list2 = dir(['O:\studies\allread\mri\analyses_NF\preprocessing_NF\version_september_2020\fbtask_1234\block_',num2str(block),'\epis\*\*']);
subjects2 = unique(cellfun(@(x) x((end-5):end), {list2.folder}, 'UniformOutput', false)) ;