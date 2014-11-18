function bscan = drawIdxOct(bscanOrig, positions, color, opacity, mode)
% DRAWIDXOCT Draws positions (marked as 1 in the positions vector)
%   on an OCT BSscan image  

if nargin < 5
    mode = '';
end

if size(bscanOrig, 3) == 1
    bscanOrig(:,:,2) = bscanOrig;
    bscanOrig(:,:,3) = bscanOrig(:,:,1);
end

idx = find(positions);

if strcmp(mode, 'max')
    bscanOrig(:,idx, 1) = max(color(1), bscanOrig(:,idx, 1));
    bscanOrig(:,idx, 2) = max(color(2), bscanOrig(:,idx, 2));
    bscanOrig(:,idx, 3) = max(color(3), bscanOrig(:,idx, 3));
else
    bscanOrig(:,idx, 1) = color(1) * opacity + (1 - opacity) * bscanOrig(:,idx, 1);
    bscanOrig(:,idx, 2) = color(2) * opacity + (1 - opacity) * bscanOrig(:,idx, 2);
    bscanOrig(:,idx, 3) = color(3) * opacity + (1 - opacity) * bscanOrig(:,idx, 3);
end
bscan = bscanOrig;