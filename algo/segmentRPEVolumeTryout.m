function [rpeAuto rpeSimple] = segmentRPEVolumeTryout(volume, DataDescriptors, Params, medline)
% SEGMENTRPEAUTO Segments the RPE from a BScan.
% RPEAUTO = segmentRPEAuto(BSCAN)
% RPEAUTO: Automated segmentation of the RPE
% BSCAN: Unnormed BScan image 
% Params:   Parameter struct for the automated segmentation
% The algorithm (of which this function is a part) is described in 
% Markus A. Mayer, Joachim Hornegger, Christian Y. Mardin, Ralf P. Tornow:
% Retinal Nerve Fiber Layer Segmentation on FD-OCT Scans of Normal Subjects
% and Glaucoma Patients, Biomedical Optics Express, Vol. 1, Iss. 5, 
% 1358-1383 (2010). Note that modifications have been made to the
% algorithm since the paper publication.
%
% Writen by Markus Mayer, Pattern Recognition Lab, University of
% Erlangen-Nuremberg
%
% First final Version: November 2010

volume(volume > 1) = 0;
volume = sqrt(volume);

mask = Params.RPELIN_VOLUME_MASK;
mask = mask ./ sum(mask);
avgMask = zeros(1,1,numel(mask), 'double');
for i = 1:numel(mask)
    avgMask(1,1,i) = mask(i);
end
volume = imfilter(volume, avgMask, 'symmetric') ;

rpeChoice = zeros(size(volume, 3), size(volume, 2), 4, 'double');
rpeSimple = zeros(size(volume, 3), size(volume, 2), 'double');

for i = 1:size(volume, 3)
    snBScan = splitnormalize(volume(:,:,i), Params, 'ipsimple opsimple soft', medline(i,:));
    snBScan = removebias(snBScan, Params);
    
    % 2) A simple noise removal
    snBScan = medfilt2(snBScan, Params.RPELIN_SEGMENT_MEDFILT);
    
    % 3) Edge detection along A-Scans (taking the sign of the derivative into
    % account)
    rpeEdge = findRetinaExtrema(snBScan, Params, 2, 'min pos', ...
        [round(medline) + Params.RPELIN_MEDLINE_MINDISTBELOW; ...
        zeros(1, size(snBScan,2), 'double') + size(snBScan,1)]);
    
    rpeChoice(i,:,1) = rpeEdge(1,:);
    rpeChoice(i,:,2) = rpeEdge(2,:);
    
    rpeEdge = findRetinaExtrema(snBScan, Params, 1, 'min pos', ...
        [round(medline(i,:)) + Params.RPELIN_MEDLINE_MINDISTBELOW; ...
        zeros(1, size(snBScan,2), 'double') + size(snBScan,1)]);
    
    rpeChoice(i,:,3) = rpeEdge;
    rpeSimple(i,:) = rpeEdge;
    
    rpeRansac = ransacEstimate(rpeEdge, 'poly', ...
        Params.RPELIN_RANSAC_NORM_RPE, ...
        Params.RPELIN_RANSAC_MAXITER, ...
        Params.RPELIN_RANSAC_POLYNUMBER);
    
    
    rpeChoice(i,:,4) = rpeRansac;
    disp(['RPE of BScan ' num2str(i) ' segmented automatically in 2D.']);
end

diff = abs(rpeChoice(:,:,3) - rpeChoice(:,:,4));
fixedIdx = diff < 2;

structureElement = strel('line', 5, 0);
fixedIdx = imerode(fixedIdx, structureElement);

data{1} = fixedIdx;
data{2} = rpeChoice(:,:,3);

OptParams.maxIter = 200;
OptParams.sizePopulation = 300;
OptParams.numCouples = 100;
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
OptParams.smallGroupSize = 10;
OptParams.splitSegmentsDiff = 3;
OptParams.genValues = [3 4];

res = mergeLayers(rpeChoice, data, OptParams, 'discOptGroup', [DataDescriptors.Header.Distance DataDescriptors.Header.ScaleX]);

rpeAuto = res;

end