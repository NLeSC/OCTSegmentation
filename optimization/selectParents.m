function parentIdx = selectParents(sizePop, numCouples, mode, factor)
% SELECTPARENTS
% Generates random couple indices for a genetic algorithm

if nargin < 3
    mode = 'uniform';
end

parentIdx = zeros(numCouples,2);

if strcmp(mode, 'uniform')
    for i = 1:numCouples
        idx = randperm(sizePop);
        parentIdx(i, 1) = idx(1);
        parentIdx(i, 2) = idx(2);
    end
else
    for i = 1:numCouples
        [ignore,idx] = sort(rand(1,sizePop) .* ((1:sizePop) .^ factor));
        parentIdx(i, 1) = idx(1);
        parentIdx(i, 2) = idx(2);
    end
end