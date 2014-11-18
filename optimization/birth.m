function child = birth(fixedLayer, layers, parentGenoms, segments, numGen, mode, adder, dist)
% BIRTH
% Generates a mixtures out of 2 parent genoms (in a genetic optimization)
% mode: 'random': Randomly mixes genoms
%       'compare': Compare results locally

if nargin < 6
    mode = 'random';
end

costFunction = 'L2';
if numel(strfind(mode, 'L1')) ~= 0
    costFunction = 'L1';
elseif numel(strfind(mode, 'L3')) ~= 0
    costFunction = 'L3';
end

if numel(strfind(mode, 'crossover')) ~= 0
    child = parentGenoms;
    for g = 1:size(parentGenoms, 2)
        if rand(1) < 0.5
            temp = child(1,g);
            child(1,g) = child(2,g);
            child(2,g) = temp;
        end
    end
else

genomIdx = randperm(size(parentGenoms, 2));
genomIdx = genomIdx(1:numGen);

child = parentGenoms(1, :);

if numel(strfind(mode, 'compare')) ~= 0
    for g = 1:numel(genomIdx)
        if parentGenoms(1,genomIdx(g)) ~= parentGenoms(2, genomIdx(g))
            img1 = renderSingleGenom(fixedLayer, layers, parentGenoms(1,:), segments, genomIdx(g), adder);
            img2 = renderSingleGenom(fixedLayer, layers, parentGenoms(2,:), segments, genomIdx(g), adder);
            cost1 = getCost(img1, costFunction, dist);
            cost2 = getCost(img2, costFunction, dist);
            if cost2 < cost1
                child(genomIdx(g)) = parentGenoms(2,genomIdx(g));
            end
        end
    end
elseif numel(strfind(mode, 'random')) ~= 0
    for g = 1:numel(genomIdx)
        if rand(1) < 0.5
            child(genomIdx(g)) = parentGenoms(2,genomIdx(g));
        end
    end
end
end
end