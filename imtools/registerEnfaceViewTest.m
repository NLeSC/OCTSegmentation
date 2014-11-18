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
    
    [Xref2, Zref2] = meshgrid(startPoint(1):scale(1):(scale(1)*octsize(1) - scale(1) + startPoint(1)), ...
        startPoint(2):scale(3):(scale(3)*octsize(3) - scale(3) + startPoint(2)));
    
    [Xn2, Zn2] = meshgrid(0:sloscale(1):(sloSize(2) - 1) * sloscale(1), 0:sloscale(2):(sloSize(1) - 1) * sloscale(2));
    
    
    enfaceRegFull = interp2(Xref2, Zref2, enfaceView, Xn2, Zn2, mode, 0);
    
    distX = ll(1) - lu(1);
    
 if distX == 0
    
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
      position = [round(startPoint(2)/sloscale(2))+1 round((octsize(3) - 1) * scale(3) / sloscale(2) + startPoint(2) / sloscale(2))+1 ...
        round(startPoint(1)/sloscale(1))+1 round((octsize(1) - 1) * scale(1) / sloscale(1) + startPoint(1) / sloscale(1))+1];
     
    vec = ru - ll;
    angle = acos(vec(2) / vec(1));
    enfaceRegFull = imrotate(enfaceRegFull, -angle);
    
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