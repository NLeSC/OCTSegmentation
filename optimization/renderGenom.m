function img = renderGenom(fixedLayer, layers, genom, segments)
% RENDERGENOM
% Creates position image out of genom and the related segments

img = fixedLayer;
for i = 1:size(genom, 2)
    img(segments(i,1), segments(i,2):segments(i,3)) = layers(segments(i,1), segments(i,2):segments(i,3), genom(i));
end
end