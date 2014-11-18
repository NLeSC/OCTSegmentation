function longlines = lineshortdrop(lines, minlength)
% LINESHORTDROP removes short lines from the linematrix
% LONGLINES = lineshortdropper(LINES, MINLENGTH)
% LINES: Linematrix according to OCTSEGs standard with one additional
%   assumption: The line segment has no breaks, that means 0 can appear 
%   only at the left and right side of the line, not in between.
% MINLENGTH: All lines above that length are kept.
% LONGLINES: All lines with length > minlength
%
% Writen by Markus Mayer, Pattern Recognition Lab, University of
% Erlangen-Nuremberg
%
% First final Version: June 2010

linesindex = lines > 0;
linesum = sum(linesindex');

longlines = [];

for i = 1:size(lines,1)
    if linesum(i) >= minlength
        longlines = vertcat(longlines, lines(i,:));
    end
end

        