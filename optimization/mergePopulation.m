function bestGenom = mergePopulation(fixedLayer, layers, population, segments, adder, values)
% MERGEPOPULATION
% Merges a population such, that always the locally best genom is prefered.

bestGenom = population(size(population, 1), :);
populationAdder = zeros(numel(values), size(population, 2));
for i = 1:numel(values)
    populationAdder(i,:) = zeros(1, size(population, 2)) + values(i);
end

population = [populationAdder; population];
genMutVec = zeros(10,1) + 1;
for i = size(population, 1)-1:-1:1
    bestGenomX = birth(fixedLayer, layers, [bestGenom; population(i, :)], segments, size(population, 2), 'compare L2', adder);
    
    genMut = sum(abs(bestGenomX - bestGenom));
    genMutVec(mod(i, 10) + 1) = genMut;
   
    if sum(genMutVec) == 0
        return;
    end
    disp(['mergePopulation (' num2str(i) ') GenMut: ' num2str(genMut)]);
    bestGenom = bestGenomX;
end

end