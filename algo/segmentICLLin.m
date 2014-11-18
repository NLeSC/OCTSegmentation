function icl = segmentICLLin(bscan, Params, rpe, medline)
% SEGMENTICLLIN
% Writen by Markus Mayer, Pattern Recognition Lab, University of
% Erlangen-Nuremberg

if numel(rpe) == 0
    rpe = zeros(1, size(bscan, 2)) + size(bscan, 1);
end

rpe = round(rpe);

bscan(bscan > 1) = 0;
bscan = sqrt(bscan);

averageMask = fspecial('average', Params.INNERLIN_SEGMENT_AVERAGEWIDTH);
bscanAvg = imfilter(bscan, averageMask, 'symmetric');

extrICLChoice = findRetinaExtrema(bscanAvg, Params,2, 'max', ...
    [medline; rpe - Params.INNERLIN_SEGMENT_MINDIST_RPE_ICL]);
extrICL = min(extrICLChoice,[], 1);
extrICL = linesweeter(extrICL, Params.INNERLIN_SEGMENT_LINESWEETER_ICL);

extrICLEstimate = ransacEstimate(extrICL, 'poly', ...
    Params.INNERLIN_RANSAC_NORM_BOUNDARIES, ...
    Params.INNERLIN_RANSAC_MAXITER, ...
    Params.INNERLIN_RANSAC_POLYNUMBER_BOUNDARIES);

extrICL = mergeLines(extrICL, extrICLEstimate, 'discardOutliers', [Params.INNERLIN_MERGE_THRESHOLD ...
    Params.INNERLIN_MERGE_DILATE ...
    Params.INNERLIN_MERGE_BORDER]);
icl = round(extrICL);
icl(icl < 1) = 1;
