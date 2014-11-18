function res = mergeLayers(layers, data, OptParams, mode, dist, gradients)
% MERGELAYERS: Mergers Layers segmentations
% mode: disOptGroup

if strcmp(mode, 'discOptGroup')
    evalAdder = [2 2];
    genValues = OptParams.genValues;
    OptParams.evalAdder = [2 2];
    
    fixedIdx = data{1};
    fixedLayer = data{2};
    
    segments = getSegments(fixedIdx);
    groups = groupSegments(segments);
    
    groupSize = zeros(1, numel(groups));
    for g = 1:numel(groups)
        %groups{g} = splitSegments(groups{g}, 'length', [OptParams.maxSegmentLength OptParams.maxSegmentLength]);
        groups{g} = splitSegments(groups{g}, 'gradient', [OptParams.maxSegmentLength OptParams.splitSegmentsDiff], layers(:,:,genValues));
        groupSize(g) = size(groups{g}, 1);
    end
    
    [groupSize idx] = sort(groupSize, 'ascend');
    newGroups = cell(1, numel(groups));
    for i = 1:numel(idx)
        newGroups{i} = groups{idx(i)};
    end
    groups = newGroups;
    
    allSegments = zeros(0, size(segments, 2));
    bestGenom = zeros(1, 0);
    
    disp(['There are ' num2str(numel(groups)) ' groups with up to ' num2str(size(groups{end}, 1)) ' entries.']);
    
    for g = 1:numel(groups)
        if groupSize(g) <= OptParams.smallGroupSize
            disp(['Optimizing group ' num2str(g) ' of ' num2str(numel(groups)) ' with brute force (size: ' num2str(size(groups{g}, 1)) ')!']);
            segments = groups{g};  
            partGenom = bruteForce(fixedLayer, layers, segments, genValues, evalAdder, 'span L2', dist);
            bestGenom = [bestGenom partGenom];
            allSegments = [allSegments; segments];   
        else
            disp(['Optimizing group ' num2str(g) ' of ' num2str(numel(groups)) ' with genetic optimization! (size: ' num2str(size(groups{g}, 1)) ')!']);
            segments = groups{g};
            
            OptParams.sizePopulation =  size(groups{g}, 1) * OptParams.sizePopulationFactor;
            if OptParams.sizePopulation > OptParams.maxSizePopulation
                OptParams.sizePopulation = OptParams.maxSizePopulation;
            end
            
            OptParams.maxIter =  size(groups{g}, 1) * OptParams.iterFactor;
            if OptParams.maxIter > OptParams.maxMaxIter
                OptParams.maxIter = OptParams.maxMaxIter;
            end
            
            OptParams.numCouples  =  size(groups{g}, 1) * OptParams.numCouplesFactor;
            if OptParams.numCouples  > OptParams.maxNumCouples
                OptParams.numCouples  = OptParams.maxNumCouples;
            end
            
            partGenom = geneticOptimization(fixedLayer, layers, segments, genValues, OptParams, 'span L2', dist);
            
            bestGenom = [bestGenom partGenom];
            allSegments = [allSegments; segments];
        end
    end
    
    res = renderGenom(fixedLayer, layers, bestGenom , allSegments);
elseif strcmp(mode, 'discOptGroupGradient')
    evalAdder = [2 2];
    genValues = OptParams.genValues;
    OptParams.evalAdder = [2 2];
    
    fixedIdx = data{1};
    fixedLayer = data{2};
    
    segments = getSegments(fixedIdx);
    groups = groupSegments(segments);
    
    groupSize = zeros(1, numel(groups));
    for g = 1:numel(groups)
        %groups{g} = splitSegments(groups{g}, 'length', [OptParams.maxSegmentLength OptParams.maxSegmentLength]);
        groups{g} = splitSegments(groups{g}, 'gradient', [OptParams.maxSegmentLength OptParams.splitSegmentsDiff], layers(:,:,genValues));
        groupSize(g) = size(groups{g}, 1);
    end
    
    [groupSize idx] = sort(groupSize, 'ascend');
    newGroups = cell(1, numel(groups));
    for i = 1:numel(idx)
        newGroups{i} = groups{idx(i)};
    end
    groups = newGroups;
    
    allSegments = zeros(0, size(segments, 2));
    bestGenom = zeros(1, 0);
    
    disp(['There are ' num2str(numel(groups)) ' groups with up to ' num2str(size(groups{end}, 1)) ' entries.']);
    
    for g = 1:numel(groups)
        if groupSize(g) <= OptParams.smallGroupSize
            disp(['Optimizing group ' num2str(g) ' of ' num2str(numel(groups)) ' with brute force (size: ' num2str(size(groups{g}, 1)) ')!']);
            segments = groups{g};  
            
            sumSeg = zeros(size(segments, 1), size(gradients, 3));
            for n = 1:size(gradients, 3)
            sumSeg(:,n) = getSegmentSums(segments, gradients(:,:,n));
            end
            
            partGenom = bruteForce(fixedLayer, layers, segments, genValues, evalAdder, 'Grad', dist, sumSeg, -100);
            bestGenom = [bestGenom partGenom];
            allSegments = [allSegments; segments];   
        else
            disp(['Optimizing group ' num2str(g) ' of ' num2str(numel(groups)) ' with genetic optimization! (size: ' num2str(size(groups{g}, 1)) ')!']);
            segments = groups{g};
            
            sumSeg = zeros(size(segments, 1), size(gradients, 3));
            for n = 1:size(gradients, 3)
            sumSeg(:,n) = getSegmentSums(segments, gradients(:,:,n));
            end
            
            OptParams.sizePopulation =  size(groups{g}, 1) * OptParams.sizePopulationFactor;
            if OptParams.sizePopulation > OptParams.maxSizePopulation
                OptParams.sizePopulation = OptParams.maxSizePopulation;
            end
            
            OptParams.maxIter =  size(groups{g}, 1) * OptParams.iterFactor;
            if OptParams.maxIter > OptParams.maxMaxIter
                OptParams.maxIter = OptParams.maxMaxIter;
            end
            
            OptParams.numCouples  =  size(groups{g}, 1) * OptParams.numCouplesFactor;
            if OptParams.numCouples  > OptParams.maxNumCouples
                OptParams.numCouples  = OptParams.maxNumCouples;
            end
            
            partGenom = geneticOptimization(fixedLayer, layers, segments, genValues, OptParams, 'Grad', dist, sumSeg, -100);
            disp(partGenom);
            bestGenom = [bestGenom partGenom];
            allSegments = [allSegments; segments];
        end
    end
    
    res = renderGenom(fixedLayer, layers, bestGenom , allSegments);
end

end
