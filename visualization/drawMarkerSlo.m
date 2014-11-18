function slo = drawMarkerSlo(sloOrig, pos, varargin)
% DRAWMARKERSLO Draws a marker on an SLO image  

circleMarker = 0;
ColorLine = [0 0 1];
header = [];
BScanHeader = [];

linethickness = 1; % thickness added left and right to the lines.
linelength = 10; % length of the single lines

if (~isempty(varargin) && iscell(varargin{1}))
    varargin = varargin{1};
end
for k = 1:2:length(varargin)
    if (strcmp(varargin{k}, 'Circle'))
        circleMarker = 1;
    elseif (strcmp(varargin{k}, 'Colorline'))
        ColorLine = varargin{k+1};
    elseif (strcmp(varargin{k}, 'Header'))
        header = varargin{k+1};
    elseif (strcmp(varargin{k}, 'BScanHeader'))
        BScanHeader = varargin{k+1};
    end
end


if circleMarker % Marker on the circular scan pattern.
    % Needs header information.
    
slo = sloOrig;    

sloscale = [header.ScaleXSlo header.ScaleYSlo];

BScanStartX = BScanHeader.StartX;
BScanStartY = BScanHeader.StartY;
BScanEndX = BScanHeader.EndX;
BScanEndY = BScanHeader.EndY;

circleCenter = [round(BScanEndY * (1/sloscale(2))); round(BScanEndX * (1/sloscale(1)))];
circleStart = [round(BScanStartY * (1/sloscale(2))); round(BScanStartX * (1/sloscale(1)))];
circleVec = circleCenter - circleStart;
circleRadius = sqrt(circleVec(1) * circleVec(1) + circleVec(2) * circleVec(2));

for cC1 = circleCenter(1) - linethickness:circleCenter(1) + linethickness
    for cC2 = circleCenter(2) - linethickness:circleCenter(2) + linethickness
        cC = [cC1; cC2];
        for cR = circleRadius - linelength:0.6:circleRadius + linelength
            angle = pos(1);
            slo(cC(1) + round(cos(angle) * cR), cC(2) + round(sin(angle) * cR), 1) = ColorLine(1);
            slo(cC(1) + round(cos(angle) * cR), cC(2) + round(sin(angle) * cR), 2) = ColorLine(2);
            slo(cC(1) + round(cos(angle) * cR), cC(2) + round(sin(angle) * cR), 3) = ColorLine(3);     
        end
    end
end

else
    
% Draw Cross on SLO Image. To prevent border conflicts, the image is
% enlarged before and shrinked after drawing.

adder = linethickness + linelength + 1;
sloR = sloOrig(:,:,1);
sloG = sloOrig(:,:,2);
sloB = sloOrig(:,:,3);
sloR = [zeros(size(sloR,1), adder, 'single')  sloR  zeros(size(sloR,1), adder, 'single')];
sloR = [zeros(adder, size(sloR,2), 'single'); sloR; zeros(adder, size(sloR,2), 'single')];
sloG = [zeros(size(sloG,1), adder, 'single')  sloG  zeros(size(sloG,1), adder, 'single')];
sloG = [zeros(adder, size(sloG,2), 'single'); sloG; zeros(adder, size(sloG,2), 'single')];
sloB = [zeros(size(sloB,1), adder, 'single')  sloB  zeros(size(sloB,1), adder, 'single')];
sloB = [zeros(adder, size(sloB,2), 'single'); sloB; zeros(adder, size(sloB,2), 'single')];
slo(:,:,1) = sloR;
slo(:,:,2) = sloG;
slo(:,:,3) = sloB;
pos = pos + adder;

for cC1 = pos(1) - linethickness:pos(1) + linethickness
    for cC2 = pos(2) - linethickness:pos(2) + linethickness
        cC = [cC1; cC2];
        for cR = 0:linelength;
            for angle = pi/4:pi/2:2*pi
                slo(cC(1) + round(cos(angle) * cR), cC(2) + round(sin(angle) * cR), 1) = ColorLine(1);
                slo(cC(1) + round(cos(angle) * cR), cC(2) + round(sin(angle) * cR), 2) = ColorLine(2);
                slo(cC(1) + round(cos(angle) * cR), cC(2) + round(sin(angle) * cR), 3) = ColorLine(3);
            end
        end
    end
end

slo = slo(adder+1:end-adder, adder+1:end-adder, :);

end