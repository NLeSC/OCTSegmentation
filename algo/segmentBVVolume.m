function bvAuto = segmentBVVolume(volume, params, onh, rpe)
% SEGMENTBVVOLUME
%
% Writen by Markus Mayer, Pattern Recognition Lab, University of
% Erlangen-Nuremberg


volume(volume > 1) = 0;
volume = sqrt(volume);

bvAuto = zeros(size(volume, 3), size(volume, 2), 'uint8');

for i = 1:size(volume, 3)
    bvAuto(i,:) = segmentBVLin(volume(:,:,i), params, onh(i,:), rpe(i,:));
    
    disp(['Blood Vessels of BScan ' num2str(i) ' segmented automatically in 2D.']);
end

end