function [octPos sloPos] = convertPosition(pos, mode, DataDescriptor)
% CONVERTPOSITION converts positions in pixels between OCT and SLO images
% and performed boundary checks.
% [OCTPOS SLOPOS] = convertPosition(POS, MODE, HEADER, BSCANHEADER)
% OCTPOS, SLOPOS: The new positions, in pixel retues
% POS: Input position. may be floating point numbers, and may also be out
%   of range
% MODE: What tranformation should be made? Possibilities:
%   - 'OctToSloVol': An OCT volume position (xy) is converted to the SLO 
%       position (xy)
%   - 'SloToOctVol': An SLO position (xy) is converted to the (xy) position
%       on the OCT volume
%   - 'OctToSloCirc': Same thing for circ. 2D Scans.
%   - 'SloToOctCirc': Same thin for circ. 2D OCT scans. 
% DataDescriptor: Structure with OCT DataDescriptor.Header OCT headers according 
%                 to HE & OCTSEG specifications. Entries:
%                 - Header
%                 - DataDescriptor.BScanHeader

startX = DataDescriptor.BScanHeader.StartX;
startY = DataDescriptor.BScanHeader.StartY;
endX = DataDescriptor.BScanHeader.EndX;
endY = DataDescriptor.BScanHeader.EndY;

sloScale = [DataDescriptor.Header.ScaleXSlo DataDescriptor.Header.ScaleYSlo];
octSize = [DataDescriptor.Header.SizeX ...
           DataDescriptor.Header.NumBScans ...
           DataDescriptor.Header.SizeZ];
     
sloSize = [DataDescriptor.Header.SizeXSlo DataDescriptor.Header.SizeXSlo];

if strcmp(mode, 'SloToOctVol')
    distX = abs(startX(1) - endX(1));
    sloPos = round(borderCheckSlo(pos));
    
    if distX == 0
        octPos = [1 1];
        
        
        rwPos = pos .* [sloScale(2) sloScale(1)];
        octPos(1) = (rwPos(2) - min([startX(1) endX(1)])) ...
            / DataDescriptor.Header.ScaleX;
        octPos(2) = octSize(2) - (rwPos(1) - min([startY(1) startY(end)])) / DataDescriptor.Header.Distance;
        
    else
        [xReal yReal] = toRealWorldSlo(pos(2),pos(1), sloScale);
        [aScanNumber bScanNumber] = toOctFromRealWorld(xReal, yReal, octSize, startX, startY, endX, endY);
        octPos = ceil([aScanNumber bScanNumber]);
    end
    
    [octPos changed] = borderCheckOct([round(octPos) 1]);
    
    if changed
        [octPos sloPos] = convertPosition(octPos, 'OctToSloVol', DataDescriptor);
    end
elseif strcmp(mode, 'OctToSloVol')
    distX = abs(startX(1) - endX(1));
    octPos = round(borderCheckOct(pos));
    octPos = [octPos(1) octPos(2) octPos(3)];
    
    if distX == 0
        sloPos(2) = (min([startX(pos(2)) endX(pos(2))]) + pos(1) * DataDescriptor.Header.ScaleX) / sloScale(1);
        sloPos(1) = startY(pos(2)) / sloScale(2);
    else
        [xReal yReal] = toRealWorldOct(octPos(1), octSize, startX(pos(2)), startY(pos(2)), endX(pos(2)), endY(pos(2)));
        [xSlo ySlo] = toSloFromRealWorld(xReal,yReal, sloScale);
        sloPos = ceil([ySlo xSlo]);
    end
    
    sloPos = borderCheckSlo(round(sloPos));
elseif strcmp(mode, 'SloToOctCirc')
    BScanEndX = endX;
    BScanEndY = endY;
    circleCenter = [round(BScanEndY * (1/sloScale(2))); round(BScanEndX * (1/sloScale(1)))];
    sloPos = atan2((pos(2) - circleCenter(2)), (pos(1) - circleCenter(1)));
    if strncmp(DataDescriptor.Header.ScanPosition, 'OD', 2)  
        octPos = (- sloPos + pi * 3 /2 ) / (2 * pi) * octSize(1);
        if octPos >= octSize(1)
            octPos = octPos - octSize(1);
        end
    else     
        octPos = (sloPos + pi * 3 /2 ) / (2 * pi) * octSize(1);
        if octPos >= octSize(1)
            octPos = octPos - octSize(1);
        end
    end
    octPos = [round(octPos + 1) 1];
elseif strcmp(mode, 'OctToSloCirc')
    octPos = round(borderCheckOct(pos));
    octPos = [octPos(1) 1 octPos(3)];
    
    if strncmp(DataDescriptor.Header.ScanPosition, 'OD', 2)
        sloPos = - octPos * (2 * pi) / octSize(1) + pi * 3 /2;
    else
        sloPos = octPos * (2 * pi) / octSize(1) - pi * 3 /2;
    end
end

function [ret changed] = borderCheckSlo(val)
    ret = val;
    
    if ret(1) > sloSize(1) 
        ret(1) = sloSize;
    elseif ret(1) < 1;
        ret(1) = 1;
    end

    if ret(2) > sloSize(2)
        ret(2) = sloSize;
    elseif ret(2) < 1
        ret(2) = 1;
    end
end

function [ret changed] = borderCheckOct(val)
    ret = val;
    changed = 0;
    if ret(1) > octSize(1) 
        ret(1) = octSize(1);
        changed = 1;
    elseif ret(1) < 1
        ret(1) = 1;
        changed = 1;
    end

    if ret(2) > octSize(2) 
        ret(2) = octSize(2);
        changed = 1;
    elseif ret(2) < 1
        ret(2) = 1;
        changed = 1;
    end
    
    if numel(val) == 3
        if ret(3) > octSize(3) 
            ret(3) = octSize(3);
        elseif ret(1) < 1
            ret(1) = 1;
        end     
    end
end

end

function [xReal yReal] = toRealWorldSlo(xSlo,ySlo, sloScale)
    xReal = xSlo * sloScale(1);
    yReal = ySlo * sloScale(2);
end

function [xSlo ySlo] = toSloFromRealWorld(xReal,yReal, sloScale)
    xSlo = xReal / sloScale(1);
    ySlo = yReal / sloScale(2);
end

function [xReal yReal] = toRealWorldOct(aScanNumber, octSize, xStart, yStart, xEnd, yEnd)
    frac = aScanNumber / octSize(1);
    xReal = xStart + (xEnd - xStart) * frac;
    yReal = yStart + (yEnd - yStart) * frac;
end

% Assumptions made: Scanpattern is a rectangular, but may be rotated
function [aScanNumber bScanNumber] = toOctFromRealWorld(xReal, yReal, octSize, startX, startY, endX, endY) 
    lu = [startX(end) startY(end)]; % left upper point
    ru = [endX(end) endY(end)]; % ...
    ll = [startX(1) startY(1)];
    rl = [endX(1) endY(1)];
    
    posOct = [(xReal - ll(1)) (yReal - ll(2))];    
    xVecOct = lu - ll;
    yVecOct = rl - ll;
    
    if (xVecOct)
        fracX = (posOct * xVecOct') / (xVecOct * xVecOct');
    else
        fracX = 1;
    end
    if  (yVecOct)    
        fracY = (posOct * yVecOct') / (yVecOct * yVecOct');
    else
        fracY = 1;
    end
    
    aScanNumber = fracY * octSize(1);
    bScanNumber = fracX * octSize(2);
end

