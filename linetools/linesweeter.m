function res = linesweeter(lines, param)
% LINESWEETER "Sweetens" lines by applying several filters. 
% "Sweeten" in this sense means: Make the line look better.
% RES = linesweeter(LINES, CASCADE, PARAM)
% Sweetens lines by applying several filters and enhancers. After each
% step, lines without any entries are removed.
% LINES: Matrix with each row defining one line, the number of columns is
%   aequivalent to the number of A-Scans in a B-Scan. The OCTSEG line
%   definition is: A row vector with as much entries as A-Scans in an B-Scan.
%   The entries corresond to positions (z-direction) in an A-Scan. If the
%   entry is 0, no line is present.
% CASCADE: 0 or 1 entries in a 1x7 matrix. Defines which filters/enhancers
%   to apply. The order and function is:
%   1) PreMedian: A simple median filter
%   2) Freedrop: Remove line segments, that have no other line segment to
%      their left or right within a certain range. All lines are looked at
%      for each segment.
%   3) Polyfit: Remove linepoints with the greatest distance to a fitting
%      polynom. Each line is processed separately. A polynom is fitted
%      trough the whole line, than the line is split in aequidistant parts.
%      Only a percentage of the points with the smallest distance to the
%      polynom is kept for each part.
%   4) Shortdrop: Remove short line segments under a certain length.
%   5) Interpolate: Fill gaps in each line by linear interpolation.
%   6) PostMedian: A simple median filter.
%   7) Gauss: Gaussian smoothing.
% PARAM: A 3x7 matrix defining the parameters for the filters/enhancers. It
%   can be set only partially, the remaining values are set to default. 
%   A value of 0 in the matrix counts as not set. If a filter/enhancer
%   requires less than 3 parameters, the corresponding columns are filled
%   from top.
%   Parameters are:
%   |width nhsize       keepPercent minlength 0       width var|
%   |0     minNum       polydegree  0         0       0     0  |
%   |0     savelength   parts       0         0       0     0  |
%   width: Width of the 1D median filter
%   nhsize: Neighborhood size around the endpoint of a line, where other
%       points are searched. Square sized, where the length of the square is
%       nhwith*2+1
%   minNum: Minimum number of neighbor points required
%   savelength: Line segments with this lengths are for sure not deleted.
%   keepPercent: This percentage is kept for each part.
%   polydegree: Polynom degree
%   parts: Number of aequidistant parts
%   minlength: Minimum length of the kept line segments
%   width: Width of the 1D median filter
%   var: Variance of the applied 1D gaussian.
% RES: The resulting sweetend lines.
%
% Writen by Markus Mayer, Pattern Recognition Lab, University of
% Erlangen-Nuremberg
%
% First final Version: June 2010

% Setting up the default values.
if nargin < 2
    param = [1 0 0 1 1 0 1; 7 5 2/3 6 0 7 3; 0 1 5 0 0 0 0; 0 20 3 0 0 0 0];
end
   
cascade = param(1,:);
param = param(2:4, :);

% Extend the lines to avoid border problems
extwidth = 30;
linesS = [lines(:,extwidth+1:-1:2) lines lines(:,end-1:-1:end-extwidth)];

% Remove lines that have only 0 entries
sumL = sum((linesS > 0)');
nonNull = find(sumL > 1);
linesS = linesS(nonNull, :);

% Apply a pre-median filtering on non-zero entries
if cascade(1) == 1
    for i = 1:size(linesS,1)
        entries = find(linesS(i,:));
        line = linesS(i,entries);
        line = medfilt1(line, param(1,1));
        linesS(i,entries) = line;
    end
end

% Remove lines that have no neighbours left and rightenside
if cascade(2) == 1
    for i = 1:size(linesS,1)
        entries = find(linesS(i,:));
        line = linesS(i,entries);
        xlines = linefinder(line,3);
        xlines = linefreedrop(xlines, param(1,2), param(2,2), param(3,2));
        if size(xlines,1) ~= 1
            line = sum(xlines);
        else
            line = xlines;
        end
        linesS(i,entries) = line;
    end
end

% Remove lines that have only 0 entries
sumL = sum((linesS > 0)');
nonNull = find(sumL > 1);
linesS = linesS(nonNull, :);

% remove the points with the greatest distance to a fitting polynom
if cascade(3) == 1
    for i = 1:size(linesS,1)
        linesS(i,:) = linepolydiscard(linesS(i,:),...
            param(1,3), param(2,3), param(3,3));
    end
end

% Remove lines that have only 0 entries
sumL = sum((linesS > 0)');
nonNull = find(sumL > 1);
linesS = linesS(nonNull, :);

% Remove short line segments
if cascade(4) == 1
    for i = 1:size(linesS,1)
        entries = find(linesS(i,:));
        line = linesS(i,entries);
        xlines = linefinder(line,3);
        xlines = lineshortdrop(xlines, param(1,4));
        if size(xlines,1) ~= 1
            line = sum(xlines);
        else
            line = xlines;
        end
        linesS(i,entries) = line;
    end
end

% Remove lines that have only 0 entries 
sumL = sum((linesS > 0)');
nonNull = find(sumL > 1);
linesS = linesS(nonNull, :);

% Interpolate wholes
if cascade(5) == 1
    for i = 1:size(linesS,1)
        entries = find(linesS(i,:));
        linesS(i, 1:entries(1)) = linesS(i, entries(1));
        linesS(i, entries(end):end) = linesS(i, entries(end));
        entries = find(linesS(i,:));
        if param(1,5) == 0
            linesS(i,:) = interp1(entries, linesS(i,entries), [1:size(linesS,2)]);
        else
            linesS(i,:) = interp1(entries, linesS(i,entries), [1:size(linesS,2)], 'spline');
        end
    end
end

% Apply a post-median filtering
if cascade(6) == 1
    for i = 1:size(linesS,1)
        entries = find(linesS(i,:));
        line = linesS(i,entries);
        line = medfilt1(line, param(1,6));
        linesS(i,entries) = line;
    end
end

% Apply a gaussian smoothing
if cascade(7) == 1
    for i = 1:size(linesS,1)
        gauss1 = fspecial('gaussian', param(1,7) * 2 + 1 , param(1,7));
        linesS(i,:) = imfilter(linesS(i,:), gauss1, 'symmetric');
    end
end

linesS(linesS < 1) = 0;
res = linesS(:,extwidth+1:end-extwidth);