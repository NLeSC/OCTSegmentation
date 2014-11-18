function features = featureStandard(data)
%[MI MA AVG MED] = FEATURESTANDARD(DATA)
% Computes the min, max, average and median value from a data vector

minVal = min(data);
maxVal = max(data);
meanVal = mean(data);
medianVal = median(data);

features = [minVal maxVal meanVal medianVal];