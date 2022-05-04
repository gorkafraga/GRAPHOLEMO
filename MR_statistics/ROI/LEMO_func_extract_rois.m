% extract beta values from volumes of interest
function data = LEMO_func_extract_rois(paths, subjects, voi, output_type)
    data = [];

    for i = 1:length(subjects)
        for v = 1:length(voi)
            fprintf(['Extracting ', voi{v},' from ' , subjects{i}]);
                        
            % read VOI coords
            Y = spm_read_vols( spm_vol( [paths.roi,'\',voi{v},'.nii']),0);
            indx = find(Y>0);
            [x,y,z] = ind2sub(size(Y),indx);
            XYZ = [x y z]';
            
             % load 2nd Level spm file 
            load(fullfile([paths.analysis_current,'\SPM.mat']));
            spm_index = find(contains(SPM.xY.P,subjects{i}));
            
            
%           % i .. subjects
%           % v .. # rois
             if strcmp('eigen',output_type)==1 
                [tmp_data] = eigen1(spm_get_data(SPM.xY.P(spm_index,:),XYZ));
             elseif strcmp('mean',output_type)==1 
                tmp_data = mean(spm_get_data(SPM.xY.P(spm_index,:),XYZ));
             elseif strcmp('median',output_type)==1 
                tmp_data = median(spm_get_data(SPM.xY.P(spm_index,:),XYZ));
             end
              data{i,v}=tmp_data;
              fprintf('\t[OK]\n',voi{v});
        end    
    end
    data=cell2mat(data);
end

function firsteigen = eigen1 (y)
    [v,s] = svd(y'*y);
    s       = diag(s);
    v       = v(:,1);
    u       = y*v/sqrt(s(1));
    d       = sign(sum(v));
    u       = u*d;
    firsteigen    = u*sqrt(s(1)/numel(y));
end