function [onflAuto additional] = segmentONFLCirc(bscan, Params, rpe, icl, ipl, infl, bv)
% SEGMENtONFLAUTO Segments the ONFL from a BScan. Intended for use on
% circular OCT B-Scans.
% ONFLAUTO = segmentINFLAuto(BSCAN)
% ONFLAUTO: Automated segmentation of the ONFL
% ADDITIONAL: May be used for transferring additional information from the
%   segmentation. Not recommended to use outside development.
% BSCAN: Unnormed BScan image 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Params:   Parameter struct for the automated segmentation
%   In this function, the following parameters are currently used:
%   CL parameters:  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   ONFL_SEGMENT_LINESWEETER_INIT_INTERPOLATE: Should be set to pure
%       interpolation of wholes
%   Region sum ratio parameters:  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   ONFL_SEGMENT_LINESWEETER_REGRATIO: The region-ratio values used for 
%       estimating thin/thick regions are also smoothed using the 
%       linesweeter function. 
%   ONFL_SEGMENT_REGRATIO_THIN: Threshold for the region-sum ratio. The
%       regions above this threshold are assumed to be thick, below thin
%       (suggestion: 0.7)
%   ONFL_SEGMENT_REGRATIO_THICK: Threshold for the region-sum ratio. The
%       regions above this threshold are assumed to be very thick. 
%       (suggestion: 2.8)
%   Denoise parameters:    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   ONFL_SEGMENT_NOISEESTIMATE_MEDIAN: The 2D median filter values used for
%       noise estimateion. (suggestion: [7 1])
%   ONFL_SEGMENT_DENOISEPM_SIGMAMULT: Multiplier for the noise estimate.
%       noise estimate * sigmamult = sigma for the complex diffusion.
%   ONFL_SEGMENT_FINDRETINAEXTREMA_SIGMA_FZ_EXTR4: Before finding the 4
%       largest contrast drops in the inner part of the scan, a gaussian 
%       with this sigma is applied
%   ONFL_SEGMENT_FINDRETINAEXTREMA_SIGMA_FZ_EXTRMAX: Before finding the 
%       largest contrast drop in the inner part of the scan, a gaussian 
%       with this sigma is applied
%   Blood vessel detection parameters - see the findBloodVessels function
%   for more details on the parameters. %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   ONFL_SEGMENT_FINDBLOODVESSELS_THRESHOLD_ALL
%   ONFL_SEGMENT_FINDBLOODVESSELS_FREEWIDTH_ALL
%   ONFL_SEGMENT_FINDBLOODVESSELS_MULTWIDTH_ALL
%   ONFL_SEGMENT_FINDBLOODVESSELS_MULTWIDTHTHRESH_ALL: These four
%       parameters are used for detecting accurate blood vessel positions 
%   ONFL_SEGMENT_FINDBLOODVESSELS_THRESHOLD_EN
%   ONFL_SEGMENT_FINDBLOODVESSELS_FREEWIDTH_EN
%   ONFL_SEGMENT_FINDBLOODVESSELS_MULTWIDTH_EN
%   ONFL_SEGMENT_FINDBLOODVESSELS_MULTWIDTHTHRESH_EN: These parameters are
%       used to find blood vessel centers for the spliting of the B-Scan 
%       into regions (used in the enrgy minimization)
%   Energy minimization parameters:  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   ONFL_SEGMENT_POLYNUMBER: A polynom of this cardinality is fit through
%       the initial segmentation and taken as an initialization for the 
%       energy minimization
%   ONFL_SEGMENT_LINESWEETER_FINAL: The resulting segmentation is smoothed
%       with this parameters (see linesweeter function)
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

bscan = mirrorCirc(bscan, 'add', Params.ONFLCIRC_SEGMENT_MIRRORWIDTH);
rpe = mirrorCirc(rpe, 'add', Params.ONFLCIRC_SEGMENT_MIRRORWIDTH);
icl = mirrorCirc(icl, 'add', Params.ONFLCIRC_SEGMENT_MIRRORWIDTH);
ipl = mirrorCirc(ipl, 'add', Params.ONFLCIRC_SEGMENT_MIRRORWIDTH);
infl = mirrorCirc(infl, 'add', Params.ONFLCIRC_SEGMENT_MIRRORWIDTH);

% 1) Normalize intensity values and align the image to the RPE
bscan(bscan > 1) = 0; 
bscan = sqrt(bscan);
bscanDSqrt = sqrt(bscan);

% 2) Find blood vessels for segmentation and energy-smooth 
idxBV = find(extendBloodVessels(bv, Params.ONFLCIRC_EXTENDBLOODVESSELS_ADDWIDTH, ...
                                    Params.ONFLCIRC_EXTENDBLOODVESSELS_MULTWIDTHTHRESH, ...
                                    Params.ONFLCIRC_EXTENDBLOODVESSELS_MULTWIDTH));
                                
[alignedBScanDSqrt flatICL transformLine] = alignAScans(bscanDSqrt, Params, [icl; round(infl)]);
flatINFL = round(infl - transformLine);
flatIPL = round(ipl - transformLine);

averageMask = fspecial('average', [3 7]);
alignedBScanDen = imfilter(alignedBScanDSqrt, averageMask, 'symmetric');

idxBVlogic = zeros(1,size(alignedBScanDSqrt, 2), 'uint8') + 1;
idxBVlogic(idxBV) = idxBVlogic(idxBV) - 1;
idxBVlogic(1) = 1;
idxBVlogic(end) = 1;
idxBVlogicInv = zeros(1,size(alignedBScanDSqrt, 2), 'uint8') + 1 - idxBVlogic;
alignedBScanWoBV = alignedBScanDen(:, find(idxBVlogic));
alignedBScanInter = alignedBScanDen;
runner = 1:size(alignedBScanDSqrt, 2);
runnerBV = runner(find(idxBVlogic));
for k = 1:size(alignedBScanDSqrt,1)
    alignedBScanInter(k, :) = interp1(runnerBV, alignedBScanWoBV(k,:), runner, 'linear', 0);
end

alignedBScanDSqrt(:, find(idxBVlogicInv)) = alignedBScanInter(:, find(idxBVlogicInv)) ;

% 2) Denoise the image with complex diffusion
noiseStd = estimateNoise(alignedBScanDSqrt, Params);
% Complex diffusion relies on even size. Enlarge the image if needed.
if mod(size(alignedBScanDSqrt,1), 2) == 1 
    alignedBScanDSqrt = alignedBScanDSqrt(1:end-1, :);
end
Params.DENOISEPM_SIGMA = [(noiseStd * Params.ONFLCIRC_SEGMENT_DENOISEPM_SIGMAMULT) (pi/1000)];
if mod(size(alignedBScanDSqrt,2), 2) == 1
    temp = alignedBScanDSqrt(:,1);
    alignedBScanDSqrt = alignedBScanDSqrt(:, 2:end);
    alignedBScanDen = real(denoisePM(alignedBScanDSqrt, Params, 'complex'));
    alignedBScanDen = [temp alignedBScanDen];
else
    alignedBScanDen = real(denoisePM(alignedBScanDSqrt, Params, 'complex')); 
end

% Find extrema highest Min, 2 highest min sorted by position
extr2 = findRetinaExtrema(alignedBScanDen, Params, 2, 'min pos', ...
    [flatINFL + 1; flatIPL - Params.ONFLCIRC_SEGMENT_MINDIST_IPL_ONFL]); 
additional(1,:) = flatIPL + transformLine;

% 6) First estimate of the ONFL:
onfl = extr2(2,:); 
idx1Miss = find(extr2(1,:) == 0); 
idx2Miss = find(extr2(2,:) == 0); 
onfl(idx2Miss) = flatINFL(idx2Miss); 
onfl(idxBV)  = flatIPL(idxBV);
onfl= linesweeter(onfl, Params.ONFLCIRC_SEGMENT_LINESWEETER_INIT_INTERPOLATE);

% Remove this line!
additional(2,:) = onfl + transformLine;

% 7) Do energy smoothing
% Forget about the ONFL estimate and fit a poly trough it. Then Energy!
onfl = linesweeter(onfl, [1 0 0 0 0 0 1; 5 0 0 0 0 0 15; 0 0 0 0 0 0 0; 0 0 0 0 0 0 0]);
onfl = round(onfl);

onfl(idx1Miss) = flatINFL(idx1Miss); 
diffNFL = onfl - flatINFL;
onfl(diffNFL < 0) = flatINFL(diffNFL < 0);

gaussCompl = fspecial('gaussian', 5 , 1);
smoothedBScan = alignedBScanDen;
smoothedBScan = imfilter(smoothedBScan, gaussCompl, 'symmetric');
smoothedBScan = -smoothedBScan;
smoothedBScan = smoothedBScan ./ (max(max(smoothedBScan)) - min(min(smoothedBScan))) .* 2 - 1;

onfl = energySmooth(smoothedBScan, Params, onfl, idxBV, [flatINFL; flatIPL]);

% Some additional constraints and a final smoothing
onfl(idx2Miss) = flatINFL(idx2Miss);
onfl(idxBV) = 0;

onfl = linesweeter(onfl, Params.ONFLCIRC_SEGMENT_LINESWEETER_FINAL);

diffNFL = onfl - flatINFL;
onfl(find(diffNFL < 0)) = flatINFL(find(diffNFL < 0));

onflAuto = onfl + transformLine;
onflAuto = mirrorCirc(onflAuto, 'remove', Params.ONFLCIRC_SEGMENT_MIRRORWIDTH);

additional = mirrorCirc(additional, 'remove', Params.ONFLCIRC_SEGMENT_MIRRORWIDTH);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Helper functions:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% A simple noise estimate for adapting a denoising filter. It may seem a
% bit weird at first glance, but it delivers appropriate results.
function res = estimateNoise(octimg, Params)
    octimg = octimg - mean(mean(octimg)); 
    mimg = medfilt2(octimg, Params.ONFLCIRC_SEGMENT_NOISEESTIMATE_MEDIAN);
    octimg = mimg - octimg;

    octimg = abs(octimg);

    line = reshape(octimg, numel(octimg), 1);
    res = std(line);
end

end