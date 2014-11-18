function Results = crossValidate(features, FeatureSelection, CrossValidation, ClassifyOptions)
% Perform a crossvalidation classification run. The results are filled
% into a results struct.
% Parameters:
% - features: See readFeatureFile(...)
% - FeatureSelection: See selectFeatures(...)
% - CrossValidation: See buildCrossValidation(...)
% - ClassifyOptions: A struct containing all the options for the classifier
%   to choose. These are:
%   * classifier: The name of the classfier (Bayes, SVM or kNN)
%   * classes: A vector containing the (mapped) classes identifier, that
%              should be differentiated in the classification process.
%   Furthermore, each classifier has its own options:
%   Bayes: 
%   * BayesSpec: Discriminant function of the Matlab "classify" function.
%                'diaglinear' is a naive Bayes, according to Matlab help.
%   * BayerPrior: Prior probabilities for the classes. The length of the
%   kNN:
%   * knnK: Number of neighest neighbors to take into account.
%   SVM:
%   * svmKernel: Kernal function to use. Options available in the strp toolbox
%                are: 'linear', 'poly', 'rbf', 'sigmoid'
%   * svmKernelArgument: 'linear' does not need an argument, but the other
%                        kernels do (polynomial degree etc.).
%   * svmRegularizationConstant: The 'C' regularization constant of the
%                                SVM or 'optimize', if a parameter
%                                optimization in the range from 0.01 to 
%                                100 should be performed.
%   * svmMulticlass: The svm multiclass method to use. Possibilities are:
%                    'oaa': One against all
%                    'oao': One against one
%                    'mv': majority voting
% 
% The output is a classification result struct with the following entries
% filled:
% - ClassifyOptions: The classification options used.
% - testIdx (cell with #runs entries): 
%       The dataset indices of the test data.
% - classGoldStandard (cell with #runs entries): 
%       The gold standard for the classfication of this test dataset.
% - classResult (cell with #runs entries): 
%       The result for the classification of this test dataset.
% - discriminators (cell with #runs entries, only for SVM classifier): 
%       The SVM discriminant function. May be used later to generate a ROC.
% - regConstants (vector with #runs entries, only for SVM classifier):
%       The regularization constants (C) that yielded the best results in 
%       the classification.

Results = createResultsStruct(ClassifyOptions, CrossValidation);
% Results.classes = ClassifyOptions.classes;

% Fill out options for the SVM classification
if strcmp(ClassifyOptions.classifier, 'SVM')
    options.ker = ClassifyOptions.svmKernel;
    options.arg = ClassifyOptions.svmKernelArgument;
    options.C =  ClassifyOptions.svmRegularizationConstant;  
end

% Perform the cross validation runs. 
for runNum = 1:size(CrossValidation.idx, 1)
    % Construct the training and test data matrices.
    disp(['Cross validation. Run: ' num2str(runNum) ' of ' num2str(size(CrossValidation.idx, 1))]);
    
    if(FeatureSelection.type == 1)
        trainingFeatures = features(CrossValidation.idx{runNum, 1}, FeatureSelection.crossIdx{runNum});
    else
        trainingFeatures = features(CrossValidation.idx{runNum, 1}, FeatureSelection.idx);
    end
    
    varTraining = var(trainingFeatures);
    validFeatures = varTraining ~= 0;
    trainingFeatures = trainingFeatures(:, validFeatures);
    
    if(FeatureSelection.type == 1)
        testFeatures = features(CrossValidation.idx{runNum, 2}, FeatureSelection.crossIdx{runNum});
    else
        testFeatures = features(CrossValidation.idx{runNum, 2}, FeatureSelection.idx);
    end
    
    testFeatures = testFeatures(:, validFeatures);
    
    classTraining = CrossValidation.classesMapped(CrossValidation.idx{runNum, 1});
    classTest = CrossValidation.classesMapped(CrossValidation.idx{runNum, 2});
    
    Results.testIdx{runNum} = CrossValidation.idx{runNum, 2};

    Results.classGoldStandard{runNum} = classTest;
    
    % Perform the classification, dependent on the classifier
    if strcmp(ClassifyOptions.classifier, 'Bayes')
        classResult = classify(testFeatures, trainingFeatures, classTraining, ClassifyOptions.BayesSpec, ClassifyOptions.BayesPrior);
        Results.classResult{runNum} = classResult;
    elseif strcmp(ClassifyOptions.classifier, 'SVM')
        ResultsRun = performSVMClassification(classTraining, trainingFeatures, classTest, testFeatures, ClassifyOptions);
        
        Results.classResult{runNum} = ResultsRun.classResult{1};
        Results.discriminators{runNum} = ResultsRun.discriminators{1};
        Results.regConstant{runNum} = ResultsRun.regConstant{1};
    elseif strcmp(ClassifyOptions.classifier, 'kNN')
         for i = 1:numel(ClassifyOptions.classes)
            classTraining(classTraining == ClassifyOptions.classes(i)) = i;
            classTest(classTest == ClassifyOptions.classes(i)) = i;
        end
        
        training.y = classTraining';
        training.X = trainingFeatures';   
        
        model = knnrule(training, ClassifyOptions.knnK);
        
        testResult = knnclass(testFeatures',model);
        
        for i = 1:numel(ClassifyOptions.classes)
            testResult(testResult == i) = ClassifyOptions.classes(i);
        end
        
        Results.classResult{runNum} = testResult';
    end

end