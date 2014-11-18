function groups = groupSegments(segments)
% GROUPSEGMENTS
% Groups segments such that the groups have no neighborhood relationship
% with each other

g = 1;
current = 1;
groups{1} = segments(1,:);
segments = segments(2:end,:);
while size(segments, 1) ~= 0
    i = 1;
    while i < size(segments, 1);
        if segments(i,1) >= groups{g}(current, 1) - 1 && segments(i,1) <= groups{g}(current, 1) + 1
            if (segments(i,2) >= groups{g}(current, 2) - 1 && segments(i,2) <= groups{g}(current, 3) + 1) || ...
                    (segments(i,3) >= groups{g}(current, 2) - 1 && segments(i,2) <= groups{g}(current, 3) + 1)
                groups{g}(end + 1, :) = segments(i, :);
                segments = segments([1:i-1 i+1:end], :);
            else
                i = i + 1;
            end
        else
            i = i + 1;
        end
    end
    if size(groups{g}, 1) > current
        current = current + 1;
    else
        g = g + 1;
        current = 1;
        groups{g} = segments(1,:);
        segments = segments(2:end,:);
    end
end
end