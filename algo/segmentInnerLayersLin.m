function [icl opl ipl] = segmentInnerLayersLin(bscan, Params, onh, rpe, infl, medline, bv)
% SEGMENtONFLAUTO Segments some inner retinal layers from a BScan.
% Intended for use on
% circular OCT B-Scans.
% BSCAN: Unnormed BScan image 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PARAMS:   Parameter struct for the automated segmentation
%   In this function, the following parameters are currently used:


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% RPE: Segmentation of the RPE in OCTSEG line format
% INFL: Segmentation of the INFL in OCTSEG line format
%
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
% First final Version: June 2010


% 1) Normalize intensity values and align the image to the RPE

%bscan(bscan > 1) = 0; 
%bscan = sqrt(bscan);
rpe = round(rpe);
infl = round(infl);
[alignedBScan flatRPE transformLine] = alignAScans(bscan, Params, [rpe; infl]);
flatINFL = infl - transformLine;
medline = round(medline - transformLine);

alignedBScanDSqrt = sqrt(alignedBScan); % double sqrt for denoising

% 3) Find blood vessels for segmentation and energy-smooth 
idxBV = find(extendBloodVessels(bv, Params.INNERLIN_EXTENDBLOODVESSELS_ADDWIDTH, ...
                                    Params.INNERLIN_EXTENDBLOODVESSELS_MULTWIDTHTHRESH, ...
                                    Params.INNERLIN_EXTENDBLOODVESSELS_MULTWIDTH));

averageMask = fspecial('average', Params.INNERLIN_SEGMENT_AVERAGEWIDTH);
alignedBScanDen = imfilter(alignedBScanDSqrt, averageMask, 'symmetric');

idxBVlogic = zeros(1,size(alignedBScan, 2), 'uint8') + 1;
idxBVlogic(idxBV) = idxBVlogic(idxBV) - 1;
idxBVlogic(1) = 1;
idxBVlogic(end) = 1;
idxBVlogicInv = zeros(1,size(alignedBScan, 2), 'uint8') + 1 - idxBVlogic;
alignedBScanWoBV = alignedBScanDen(:, find(idxBVlogic));
alignedBScanInter = alignedBScanDen;
runner = 1:size(alignedBScanDSqrt, 2);
runnerBV = runner(find(idxBVlogic));
for k = 1:size(alignedBScan,1)
    alignedBScanInter(k, :) = interp1(runnerBV, alignedBScanWoBV(k,:), runner, 'linear');
end

alignedBScanDSqrt(:, find(idxBVlogicInv)) = alignedBScanInter(:, find(idxBVlogicInv)) ;
averageMask = fspecial('average', Params.INNERLIN_SEGMENT_AVERAGEWIDTH);
alignedBScanDenAvg = imfilter(alignedBScanDSqrt, averageMask, 'symmetric');

% 4) We try to find the CL boundary.
% This is pretty simple - it lies between the medline and the RPE and has
% rising contrast. It is the uppermost rising border.
extrICLChoice = findRetinaExtrema(alignedBScanDenAvg, Params,2, 'max', ...
                [medline; flatRPE - Params.INNERLIN_SEGMENT_MINDIST_RPE_ICL]);
extrICL = min(extrICLChoice,[], 1);
extrICL(idxBV) = 0;
extrICL = linesweeter(extrICL, Params.INNERLIN_SEGMENT_LINESWEETER_ICL);
                                              
                        
extrICLEstimate = ransacEstimate(extrICL, 'poly', ...
                            Params.INNERLIN_RANSAC_NORM_BOUNDARIES, ...
                            Params.INNERLIN_RANSAC_MAXITER, ...
                            Params.INNERLIN_RANSAC_POLYNUMBER_BOUNDARIES, ...
                            onh);
extrICL = mergeLines(extrICL, extrICLEstimate, 'discardOutliers', [Params.INNERLIN_MERGE_THRESHOLD ...
                                                                   Params.INNERLIN_MERGE_DILATE ...
                                                                   Params.INNERLIN_MERGE_BORDER]);                                                
flatICL = round(extrICL);

% 5) OPL Boundary: In between the ICL and the INFL
oplInnerBound = flatINFL;

extrOPLChoice = findRetinaExtrema(alignedBScanDenAvg, Params,3, 'min', ...
                [oplInnerBound; flatICL - Params.INNERLIN_SEGMENT_MINDIST_ICL_OPL]);
extrOPL = max(extrOPLChoice,[], 1);
extrOPL(idxBV) = 0;
extrOPL = linesweeter(extrOPL, Params.INNERLIN_SEGMENT_LINESWEETER_OPL);

extrOPLEstimate = ransacEstimate(extrOPL, 'poly', ...
                            Params.INNERLIN_RANSAC_NORM_BOUNDARIES, ...
                            Params.INNERLIN_RANSAC_MAXITER, ...
                            Params.INNERLIN_RANSAC_POLYNUMBER_BOUNDARIES, ...
                            onh);
extrOPL = mergeLines(extrOPL, extrOPLEstimate, 'discardOutliers', [Params.INNERLIN_MERGE_THRESHOLD ...
                                                                   Params.INNERLIN_MERGE_DILATE ...
                                                                   Params.INNERLIN_MERGE_BORDER]);                                                
flatOPL = round(extrOPL);

% 5) IPL Boundary: In between the OPL and the INFL
iplInnerBound = flatINFL;
extrIPLChoice = findRetinaExtrema(alignedBScanDenAvg, Params,2, 'min pos', ...
                [iplInnerBound; flatOPL - Params.INNERLIN_SEGMENT_MINDIST_OPL_IPL]);
extrIPL = extrIPLChoice(2,:);
extrIPL(idxBV) = 0;
extrIPL = linesweeter(extrIPL, Params.INNERLIN_SEGMENT_LINESWEETER_IPL);

extrIPLEstimate = ransacEstimate(extrIPL, 'poly', ...
                            Params.INNERLIN_RANSAC_NORM_BOUNDARIES, ...
                            Params.INNERLIN_RANSAC_MAXITER, ...
                            Params.INNERLIN_RANSAC_POLYNUMBER_BOUNDARIES, ...
                            onh);
extrIPL = mergeLines(extrIPL, extrIPLEstimate, 'discardOutliers', [Params.INNERLIN_MERGE_THRESHOLD ...
                                                                   Params.INNERLIN_MERGE_DILATE ...
                                                                   Params.INNERLIN_MERGE_BORDER]);                          
                        
% 6) Bring back to non-geometry corrected space
icl = extrICL + transformLine;
opl = extrOPL + transformLine;
ipl = extrIPL + transformLine;

% 7) Some final constraints
icl(icl < 1) = 1;
opl(opl < 1) = 1;
ipl(ipl < 1) = 1;

ipl(ipl < infl) = infl(ipl < infl);
icl(icl > rpe) = rpe(icl > rpe);
opl(opl > icl) = icl(opl > icl);
opl(opl < ipl) = ipl(opl < ipl);
icl(icl < opl) = opl(icl < opl);

end