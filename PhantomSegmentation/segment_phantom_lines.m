%% segment_phantom_lines - function to segment the lines in 2D phantom image
%
% author: Elena Ranguelova, NLeSc
% date creation: 13-01-2014
% modification date: 27-01-2015
% modification details: Separate function for segmenting each individual
% layer
% -----------------------------------------------------------------------
% SYNTAX
% [lines]=segment_pahntom_lines(data, PARAMS)
%
% INPUT
% data- 2D inut array of image values
% PARAMS:   Parameter struct for the automated segmentation
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
thresh_data = treshold(filtered_data, 'ascanmax', [0.97 0.6]);
%thresh_data = imadjust(thresh_data);
%thresh_data = medfilt2(thresh_data,[3 5]);
assignin('base', 'thresh_data', thresh_data);

%% results
% lineregions for rough estimation of the layer 1
lineregion1 = zeros(2,size(thresh_data,2));
lineregion1(1,:) = 2;
lineregion1(2,:) = 100;

[line_upper1, line_lower1] =  segmentOneLayer(thresh_data, PARAMSI, PARAMSE, lineregion1);

% lineregions for rough estimation of the layer 2
lineregion2 = zeros(2,size(thresh_data,2));
lineregion2(1,:) = lineregion1(2,:);
lineregion2(2,:) = 200;

[line_upper2, line_lower2] =  segmentOneLayer(thresh_data, PARAMSI, PARAMSE, lineregion2);

lines(1,:) = line_upper1;
lines(2,:) = line_lower1;
lines(3,:) = line_upper2;
lines(4,:) = line_lower2;

assignin('base', 'lines', lines);

