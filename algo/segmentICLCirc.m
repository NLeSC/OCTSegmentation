function icl = segmentICLCirc(bscan, params, rpe, medline)
% SEGMENtICLCIRC Segments some inner retinal layers from a BScan.
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

bscan = mirrorCirc(bscan, 'add', params.INNERCIRC_SEGMENT_MIRRORWIDTH);
medline = mirrorCirc(medline, 'add', params.INNERCIRC_SEGMENT_MIRRORWIDTH);

if numel(rpe) == 0 
    rpe = zeros(1, size(bscan, 2)) + size(bscan, 1);
else  
    rpe = mirrorCirc(rpe, 'add', params.INNERCIRC_SEGMENT_MIRRORWIDTH);
end

bscan(bscan > 1) = 0; 
bscan = sqrt(bscan);
rpe = round(rpe);

averageMask = fspecial('average', params.INNERCIRC_SEGMENT_AVERAGEWIDTH);
bscanAvg = imfilter(bscan, averageMask, 'symmetric');

% We try to find the CL boundary.
% This is pretty simple - it lies between the medline and the RPE and has
% rising contrast. It is the uppermost rising border.
extrICLChoice = findRetinaExtrema(bscanAvg, params,2, 'max', ...
                [medline; rpe - params.INNERCIRC_SEGMENT_MINDIST_RPE_ICL]);
extrICL = min(extrICLChoice,[], 1);

extrICL = linesweeter(extrICL, params.INNERCIRC_SEGMENT_LINESWEETER_ICL);
icl = round(extrICL);

icl = mirrorCirc(icl, 'remove', params.INNERCIRC_SEGMENT_MIRRORWIDTH);

end