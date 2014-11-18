function octCircle = createONHCircle(DataDescriptor, onhCenter, radius)

if nargin < 3
    radius = 1;
end

sloScale = [DataDescriptor.Header.ScaleXSlo DataDescriptor.Header.ScaleYSlo];

[octPos sloPos] = convertPosition([onhCenter(2) onhCenter(1) 1], 'OctToSloVol', DataDescriptor);
circleCenter = sloPos;

slo = zeros(DataDescriptor.Header.SizeXSlo, DataDescriptor.Header.SizeYSlo, 'uint8');

circleRadius = radius / sloScale(1); % in mm

cR = circleRadius;

for angle = pi/2+pi:-0.002:pi/2-pi
    y = circleCenter(1) + round(cos(angle) * cR);
    x = circleCenter(2) + round(sin(angle) * cR);
    
    if y < 1
        y = 1;
    elseif y > size(slo,1) 
        y = size(slo,1);
    end
    
    if x < 1
        x = 1;
    elseif x > size(slo,2)
        x = size(slo,2);
    end
    
    slo(y, x, 1) = 1;
end

octCircle = zeros(DataDescriptor.Header.NumBScans, DataDescriptor.Header.SizeX, 'uint8');

for i = 1:size(slo,1)
    idx = find(slo(i,:) == 1);
    if numel(idx) ~= 0        
        octPosStart = convertPosition([i, idx(1)], 'SloToOctVol', DataDescriptor);
        octPosEnd = convertPosition([i, idx(end)], 'SloToOctVol', DataDescriptor);
        octCircle(octPosStart(2), octPosStart(1):octPosEnd(1)) = 1;
    end
end

end
