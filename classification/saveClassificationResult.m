function saveClassificationResult(path, Result, FeatureSelection, CrossValidationOptions, additional, description)
% Calls all possible storing methods and passes the data along.

saveClassificationResultMat([path '.mat'], Result, FeatureSelection, CrossValidationOptions, additional, description)

saveClassificationResultText([path '.txt'], Result, FeatureSelection, CrossValidationOptions, additional, description)

saveClassificationResultTex(path, Result, FeatureSelection, CrossValidationOptions, additional, description)