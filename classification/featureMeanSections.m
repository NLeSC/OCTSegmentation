function features = featureMeanSections(data, numSamples)
% Compute the mean of numSamples sections of a data vector. It is assumed
% that the input data are layer thicknesses from a circular OCT scan. 
% Therefore, the case that 4 mean values (e.g. mean in quadrants) should 
% be generated is treated specially: The data is shifted by 1/8, so that
% the retina quadrants align to the mean computation sections.

% Shift by 1/8 if samples are quadrants
if(numSamples == 4)
    dataLength = numel(data);
    data = [data((dataLength / 8):end) data(1:(dataLength / 8 - 1))];
end

stepSize = ceil(numel(data) / numSamples);

features = zeros(1, numSamples);

for i = 0:numSamples-2
    dataSection = data((i * stepSize) + 1:((i+1) * stepSize));
    features(i+1) = mean(dataSection);
end
dataSection = data(((numSamples - 1) * stepSize) + 1:end);
features(numSamples) = mean(dataSection);

end