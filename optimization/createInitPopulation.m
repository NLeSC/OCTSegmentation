function population = createInitPopulation(sizePop, length, values, mode, option)
% CREATEINITPOPULATION
% Implements various ways to create a initial population for a genetic
% algorithm, as well as the possibility to create all possible combinations
% (for a brute force method)

if strcmp(mode, 'rand')
    population = zeros(sizePop, length);
    for i = 1:sizePop
        population(i,:) = getRandomGenom(length, values);
    end
elseif strcmp(mode, 'fillRand')
    population = zeros(sizePop, length);
    for i = 1:numel(values)
        population(i,:) = zeros(1, length) + values(i);
    end
    for i = (numel(values)+1):sizePop
        population(i,:) = getRandomGenom(length, values);
    end
elseif strcmp(mode, 'fillRandMinor')
    population = zeros(sizePop, length);
    for i = 1:sizePop
        population(i,:) = zeros(1, length) + values(mod(i, numel(values)) + 1);
    end
    numMut = round(option(1) * length);
    for i = (numel(values)+1):sizePop
       population(i, :) = mutateGenom(population(i, :), numMut, values);
    end    
elseif strcmp(mode, 'all')
    population = zeros(numel(values), 1);
    population(:,1) = values';
    for i = 1:length-1
        newPopulation = zeros(numel(values), size(population, 2) + 1);
        for v = 1:numel(values)
            newPopulation(v, :) = [population(1,:) values(v)];
        end      
        
        for p = 2:size(population, 1)
            newPopulationAdder = zeros(numel(values), size(population, 2) + 1);
            for v = 1:numel(values)
                newPopulationAdder(v, :) = [population(p,:) values(v)];
            end
            newPopulation = [newPopulation; newPopulationAdder];
        end
        
        population = newPopulation;
    end
end
end