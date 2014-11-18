function saveClassificationResultText(path, Results, FeatureSelection, CrossValidationOptions, additional, description)
% Stores the classification result into a text file. The most important
% fields of the result are stored in a human readable manner.

fido = fopen(path, 'w');
ClassifyOptions = Results.ClassifyOptions;

% Print out general information
fprintf(fido, '---------------------------------------------------------------------------\n');
fprintf(fido, 'General Information: \n');
fprintf(fido, '---------------------------------------------------------------------------\n');

fprintf(fido, 'Classes (Mapped): %s\n', generateClassString(Results.classes));
fprintf(fido, 'Classes original: %s\n', generateClassString(CrossValidationOptions.classes));
fprintf(fido, '\n');

fprintf(fido, 'Number of samples in each class:\n');
for k = 1:numel(Results.classes)
    fprintf(fido, 'Class %d: %d\n', Results.classes(k), Results.numSamplesClasses(k));
end
fprintf(fido, '\n');

% Print out information regarding the cross validation
fprintf(fido, '---------------------------------------------------------------------------\n');
fprintf(fido, 'Cross Validation: \n');
fprintf(fido, '---------------------------------------------------------------------------\n');

fprintf(fido, 'Number of folds: %d\n', CrossValidationOptions.numFold);
fprintf(fido, 'Patient sensitiv: %d\n', CrossValidationOptions.patientSensitive);
fprintf(fido, 'Equal class size: %d\n', CrossValidationOptions.equalSizeClasses);
fprintf(fido, '\n');

% Print out information regarding the feature selection
fprintf(fido, '---------------------------------------------------------------------------\n');
fprintf(fido, 'Feature Selection: \n');
fprintf(fido, '---------------------------------------------------------------------------\n');

fprintf(fido, 'Method: %s\n', FeatureSelection.method);
if strcmp(FeatureSelection.method, 'StrCmp')
    for k = 1:numel(FeatureSelection.compareStrings)
        fprintf(fido, 'Feature Selector %k: %s\n', k, FeatureSelection.compareStrings{k});
    end
elseif strcmp(FeatureSelection.method, 'bestNext') || strcmp(FeatureSelection.method, 'alternate')
    printClassifyOptions (fido, FeatureSelection.ClassifyOptions)
    fprintf(fido, '\n');
    
    fprintf(fido, 'Maximum number of features allowed: %d\n', FeatureSelection.numFeat);
    if isfield(FeatureSelection, 'corrRejectFirst')
        fprintf(fido, 'First run correlation rejection: %.3f\n', FeatureSelection.corrRejectFirst);
    end
    if isfield(FeatureSelection, 'corrRejectOther')
        fprintf(fido, 'General correlation rejection: %.3f\n', FeatureSelection.corrRejectOther);
    end
    fprintf(fido, '\n');
    
    fprintf(fido, 'Feature ranking:\n');
    descriptionFeatures = description((size(additional, 2) + 2):end);
    for i = 1:numel(FeatureSelection.idx)
        fprintf(fido, '%d\t%s\t%.3f\n', i, descriptionFeatures{FeatureSelection.idx(i)}, FeatureSelection.ranking(i));
    end
    fprintf(fido, '\n');
    
    if isfield(FeatureSelection, 'rankingSimple')
        fprintf(fido, 'Feature ranking (simple):\n');
        descriptionFeatures = description((size(additional, 2) + 2):end);
        for i = 1:numel(FeatureSelection.idx)
            fprintf(fido, '%d\t%s\t%.3f\n', i, descriptionFeatures{FeatureSelection.idx(i)}, FeatureSelection.rankingSimple(i));
        end
    end
end
fprintf(fido, '\n');

% Print out information regarding the classification:
fprintf(fido, '---------------------------------------------------------------------------\n');
fprintf(fido, 'Classification: \n');
fprintf(fido, '---------------------------------------------------------------------------\n');

fprintf(fido, 'Classifier:\n');
printClassifyOptions (fido, ClassifyOptions)
fprintf(fido, '\n');
    

% Print out general results:
fprintf(fido, '---------------------------------------------------------------------------\n');
fprintf(fido, 'General Results: \n');
fprintf(fido, '---------------------------------------------------------------------------\n');

fprintf(fido, 'Confusion matrix: \n');
fprintf(fido, '%s', generateCMString(Results.confusionMatrix, Results.classes, '%d'));
fprintf(fido, '\n');

fprintf(fido, 'Confusion matrix (normalized): \n');
fprintf(fido, '%s', generateCMString(Results.confusionMatrixNorm, Results.classes, '%.3f'));
fprintf(fido, '\n');

fprintf(fido, 'Classwise averaged classfication rate: %f\n', Results.classificationRate);
if isfield(Results, 'auRoc')
    fprintf(fido, 'Area under the ROC: %f\n', Results.auRoc);
end
fprintf(fido, '\n');

% Print out missclassifications:
fprintf(fido, '---------------------------------------------------------------------------\n');
fprintf(fido, 'Missclassified: \n');
fprintf(fido, '---------------------------------------------------------------------------\n');

if strcmp(ClassifyOptions.classifier, 'SVM')
    fprintf(fido, 'Dist borders: %0.3f, %0.3f\n\n', min(Results.allDiscriminators), max(Results.allDiscriminators));
    fprintf(fido, 'Mean,Std Dist: %0.3f, %0.3f\n\n', mean(Results.allDiscriminators), std(Results.allDiscriminators));
end

fileNameIdx = find(strcmp(description, 'Filename'));
ageIdx = find(strcmp(description, 'Age'));

fprintf(fido, 'Filename\tAge\tGoldstandard\tResult\t(Distance)\n')
for i = 1:numel(Results.allCorrect)
    if strcmp(ClassifyOptions.classifier, 'SVM')
        if Results.allCorrect(i) == 0
            fprintf(fido, '%s\t%.1f\t%d\t%d\t%0.3f\n', ...
                additional{i, fileNameIdx}, ...
                str2double(additional{i, ageIdx}), ...
                Results.allGoldstandard(i), ...
                Results.allResult(i), ...
                Results.allDiscriminators(i) ...
                );
        end
    else
        if Results.allCorrect(i) == 0
            fprintf(fido, '%s\t%.1f\t%d\t%d\t%0.3f\n', ...
                additional{i, fileNameIdx}, ...
                str2double(additional{i, ageIdx}), ...
                Results.allGoldstandard(i), ...
                Results.allResult(i) ...
                );
        end
    end
end

fclose(fido);
end

%--------------------------------------------------------------------------
% Helper functions

function classString = generateClassString(classes)
classString = '';
if iscell(classes)
    for i = 1:numel(classes)-1
        for k = 1:numel(classes{i})
            classString = [classString num2str(classes{i}(k)) ' ' ];
        end
        classString = [classString '| ' ];
    end
    for k = 1:numel(classes{numel(classes)})
        classString = [classString num2str(classes{numel(classes)}(k)) ' ' ];
    end
    
else
    for i = 1:numel(classes)-1
        classString = [classString num2str(classes(i)) ' | ' ];
    end
    classString = [classString num2str(classes(numel(classes)))];
end
end

function cm = generateCMString(matrix, classes, format)
lineBreak = sprintf('\n');
tab = sprintf('\t');

cm = ' ';
for i = 1:numel(classes)
    cm = [cm tab num2str(classes(i))];
end
cm = [cm lineBreak];

for r = 1:numel(classes)
    cm = [cm num2str(classes(r))];
    for c = 1:numel(classes)
        num = sprintf(format, matrix(r,c));
        cm = [cm tab num];
    end
    cm = [cm lineBreak];
end
end

function printClassifyOptions (fido, ClassifyOptions)
fprintf(fido, 'Classifier: %s\n', ClassifyOptions.classifier);
if strcmp(ClassifyOptions.classifier, 'Bayes')
    fprintf(fido, 'Specification: %s\n', ClassifyOptions.BayesSpec);
    fprintf(fido, 'Priors: %s\n', num2str(ClassifyOptions.BayesPrior));
elseif strcmp(ClassifyOptions.classifier, 'kNN')
    fprintf(fido, 'k Number: %d\n', ClassifyOptions.knnK);
elseif strcmp(ClassifyOptions.classifier, 'SVM')
    fprintf(fido, 'Kernel: %s\n', ClassifyOptions.svmKernel);
    fprintf(fido, 'Kernel arguments: %s\n', num2str(ClassifyOptions.svmKernelArgument));
    
    fprintf(fido, 'Regularization constant: ', num2str(ClassifyOptions.svmRegularizationConstant));
    for i = 1:numel(ClassifyOptions.svmRegularizationConstant)
        fprintf(fido, '%s ', num2str(ClassifyOptions.svmRegularizationConstant(i)));
    end
    fprintf(fido, '\n');
    
    if isfield (ClassifyOptions, 'optimizationDepth')
        fprintf(fido, 'Optimization depth: %s\n', ClassifyOptions.optimizationDepth);
    end
    
    
    if isfield (ClassifyOptions, 'svmMulticlass')
        fprintf(fido, 'Multiclass method: %s\n', ClassifyOptions.svmMulticlass);
    end
    
    if isfield (ClassifyOptions, 'tolerance')
        fprintf(fido, 'Tolerance: %s\n', ClassifyOptions.tolerance);
    end
    
    if isfield (ClassifyOptions, 'maxIter')
        fprintf(fido, 'Max. iterations: %s\n', ClassifyOptions.maxIter);
    end
end
end
