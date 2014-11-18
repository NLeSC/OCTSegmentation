function lines = linefinder(pmx, tresh)
% LINEFINDER Searches a point matrix for lin segment
% LINES = linefinder(PMX, TRESH)
% Searches a pointmatrix for lines, from left to right. It works the
% following: If a point lies within tresh pixels range from the point left 
% to it, it is added to the line. A point can be added to multiple lines.
% For each point a line is searched (so there are a lot of overlapping
% lines).
% PMX: Point matrix (same y-size as an BScan, z-values of points on A-Scans
%   saved). 
% TRESH: treshhold for linesearching. This distance in Pixels is allowed
% from one A-Scan to the next in z-direction within one line.
% LINES: A matrix, same y-size as PMX, in which each line defines a
%   connected line in an image. All values except the linepoints are 0.
%
% Writen by Markus Mayer, Pattern Recognition Lab, University of
% Erlangen-Nuremberg
%
% First final Version: June 2010

% Set default parameters
if nargin < 2
    tresh = 2;
end

lines = zeros(size(pmx,1), size(pmx,2), 'double');
lines(:,1) = pmx(:,1);

for j = 2:size(pmx,2)
    for i = 1:size(pmx,1)
        success = 0;
        ib = 1;
        while ~success && ib <= size(lines,1)
            if (pmx(i,j) <= lines(ib,j-1) + tresh) &&  (pmx(i,j) >= lines(ib,j-1) - tresh)
                lines(ib,j) = pmx(i,j);
                success = 1;
            end
            ib = ib + 1;
        end        
        if  ~success
            new_l =  zeros(1, size(pmx,2), 'double');
            new_l(j) = pmx(i,j);
            lines = vertcat(lines, new_l);
        end
    end
end
    
 