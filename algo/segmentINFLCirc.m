function inflAuto = segmentINFLCirc(bscan, params, rpe, medline)
% SEGMENTINFLAUTO Segments the INFL from a BScan. Intended for use on
% circular OCT B-Scans.
% INFLAUTO = segmentINFLAuto(BSCAN)
% INFLAUTO: Automated segmentation of the INFL
% BSCAN: Unnormed BScan image 
% RPE: Segmentation of the RPE in OCTSEG line format
% PARAMS:   Parameter struct for the automated segmentation
%   In this function, the following parameters are currently used:
%   INFL_SEGMENT_LINESWEETER_MEDLINE Linesweeter smoothing values for 
%   correcting errors in the medline. (suggestion: Use only linear 
%   interpolation for filling wholes, nothing else)
%   INFL_SEGMENT_LINESWEETER_FINAL Linesweeter smoothing values for the
%   resulting INFL segmentation result
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
bscan(bscan > 1) = 0; 
bscan = sqrt(bscan);
[alignedBScan flatRPE transformLine] = alignAScans(bscan, params, rpe);
medline = round(medline - transformLine);

% 2) Some error handling/constraints are performed here. The medline can 
% not lay below the RPE. The medline is smoothed some more - actually, the
% linesweeter parameters should only be set to do hole interpolation.
medline(medline > flatRPE) = flatRPE(medline > flatRPE);
diffRpeMed = flatRPE - medline;
medline(diffRpeMed < 10) = 0;
medline = linesweeter(medline, params.INFL_SEGMENT_LINESWEETER_MEDLINE);
medline = round(medline);

snBScan = splitnormalize(alignedBScan, params, 'ipsimple opsimple soft', medline);

% 3) Find the INFL in the upper region of the scan 
inflAuto = findRetinaExtrema(snBScan, params, 1, 'max', ...
                            [zeros(1, size(bscan,2), 'double') + 2; medline - 1]);
inflAuto = inflAuto(1,:);

% 4) Transformation of segmentation results from the aligned-RPE image back
% to the original one
inflAuto = inflAuto + transformLine;
inflAuto(inflAuto < 1) = 1;

% 5) Some additional smoothing
inflAuto =  linesweeter(inflAuto, params.INFL_SEGMENT_LINESWEETER_FINAL);

end