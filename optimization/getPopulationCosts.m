function costs = getPopulationCosts(fixedLayer, layers, population, segments, mode, adder, dist, gradient)
% GETPOPULATIONCOSTS
% Returns the costs of a complete population
% mode: the costfunction can be specified and 'span' computes the
% costfunction only on the span of the segments

costFunction = 'L2';
if numel(strfind(mode, 'L1')) ~= 0
    costFunction = 'L1';
elseif numel(strfind(mode, 'L3')) ~= 0
    costFunction = 'L3';
elseif numel(strfind(mode, 'Grad')) ~= 0
    costFunction = 'Grad';
end

if ~strcmp(costFunction , 'Grad')
    if numel(strfind(mode, 'span')) ~= 0
        costs = zeros(size(population,1), 1);
        span = getSpan(fixedLayer, segments, adder);
        for i = 1:size(population,1)
            img = renderGenom(fixedLayer, layers, population(i,:), segments);
            img = img(span(1):span(2), span(3):span(4));
            costs(i) = getCost(img, costFunction, dist);
        end
    else
        costs = zeros(size(population,1), 1);
        for i = 1:size(population,1)
            img = renderGenom(fixedLayer, layers, population(i,:), segments);
            costs(i) = getCost(img, costFunction, dist);
        end
    end
else
    if numel(strfind(mode, 'Grad')) ~= 0
        costs = zeros(size(population,1), 1);
        for i = 1:size(population,1)
            for k = 1:size(population, 2)
                costs(i) = costs(i) + gradient(k, population(i,k));
            end
        end
    end
end

end