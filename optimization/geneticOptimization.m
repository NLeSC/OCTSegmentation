function bestGenom = geneticOptimization(fixedLayer, layers, segments, genValues, Params, costFunction, dist, gradient, factor)
% Params: parameter struct. Entries
% sizePopulation = size of the population
% maxIter = maxNumber of iterations.
% numCouples = number of couples
% numChildren = number of children for each couple
% numGenBirth = Percentage of genes to merge during birth
% numGenMutate = Percentage of genes to mutate
% evalAdder = extra space for evaluation
% chanceMutate = chance of Mutation
% mutationDrop: 0/1 Lower chance of mutation linearly with iterations
% mutationStop: Percentage of iterations where a mutation is performed
% mergePopulation: 0/1 : Should a merge of the population be performed?

population = createInitPopulation(Params.sizePopulation, size(segments, 1), genValues, 'fillRandMinor', 0.1);

Params.numGenMutate = ceil(Params.numGenMutate * size(segments, 1));
Params.numGenBirth = ceil(Params.numGenBirth * size(segments, 1));

disp(['Starting genetic optimization with ' num2str(Params.maxIter) ' iterations.']);

iter = 0;
while iter < Params.maxIter
    if numel(strfind(costFunction, 'Grad')) == 0
    costs = getPopulationCosts(fixedLayer, layers, population, segments, costFunction, Params.evalAdder, dist);
    else
        costs = getPopulationCosts(fixedLayer, layers, population, segments, 'L2 span', Params.evalAdder, dist);
        costsGrad  = getPopulationCosts(fixedLayer, layers, population, segments, 'Grad', Params.evalAdder, dist, gradient);
        costs = costs + costsGrad * factor;
    end
    [costsSorted idx] = sort(costs, 'ascend');
    
    population = population(idx(1:Params.sizePopulation), :);
    bestGenom = population(1,:);
    bestCost = costsSorted(1);
    
    parentIdx = selectParents(Params.sizePopulation, Params.numCouples, 'prefer', 0.5);
    
    %newPopulation = zeros(Params.numCouples * Params.numChildren, size(population, 2));
    newPopulation = zeros(Params.numCouples * 2, size(population, 2));
    
    for couple = 1:Params.numCouples
        %         for child = 1:Params.numChildren
        %             newPopulation((couple - 1) * Params.numChildren + child, :) = ...
        %                 birth(fixedLayer, layers, [population(parentIdx(couple, 1), :); population(parentIdx(couple, 2), :)], ...
        %                 segments, Params.numGenBirth, 'random', Params.evalAdder);
        %         end
        
        newPopulation([(couple * 2 - 1) (couple * 2)], :) = birth(fixedLayer, layers, [population(parentIdx(couple, 1), :); population(parentIdx(couple, 2), :)], ...
            segments, Params.numGenBirth, 'crossover', Params.evalAdder);
    end
    
    if Params.mutationDrop
        mutateFactor = iter/Params.maxIter;
    else
        mutateFactor = 0;
    end
    
    dev = std(newPopulation, 0,1);
    stuckIdx = find(dev == 0);
    
    for child = 1:Params.numCouples * Params.numChildren
        
        if (rand(1) < Params.chanceMutate * (Params.mutationStop - mutateFactor))
            newPopulation(child, :) = mutateGenom(newPopulation(child, :), Params.numGenMutate, genValues);
        end
        
        %if (rand(1) < Params.chanceMutate * (Params.mutationDrop - mutateFactor))  
        if numel(stuckIdx) ~= 0
            if (rand(1) < 0.8 * (Params.mutationStop - mutateFactor))  
                newPopulation(child, :) = mutateGenomIdx(newPopulation(child, :), stuckIdx, genValues);
            end
        end
    end
    
    newPopulation = [population; newPopulation];
    newPopulation = killPopulationDuplicates(newPopulation);
    
    disp(['Genetic optimization - ' num2str(iter) ' - bestCost: ' num2str(bestCost) ' - stuckGenes: ' num2str(numel(stuckIdx)) ' - sizePop: ' num2str(size(newPopulation, 1))]);
     
    if size(newPopulation, 1) < Params.sizePopulation
        population = newPopulation;
        populationAdder = createInitPopulation(Params.sizePopulation - size(population, 1), size(segments, 1), genValues, 'rand');
        population = [newPopulation; populationAdder];
    else
        population = newPopulation;
    end

      iter = iter + 1;
end

disp(['Genetic optimization finished!']);
%disp(bestGenom);

if Params.mergePopulation
    bestGenom = mergePopulation(fixedLayer, layers, population, segments, evalAdder, genValues);
end