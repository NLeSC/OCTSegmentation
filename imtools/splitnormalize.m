function [noctimg medline] = splitnormalize(octimg, params, mode, medline)
% SPLITNORMALIZE An OCT BScan is normaized differently in the inner and
% outer part
% [RESOCTIMAGE MEDLINE] = splitnormalize(OCTIMAGE, MODE, CUTOFF)
% Partnorm: Norms the inner and outer part of an circular B-Scan different.
% OCTIMAGE: The input BScan (not intensity change applied yet) - raw data
% PARAMS:  Parameter struct for the automated segmentation
%   In this function, the following parameters are currently used:
%   SPLITNORMALIZE_CUTOFF: For the modes it is appropriate, this value 
%   defines how much high reflectivity is cut off. If set high, less highly
%   reflective A-Scans are affected by cut off. The threshold is calculated
%   as follows: 
%   mean of each A-Scan * CUTOFF - mean of all A-Scans. 
%   (Note by Markus Mayer: Pretty weird, but it works.)
%   SPLITNORMALIZE_LINESWEETER: Additional linesweeter smoothing parameters for 
%   the used medline
% MODE: How is the normailzation performed?
% Possibilities are:
%   - ipbscan/opbscan: the max of the IP/OP in the whole bscan is taken
%   - ipsimple/opsimple: (default) [0:1] scaling in IP/OP separately per
%       AScan
%   - ipnonlin/opnonlin: sqrt is taken additionally to the scaling
%   - ipnearmax: The max. value is computed out of values only
%       near max, but not the highest values ( to skip outliers)
%   - soft: The min/max values of each A-Scan are median filtered with
%       their neighbors
% Examples: 'ipsimple opnonlin soft'
% NOCTIMG: Result of the normalization
% MEDLINE: Medline from the used medline function
%
% Note: The mode aequivalence to older versions of this function is:
% simple: 'ipsimple opsimple soft'
% nonlin: 'ipnonlin opsimple soft'
% downhalf: 'ipnearmax opsimple soft'
% 
% Writen by Markus Mayer, Pattern Recognition Lab, University of
% Erlangen-Nuremberg
%
% First final Version: June 2010

PRECISION = 'double';

if nargin < 3
    mode = 'ipsimple opsimple soft';
end

cutoff = params.SPLITNORMALIZE_CUTOFF;

if nargin < 4
    medline = findmedline(octimg, params);
    medline = medfilt1(medline, 5);
    medline = linesweeter(medline, params.SPLITNORMALIZE_LINESWEETER);
    medline = floor(medline);
    medline(medline < 1) = 1;
end

noctimg = octimg;

maxIP = zeros(1, size(octimg,2), PRECISION);
minIP = zeros(1, size(octimg,2), PRECISION);
maxOP = zeros(1, size(octimg,2), PRECISION);
minOP = zeros(1, size(octimg,2), PRECISION);

if numel(strfind(mode, 'ipnearmax')) == 0
    meanVal = zeros(1, size(octimg,2), PRECISION);
else
    meanVal = zeros(1, size(octimg,2), PRECISION);
    for i= 1:size(octimg, 2)
        sorter = sort(octimg(1:medline(i),i));
        meanVal(i) = mean(sorter);
    end
    meanVal = meanVal * cutoff - mean(meanVal); % 2.0
    meanVal(meanVal < 0) = 0;
end

for i= 1:size(octimg, 2)
    minIP(i) = min(min(octimg(1:medline(i),i)));
    maxIP(i) = max(max(octimg(1:medline(i),i)));
    maxOP(i) = max(max(octimg(medline(i):end,i)));
    minOP(i) = min(min(octimg(medline(i):end,i)));
end

if numel(strfind(mode, 'ipnonlin')) ~= 0
    maxIP = maxIP - meanVal + minIP;
end

if numel(strfind(mode, 'soft')) ~= 0   
    maxIP = medfilt1(maxIP, 5);
    maxOP = medfilt1(maxOP, 5);
    minIP = medfilt1(minIP, 5);
    minOP = medfilt1(minOP, 5);
end

ipDiff = maxIP - minIP;

if numel(strfind(mode, 'ipbscan')) ~= 0
    minIP = zeros(1,numel(minIP), PRECISION) + min(minIP);
    maxIP = zeros(1,numel(maxIP), PRECISION) + max(minIP);
    ipDiff = maxIP - minIP;
    for i= 1:size(octimg, 2)
        if ipDiff(i) ~= 0
            noctimg(1:medline(i),i) = ((octimg(1:medline(i),i) - minIP(i)) ./ ipDiff(i));
        end
    end
elseif numel(strfind(mode, 'ipnonlin')) ~= 0
    for i= 1:size(octimg, 2)
        if ipDiff(i) ~= 0
            noctimg(1:medline(i),i) = ((octimg(1:medline(i),i) - minIP(i)) ./ ipDiff(i)) .^ 2;
        end
    end
elseif numel(strfind(mode, 'ipnearmax')) ~= 0
    minIP = zeros(1,numel(minIP), PRECISION) + min(minIP);
    maxIPS = sort(maxIP);
    maxIP = zeros(1,numel(minIP), PRECISION) + mean(maxIPS(end-ceil(numel(maxIP)/5):end-ceil(numel(maxIP)/10)));
    ipDiff = maxIP - minIP;
    for i= 1:size(octimg, 2)
        if ipDiff(i) ~= 0
            noctimg(1:medline(i),i) = (octimg(1:medline(i),i) - minIP(i)) ./ ipDiff(i);
        end
    end
else
    for i= 1:size(octimg, 2)
        if ipDiff(i) ~= 0
            noctimg(1:medline(i),i) = ((octimg(1:medline(i),i) - minIP(i)) ./ ipDiff(i));
        end
    end
end

opDiff = maxOP - minOP;

if numel(strfind(mode, 'opbscan')) ~= 0
    minOP = zeros(1,numel(minOP), PRECISION) + min(minOP);
    maxOP = zeros(1,numel(maxOP), PRECISION) + max(minOP);
    opDiff = maxOP - minOP;
    for i= 1:size(octimg, 2)
        if opDiff(i) ~= 0
            noctimg(medline(i):end,i) = (octimg(medline(i):end,i) - minOP(i)) ./ opDiff(i);
        end
    end
elseif numel(strfind(mode, 'opnonlin')) ~= 0
    for i= 1:size(octimg, 2)
        if opDiff(i) ~= 0
            noctimg(medline(i):end,i) = (octimg(medline(i):end,i) - minOP(i)) ./ opDiff(i) .^ 2;
        end
    end
else
    for i= 1:size(octimg, 2)
        if opDiff(i) ~= 0
            noctimg(medline(i):end,i) = (octimg(medline(i):end,i) - minOP(i)) ./ opDiff(i);
        end
    end
end

noctimg(noctimg > 1) = 1;
noctimg(noctimg < 0) = 0;