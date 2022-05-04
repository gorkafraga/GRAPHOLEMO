function [resTbl] = get_cluster_maxima(map, voxthresh, sizethresh, npeaks)
%function [resTbl] = get_cluster_maxima(map, voxthresh, sizethresh, npeaks)
% Returns table with up to npeaks maxima for clusters retrieved from map
% and defined by voxthresh and sizethresh.
%e.g.:
%map = 'my_file.nii';
%voxthresh = 2.5;
%sizethresh = 10;
%npeaks = 3;
disp(map);
% load image
vol = spm_vol(map);
[Y, XYZ] = spm_read_vols(vol);
% voxel space
dim = size(Y);
[R,C,P] = ndgrid(1:dim(1), 1:dim(2), 1:dim(3));
RCP = [R(:)';C(:)';P(:)'];
% thresholding
ind = Y > voxthresh;
Y = Y(ind);
RCP = RCP(:, ind);
XYZ = XYZ(:, ind);
% get maxima
[N,Z,M,A,~] = spm_max(Y(:), RCP);
% get MNI coordinates for all clusters
[~, idxCoord] = ismember(M.', RCP.', 'rows');
XYZpeak = XYZ(1:3, idxCoord);
% create results table
resTbl = {'cluster-level','voxel-level','coordinates (mm)',[],[]; ...
'k','val','x','y','z'};
curRow = 3;
for iClust = 1:max(A)
% get associated voxels
idxClust = A == iClust;
% get associated coordinates
xyzClust = XYZpeak(:,idxClust);
% sort by value
[B,I] = sort(Z(idxClust),'descend');
% cluster extent
n = N(find(idxClust,1));
% cluster size threshold for printing
if n > sizethresh
resTbl{curRow,1} = n;
% iterate over peaks
for iPeak = 1:min(length(I), npeaks)
% value
resTbl{curRow,2} = B(iPeak);
% coordinates
xyz = xyzClust(:, I(iPeak));
resTbl{curRow,3} = xyz(1);
resTbl{curRow,4} = xyz(2);
resTbl{curRow,5} = xyz(3);
curRow = curRow + 1;
end
end
end
% display table
disp(resTbl);
% save csv
[p,n,~] = fileparts(map);
writetable(table(resTbl), fullfile(p, ['peaks_' n '.csv']), 'WriteVariableNames', 0);
end
 