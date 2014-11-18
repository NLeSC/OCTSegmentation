function dataNormalized = thicknessAgeNormalize(dataAll, age, classes, classNormal, sections, normAge)


valid = (classes == classNormal) & ((age > 20) & (age < 80));
numLayers = size(dataAll{1}, 1);

ageNormal = age(valid);
dataAllNormal = dataAll(valid);

dataResampled = cell(numel(ageNormal),1);

% Resample layers to number of sample points defined by "sections"
for i = 1:numel(ageNormal)
    layersResampled = zeros(size(dataAllNormal{i}, 1), sections);
    
    for k = 1:numLayers
        layersResampled(k, :) = featureMeanSections(dataAllNormal{i}(k,:), sections);
    end
    
    dataResampled{i} = layersResampled;
end

% Reorder the data, so that for each layer we have the corresponding normal
% values
layerColl = cell(numLayers, 1);
for k = 1:numLayers
    layerColl{k} = zeros(numel(ageNormal), sections);
    for i = 1:numel(ageNormal)
        layerColl{k}(i,:) = dataResampled{i}(k,:);
    end
end

% Fit a polynomial of degree 1 through the normal values
pVal = cell(numLayers, sections);
for k = 1:numLayers
    for s = 1:sections
        [x idx] = sort(ageNormal', 'ascend');
        y = layerColl{k}(idx,s);
        p = polyfit(x, y, 1);
        pVal{k,s} = p;
    end
end

% Normalize data
dataNormalized = cell(size(dataAll));
stepSize = ceil(size(dataAll{1}, 2) / sections);
for i = 1:numel(age)
    dataNormalized{i} = zeros(size(dataAll{i}));
    for k = 1:numLayers
        for s = 0:sections-2
            dataSection = dataAll{i}(k, (s * stepSize) + 1:((s+1) * stepSize));
            bias = (age(i) - normAge) * pVal{k,s + 1}(1);
            normAgeVal = polyval(pVal{k, s + 1}, normAge);
            correctionFactor = (normAgeVal + bias) / normAgeVal;
            % dataNormalized{i}((s * stepSize) + 1:((s+1) * stepSize)) = dataSection - bias;
            dataNormalized{i}(k, (s * stepSize) + 1:((s+1) * stepSize)) = dataSection * correctionFactor;
        end
        dataSection = dataAll{i}(k, ((sections - 1) * stepSize) + 1:end);
        bias = (age(i) - normAge) * pVal{k,sections}(1);
        normAgeVal = polyval(pVal{k, sections}, normAge);
        correctionFactor = (normAgeVal + bias) / normAgeVal;
        dataNormalized{i}(k, ((sections - 1) * stepSize) + 1:end) = dataSection * correctionFactor;
        % dataNormalized{i}(((sections - 1) * stepSize) + 1:end) = dataSection - bias;
    end 
end

end
