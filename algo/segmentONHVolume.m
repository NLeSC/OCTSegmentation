function [onh onhCenter onhRadius] = segmentONHVolume(volume, params, rpe)

volume(volume > 1) = 0;

volume = volume ./ max(max(max(volume)));

for k = 1:size(volume, 3)
    bscan = volume(:,:,k);
    bscanSorted = sort(bscan(:), 'ascend');
    bScanMax = bscanSorted(floor(end * params.ONH_SEGMENT_BSCANTHRESHOLD));
    bscan(bscan > bScanMax) = bScanMax;
    bscan = bscan ./ max(max(bscan));
    volume(:,:,k) = bscan;
end

border = rpe - 10;
border(:,:,2) = rpe;
enface = createEnfaceView(volume, border);

enface(enface > params.ONH_SEGMENT_ENFACETHRESHOLD * mean(mean(enface))) = 1;
enface = 1 - enface;

border = 0.1;
enface(:, 1:round((end * border))) = 0;
enface(:, end-round((end * border)):end) = 0;

enface = medfilt2(enface, params.ONH_SEGMENT_MEDFILT);
enface = medfilt2(enface, params.ONH_SEGMENT_MEDFILT);

enfaceMean2 = mean(enface, 2) ./ sum(mean(enface, 2));
enfaceCP(1) = sum(enfaceMean2 .* single(1:size(enface,1))');
enfaceMean1 = mean(enface, 1) ./ sum(mean(enface, 1));
enfaceCP(2) = sum(enfaceMean1 .* single(1:size(enface,2)));

enfaceTH = enface > 0;

enfaceTH = bwmorph(enfaceTH, 'erode', params.ONH_SEGMENT_ERODENUMBER); 

onh = zeros(size(enface, 1), size(enface,2));
onh =  logical(onh);
onhOld = onh;
onh(round(enfaceCP(1)), round(enfaceCP(2))) = true;

maxiter = 200;
iter = 0;
while sum(sum(abs(onh - onhOld))) > 0 && iter <= maxiter
    onhOld = onh;
    onh = bwmorph(onh, 'dilate'); 
    onh = onh & enfaceTH;
    iter = iter + 1;
end

onh = bwmorph(onh, 'dilate', params.ONH_SEGMENT_DILATENUMBER); 

for k = 1:size(volume, 3)
    idx = find(onh(k,:));
    if numel(idx > 1)
        onh(k,idx(1):idx(end)) = 1;
    end
end

success = 1;

if sum(sum(single(onh))) == 0
    success = 0;
elseif sum(sum(isnan(onh))) ~= 0
    success = 0;
else
    onhCenterMean2 = mean(single(onh), 2) ./ sum(mean(single(onh), 2));
    onhCenter(1) = size(onh, 1) - sum(onhCenterMean2 .* single(1:size(onh,1))');
    onhCenterMean1 = mean(single(onh), 1) ./ sum(mean(single(onh), 1));
    onhCenter(2) = sum(onhCenterMean1 .* single(1:size(onh,2)));
    
    if onhCenter(1) <= 1
        success = 0;
    elseif onhCenter(1) >= size(onh, 1);
        success = 0;
    end
    
    if onhCenter(2) <= 1
        success = 0;
    elseif onhCenter(2) >= size(onh, 2);
        success = 0;
    end
end

onh = flipdim(onh, 1);

if success
    onhCenter = round(onhCenter);
    onhRadius = 1.0;
else
    disp('ONH Segmentation failed.');
    onhCenter = round( [size(onh,1)/2 size(onh, 2)/2] );
    onhRadius = 0;
end