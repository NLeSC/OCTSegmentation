function [rpeAuto newMedline] = optimizeRPE(DataDescriptors, rpeChoice, medline)

diff = abs(rpeChoice(:,:,1) - rpeChoice(:,:,2));
fixedIdx = diff < 2;

structureElement = strel('line', 5, 0);
fixedIdx = imerode(fixedIdx, structureElement);

data{1} = fixedIdx;
data{2} = rpeChoice(:,:,1);

OptParams.maxIter = 200;
OptParams.maxMaxIter = 200;
OptParams.iterFactor = 2;
OptParams.sizePopulation = 300;
OptParams.maxSizePopulation = 300;
OptParams.sizePopulationFactor = 1;
OptParams.numCouples = 100;
OptParams.maxNumCouples = 100;
OptParams.numCouplesFactor = 1;
OptParams.numChildren = 2;
OptParams.evalAdder = [2 2];
OptParams.numGenBirth = 1;
OptParams.numGenMutate = 0.4;
OptParams.chanceMutate = 0.2;
OptParams.mutationDrop = 0;
OptParams.mutationStop = 0.95;
OptParams.mergePopulation = 0;
OptParams.maxSegmentLength = 5;
OptParams.genValues = [3 4];
OptParams.smallGroupSize = 8;
OptParams.splitSegmentsDiff = 3;
OptParams.genValues = [1 2];

rpeAuto = mergeLayers(rpeChoice, data, OptParams, 'discOptGroup', [DataDescriptors.Header.Distance DataDescriptors.Header.ScaleX]);

boundaries = cell(1, 2);
boundaries{1} = medline;
boundaries{2} = rpeAuto;
boundaries = corrBoundaryOrder(boundaries);
rpeAuto = boundaries{2};
newMedline = boundaries{1};

end