function [lines FZ] = findRetinaExtrema(normOctimg, params, c, mode, lineregion)
% FINDRETINAEXTREMA Helper function to find contrast changes in A-Scans all
% along B-Scans. Used in RPE, INFL and ONFL detection - just puts commonly
% used code in one function. Computes the gradient in A-Scan direction (z),
% then detect the extrema on the gradient (edges on the original image)
% [LINES FZ SMOOTHOCTIMG] = findRetinaExtrema(NORMOCTIMG, C, MODE, VARIANCE, LINEREGION)
% NORMOCTIMG: BScan image, already normalized.
% PARAMS:  Parameter struct for the automated segmentation
%   In this function, the following parameters are currently used:
%   FINDRETINAEXTREMA_SIGMA_GRADIENT: Sigma for the gaussian that is
%   applied before gradient computation. 
%   (suggestion: A small number, e.g. 1)
%   FINDRETINAEXTREMA_SIGMA_FZ: Sigma for the gaussion that is aplied to
%   the gradient in Z-direction previous tho extrema finding. 
%   (suggestion: 3);
% C: Vector with two entries. First: Number of contrast rises to detect. 
%       Second: Number of contrast drops. 
% MODE: How does the function work? Possiblities are: 
%   part: All C(1) contrast rises and C(2) contrast drops are detected
%   allregion: All C(1) extremas are detected within the requested region
%   ANYTHING ELSE: The mode is passed to the extremafinder function
% LINEREGION: Only edges within this region are detected. Two lines
%   according to OCTSEG standard, without holes.
%
% Writen by Markus Mayer, Pattern Recognition Lab, University of
% Erlangen-Nuremberg
%
% First final Version: June 2010

% Default parameters
if nargin < 4
    mode = 'abs pos';
end
if nargin < 3
    c = [10 10];
end
if nargin < 5
    lineregion = [zeros(1,size(normOctimg,2), 'single') + 2; zeros(1,size(normOctimg,2), 'single') + size(normOctimg,1)];
end

sigma2D = params.FINDRETINAEXTREMA_SIGMA_GRADIENT;
gauss2D = fspecial('gaussian', sigma2D * 2+ 1, sigma2D);
smoothedImg = imfilter(normOctimg, gauss2D, 'symmetric');

[FX FZ] = gradient(real(smoothedImg));
FZ = FZ ./ max(max(FZ));

if params.FINDRETINAEXTREMA_SIGMA_FZ ~= 0
    sigmaZ = params.FINDRETINAEXTREMA_SIGMA_FZ;
    gauss2Dnew = fspecial('gaussian', sigmaZ * 2 + 1 , sigmaZ);
    gaussZ = gauss2Dnew(:,sigmaZ + 1);
    
    smoothedFZ = imfilter(FZ, gaussZ, 'symmetric');
    smoothedFZ = smoothedFZ ./ max(max(smoothedFZ));
else
    smoothedFZ = FZ ./ max(max(FZ));
end

if strcmp(mode, 'part')
    maxlines = extremafinder(smoothedFZ, c(1), 'max pos');
    minlines = extremafinder(smoothedFZ, c(2), 'min pos');
    lines = vertcat(maxlines, minlines);
else
    if strcmp(mode, 'allregion')
        lt = extremafinder(smoothedFZ, c, 'abs pos', lineregion);
    else
        lt = extremafinder(smoothedFZ, c, mode, lineregion);
    end
    lines = lt;
end

end
