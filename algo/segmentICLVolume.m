function iclAuto = segmentICLVolume(volume, params, rpe, medline)

% Writen by Markus Mayer, Pattern Recognition Lab, University of
% Erlangen-Nuremberg
%
% First final Version: November 2010

volume(volume > 1) = 0;
volume = sqrt(volume);

mask = params.INNERLIN_VOLUME_MASK;
mask = mask ./ sum(mask);
avgMask = zeros(1,1,numel(mask), 'double');
for i = 1:numel(mask)
    avgMask(1,1,i) = mask(i);
end
volume = imfilter(volume, avgMask, 'symmetric') ;

iclAuto = zeros(size(volume, 3), size(volume, 2), 'double');

for i = 1:size(volume, 3)
    if numel(rpe) == 0
        iclAuto(i,:) = segmentICLLin(volume(:,:,i), params, [], medline(i,:));
    else
        iclAuto(i,:) = segmentICLLin(volume(:,:,i), params, rpe(i,:), medline(i,:));
    end
    disp(['ICL of BScan ' num2str(i) ' segmented automatically in 2D.']);
end

end