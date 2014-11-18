function [rpeAuto rpeMult] = segmentRPELin(bscan, PARAMS, medline)
% SEGMENTRPELINAUTO Segments the RPELIN from a BScan. Intended for the use on
% circular OCT-Bscans
% RPELINAUTO = segmentRPELINAuto(BSCAN)
% RPELINAUTO: Automated segmentation of the RPELIN
% BSCAN: Unnormed BScan image 
% PARAMS:   Parameter struct for the automated segmentation
%   In this function, the following parameters are currently used:
%   RPELIN_SEGMENT_MEDFILT1 First median filter values (in z and x direction).
%   Preprocessing before finding extrema. (suggestion: 5 7)
%   RPELIN_SEGMENT_MEDFILT2 Second median filter values (in z and x direction).
%   Preprocessing before finding extrema. Directly applied after the first
%   median filter. (suggestion: Use the same settings)
%   RPELIN_SEGMENT_LINESWEETER1 Linesweeter smoothing values before blood
%   vessel region removal
%   RPELIN_SEGMENT_LINESWEETER2 Linesweeter smoothing values after blood
%   vessel region removal. This is the final smoothing applied to the RPELIN.
%   RPELIN_SEGMENT_POLYDIST
%   RPELIN_SEGMENT_POLYNUMBER
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

% 1) Normalize the intensity values
bscan(bscan > 1) = 0; 
snBScan = splitnormalize(bscan, PARAMS, 'ipsimple opsimple soft', medline);
snBScan = removebias(snBScan, PARAMS);

% 2) A simple noise removal
snBScan = medfilt2(snBScan, PARAMS.RPELIN_SEGMENT_MEDFILT);

rpeMult = zeros(3, size(bscan, 2));

% 3) Edge detection along A-Scans (taking the sign of the derivative into
% account)
rpe = findRetinaExtrema(snBScan, PARAMS, 2, 'min', ...
                        [round(medline) + PARAMS.RPELIN_MEDLINE_MINDISTBELOW; ...
                        zeros(1, size(bscan,2), 'double') + size(bscan,1)]);

rpeSimple = rpe(1,:);
rpeMult(1,:) = rpe(1,:);
rpeMult(3,:) = rpe(2,:);
                    
rpeRansac = ransacEstimate(rpeSimple, 'poly', ...
                            PARAMS.RPELIN_RANSAC_NORM_RPE, ...
                            PARAMS.RPELIN_RANSAC_MAXITER, ...
                            PARAMS.RPELIN_RANSAC_POLYNUMBER);
                        
rpeMult(2,:) = rpeRansac;

rpe = mergeLines(rpeSimple, rpeRansac, 'discardOutliers', [PARAMS.RPELIN_MERGE_THRESHOLD ...
                                                           PARAMS.RPELIN_MERGE_DILATE ...
                                                           PARAMS.RPELIN_MERGE_BORDER]);
                                                      
rpeAuto =  linesweeter(rpe, PARAMS.RPELIN_LINESWEETER_FINAL);

end