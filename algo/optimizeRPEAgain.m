function [rpeAuto newMedline] = optimizeRPEAgain(DataDescriptors, rpeChoice, onh, bv, medline)

onh = onh == 1;

sizeFactor = DataDescriptors.Header.Distance / DataDescriptors.Header.ScaleX;
structureElement = strel('arbitrary', generateElipse(20, sizeFactor));
onh = imerode(onh, structureElement);

bv = bv == 2; %% No function. Change to "== 1" when we have a good 3D BV segmentation
structureElement = strel('line', 2, 0);
bv = imerode(bv, structureElement);

diff = abs(rpeChoice(:,:,1) - rpeChoice(:,:,2));
fixedIdx = diff < 2;
structureElement = strel('line', 5, 0);
fixedIdx = imerode(fixedIdx, structureElement);

fixedIdx(onh) = 1;
fixedIdx(bv) = 1;

for i = 1:size(rpeChoice,1)
    rpeChoice(i,:,2) = ransacEstimate(rpeChoice(i,:,1), 'poly', ...
        1, ...
        100, ...
        5,...
        onh(i,:));
end

data{1} = fixedIdx;
data{2} = rpeChoice(:,:,1);

% gradientChoice = zeros(size(rpeChoice));
% 
% bScans(bScans > 1) = 0;
% bScans = sqrt(sqrt(bScans));
% 
% for n = 1:size(rpeChoice, 3)
%     for i = 1:size(rpeChoice,1)
%         gauss2D = fspecial('gaussian', 5, 1.5);
%         bScans(:,:,i) = imfilter(bScans(:,:,i), gauss2D, 'symmetric');
%         centralDiff = zeros(1, size(bScans, 2));
%         for k = 1:size(bScans, 2)
%             if rpeChoice(i,k,n) > 1 && rpeChoice(i,k,n) < size(bScans, 1)
%                 centralDiff(k) = bScans(round(rpeChoice(i,k,n)) + 1, k, i) - bScans(round(rpeChoice(i,k,n)) - 1, k, i);
%                 centralDiff(k) = centralDiff(k) * bScans(round(rpeChoice(i,k,n)), k, i);
%             else
%                 centralDiff(k) = 1000;
%             end
%         end
%         gradientChoice(i,:,n) = centralDiff;
%     end
% end

OptParams.maxIter = 200;
OptParams.maxMaxIter = 200;
OptParams.iterFactor = 2;
OptParams.sizePopulation = 300;
OptParams.maxSizePopulation = 200;
OptParams.sizePopulationFactor = 3;
OptParams.numCouples = 100;
OptParams.maxNumCouples = 100;
OptParams.numCouplesFactor = 2;
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

%res = mergeLayers(rpeChoice, data, OptParams, 'discOptGroupGradient', [DataDescriptors.Header.Distance DataDescriptors.Header.ScaleX], gradientChoice);
rpeAuto = mergeLayers(rpeChoice, data, OptParams, 'discOptGroup', [DataDescriptors.Header.Distance DataDescriptors.Header.ScaleX]);

rpeSmooth = rpeChoice(:,:,1);
rpeSmooth = medfilt2(rpeSmooth, [5 7]);
rpeSmooth = medfilt2(rpeSmooth, [5 7]);
gauss2D = fspecial('gaussian', 5, 2);
rpeSmooth = imfilter(rpeSmooth, gauss2D, 'symmetric');
rpeSmooth = imfilter(rpeSmooth, gauss2D, 'symmetric');
rpeSmooth = rpeSmooth + 20;
rpeAuto(onh) = rpeSmooth(onh);
rpeAuto = medfilt2(rpeAuto, [5 7]);
rpeAuto = imfilter(rpeAuto, gauss2D, 'symmetric');

boundaries = cell(1, 2);
boundaries{1} = medline;
boundaries{2} = rpeAuto;
boundaries = corrBoundaryOrder(boundaries);
rpeAuto = boundaries{2};
newMedline = boundaries{1};


end

function idx = generateElipse(width, factor)
height = width / factor;
idx = zeros(round(height), width);
factor = size(idx, 2) / size(idx, 1);
center = size(idx) / 2;
for i = 1:size(idx, 1)
    for j = 1:size(idx, 2)
        dist = sqrt((center(1) - i +0.5) * (center(1) - i +0.5)  * factor * factor + (center(2) - j +0.5) * (center(2) - j +0.5));
        if dist < (width+2) / 2
            idx(i,j) = 1;
        end
    end
end
end