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
function [lines] = segment_phantom_lines(data, PARAMS)

if nargin < 2
    PARAMS =[];
end
%------------------------------------------------------------------------------
% rescale the data to interval [0,1]

min_value= min(min(data));
max_value= max(max(data));

data = (data - min_value)./(max_value - min_value);

% make some data available for inspection in the work space
assignin('base', 'data', data);

%------------------------------------------------------------------------------
% take sqrt of he data
data(data>1) = 0;
data = sqrt(data);

% make some data available for inspection in the work space
assignin('base', 'data', data);


lines=[];
