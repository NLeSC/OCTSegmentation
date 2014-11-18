function [enfaceReg position enfaceRegFull] = registerEnfaceView(enfaceView, DataDescriptor, mode)

if nargin < 3
    mode = 'nearest';
end

scale = [DataDescriptor.Header.ScaleX ...
         DataDescriptor.Header.ScaleZ ...
         DataDescriptor.Header.Distance];
sloscale = [DataDescriptor.Header.ScaleXSlo ...
            DataDescriptor.Header.ScaleYSlo];
octsize = [DataDescriptor.Header.SizeX ...
           DataDescriptor.Header.SizeZ ...
           DataDescriptor.Header.NumBScans];
sloSize = [DataDescriptor.Header.SizeXSlo ...
           DataDescriptor.Header.SizeYSlo];

BScanStartY = DataDescriptor.BScanHeader.StartY;
BScanStartX = DataDescriptor.BScanHeader.StartX;
BScanEndY = DataDescriptor.BScanHeader.EndY;
BScanEndX = DataDescriptor.BScanHeader.EndX;

% A rectangular scanpattern is assumed!

lu = [BScanStartX(end) BScanStartY(end)]; % Left Upper Point. 
ll = [BScanStartX(1) BScanStartY(1)]; % Left Lower Point
ru = [BScanEndX(end) BScanEndY(end)]; %...
rl = [BScanEndX(1) BScanEndY(1)];


startPoint = [BScanStartX(end) BScanStartY(end)];

distX = ll(1) - lu(1);
    
 if distX == 0 
    [Xref2, Zref2] = meshgrid(startPoint(1):scale(1):(scale(1)*octsize(1) - scale(1) + startPoint(1)), ...
        startPoint(2):scale(3):(scale(3)*octsize(3) - scale(3) + startPoint(2)));
    
    [Xn2, Zn2] = meshgrid(0:sloscale(1):(sloSize(2) - 1) * sloscale(1), 0:sloscale(2):(sloSize(1) - 1) * sloscale(2));
    
    enfaceRegFull = interp2(Xref2, Zref2, enfaceView, Xn2, Zn2, mode, 0);
     
    position = [round(startPoint(2)/sloscale(2))+1 round((octsize(3) - 1) * scale(3) / sloscale(2) + startPoint(2) / sloscale(2))+1 ...
        round(startPoint(1)/sloscale(1))+1 round((octsize(1) - 1) * scale(1) / sloscale(1) + startPoint(1) / sloscale(1))+1];
    
    if position(2) > size(enfaceRegFull,1)
        position(2) = size(enfaceRegFull,1);
    end
    
    if position(4) > size(enfaceRegFull,2)
        position(4) = size(enfaceRegFull,2);
    end

    enfaceReg = enfaceRegFull(position(1):position(2), position(3):position(4));
 else
     
    [Xref2, Zref2] = meshgrid(0:scale(1):(scale(1)*octsize(1) - scale(1)), ...
    0:scale(3):(scale(3)*octsize(3) - scale(3)));

    [Xn2, Zn2] = meshgrid(0:sloscale(1):(scale(1)*octsize(1) - scale(1)), 0:sloscale(2):(scale(3)*octsize(3) - scale(3)));

    enfaceRegFull = interp2(Xref2, Zref2, enfaceView, Xn2, Zn2, mode, 0);
      
    vec1 = ru - lu;
    vec2 = lu - ll;
    angle = atan2(vec1(1) , vec1(2)) - pi / 2;
    
    adderValX = ceil(vec1(2) / sloscale(1));
    adderValY = ceil(vec2(1) / sloscale(2));
    
    adderY = zeros(size(enfaceRegFull, 1), abs(adderValY));
    enfaceRegFull = [adderY enfaceRegFull adderY];

    adderX = zeros(abs(adderValX), size(enfaceRegFull, 2));
    enfaceRegFull = [adderX; enfaceRegFull; adderX];
    
    enfaceRegFull = imrotate(enfaceRegFull, angle * 180 / pi, 'crop');
    enfaceRegFull = enfaceRegFull(ceil(abs(adderValX)/2)  + 1:end -  ceil(abs(adderValX)/2) , ceil(abs(adderValY)/2)  + 1:end - ceil(abs(adderValY)/2)); 
    
    drawY = floor(min([ru(2) lu(2)]) / sloscale(2));
    if drawY > 0
        adderY = zeros(drawY-1, size(enfaceRegFull, 2));
        enfaceRegFull = [adderY; enfaceRegFull];
    else
        enfaceRegFull = enfaceRegFull(-drawY:end, :);
    end
    
    drawX = floor(min([lu(1) ll(1)]) / sloscale(1));
    if drawX > 0
        adderX = zeros(size(enfaceRegFull, 1), drawX-1);
        enfaceRegFull = [adderX enfaceRegFull];
    else
        enfaceRegFull = enfaceRegFull(:, -drawX:end);
    end
    
    enfaceRegFullTemp = zeros(sloSize);
    enfaceRegFullTemp(1:size(enfaceRegFull,1), 1:size(enfaceRegFull,2)) = enfaceRegFull;
    enfaceRegFull = enfaceRegFullTemp;
    
    position = [round(startPoint(2)/sloscale(2)) + min(adderValX, 0) ...
                 round((octsize(3) - 1) * scale(3) / sloscale(2) + startPoint(2) / sloscale(2)) + min(adderValX, 0) + abs(adderValX) ...
                 round(startPoint(1)/sloscale(1)) - max(adderValY, 0) ...
                 round((octsize(1) - 1) * scale(1) / sloscale(1) + startPoint(1) / sloscale(1)) - max(adderValY, 0) + abs(adderValY)];
      
    position = checkPosition(position, size(enfaceRegFull));
    position = checkPosition(position, sloSize);

    enfaceReg = enfaceRegFull(position(1):position(2), position(3):position(4));
 end
end
 
    function position = checkPosition(position, sizeImg)
        
        if position(1) < 1
            position(1) = 1;
        end
        
        if position(2) > sizeImg(1)
            position(2) = sizeImg(1);
        end
        
        if position(3) < 1
            position(3) = 1;
        end
        
        if position(4) > sizeImg(2)
            position(4) = sizeImg(2);
        end
        
    end