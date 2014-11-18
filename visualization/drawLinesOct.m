function colorimg = drawLinesOct(img, lines, varargin)
% DRAWLINESOCT Draws a OCTSEG line on an oct image. Differences in
% Z-direction are interpolated. 
% COLORIMAGE = drawLinesOct(IMG, LINES, VARARGIN)
% COLORIMAGE: Image with a line drawn onto, in RGB format.
% IMG: Oct image, either RGB or grayvalues
% LINES: Multiple lines in OCTSEG line format
% VARARGIN: Multiple options (format: ...,'option', value,...)
%   Possibilities are:
%   blowup: the image is rescaled by a factor of 2
%   LineColors: N x 3 Matrix with RGB colors for the lines
%   double: The line is 2 pixels in height
%   lineExtend: The line will be 1 + 2 * lineExtend pixels in height.
%   nointerp: No interpolation

blowUpOn = 0;
doubleOn = 0;
lineExtend = 0;
lineColors = [1 0 0; 0 1 0; 0 0 1; 1 1 0; 1 0 1; 0 1 1; 1 0.5 0.5; 0.5 1 0.5; 0.5 0.5 1;...
    0 0.5 1; 0 1 0.5; 1 0 0.5; 0.5 0 1; 0.5 1 0; 1 0.5 0];
interp = 1;

if (~isempty(varargin) && iscell(varargin{1}))
    varargin = varargin{1};
end
for k = 1:2:length(varargin)
    if (strcmp(varargin{k}, 'blowup'))
        blowUpOn = 1;
    elseif (strcmp(varargin{k}, 'nointerp'))
        interp = 0;
    elseif (strcmp(varargin{k}, 'LineColors'))
        lineColors = varargin{k+1};
    elseif (strcmp(varargin{k}, 'double'))
        doubleOn = 1;
    elseif (strcmp(varargin{k}, 'lineExtend'))
        lineExtend = varargin{k+1};
    end
end

if blowUpOn
    img = imresize(img, 2);
    linestemp = zeros(size(lines,1), size(lines,2)*2, 'single');
    linestemp(:,1:2:end-1) = lines;   
    linestemp = linesweeter(linestemp, [0 0 0 0 1 0 0],... 
         [5 0 0 3 0 5 1; 0 0 0 0 0 0 0; 0 0 0 0 0 0 0]);

    idx = lines > 1;
   
    linestemp(:,1:2:end-1) = linestemp(:,1:2:end-1) .* idx;   
    linestemp(:,2:2:end-2) = linestemp(:,2:2:end-2) .* idx(:,1:end-1);
    linestemp(:,1:2:end-3) = linestemp(:,1:2:end-3) .* idx(:,2:end);
    linestemp(:,2:2:end) = linestemp(:,2:2:end) .* idx;

    lines = linestemp .* 2;
end

if size(img, 3) ~= 3
    colorimg(:,:,1) = img;
    colorimg(:,:,2) = img;
    colorimg(:,:,3) = img;
else
    colorimg = img;
end

nc = size(lineColors, 1);
m = 0;
for i = 1:size(lines,1)
    for j = 1:(size(lines,2)-1)
        if lines(i,j) >= 1 && lines(i,j + 1)
            X = [j j+1];
            
            startZ = ceil(lines(i,j));
            endZ = ceil(lines(i,j+1));
            Y = [startZ endZ];
            Zdiff = abs(endZ - startZ);
            if Zdiff ~= 0 && interp
                Zdiff = abs(endZ - startZ);
                newX = [j:1/(2*Zdiff):j+1];
                part = interp1(X,Y,newX);
            else
                newX = X;
                part = Y;
            end
            if doubleOn
                part = part + 0.1;
                part(part < 1) = 1;
                part(part > size(colorimg, 1)) = size(colorimg, 1);
            end
            for k = 1:numel(newX)                               
                if lineExtend ~= 0
                    for z = -lineExtend:1:lineExtend
                        colorimg(round(part(k)) + z,round(newX(k)), 1) = lineColors(mod(m,nc) + 1, 1);
                        colorimg(round(part(k)) + z,round(newX(k)), 2) = lineColors(mod(m,nc) + 1, 2);
                        colorimg(round(part(k)) + z,round(newX(k)), 3) = lineColors(mod(m,nc) + 1, 3);
                    end
                else               
                    colorimg(ceil(part(k)),round(newX(k)), 1) = lineColors(mod(m,nc) + 1, 1);
                    colorimg(ceil(part(k)),round(newX(k)), 2) = lineColors(mod(m,nc) + 1, 2);
                    colorimg(ceil(part(k)),round(newX(k)), 3) = lineColors(mod(m,nc) + 1, 3);
                    
                    if doubleOn
                        colorimg(floor(part(k)),round(newX(k)), 1) = lineColors(mod(m,nc) + 1, 1);
                        colorimg(floor(part(k)),round(newX(k)), 2) = lineColors(mod(m,nc) + 1, 2);
                        colorimg(floor(part(k)),round(newX(k)), 3) = lineColors(mod(m,nc) + 1, 3);
                    end
                end
            end
        end
        
    end
    m = m + 1;
end

