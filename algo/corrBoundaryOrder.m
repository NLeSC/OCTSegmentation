function boundaries = corrBoundaryOrder(boundaries)

for i = 1:numel(boundaries) - 1
    boundaries{i}(boundaries{i} > boundaries{i + 1}) = ...
        boundaries{i + 1}(boundaries{i} > boundaries{i + 1});
    boundaries{i + 1}(boundaries{i + 1} < boundaries{i}) = ...
        boundaries{i}(boundaries{i + 1} < boundaries{i});
end