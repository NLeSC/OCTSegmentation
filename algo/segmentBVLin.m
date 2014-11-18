function bv = segmentBVLin(bscan, params, onh, rpe)
% SEGMENTBVLIN Segments the blood vesses from a BScan
% BV = segmentRPEAuto(BSCAN, PARAMS, RPE)
% BSCAN: Unnormed BScan image (all parameters in the algorithm are
%   currently adapted to HE VOL data)
% PARAMS:   Parameter struct for the automated segmentation
% RPE: Segmentation of the RPE
%
% Writen by Markus Mayer, Pattern Recognition Lab, University of
% Erlangen-Nuremberg
%
% First final Version: June 2010

bscan(bscan > 1) = 0; 
bscan = sqrt(bscan);

idx = findbloodvessels(bscan, params, rpe);
bv = zeros(1, size(bscan,2), 'uint8');

bv(idx) = 1;

end