function Results = performSVMClassification(classTraining,...
    featuresTraining,...
    classTest,...
    featuresTest,...
    ClassifyOptions)

options.ker = ClassifyOptions.svmKernel;
options.arg = ClassifyOptions.svmKernelArgument;
options.C =  ClassifyOptions.svmRegularizationConstant;
if isfield(ClassifyOptions, 'tolerance')
    options.tol = ClassifyOptions.tolerance;
    options.eps = ClassifyOptions.tolerance;
end
if isfield(ClassifyOptions, 'maxIter')
    options.maxIter = ClassifyOptions.maxIter;
end

% Map classes
for i = 1:numel(ClassifyOptions.classes)
    classTraining(classTraining == ClassifyOptions.classes(i)) = i;
    classTest(classTest == ClassifyOptions.classes(i)) = i;
end

training.y = classTraining';
training.X = featuresTraining';

% If C is a vector, do optimization. 
% The optimization is done as follows:
% The starting values of C are tried out.
% If the best C is inf, take that. Otherwise Perform a grid search
% from the smaller power of 10 to the next (seen from the currently best C)
% Refine a certain number of steps 
% (defined in ClassifyOptions.optimizationDepth). 
% Compute the SVN again with the selected C 
% This would be not necessry, but makes the code so much nicer ;-)
if isvector(options.C) && numel(options.C) > 1
    MAX_STEPS = ClassifyOptions.optimizationDepth;
    
    cPos = options.C; % CurrentPossibilities for C, C > 0 (add inf?)
    
    featRate = zeros(size(cPos));
    
    for k = 1:numel(cPos)
        options.C = cPos(k);
        
        Results = classifyWithSingleC(options, ClassifyOptions, classTraining, training, classTest, featuresTest);

        featRate(k) = Results.classificationRate;
    end
    
    [featRateSorted, idx] = sort(featRate, 'descend');
    C = cPos(idx(1));
    if C ~= inf % If C is infinity, do no further optimization
        steps = 0;
        while (steps < MAX_STEPS)
            minC = C - 0.9 * C;
            maxC = 10 * C;
            stepSize = 0.9 * C;
            cPos = minC:stepSize:maxC;
            featRate = zeros(size(cPos));
            
            for k = 1:numel(cPos)
                options.C = cPos(k);
                
                Results = classifyWithSingleC(options, ClassifyOptions, classTraining, training, classTest, featuresTest);
                
                featRate(k) = Results.classificationRate;
            end
            
            [featRateSorted, idx] = sort(featRate, 'descend');
            C = cPos(idx(1));
            
            steps = steps + 1;
        end
    end 
    
    options.C = C;
end

% disp (options);

ClassifyOptions.svmRegularizationConstant = options.C;
Results = createResultsStruct(ClassifyOptions);

% Normal computation of the SVM: 
model = getModel(options, ClassifyOptions, training); % Get the model (Training)

[testResult, discriminators] = svmclass(featuresTest',model); % Evaluation

for i = 1:numel(ClassifyOptions.classes) % Map the classes back
    testResult(testResult == i) = ClassifyOptions.classes(i);
end

% Fill in results struct
Results.classResult{1} = testResult'; 
Results.discriminators{1} = discriminators';
Results.regConstant{1} = options.C;
Results.testIdx{1} = 1;


end

% -------------------------------------------------------------------------
% Helper functions

% Get the fitting SVM model
function model = getModel(options, ClassifyOptions, training)
options.bin_svm = 'svmlight';
options.svm_command = '~/svn/octseg/3rdParty/svm_light_osx/svm_learn';
if numel(options.C) > 1
    if numel(ClassifyOptions.classes) ~= 2
        if strcmp(ClassifyOptions.svmMulticlass, 'oaa')
            options.solver = 'oaasvm';
            model = evalsvm(training,options);
        else
            options.solver = 'oaosvm';
            model = evalsvm(training,options);
        end
    else
        disp(options.C);
        model = evalsvm(training,options);
    end
else
    if numel(ClassifyOptions.classes) == 2
        model = smo(training,options);
        % model = svmlight(training,options);
    elseif strcmp(ClassifyOptions.svmMulticlass, 'oaa')
        model = oaasvm(training,options);
    else
        model = oaosvm(training,options);
    end
end
end

% Perform a classification where we know that C is only a single parameter
% Evaluate the results to get a classwise averaged classification rate.
function Results = classifyWithSingleC(options, ClassifyOptions, classTraining, training, classTest, featuresTest)
Results = createResultsStruct(ClassifyOptions);
Results.testIdx{1} = 1:size(classTest, 1);
Results.classGoldStandard{1} = classTest;

model = getModel(options, ClassifyOptions, training);

[testResult, discriminators] = svmclass(featuresTest',model);

for i = 1:numel(ClassifyOptions.classes)
    testResult(testResult == i) = ClassifyOptions.classes(i);
end

Results.classResult{1} = testResult';
Results.discriminators{1} = discriminators;

% Use the evaluateClassification function to calculate the
% classwise averaged classification rate.
options.disp = 0;
options.roc = 0;
options.datasetSize = size(featuresTest, 1);
Results = evaluateClassification(Results, options);
end