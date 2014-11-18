function sumSeg = getSegmentSums(segments, img)

sumSeg = zeros(size(segments, 1), 1);
for i = 1:size(segments, 1)
    sumSeg(i) = sum(img(segments(i,1), segments(i,2):segments(i,3)));
end

end
