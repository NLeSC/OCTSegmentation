function bvRes = extendBloodVessels(bv, addWidth, multWidthTresh, multWidth)

lineWidth = size(bv, 2);

if nargin < 3
    multWidth = 0;
end

% Extend the BV by a constant factor to the left or right
for k = 1:addWidth
    for j = 1:size(bv,2)-1
        if bv(j+1) ~= 0
            bv(j) = 1;
        end
    end
    for j = size(bv,2):-1:2
        if bv(j-1) ~= 0
            bv(j) = 1;
        end
    end
end

% Extend the BV by a multiplicative factor
if multWidth ~= 0
    bvNew = zeros(1, lineWidth, 'uint8');
    j = 1;
    while j <= lineWidth
        if bv(j) == 1
            a = j;
            while a <= lineWidth && bv(a) == 1 
                a = a + 1;
            end
            a = a - 1;
            length = a - j + 1;
            if length > multWidthTresh
                start = floor(j - multWidth * length);
                if start < 1
                    start = 1;
                end
                last = ceil(a + multWidth * length);
                if last > lineWidth
                    last = lineWidth;
                end
                vec = start:1:last;
                bvNew(vec) = 1;
            end          
            j = a;
        end
        j = j + 1;
    end
    bv = bvNew;
end

bvRes = bv;