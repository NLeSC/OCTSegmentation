function line = energySmooth(img, params, start, bvIdx, hardborder)
% LINE = energySmooth(IMG, PARAMS, BVIDX, HARDBORDER)
% Algorithm: The energy is computed for each point of the line
% A random number of points are chosen. If The energy is lower, the point
% is moved up/down. Energy minimization.
% IMG: OCT image
% START: Initialisation of the line
% PARAMS:  Parameter struct for the automated segmentation
%   In this function, the following parameters are currently used:
%   ENERGYSMOOTH_GRADIENTWEIGHT: Weight of gradient computed from IMG with 
%       central difference (in z-Direction)
%   ENERGYSMOOTH_NEIGHBORWEIGHT: Weight of distance to neighbouring pixel, squared
%       for left/right neighbour.
%   ENERGYSMOOTH_REGIONWEIGHT: Weight of distance to constant line in
%       between blood vessels
%   ENERGYSMOOTH_MAXITER: Maximum number of iterations
% BVIDX: BVIDX for Theta. Assumes BV of size 1.
% HARDBORDER: Max. upper border. If two lines are given: Upper & Lower
% Border
%
% Writen by Markus Mayer, Pattern Recognition Lab, University of
% Erlangen-Nuremberg
%
% First final Version: November 2010

line = start;
lineOld = start;

PRESICION = 'single'; % Hard coded PRESICION value.
% You may want to change it to 'double'.

for k = 1:params.ENERGYSMOOTH_MAXITER
    line(line < 3) = 3;
    line(line > size(img,1) - 2) = size(img ,1) - 2;
    
    gradientU = zeros(1, size(line, 2), PRESICION);
    gradient = zeros(1, size(line, 2), PRESICION);
    gradientL = zeros(1, size(line, 2), PRESICION);
    for i = 1:size(line, 2)
        gradientU(i) = img(line(i) - 2, i) - img(line(i), i);
        gradient(i) = img(line(i) - 1, i) - img(line(i) + 1, i);
        gradientL(i) = img(line(i), i) - img(line(i) + 2, i);
    end
    
    region = zeros(1, size(line, 2), PRESICION);
    regionU = zeros(1, size(line, 2), PRESICION);
    regionL = zeros(1, size(line, 2), PRESICION);
    
    if(params.ENERGYSMOOTH_REGIONWEIGHT ~= 0)
        msum = zeros(1, size(line, 2), PRESICION);
        if numel(bvIdx) > 0
            msum(1:bvIdx(1)) = mean(line( 1:bvIdx(1)));
        else
            bvIdx = 1;           
        end
        bx = 1;
        bi = 1;
        while bx < numel(bvIdx) - 1
            z = bx;
            while (bvIdx(z)+1 == bvIdx(z+1)) && z < numel(bvIdx) - 1
                z = z + 1;
            end
            
            tl = line(bi:bvIdx(bx));
            tls = sort(tl);
            msum(bi:bvIdx(bx)) = mean(tls(ceil(end/4):ceil(end/4*3)));
            
            tl = line(bvIdx(bx):bvIdx(z));
            tls = sort(tl);
            msum(bvIdx(bx):bvIdx(z)) = mean(tls(ceil(end/4):ceil(end/4*3)));
            
            bi = bvIdx(z);
            bx = z + 1;
        end
        tl = line(bvIdx(end):end);
        tls = sort(tl);
        msum(bvIdx(end):end) = mean(tls(ceil(end/4):ceil(end/4*3)));
        
        region = abs(line - msum);
        regionU = abs(line - msum - 1);
        regionL = abs(line - msum + 1);
    end
    
    neighbor = zeros(1, size(line,2), PRESICION);
    neighborU = zeros(1, size(line, 2), PRESICION);
    neighborL = zeros(1, size(line, 2), PRESICION);
    
    neighborU(2:end-1) = abs(line( 1:end-2) - (line( 2:end-1) - 1)) .^ 1 + ...
                        abs((line( 2:end-1) - 1) - line( 3:end)) .^ 1  ;
    neighbor(2:end-1) = abs(line( 1:end-2) - line( 2:end-1)) .^ 1 + ...
                        abs(line( 2:end-1) - line( 3:end))  .^ 1 ;
    neighborL(2:end-1) = abs(line( 1:end-2) - (line( 2:end-1) + 1)) .^ 1 + ...
                        abs((line( 2:end-1) + 1) - line( 3:end))  .^ 1 ;
    
    energy = gradient .* params.ENERGYSMOOTH_GRADIENTWEIGHT + ...
                neighbor * params.ENERGYSMOOTH_NEIGHBORWEIGHT + ...
                region .* params.ENERGYSMOOTH_REGIONWEIGHT;
    energyU = gradientU .* params.ENERGYSMOOTH_GRADIENTWEIGHT + ...
                neighborU * params.ENERGYSMOOTH_NEIGHBORWEIGHT + ...
                regionU .* params.ENERGYSMOOTH_REGIONWEIGHT;
    energyL = gradientL .* params.ENERGYSMOOTH_GRADIENTWEIGHT + ...
                neighborL * params.ENERGYSMOOTH_NEIGHBORWEIGHT + ...
                regionL .* params.ENERGYSMOOTH_REGIONWEIGHT;
    
    distU = energyU - energy;
    distL = energyL - energy;
    
    moveUp = distU < 0;
 %   choice = rand(1,numel(moveUp));
 %   tt = find(choice > 0.5);
    
    
    moveDown = distL < 0;
    
    moveUpDown = moveUp & moveDown;
    distUL = energyU - energyL;
    line(distUL > 0 & moveUpDown) = line(distUL > 0 & moveUpDown) + 1;
    line(distUL < 0 & moveUpDown) = line(distUL < 0 & moveUpDown) - 1;
    
   % choice = rand(1,numel(moveDown));
   % tt = find(choice > 0.5);
    line( moveDown & ~moveUpDown) = line( moveDown & ~moveUpDown) + 1;
    line( moveUp & ~moveUpDown) = line( moveUp & ~moveUpDown) - 1;
    
    if numel(hardborder) ~= 0
        line(line < hardborder(1,:)) =  hardborder(line < hardborder(1,:));      
    end
    if size(hardborder, 1) == 2
        line(line > hardborder(2,:)) =  hardborder(line > hardborder(2,:));  
    end
    
    res = abs(lineOld - line);
    if sum(res) == 0
        break;
    end
    lineOld = line;
end
