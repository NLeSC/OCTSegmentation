function [onflAuto additional] = segmentONFLVolume(volume, Params, onh, rpe, icl, ipl, infl, bv)
% SEGMENTRPEAUTO Segments the RPE from a BScan. Intended for the use on
% circular OCT-Bscans
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

bvAll = zeros(size(volume, 3), size(volume, 2), 'uint8');
bvEn = zeros(size(volume, 3), size(volume, 2), 'uint8');

for i = 1:size(volume, 3)
    bvAll(i,:) = extendBloodVessels(bv, Params.ONFLLIN_EXTENDBLOODVESSELS_ADDWIDTH_ALL, ...
                                        Params.ONFLLIN_EXTENDBLOODVESSELS_MULTWIDTHTHRESH_ALL, ...
                                        Params.ONFLLIN_EXTENDBLOODVESSELS_MULTWIDTH_ALL);
    
    bvEn(i,:) = extendBloodVessels(bv, Params.ONFLLIN_EXTENDBLOODVESSELS_ADDWIDTH_EN, ...
                                       Params.ONFLLIN_EXTENDBLOODVESSELS_MULTWIDTHTHRESH_EN, ...
                                       Params.ONFLLIN_EXTENDBLOODVESSELS_MULTWIDTH_EN);                                   
end

mask = Params.ONFLLIN_VOLUME_MASK;
mask = mask ./ sum(mask);
avgMask = zeros(1,1,numel(mask), 'double');
for i = 1:numel(mask)
    avgMask(1,1,i) = mask(i);
end
volume = imfilter(volume, avgMask, 'symmetric') ;

onflAuto = zeros(size(volume, 3), size(volume, 2), 'double');
additional = zeros(size(volume, 3), size(volume, 2), 'double');

for i = 1:size(volume, 3)
    
    [onflLin additionalLin] = segmentONFLLin(volume(:,:,i), Params, onh(i, :), [bvAll(i,:); bvEn(i,:)], rpe(i,:), icl(i,:), ipl(i,:), infl(i,:));
    
    onflAuto(i,:) = onflLin;
    additional(i,:) = additionalLin;
    
    disp(['ONFL of BScan ' num2str(i) ' segmented automatically in 2D.']);
end


onflAuto = medfilt2(onflAuto, Params.ONFLLIN_VOLUME_MEDFILT, 'symmetric');

end