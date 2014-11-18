disp('-----------------------------------------------------------------');
disp('-----------------------------------------------------------------');
[features, classes, additional, description] = readFeatureFile('~/diss/features/features_man_focus_age.txt');

stream = RandStream.getGlobalStream;
reset(stream);

% SELECT ALL GROUPS
GroupOptions.valid = [0 2 3];
GroupOptions.classBased = 1; 
[featuresGroup, classesGroup, additionalGroup] = selectGroup(features, classes, additional, GroupOptions);

% BUILD CROSSVALIDATION

CrossValidationOptions.numFold = 10;
CrossValidationOptions.patientSensitive = 1;
CrossValidationOptions.classes = {0 3};
CrossValidationOptions.classMapping = [0 3];
CrossValidationOptions.equalSizeClasses = 0;
CrossValidationOptions.ageColumn = 2;
CrossValidationOptions.patientIDColumn = 3;
CrossValidation = buildCrossValidation(featuresGroup, classesGroup, additionalGroup, CrossValidationOptions);

% FEATURE SELECTION (Layer)
% SelectionOptions.method = 'all';
% FeatureSelectionAll = selectFeatures(featuresGroup, CrossValidation.classesMapped, additionalGroup, description, SelectionOptions);
 
SelectionOptions.method = 'StrCmp';
SelectionOptions.compareStrings = {'RetinaStdMean', []};
FeatureSelectionRetinaStdMean = selectFeatures(featuresGroup, CrossValidation.classesMapped, additionalGroup, description, SelectionOptions);

%SelectionOptions.compareStrings = {'RNFL', 'Std'};
%FeatureSelectionRNFLStd = selectFeatures(featuresGroup, CrossValidation.classesMapped, additionalGroup, description, SelectionOptions);

% SelectionOptions.compareStrings = {'IPL', 'Std'};
% FeatureSelectionIPL = selectFeatures(featuresGroup, CrossValidation.classesMapped, additionalGroup, description, SelectionOptions);
% 
% SelectionOptions.compareStrings = {'OPL', 'Std'};
% FeatureSelectionOPL = selectFeatures(featuresGroup, CrossValidation.classesMapped, additionalGroup, description, SelectionOptions);
% 
% SelectionOptions.compareStrings = {'ONL', 'Std'};
% FeatureSelectionONL = selectFeatures(featuresGroup, CrossValidation.classesMapped, additionalGroup, description, SelectionOptions);
% 
% SelectionOptions.compareStrings = {'RPE', 'Std'};
% FeatureSelectionRPE = selectFeatures(featuresGroup, CrossValidation.classesMapped, additionalGroup, description, SelectionOptions);
% 
% SelectionOptions.compareStrings = {'BV', 'Std'};
% FeatureSelectionBV = selectFeatures(featuresGroup, CrossValidation.classesMapped, additionalGroup, description, SelectionOptions);

% FEATURE SELECTION (Method)
% SelectionOptions.compareStrings = {'RNFL', []};
% FeatureSelectionRNFLAll = selectFeatures(featuresGroup, CrossValidation.classesMapped, additionalGroup, description, SelectionOptions);
% 
% SelectionOptions.compareStrings = {'RNFL', 'Section'};
% FeatureSelectionRNFLSection = selectFeatures(featuresGroup, CrossValidation.classesMapped, additionalGroup, description, SelectionOptions);
% 
% SelectionOptions.compareStrings = {'RNFL', 'PCAAll'};
% FeatureSelectionRNFLPCAAll = selectFeatures(featuresGroup, CrossValidation.classesMapped, additionalGroup, description, SelectionOptions);
% 
% SelectionOptions.compareStrings = {'RNFL', 'PCANormal'};
% FeatureSelectionRNFLPCANormal = selectFeatures(featuresGroup, CrossValidation.classesMapped, additionalGroup, description, SelectionOptions);

% Better Feature Selection
SelectionOptions.ClassifyOptions.classifier = 'Bayes';
SelectionOptions.ClassifyOptions.BayesSpec = 'diaglinear';
SelectionOptions.ClassifyOptions.BayesPrior = [0.5 0.5];
SelectionOptions.ClassifyOptions.classes = [0 3];
SelectionOptions.disp = 0;

% SelectionOptions.ClassifyOptions.classifier = 'SVM';
% SelectionOptions.ClassifyOptions.svmKernel = 'linear';
% SelectionOptions.ClassifyOptions.svmKernelArgument = 1;
% SelectionOptions.ClassifyOptions.tolerance = 0.01;
% SelectionOptions.ClassifyOptions.maxIter = 1000;
% % ClassifyOptions.svmRegularizationConstant = 1000;
% %ClassifyOptions.svmRegularizationConstant = [10 1 0.1 0.01]; % Best:0.1
% % ClassifyOptions.svmRegularizationConstant = 0.1;
% SelectionOptions.ClassifyOptions.classes = [0 3];
% SelectionOptions.ClassifyOptions.svmRegularizationConstant = [1];
% SelectionOptions.ClassifyOptions.optimizationDepth = 1;
% SelectionOptions.ClassifyOptions.svmMulticlass = 'oaa';
% SelectionOptions.corrRejectFirst = 0.7;

SelectionOptions.crossValidationIdx = CrossValidation.idx;
SelectionOptions.numFeat = 30;

SelectionOptions.method = 'alternate';

disp('Select the best Features:');
FeatureSelectionBest = selectFeatures(featuresGroup, CrossValidation.classesMapped, additionalGroup, description, SelectionOptions);
% FeatureSelectionBest =
% [49,85,77,58,87,108,148,76,259,39,59,129,37,74,105,44,71,86,94,98,123,124
% ,162,222,232,278]; % 0-3 Diff

% SelectionOptions.compareStrings = {'Retina', 'Mean'; 'RNFL', []};
% SelectionOptions.compareStrings = {'RNFL', []; 'Retina', []};
%SelectionOptions.compareStrings = {'RNFL', []};

% SPECIFY CLASSIFIER

% ClassifyOptions.classifier = 'Bayes';
% ClassifyOptions.BayesSpec = 'diaglinear';
% ClassifyOptions.BayesPrior = [0.5 0.5];
%ClassifyOptions.BayesPrior = [0.25 0.25 0.25 0.25];

ClassifyOptions.classifier = 'SVM';
ClassifyOptions.svmKernel = 'linear';
ClassifyOptions.svmKernelArgument = 1;
ClassifyOptions.maxIter = 10000;
% ClassifyOptions.svmRegularizationConstant = 1000;
%ClassifyOptions.svmRegularizationConstant = [10 1 0.1 0.01]; % Best:0.1
ClassifyOptions.svmRegularizationConstant = 0.1;
%ClassifyOptions.svmRegularizationConstant = [0.01 0.01 0.1 1 10 100];
%ClassifyOptions.tolerance = 0.001;
ClassifyOptions.optimizationDepth = 3;
ClassifyOptions.svmMulticlass = 'oaa';

% ClassifyOptions.classifier = 'kNN';
% ClassifyOptions.knnK = 8;

ClassifyOptions.classes = [0 3];

% TESTS
EvaluationOptions.disp = 1;
EvaluationOptions.datasetSize = size(featuresGroup, 1);
EvaluationOptions.roc = 1;
EvaluationOptions.rocSamples = 100;

% disp('ALL Features:');
% Results = crossValidate(featuresGroup, FeatureSelectionAll, CrossValidation, ClassifyOptions);
% Results = evaluateClassification(Results, EvaluationOptions);

% disp('Retina Std Features:');
% Results = crossValidate(featuresGroup, FeatureSelectionRetina, CrossValidation, ClassifyOptions);
% Results = evaluateClassification(Results, EvaluationOptions);

% disp('RNFL Std Features:');
% Results = crossValidate(featuresGroup, FeatureSelectionRNFLStd, CrossValidation, ClassifyOptions);
% Results = evaluateClassification(Results, EvaluationOptions);

% disp('IPL Std Features:');
% Results = crossValidate(featuresGroup, FeatureSelectionIPL, CrossValidation, ClassifyOptions);
% Results = evaluateClassification(Results, EvaluationOptions);
% 
% disp('OPL Std Features:');
% Results = crossValidate(featuresGroup, FeatureSelectionOPL, CrossValidation, ClassifyOptions);
% Results = evaluateClassification(Results, EvaluationOptions);
% 
% disp('ONL Std Features:');
% Results = crossValidate(featuresGroup, FeatureSelectionONL, CrossValidation, ClassifyOptions);
% Results = evaluateClassification(Results, EvaluationOptions);
% 
% disp('RPE Std Features:');
% Results = crossValidate(featuresGroup, FeatureSelectionRPE, CrossValidation, ClassifyOptions);
% Results = evaluateClassification(Results, EvaluationOptions);
% 
% disp('BV Std Features:');
% Results = crossValidate(featuresGroup, FeatureSelectionBV, CrossValidation, ClassifyOptions);
% Results = evaluateClassification(Results, EvaluationOptions);
% 
% disp('RNFL All Features:');
% Results = crossValidate(featuresGroup, FeatureSelectionRNFLAll, CrossValidation, ClassifyOptions);
% Results = evaluateClassification(Results, EvaluationOptions);
% 
% disp('RNFL Section Features:');
% Results = crossValidate(featuresGroup, FeatureSelectionRNFLSection, CrossValidation, ClassifyOptions);
% Results = evaluateClassification(Results, EvaluationOptions);

% disp('RNFL PCA All Features:');
% Results = crossValidate(featuresGroup, FeatureSelectionRNFLPCAAll, CrossValidation, ClassifyOptions);
% Results = evaluateClassification(Results, EvaluationOptions);
% 
% disp('RNFL PCA Normal Features:');
% Results = crossValidate(featuresGroup, FeatureSelectionRNFLPCANormal, CrossValidation, ClassifyOptions);
% Results = evaluateClassification(Results, EvaluationOptions);

disp('Classify with best Features:');
Results = crossValidate(featuresGroup, FeatureSelectionBest, CrossValidation, ClassifyOptions);
Results = evaluateClassification(Results, EvaluationOptions);

saveClassificationResult('test', Results, FeatureSelectionBest, CrossValidationOptions, additionalGroup, description);

generateTextReport('testOld.txt', ...
                            Results, ...
                            FeatureSelectionBest, ...
                            additionalGroup, ...
                            ClassifyOptions, ...
                            CrossValidationOptions, ...
                            SelectionOptions, ...
                            description);
