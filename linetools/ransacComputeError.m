function err = ransacComputeError(line, lineEst, norm, options, falsePositions)
% RANSACCOMPUTEERROR: Computes the error (difference) in between two lines
% line, lineEst: the two lines
% norm: Currently supported:
%   - 2: L1 Norm.
%   - 1: L1 Norm.
%   - 0: Distances greater than options(1) are counted 
% falsePositions: A vector (same length as line, where a 1 entry markes an
%   invalid position). These will not go into the error computation

correctPositions = falsePositions == 0;
lineValid = line(correctPositions);
lineEstValid = lineEst(correctPositions);

switch norm
    case 2
        err = sum((lineValid - lineEstValid) .^ 2);
    case 1
        err = sum(abs(lineValid - lineEstValid));
    case 0
        dist = abs(lineValid - lineEstValid);
        err = numel(dist(dist > options(1)));
end
        
