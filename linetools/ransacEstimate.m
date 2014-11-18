function lineBest = ransacEstimate(line, modelmode, errormode, maxiter, modeloptions, falsePositions)
% RANSACESTIMATE: Gives the best fitting RANSAC model fit for a line

if nargin < 6
    falsePositions = zeros(1, size(line, 2), 'uint8');
end

if nargin < 5
    modeloptions = 5;
end

err = 1000000000;
lineBest = zeros(1, size(line,2), 'single');

for i = 1:maxiter
    lineEst = ransacFitModel(line, modelmode, [(modeloptions(1) * 2) modeloptions(1)], falsePositions);
    
    errNew = ransacComputeError(line, lineEst, errormode, 2, falsePositions);
    
    if errNew < err
        lineBest = lineEst;
        err = errNew;
    end
end

end