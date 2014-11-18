function colorimg = grayToColor(img, mode, varargin)

colors = [1 0 0; 0 1 0; 1 0 0];
cutoff = [50 120 150];

if (~isempty(varargin) && iscell(varargin{1}))
    varargin = varargin{1};
end
for k = 1:2:length(varargin)
    if (strcmp(varargin{k}, 'colors'))
        colors = varargin{k+1};
    elseif (strcmp(varargin{k}, 'cutoff'))
        cutoff = varargin{k+1};
    end
end

if strcmp(mode, 'twocolors')
    color1 = colors(1,:);
    color2 = colors(2,:);
    
    %cutOffMax = max(max(img));
    %cutOffMin = min(min(img));
    
    cutOffMax = cutoff(2);
    cutOffMin = cutoff(1);
    
    img(img > cutOffMax) = cutOffMax;
    img(img < cutOffMin) = cutOffMin;
    
    dist = abs(cutOffMax - cutOffMin);
    
    colorimg = zeros(size(img,1), size(img,2), 3, 'single');
    
    weightColor2 = (img - cutOffMin) / dist;
    weightColor1 = 1 - weightColor2;
    
    colorimg(:,:,1) = weightColor1 * color1(1) + weightColor2 * color2(1);
    colorimg(:,:,2) = weightColor1 * color1(2) + weightColor2 * color2(2);
    colorimg(:,:,3) = weightColor1 * color1(3) + weightColor2 * color2(3);
elseif strcmp(mode, 'threecolors')
    color1 = colors(1,:);
    color2 = colors(2,:);
    color3 =  colors(3,:);
    
    cutOffMax = cutoff(3);
    cutOffMiddle = cutoff(2);
    cutOffMin = cutoff(1);
    
    img(img > cutOffMax) = cutOffMax;
    img(img < cutOffMin) = cutOffMin;
    
    distLow = abs(cutOffMiddle - cutOffMin);
    distHigh = abs(cutOffMax - cutOffMiddle);
    
    colorimg = zeros(size(img,1), size(img,2), 3, 'single');
    
    for i = 1:size(img,1)
        for j = 1:size(img,2)
            if img(i,j) <= cutOffMiddle
                weight1 = (img(i,j) - cutOffMin) / distLow;
                weight2 = 1 - weight1;
                colorimg(i,j,1) = weight1 * color2(1) + weight2 * color1(1);
                colorimg(i,j,2) = weight1 * color2(2) + weight2 * color1(2);
                colorimg(i,j,3) = weight1 * color2(3) + weight2 * color1(3);
            else
                weight1 = (img(i,j) - cutOffMiddle) / distHigh;
                weight2 = 1 - weight1;
                colorimg(i,j,1) = weight1 * color3(1) + weight2 * color2(1);
                colorimg(i,j,2) = weight1 * color3(2) + weight2 * color2(2);
                colorimg(i,j,3) = weight1 * color3(3) + weight2 * color2(3);
            end
        end
    end
    
end


end