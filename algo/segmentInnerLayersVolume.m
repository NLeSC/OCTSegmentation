function [icl opl ipl] = segmentInnerLayersVolume(volume, params, onh, rpe, infl, medline, bv)
% The algorithm (of which this function is a part) is described in 
% Markus A. Mayer, Joachim Hornegger, Christian Y. Mardin, Ralf P. Tornow:
% Retinal Nerve Fiber Layer Segmentation on FD-OCT Scans of Normal Subjects
% and Glaucoma Patients, Biomedical Optics Express, Vol. 1, Iss. 5, 
% 1358-1383 (2010). Note that modifications have been made to the
% algorithm since the paper publication.
%
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

icl = zeros(size(volume, 3), size(volume, 2), 'double');
opl = zeros(size(volume, 3), size(volume, 2), 'double');
ipl = zeros(size(volume, 3), size(volume, 2), 'double');


for i = 1:size(volume, 3)
    [iclLin oplLin iplLin] = segmentInnerLayersLin(volume(:,:,i), params, onh(i,:), rpe(i, :), infl(i, :), medline(i,:), bv(i,:));
    
    icl(i,:) = iclLin;
    opl(i,:) = oplLin;
    ipl(i,:) = iplLin;
    disp(['Inner Layers of BScan ' num2str(i) ' segmented automatically in 2D.']);
end

icl = medfilt2(icl, params.INNERLIN_VOLUME_MEDFILT	, 'symmetric');
ipl = medfilt2(ipl, params.INNERLIN_VOLUME_MEDFILT	, 'symmetric');
opl = medfilt2(opl, params.INNERLIN_VOLUME_MEDFILT	, 'symmetric');

end