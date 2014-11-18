function saveClassificationResultMat(path, Result, FeatureSelection, CrossValidationOptions, additional, description)
% Stores the classification result into a .mat file for future evaluation

save (path, 'Result', 'FeatureSelection', 'CrossValidationOptions', 'additional', 'description');