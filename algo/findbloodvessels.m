function idx = findbloodvessels(bscan, params, linerpe)
% FINDBLOODVESSELS Finds the indices of blood vessel shadows along a line. 
% The line shoud be preferably the RPE. Adaptive tresholding is used. The
% width of the lines may then be extended by a constant and/or 
% multiplicative factor.
% Algorithm:
% A moving window of certainn width is moved along linerpe, values above in
% a certain range are summed). If the act value is smaller than the mean
% value in the window * treshold, the position is believed to be a BV
% IDX = findbloodvessels(BSCAN, PARAMS, LINERPE)
% IDX: Vector with the detected blood vessel positions (y-value).
% BSCAN: An OCT bscan image.
% PARAMS:   Parameter struct for the automated segmentation
%   In this function, the following parameters are currently used:
%   FINDBLOODVESSELS_WINDOWWIDTH The actual windowwidth of the computed
%   mean intensity value is 2 * windowwidth + 1. 
%   (suggestion: 30)
%   FINDBLOODVESSELS_WINDOWHEIGHT The windowheight above the RPE of the 
%   computed mean intensity value (suggestion: 7)
%   FINDBLOODVESSELS_THRESHOLD The A-Scan is marked as BV, when it lies
%   below threshold * mean_in_window (suggestion: 0.7)
%   FINDBLOODVESSELS_FREEWIDTH Number of A-Scans that are marked as BV left
%   and right to the found BV (suggestion: 2)
%   FINDBLOODVESSELS_MULTWIDTH The width of the BV is multiplied by that 
%   factor. Posisiton stays the same (suggestion: 0)
%   FINDBLOODVESSELS_MULTWIDTHTHRESH if multwidth != 0, BV width length 
%   smaller than this are discarded (suggestion: 5)
% LINERPE: The hopefully correct RPE
%
% Writen by Markus Mayer, Pattern Recognition Lab, University of
% Erlangen-Nuremberg
%
% First final Version: June 2010

PRESICION = 'single'; % Hard coded presicion value.
% You may want to change it to 'double'.

multWidthTresh  = params.FINDBLOODVESSELS_MULTWIDTHTHRESH;
multWidth       = params.FINDBLOODVESSELS_MULTWIDTH;
addWidth        = params.FINDBLOODVESSELS_FREEWIDTH;
treshold        = params.FINDBLOODVESSELS_THRESHOLD;
width           = params.FINDBLOODVESSELS_WINDOWWIDTH;
height          = params.FINDBLOODVESSELS_WINDOWHEIGHT;

% Find the BV positions by an adaptive tresholding in a moving window
idx = zeros(1,size(linerpe,2), 'uint8');
sumline = zeros(1, size(linerpe,2), PRESICION);
linerpe(linerpe < height + 1) = height + 1;
linerpe(linerpe > size(bscan, 1)) = size(bscan, 1);

for j = 1:size(linerpe,2)
    sumline(j) = sum(bscan(floor(linerpe(j)) - height:floor(linerpe(j)),j));
end

sumline = [sumline(width+2:-1:2) sumline sumline(end-1:-1:end-width)];

for j = 1:size(linerpe,2)
    maxmean = mean(sumline(j:j+2*width));
    if sumline(j+width) < maxmean * treshold
        idx(j) = 1;
    end
end

if addWidth ~= 0 || multWidth ~= 0
    idx = extendBloodVessels(idx, addWidth, multWidthTresh, multWidth);
end

idx = find(idx > 0);
