%% segment_phantom_lines - function to segment the lines in 2D phantom image
%
% author: Elena Ranguelova, NLeSc
% date creation: 13-01-2014
% modification date: 
% modification details: 
% -----------------------------------------------------------------------
% SYNTAX
% [lines]=segment_pahntom_lines(data, PARAMS)
%
% INPUT
% data- 3D output array of voxel values
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
%
% OUPTPUT
% lines between layers 

% EXAMPLE
% [lines]=segment_phantom_lines(data)
%
% SEE ALSO
% segment_phantom_image
%
% REFERENCES
% e-mail correspondence with Martin and Dirk from AMC
%
% NOTES

function [lines] = segment_phantom_lines(data, PARAMSI, PARAMSE)

if nargin < 2
    PARAMSI =[];
    PARAMSE =[];
end

%% rescale the data
%scaled_data = 10.^(data./20);
min_value= min(min(data));
max_value= max(max(data));

scaled_data = (data - min_value)./(max_value - min_value);

%scaled_data = sqrt(scaled_data);
scaled_data(scaled_data>1) = 0;

% make some data available for inspection in the work space
assignin('base', 'scaled_data', scaled_data);

%% filter the data with median filterring
mask = PARAMSI.INFLLIN_VOLUME_MEDFILT;
mask = mask ./ sum(mask);

%filtered_data = imfilter(scaled_data, mask, 'symmetric') ;

filtered_data = medfilt2(scaled_data,[13 17]);
assignin('base', 'filtered_data', filtered_data);

%% threshold the data
thresh_data = treshold(filtered_data, 'ascanmax', [0.97 0.5]);
%thresh_data = imadjust(thresh_data);
%thresh_data = medfilt2(thresh_data,[3 5]);
assignin('base', 'thresh_data', thresh_data);

%% results
%automatic
line_max = findRetinaExtrema(thresh_data, PARAMSI, 1, 'max');
line_min = findRetinaExtrema(thresh_data, PARAMSI, 1, 'min');
% % ransac
line_max_Ransac = ransacEstimate(line_max, 'poly', ...
                            PARAMSE.RPELIN_RANSAC_NORM_RPE, ...
                            PARAMSE.RPELIN_RANSAC_MAXITER, ...
                            PARAMSE.RPELIN_RANSAC_POLYNUMBER);
                        
line_min_Ransac = ransacEstimate(line_min, 'poly', ...
                            PARAMSE.RPELIN_RANSAC_NORM_RPE, ...
                            PARAMSE.RPELIN_RANSAC_MAXITER, ...
                            PARAMSE.RPELIN_RANSAC_POLYNUMBER);

% merge
lmax = mergeLines(line_max, line_max_Ransac, 'discardOutliers', [PARAMSE.RPELIN_MERGE_THRESHOLD ...
                                                           PARAMSE.RPELIN_MERGE_DILATE ...
                                                           PARAMSE.RPELIN_MERGE_BORDER]);

lmin = mergeLines(line_min, line_min_Ransac, 'discardOutliers', [PARAMSE.RPELIN_MERGE_THRESHOLD ...
                                                           PARAMSE.RPELIN_MERGE_DILATE ...
                                                           PARAMSE.RPELIN_MERGE_BORDER]);
% lmax = line_max;
% lmin = line_min;
% smooth
line_max =  linesweeter(lmax, PARAMSI.INFL_SEGMENT_LINESWEETER_FINAL);
line_min =  linesweeter(lmin, PARAMSI.INFL_SEGMENT_LINESWEETER_FINAL);

lines(1,:) = line_max;
lines(2,:) = line_min;
assignin('base', 'lines', lines);
