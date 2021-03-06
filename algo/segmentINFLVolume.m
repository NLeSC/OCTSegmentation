function [inflAuto inflChoice] = segmentINFLVolume(volume, params, onh, rpe, medline)
% SEGMENTRPEAUTO Segments the RPE from a BScan. Intended for the use on
% circular OCT-Bscans
% RPEAUTO = segmentRPEAuto(BSCAN)
% RPEAUTO: Automated segmentation of the RPE
% BSCAN: Unnormed BScan image 
% PARAMS:   Parameter struct for the automated segmentation
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

mask = params.INFLLIN_VOLUME_MASK;
mask = mask ./ sum(mask);
avgMask = zeros(1,1,numel(mask));
for i = 1:numel(mask)
    avgMask(1,1,i) = mask(i);
end
volume = imfilter(volume, avgMask, 'symmetric') ;

inflAuto = zeros(size(volume, 3), size(volume, 2));
inflChoice = zeros(size(volume, 3), size(volume, 2), 3);

for i = 1:size(volume, 3)
    [inflLin inflLinChoice]= segmentINFLLin(volume(:,:,i), params, rpe(i,:), medline(i,:));
    
    %inflLin(onh(i,:) == 1) = inflLinChoice(2, onh(i,:) == 1);
    inflAuto(i,:) = inflLin;
 
    for n = 1:size(inflLinChoice, 1)
        inflChoice(i,:, n) = inflLinChoice(n, :);
    end
    
    disp(['INFL of BScan ' num2str(i) ' segmented automatically in 2D.']);
end


%inflAuto = medfilt2(inflAuto, params.INFL_VOLUME_MEDFILT, 'symmetric');

end