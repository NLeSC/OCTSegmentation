function lineMerged = mergeLines(lineRough, lineEstimate, mode, option, img)
% MERGELINES: Merges a rough line and a better estimate
% mode: Hot to merge
% 'discardOutliers': option(1) - distance treshold
%                    option(3) - boundaries: how many linepoints left and
%                    right are just taken over from the rough estimate?
%                    options(2) - if there are outliers, how many
%                    linepoints left and right of the outliers are
%                    additionally taken over from the estimate?

switch mode
    case 'discardOutliers'
        
        diff = abs(lineEstimate - lineRough);
        
        lineMerged = lineRough;
        idx = diff > option(1);
        idx = idx | lineRough == 0;
        
        if option(3) ~= 0
            idx(1:option(3)) = 0;
            idx(end-option(3):end) = 0;
        end
        
        idx = bwmorph(idx, 'dilate', option(2));
        
        lineMerged(idx) = lineEstimate(idx);
        
        lineMerged(lineMerged < 1) = 1;
    case 'similarity'
        
        lineRoughCopy = round(lineRough);
        lineRoughCopy(lineRoughCopy < option(1) + 1) = option(1) + 1;
        lineRoughCopy(lineRoughCopy > size(img, 1) - option(1) + 1) = size(img, 1) - option(1) + 1;
        
        lineEstimateCopy = round(lineEstimate);
        lineEstimateCopy(lineEstimateCopy < option(1) + 1) = option(1) + 1;
        lineEstimateCopy(lineEstimateCopy > size(img, 1) - option(1) + 1) = size(img, 1) - option(1) + 1;
        
        neighborsRough = zeros(option(1) * 2 + 1, size(lineRoughCopy, 2), 'single');
        
        for i = 1:size(lineRoughCopy, 2)
            neighborsRough(:,i) = img(lineRoughCopy(i)-option(1):lineRoughCopy(i)+option(1), i);
        end
        
%         for i = 1:size(neighborsRough, 1)
%             neighborsRough(:,i) = neighborsRough(:,i) - mean(mean(neighborsRough));
%         end
        base = mean(neighborsRough, 2);
        
        dist = neighborsRough;
        for i = 1:size(neighborsRough, 2)
            dist(:,i) = neighborsRough(:,i) - base;
        end
        
        dist = sum(abs(dist), 1);
        [distSorted idx] = sort(dist, 'ascend');
        
        comparVal = mean(neighborsRough(:,idx(1:end)) , 2);
        
        neighborsEstimate = zeros(option(1) * 2 + 1, size(lineEstimateCopy, 2), 'single');
        
        for i = 1:size(lineEstimateCopy, 2)
            neighborsEstimate(:,i) = img(lineEstimateCopy(i)-option(1):lineEstimateCopy(i)+option(1), i);
        end
        
%         for i = 1:size(neighborsEstimate, 2)
%             neighborsEstimate(:,i) = neighborsEstimate(:,i) - mean(mean(neighborsEstimate));
%         end
        
        lineMerged = lineRough;
        for i = 1:size(lineRough)
            distRough = sum(abs(neighborsRough(:,i) - comparVal), 1);
            distEstimate = sum(abs(neighborsEstimate(:,i) - comparVal), 1);
            
            if distEstimate < distRough
                lineMerged(i) = lineEstimate(i);
            end
        end
        
    otherwise
        lineMerged = lineRough;
end