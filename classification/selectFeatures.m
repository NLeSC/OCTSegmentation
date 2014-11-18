function FeatureSelection = selectFeatures(features, classes, additional, description, SelectionOptions)
% Perform feature selection.
% Parameters: features, classes, additional, description: see 
%   readFeatureFile(...).
% SelectionOptions is a struct with the following fields:
%   method: 
%       - 'all': Select all features.
%       - 'StrCmp': Select features of which the description name contain 
%                   certain strings.
%       - 'bestNext': Select the next best feature (from the Nieman book).
%       - 'alternate': Alternating feature addition/removal (from the 
%                      Niemann book).
%   compareStrings: Nx2 cell with Strings. The single rows are treated as
%       "OR" condition entries, while the two entries in one row are 
%       cobined with and "And". One might leave the second cell in a row
%       empty. Example {{RNFL}{Std}; {BV}{}} selects only the Std features
%       from the RNFL and all features from the blood vessels.
%       FOR METHOD: StrCmp
%   corrRejectFirst: If the features pearson correlation coefficient is
%       lower than this value, it is reject as first feature to the 
%       selection. (Correlation with class labels)
%   corrRejectOther: If the features pearson correlation coefficient is 
%       lower than this value, it is reject. (Correlation with class label)
%   crossValidationIdx: See crossValidate/buildCrossValidation
%       FOR METHOD: bestNext and alternate
%   ClassifyOptions: see crossValidate
%       FOR METHOD: bestNext and alternate
%   disp: Do display each step or not.
%   numFeat: Maximum number of features allowed.
%   
% Return struct FeatureSelection entries:
% type: 0 if all features are the same for all cross validation runs, 
%   1 if they change.
% featureIdx: The indices of the features to select. If type is one it
%   contains all features selected in the cross validation runs.
% crossIdx: A cell vector with the feature indices of for each cross
%   validation run if type is 1.
% ranking: A ranking value for the feature indices.
% rankingSimple: A simpler ranking (not weighted) for the feature
%                       indices
% 
% In addition, the following SelectionOptions are copied into the result:
% method, compareStrings, corrRejectFirst, corrRejectOther, 
% ClassifyOptions, numFeat.


FeatureSelection.method = SelectionOptions.method;
if ~isfield(SelectionOptions, 'corrRejectFirst')
    SelectionOptions.corrRejectFirst = 0.0;
end
if ~isfield(SelectionOptions, 'corrRejectOther')
    SelectionOptions.corrRejectOther = 0;
end
if isfield(SelectionOptions, 'ClassifyOptions')
    FeatureSelection.ClassifyOptions = SelectionOptions.ClassifyOptions;
end
if isfield (SelectionOptions, 'compareStrings')
    FeatureSelection.compareStrings = SelectionOptions.compareStrings;
end
if isfield (SelectionOptions, 'corrRejectFirst')
    FeatureSelection.corrRejectFirst = SelectionOptions.corrRejectFirst;
end
if isfield (SelectionOptions, 'corrRejectOther')
    FeatureSelection.corrRejectOther = SelectionOptions.corrRejectOther;
end
if isfield (SelectionOptions, 'numFeat')
    FeatureSelection.numFeat = SelectionOptions.numFeat;
end

% Select all features.
if strcmp(SelectionOptions.method, 'all')
    FeatureSelection.type = 0;
    featuresIdx = 1:size(features, 2);
    featureRanking = zeros(size(featuresIdx));
% Select only features of which the description contains a certain string.
elseif strcmp(SelectionOptions.method, 'StrCmp')
    FeatureSelection.type = 0;
    description = description((size(additional, 2) + 2):end);
    
    idxColl = zeros(size(SelectionOptions.compareStrings, 1), numel(description));
    for i = 1:size(SelectionOptions.compareStrings, 1);
        % If the row has only one cell entry.
        if numel(SelectionOptions.compareStrings{i, 2}) == 0 
            for k = 1:numel(description)
                if numel(strfind(description{k}, SelectionOptions.compareStrings{i, 1})) > 0
                    idxColl(i,k) = 1;
                end
            end
        else % Otherwise concatenate the two strings in a row with "And"
            for k = 1:numel(description) 
                if (numel(strfind(description{k}, SelectionOptions.compareStrings{i, 1})) > 0) && ...
                   (numel(strfind(description{k}, SelectionOptions.compareStrings{i, 2})) > 0)
                    idxColl(i,k) = 1;
                end
            end
        end
    end
    idxColl = sum(idxColl, 1);
    
    featuresIdx = find(idxColl);
    featureRanking = zeros(size(featuresIdx));
% From the Niemann book: Classify on the training data with a (perhaps
% weaker classifier) and take the classification result as a feature 
% ranking. Add the next best single feature to the selected features until
% the classification rate does not get better anymore. 
elseif strcmp(SelectionOptions.method, 'bestNext')
    FeatureSelection.type = 1;
    featureRanking = zeros(1, size(features, 2));
    
    crossValidationIdx = SelectionOptions.crossValidationIdx;
    ClassifyOptions = SelectionOptions.ClassifyOptions;
    
    Results.classGoldStandard = cell(size(crossValidationIdx, 1), 1);
    Results.classResult = cell(size(crossValidationIdx, 1), 1);
    Results.numFolds = size(crossValidationIdx, 1);
    Results.classes = ClassifyOptions.classes;
    
    EvaluationOptions.disp = 0;
    
    FeatureSelection.crossIdx = cell(1,size(crossValidationIdx, 1));
    
    for runNum = 1:size(crossValidationIdx, 1)
        
        %disp(['Cross validation. Run: ' num2str(runNum) ' of ' num2str(size(crossValidationIdx, 1))]);
        featuresSet = [];
        featuresOpen = 1:size(features, 2);
        
        for runFeat = 1:SelectionOptions.numFeat
            disp(['We chose the feature ' num2str(runFeat)]);
            featRate = zeros(size(featuresOpen));
            
            for i = 1:numel(featuresOpen)

                trainingFeatures = features(crossValidationIdx{runNum, 1}, [featuresSet featuresOpen(i)]);
                varTraining = var(trainingFeatures);
                validFeatures = varTraining ~= 0;
                trainingFeatures = trainingFeatures(:, validFeatures);
                
                if numel(trainingFeatures) == 0
                    featRate(i) = 0;
                    continue;
                end
                
                classTraining = classes(crossValidationIdx{runNum, 1});

                
                featRate(i) = classRun(trainingFeatures, classTraining, ClassifyOptions);
            end
            
            [featRateSorted idx] = sort(featRate, 'descend');
            featuresSet = [featuresSet featuresOpen(idx(1))];
            featuresOpen = featuresOpen(featuresOpen ~= featuresOpen(idx(1)));
        end
        
        FeatureSelection.crossIdx{runNum} = featuresSet;
        featureRanking(featuresSet) = featureRanking(featuresSet) + [SelectionOptions.numFeat:-1:1] * 0.3;
    end
    
    [featureRankingSorted idx] = sort(featureRanking, 'descend');
    featuresIdx = idx(1:SelectionOptions.numFeat);
    featureRanking = featureRankingSorted(1:SelectionOptions.numFeat);
% From the Niemann book: Classify on the training data with a (perhaps
% weaker classifier) and take the classification result as a feature 
% ranking. Add the next best single feature to the selected features until
% the classification rate does not get better anymore. Then remove the
% weakest feature, until the classification rate does not get better
% anymore, start adding again. Stop when no add/remove is possible
elseif strcmp(SelectionOptions.method, 'alternate')
    disp('Alternating feature selection.');
    FeatureSelection.type = 1;
    featureRanking = zeros(1, size(features, 2));
    featureRankingSimple = zeros(1, size(features, 2));
    
    crossValidationIdx = SelectionOptions.crossValidationIdx;
    ClassifyOptions = SelectionOptions.ClassifyOptions;
    
    Results.classGoldStandard = cell(size(crossValidationIdx, 1), 1);
    Results.classResult = cell(size(crossValidationIdx, 1), 1);
    Results.numFolds = size(crossValidationIdx, 1);
    Results.classes = ClassifyOptions.classes;
    
    EvaluationOptions.disp = 0;
    
    FeatureSelection.crossIdx = cell(1,size(crossValidationIdx, 1));
    
    corrRejectFirst = SelectionOptions.corrRejectFirst;
    corrRejectOther = SelectionOptions.corrRejectOther;
    
    for runNum = 1:size(crossValidationIdx, 1)
        disp(['Cross validation. Run: ' num2str(runNum) ' of ' num2str(size(crossValidationIdx, 1))]);
        featuresSet = [];
        featuresOpen = 1:size(features, 2);
        
        bestRate = 0;
        actRate = 1;
        
        classTraining = classes(crossValidationIdx{runNum, 1});
        
        while numel(featuresSet) < SelectionOptions.numFeat
            if SelectionOptions.disp
                disp(['Currently: ' num2str(numel(featuresSet)) ' features selected. Best rate: ' num2str(bestRate) ' Act rate: ' num2str(actRate)]);
            end
            
            bestRateBefore = bestRate;
            featuresSetBefore = featuresSet;
            featRate = zeros(size(featuresOpen));
            
            if SelectionOptions.disp
                disp('Adding');
            end
            for i = 1:numel(featuresOpen)
                
                trainingFeatures = features(crossValidationIdx{runNum, 1}, [featuresSet featuresOpen(i)]);
                varTraining = var(trainingFeatures);
                validFeatures = varTraining > 0.000001;
                trainingFeatures = trainingFeatures(:, validFeatures);
                
                if numel(trainingFeatures) == 0
                    featRate(i) = 0;
                    continue;
                end
                
                % The following lines enhance the training speed for the
                % first feature. The first feature is not considered
                % if it has a correlation with the classes of less than
                % 0.7. This holds only for the selection of the first
                % feature!
                corr = 1;
                if (size(trainingFeatures,2) == 1)
                    if (corrRejectFirst ~= 0)
                        corr = correlationCol (trainingFeatures, classTraining);
                        if (abs(corr) < corrRejectFirst)
                            featRate(i) = 0;
                            continue;
                        end
                    end
                else
                    if (corrRejectOther ~= 0)
                        corr = correlationCol (trainingFeatures(:,end), classTraining);
                        if (abs(corr) < corrRejectOther)
                            featRate(i) = 0;
                            continue;
                        end
                    end
                end
                
                if SelectionOptions.disp > 1
                    disp (['Feature '  num2str(i) ' Var: ' num2str(varTraining(1)) ' Corr: ' num2str(corr)]);
                end
                featRate(i) = classRun(trainingFeatures, classTraining, ClassifyOptions);
                % disp ('Done');
            end
            
            [featRateSorted idx] = sort(featRate, 'descend');
            if SelectionOptions.disp
                disp(['featRateBest after Adding: ' num2str(featRateSorted(1))]);
            end
            actRate = featRateSorted(1);
            
            bestRate = actRate;
            featuresSet = [featuresSet featuresOpen(idx(1))];
            featuresOpen = featuresOpen(featuresOpen ~= featuresOpen(idx(1)));
            
            if numel(featuresSet) >= SelectionOptions.numFeat
                break;
            end
            
            if SelectionOptions.disp
                disp('Removing');
            end
            while actRate >= bestRate && numel(featuresSet) < SelectionOptions.numFeat
                featRate = zeros(size(featuresSet));
                %disp(['Shrink: ' num2str(bestRate) ', ' num2str(actRate)]);
                for i = 1:numel(featuresSet)
                    if SelectionOptions.disp
                        disp (['Feature '  num2str(i)]);
                    end
                    trainingFeatures = features(crossValidationIdx{runNum, 1}, featuresSet([1:(i-1) (i+1):end]));
                    varTraining = var(trainingFeatures);
                    validFeatures = varTraining > 0.000001;
                    trainingFeatures = trainingFeatures(:, validFeatures);
                    
                    if numel(trainingFeatures) == 0
                        featRate(i) = 0;
                        continue;
                    end
                    
                    featRate(i) = classRun(trainingFeatures, classTraining, ClassifyOptions);
                end
                
                [featRateSorted idx] = sort(featRate, 'descend');
                actRate = featRateSorted(1);
                if actRate >= bestRate
                    bestRate = actRate;
                    featuresOpen = [featuresOpen featuresSet(idx(1))];
                    featuresSet = [featuresSet([1:(idx(1)-1) (idx(1)+1):end])];    
                end
            end
            
            if (bestRateBefore == bestRate) && (isequal (featuresSet, featuresSetBefore))
                break;
            end
        end
        disp(featuresSet);
        
        FeatureSelection.crossIdx{runNum} = featuresSet;
        featureRanking(featuresSet) = featureRanking(featuresSet) + ones(size(featuresSet)) ./ numel(featuresSet);
        featureRankingSimple(featuresSet) = featureRankingSimple(featuresSet) + ones(size(featuresSet));
    end
    
    [featureRankingSorted, idx] = sort(featureRanking, 'descend');
    featuresIdx = idx(1:SelectionOptions.numFeat);
    featureRankingSimple = featureRankingSimple (idx(1:SelectionOptions.numFeat));
    
    featureRanking = featureRankingSorted(1:SelectionOptions.numFeat);
    featureRanking = featureRanking(featureRanking ~= 0);
    featuresIdx = featuresIdx(1:numel(featureRanking));
    featureRankingSimple = featureRankingSimple(1:numel(featureRanking));
end

FeatureSelection.idx = featuresIdx;
FeatureSelection.ranking = featureRanking;
if exist ('featureRankingSimple', 'var')
    FeatureSelection.rankingSimple = featureRankingSimple;
end

end

% Classify on the training data. Test data == training data.
% Parameters:
%   trainingFeatures: NxF matrix, where N is the number of datasets and 
%       F is the number of features.
%   classTraining: N-sized columns vector. The class indices for the 
%       datasets.
%   ClassifyOptions: see crossValidate.
% Return:
% Classwise averaged classification rate.
function featRate = classRun(trainingFeatures, classTraining, ClassifyOptions)

% Create result struct for the use in evaluateClassification(...)
Results = createResultsStruct(ClassifyOptions);

Results.testIdx{1} = 1:numel(classTraining);
Results.classGoldStandard{1} = classTraining;

% Perform the classification, depending on the classifier.
if strcmp(ClassifyOptions.classifier, 'Bayes')
    classResult = classify(trainingFeatures, trainingFeatures, classTraining, ClassifyOptions.BayesSpec, ClassifyOptions.BayesPrior);
    Results.classResult{1} = classResult;
elseif strcmp(ClassifyOptions.classifier, 'SVM')
    ResultsSVM = performSVMClassification(classTraining, trainingFeatures, classTraining, trainingFeatures, ClassifyOptions);
    Results.classResult{1} = ResultsSVM.classResult{1};
    Results.discriminators{1} = ResultsSVM.discriminators{1};
elseif strcmp(ClassifyOptions.classifier, 'kNN')
    for i = 1:numel(ClassifyOptions.classes)
        classTraining(classTraining == ClassifyOptions.classes(i)) = i;
    end
    
    training.y = classTraining';
    training.X = trainingFeatures';
    
    model = knnrule(training, ClassifyOptions.knnK);
    
    classResult = knnclass(trainingFeatures',model);
    for i = 1:numel(ClassifyOptions.classes)
        classResult(classResult == i) = ClassifyOptions.classes(i);
    end
    Results.classResult{1} = classResult';
end

% Use the evaluateClassification function to calculate the 
% classwise averaged classification rate.
options.disp = 0;
options.roc = 0;
options.datasetSize = size(trainingFeatures, 1);
Results = evaluateClassification(Results, options);
featRate = Results.classificationRate;

% OLD CODE: Simple classification rate.
% featRate = mean(double(classResult == classTraining));
end

% Pearsons correlation coefficient
function corr = correlationCol(A, B)
meanA = mean(A);
meanB = mean(B);

varA = var(A);
varB = var(B);

varA(varA < 0.0001) = 0.0001;
varB(varB < 0.0001) = 0.0001;

corr = (mean((A - meanA(ones(size(A,1),1), :)) .* (B - meanB(ones(size(B,1),1),:))) ./ sqrt(varA .* varB));

end

