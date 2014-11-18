function Results = createResultsStruct(ClassifyOptions, CrossValidation)
% Create a basic classification result struct, that is filled with 
% cells of the appropriate size

Results.ClassifyOptions = ClassifyOptions;
Results.classes = ClassifyOptions.classes;

if nargin < 2
    Results.classGoldStandard = cell(1, 1);
    Results.classResult = cell(1, 1);
    Results.testIdx = cell(1, 1);
    Results.numFolds = 1;
else
    Results.classGoldStandard = cell(size(CrossValidation.idx, 1), 1);
    Results.classResult = cell(size(CrossValidation.idx, 1), 1);
    Results.testIdx = cell(size(CrossValidation.idx, 1), 1);
    Results.numFolds = size(CrossValidation.idx, 1);
end