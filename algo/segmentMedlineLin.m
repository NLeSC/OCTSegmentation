function medline = segmentMedlineLin(bscan, PARAMS)
% SEGMENTMEDLINELIN
%
% Writen by Markus Mayer, Pattern Recognition Lab, University of
% Erlangen-Nuremberg


bscan(bscan > 1) = 0; 
medline = findmedline(bscan, PARAMS);

medlineRansac = ransacEstimate(medline, 'poly', ...
                            PARAMS.MEDLINE_RANSAC_NORM, ...
                            PARAMS.MEDLINE_RANSAC_MAXITER, ...
                            PARAMS.MEDLINE_RANSAC_POLYNUMBER);

medline = mergeLines(medline, medlineRansac, 'discardOutliers', [PARAMS.MEDLINE_MERGE_THRESHOLD ...
                                                           PARAMS.MEDLINE_MERGE_DILATE ...
                                                           PARAMS.MEDLINE_MERGE_BORDER]);

medline = round(medline);                       
medline(medline < 1) = 1;                                                       
                                                       

end