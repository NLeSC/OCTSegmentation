%% segmentOneLayer - function to segment ome layer in 2D phantom image
%
% author: Elena Ranguelova, NLeSc
% date creation: 27-01-2014
% modification date: 
% modification details: 
% -----------------------------------------------------------------------
% SYNTAX
% [upper, lower]=segmentOneLayer(data, PARAMSA, PARAMSR, lineregion)
%
% INPUT
% data- filtered and thresholded OCT 2D data
% PARAMSA:   Parameter struct for the automated segmentation
% PARAMSR:   Parameter struct for the RANSAC segmentation
%  
% OUPTPUT
% upper- upper boundary of the layer 
% lower- lower boundary of the layer 

% EXAMPLE
% [line_upper, line_lower] =  segmentOneLayer(data, paramsa, paramsr, lineregion);
%
% SEE ALSO
% segment_phantom_lines
%
% REFERENCES
%
% NOTES

function [upper, lower] =  segmentOneLayer(data, PARAMSA, PARAMSR, lineregion)

% automatic
upper_auto = findRetinaExtrema(data, PARAMSA, 1, 'max', lineregion);
lower_auto = findRetinaExtrema(data, PARAMSA, 1, 'min', lineregion);

% ransac
upper_Ransac = ransacEstimate(upper_auto, 'poly', ...
                            PARAMSR.RPELIN_RANSAC_NORM_RPE, ...
                            PARAMSR.RPELIN_RANSAC_MAXITER, ...
                            PARAMSR.RPELIN_RANSAC_POLYNUMBER);
                        
lower_Ransac = ransacEstimate(lower_auto, 'poly', ...
                            PARAMSR.RPELIN_RANSAC_NORM_RPE, ...
                            PARAMSR.RPELIN_RANSAC_MAXITER, ...
                            PARAMSR.RPELIN_RANSAC_POLYNUMBER);

% smooth
upper =  linesweeter(upper_Ransac, PARAMSA.INFL_SEGMENT_LINESWEETER_FINAL);
lower =  linesweeter(lower_Ransac, PARAMSA.INFL_SEGMENT_LINESWEETER_FINAL);