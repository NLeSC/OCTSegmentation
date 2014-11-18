function swline = linepolydiscard(in_line, goodpercent, polydegree, parts)
% POLYLINEMATCHER Fits a polynome trough a line. Than spilts the line in
% aequidistant parts. A fixed percentage of each part is kept, the most
% distant points to the polynom are discarded.
% [SWLINE DELTA] = polyline(IN_LINE, GOODPERCENT, POLYDEGREE, PARTS)
% IN_LINE: The input line (Row vector according to OCTSEGs line definition)
% GOODPERCENT: How much (in %) of the points are kept?
% POLYDEGREE: Polynom degree used
% PARTS: In how many parts the line is split for comparisong with the
%   polynom?
% SWLINE: Resulting line. 


% Set default parameters
if nargin < 4
    parts = 5;
end
if nargin < 3
    polydegree = 4;
end
if nargin < 2
    goodpercent = 2/3;
end

% Fill gaps in the input line
entries = find(in_line);
noentries = in_line < 1;
line = interp1(entries, in_line(entries), [1:size(in_line,2)], 'linear', 'extrap'); 

swline = zeros(1,size(in_line,2), 'single');
     
% Perform the polynom split
x = [1:size(line,2)];
[p S mu] = polyfit(x, line, polydegree);
[ynew, delta] = polyval(p, x, S, mu);

diff = abs(ynew - line);

% Compute the part positions
segments = [1:floor(size(diff,2)/parts):size(diff,2)];
segments(end + 1) = size(diff,2);

% throw out the most distant points from the polynom.
for i = 1:size(segments, 2)-1
    [bla IX] = sort(diff(segments(i):segments(i+1)));
    goodVsIdx = sort(IX(1:floor(end * goodpercent))) + segments(i) - 1;
    goodVs = line(goodVsIdx);
    swline(goodVsIdx) = goodVs;
end

swline(noentries) = 0;