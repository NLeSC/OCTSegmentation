function extrema = extremafinder(octimg, count, mode, lineregion)
% EXTREMAFINDER finds the positions with highest/lowest gradient within
% A-Ascans
% EXTREMA = extremafinder(OCTIMG, COUNT, MODE, LINEREGION)
% finds the positions with highest/lowest gradient within
% A-Ascans. Extrema means in this case: Change of the gradient from
% negative to positive and vice versa.
% OCTIMG: An OCT BScan, processed to the desired smoothing/denoising/
%   gradient. E.g., if you want to detect contrast changes on the original
%   B-Scan, this already has to be a gradient image.
% COUNT: Number of extrema to search for in each A-Scan. 
% MODE: Should the all extrema be searched? Or just in one direction?
%   Should the resulting points be ordered by the
%   intensity of the input image or by their positions in the A-Scan?
%   The options can be written in a string. Example: 'abs pos'
%   Possibilities are:
%       - abs: All gradient changes are detected (decision by abs. value)
%       - min: Only gradient - + changes (seen from the inner side of the scan)
%       - low: The lowest intensity values in the A-Scan 
%       - max: Only gradient + - changes
%       - pos: sorted by position in the A-Scan
% LINEREGION: Two lines are given. Only in between those a search for
%   extrema is performed.
% EXTREMA: Matrix of size Count x #AScans. In each column the extrema 
% z-values in the respective A-Scan are listed
%
% Writen by Markus Mayer, Pattern Recognition Lab, University of
% Erlangen-Nuremberg
%
% First final Version: June 2010

% Default parameters

PRECISION = 'double';

if nargin < 2
    count = 10;
end
if nargin < 3
    mode = 'abs';
end
if nargin < 4
    % Default search region: The whole image.
    lineregion = [zeros(1,size(octimg,2), PRECISION) + 2; zeros(1,size(octimg,2), PRECISION) + size(octimg,1)];
end
extrema = zeros(count, size(octimg,2), PRECISION);

% Compute if the gradient of the input rises or falls.
gradoctimg = octimg(2:end, :) - octimg(1:end-1, :);
gradoctimg = [zeros(1, size(octimg,2), 'single') - 1; gradoctimg];
gradoctimg(gradoctimg < 0) = -1;
gradoctimg(gradoctimg > 0) = 1;
extremaoctimg = gradoctimg(2:end, :) - gradoctimg(1:end-1, :);

% Delete rises/drops, if desired
if numel(strfind(mode, 'min')) ~= 0 
    extremaoctimg(extremaoctimg < 0) = 0;
elseif numel(strfind(mode, 'max')) ~= 0 
    extremaoctimg(extremaoctimg > 0) = 0;
end

octimg = abs(octimg);
if numel(strfind(mode, 'low')) ~= 0 
    octimg = -octimg;
end

% Delete extrema outside of the search region
for i = 1:size(octimg,2)
    lineregion(lineregion < 2) = 2;
    lineregion(lineregion > size(octimg, 1) - 1) = size(octimg, 1) - 1;
    extremaoctimg(1:lineregion(1,i)-1,i) = 0;
    extremaoctimg(lineregion(2,i)+1:end,i) = 0;
end

% Find the COUNT highest extrema.
 for i = 1:size(octimg,2) 
     extremline = extremaoctimg(:,i);
     points = find(extremline);
     val = octimg(points, i);
     [sortval IX] = sort(val, 'descend');
     if numel(strfind(mode, 'th')) ~= 0 
         idxDis = find(abs(sortval) < 0.05);
         if numel(idxDis) ~= 0
             if idxDis(1) == 1
                 %sortval = [];
                 IX = [];
             else
                %sortval = sortval(1:idxDis(1)-1);
                IX = IX(1:idxDis(1)-1);
             end
         end
     end
     sortpoints = points(IX);
     if size(sortpoints,1) < count
         sortpoints = [sortpoints; zeros(count - size(sortpoints,1), 1, PRECISION)];
     end
     extrema(:,i) = sortpoints(1:count);
 end
 
 % Sort by position in the A-Scan, if desired.
 if numel(strfind(mode, 'pos')) ~= 0 
     for i = 1:size(octimg,2)
         extrema(:,i) = sort(extrema(:,i));
     end
 end

