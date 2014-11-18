[features, classes, additional, description] = readFeatureFile('features.txt');

GroupOptions.valid = [0 1 2 3];
GroupOptions.classBased = 1; 
[featuresGroup, classesGroup, additionalGroup] = selectGroup(features, classes, additional, GroupOptions);

 SelectionOptions.method = 'all';
%SelectionOptions.method = 'StrCmp';
% SelectionOptions.compareStrings = {'Retina', 'Mean'; 'RNFL', []};
% SelectionOptions.compareStrings = {'RNFL', []; 'Retina', []};
%SelectionOptions.compareStrings = {'RNFL', []};
featuresIdx = selectFeatures(featuresGroup, classesGroup, additionalGroup, description, SelectionOptions);

CrossValidationOptions.numFold = 10;
CrossValidationOptions.patientSensitive = 1;
CrossValidationOptions.classes = [0 3];
CrossValidationOptions.equalSizeClasses = 1;
CrossValidationOptions.ageColumn = 2;
CrossValidationOptions.patientIDColumn = 3;
crossValidationIdx = buildCrossValidation(featuresGroup, classesGroup, additionalGroup, CrossValidationOptions);

ClassifyOptions.classifier = 'Bayes';
ClassifyOptions.BayesSpec = 'diaglinear';
ClassifyOptions.BayesPrior = [0.5 0.5];

% ClassifyOptions.classifier = 'SVM';
% ClassifyOptions.svmKernel = 'linear';
% ClassifyOptions.svmKernelArgument = 1;
% ClassifyOptions.svmRegularizationConstant = 0.001;

ClassifyOptions.classes = [0 3];

Results = crossValidate(featuresGroup, classesGroup, additionalGroup, featuresIdx, crossValidationIdx, ClassifyOptions);

Results = evaluateClassification(Results);