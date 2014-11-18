function generateTextReport(filename, ...
                            Results, ...
                            FeatureSelection, ...
                            additional, ...
                            ClassifyOptions, ...
                            CrossValidationOptions, ...
                            SelectionOptions, ...
                            description)

fido = fopen([filename], 'w');

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

fprintf(fido, 'Method: %s\n', SelectionOptions.method);
if strcmp(SelectionOptions.method, 'StrCmp')
    for k = 1:numel(SelectionOptions.compareStrings)
        fprintf(fido, 'Feature Selector %k: %s\n', k, SelectionOptions.compareStrings{k});
    end
elseif strcmp(SelectionOptions.method, 'bestNext') || strcmp(SelectionOptions.method, 'alternate')
    fprintf(fido, 'Classifier: %s\n', SelectionOptions.ClassifyOptions.classifier);
    if strcmp(SelectionOptions.ClassifyOptions.classifier, 'Bayes')
        fprintf(fido, 'Specification: %s\n', SelectionOptions.ClassifyOptions.BayesSpec);
    end
    fprintf(fido, 'Maximum number of features allowed: %d\n', SelectionOptions.numFeat);
    fprintf(fido, '\n');
    
    fprintf(fido, 'Feature ranking:\n');
    
    descriptionFeatures = description((size(additional, 2) + 2):end);
    
    for i = 1:numel(FeatureSelection.idx)
        fprintf(fido, '%d\t%s\t%.3f\n', i, descriptionFeatures{FeatureSelection.idx(i)}, FeatureSelection.ranking(i));
    end
end
fprintf(fido, '\n');

% Print out information regarding the classification:
fprintf(fido, '---------------------------------------------------------------------------\n');
fprintf(fido, 'Classification: \n');
fprintf(fido, '---------------------------------------------------------------------------\n');

fprintf(fido, 'Classifier: %s\n', ClassifyOptions.classifier);
if strcmp(ClassifyOptions.classifier, 'Bayes')
    fprintf(fido, 'Specification: %s\n', ClassifyOptions.BayesSpec);
    fprintf(fido, 'Priors: %s\n', num2str(ClassifyOptions.BayesPrior));
elseif strcmp(ClassifyOptions.classifier, 'kNN')
    fprintf(fido, 'k Number: %d\n', ClassifyOptions.knnK);
elseif strcmp(ClassifyOptions.classifier, 'SVM')
    fprintf(fido, 'Kernel: %s\n', ClassifyOptions.svmKernel);
    fprintf(fido, 'Kernel arguments: %s\n', num2str(ClassifyOptions.svmKernelArgument));
    fprintf(fido, 'Evaluated regularization constants: %s\n', num2str(ClassifyOptions.svmRegularizationConstant));
    if numel(Results.classes) > 2
        fprintf(fido, 'Multiclass method: %s\n', ClassifyOptions.svmMulticlass);
    end
end
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

% Print out missclassifications:
fprintf(fido, '---------------------------------------------------------------------------\n');
fprintf(fido, 'Missclassified: \n');
fprintf(fido, '---------------------------------------------------------------------------\n');

fileNameIdx = find(strcmp(description, 'Filename'));
ageIdx = find(strcmp(description, 'Age'));

fprintf(fido, 'Filename\tAge\tGoldstandard\tDistance\tResult\n')
for i = 1:numel(Results.allCorrect)
    if Results.allCorrect(i) == 0
        fprintf(fido, '%s\t%.1f\t%d\t%0.3f\t%d\n', ...
            additional{i, fileNameIdx}, ...
            str2double(additional{i, ageIdx}), ...
            Results.allGoldstandard(i), ...
            Results.allDiscriminators(i), ...
            Results.allResult(i) ...
            );
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
