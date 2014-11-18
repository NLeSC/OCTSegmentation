function resoctimg = removebias(octimg, params)
% REMOVEBIAS A bias value is estimated from the innermost and outermost 10
% rows of the BScan image (the mean value of the 3/4 lowest intensities in
% these region) and removed from the image. The image is then again [0:1]
% normalized.
% RESOCTIMG = removeBias(OCTIMG)
% OCTIMG: BScan image. 
% PARAMS:  Parameter struct for the automated segmentation
%   In this function, the following parameters are currently used:
%   REMOVEBIAS_REGIONWIDTH: Defines how large (in  pixels) the regions for
%   computation (from the top and bottom of the B-Scan) are 
%   (suggestion: 10)
%   REMOVEBIAS_FRACTION: Defines what fraction of the pixels with lowest
%   intensity are used for bias computation. 
%   (suggestion: 0.75)
% RESOCTIMG: BScan after Bias removal
%
% Writen by Markus Mayer, Pattern Recognition Lab, University of
% Erlangen-Nuremberg
%
% First final Version: June 2010

% Compute bias

regionwidth = params.REMOVEBIAS_REGIONWIDTH;
fraction = params.REMOVEBIAS_FRACTION;

temp = [reshape(octimg(1:regionwidth,:),1, size(octimg,2) * regionwidth)...
    reshape(octimg(end-regionwidth+1:end,:),1, size(octimg,2) * regionwidth)];
temp = sort(temp);
bias = mean(mean(temp(floor(end*fraction):end)));

% Remove bias
resoctimg = octimg - bias;
resoctimg(resoctimg > 1) = 1;
resoctimg(resoctimg < 0) = 0;
resoctimg = resoctimg ./ max(max(resoctimg));