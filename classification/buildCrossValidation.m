function CrossValidation = buildCrossValidation(features, classes, additional, options)
% Build a crossvalidation for a classification task. 
% Input:
% * features: never used, but there for code writeability.
% * classes: The class identifier for the datasets.
% * additional: The additional information for the datasets.
% * options: A options struct.
% The options available are:  
% * classes: A cell array of vectors. Each vector contains the class
%   identifiers that should be mapped to one class for the classification
%   task.
% * classMapping: The class identifiers the grouped classes as defined by
%   classes are mapped to.
% * equaliSizeClasses: Should all the (mapped) classes contain the same 
%   number of of datasets? If yes, the classes are reduced to the one with
%   minimum size by random exclusion of datasets.
% * ageColumn: The column of the age information in the additional cell
%   array.
% * patientIDColumn: The column of the patient ID information in the
%   additonal cell array.
% * patientSensitive: If 1, datasets with the same patient ID are never
%   separated into the training and test sets.
% * numFold: Number of folds.
% The output struct has the following fields:
% * classesMapped: A vector (size: number of datasets) with the mapped
%   classes for this crossvalidation.
% * crossValidationIdx: Cell array of size numFolds x 2; The first cell 
%   in each row contains the dataset indices of the training data, the
%   second cell the dataset indices of the test data.

disp('Building Cross Validation');
numClasses = numel(options.classes);
CrossValidation.classesMapped = classes; % The mapped classes are initialized with the original ones.
% idxClasses Stores the dataset inidices of the respective mapped classes. 
% It is initialized to 2 cell values, but may grow accoring to numClasses.
idxClasses = cell(1,2); 
% Change the mapped classes according to options.classes and
% options.classMapping.
for i = 1:numClasses
    idxClasses{i} = [];
    for k = 1:numel(options.classes{i})
        idxClasses{i} = [idxClasses{i}; find(classes == int8(options.classes{i}(k)))];
    end
    idxClasses{i} = sort(idxClasses{i}, 'ascend');
    CrossValidation.classesMapped(idxClasses{i}) = options.classMapping(i);
end

% Make class sizes equal if the option is set.
if options.equalSizeClasses
    % Find out the class with minimum dataset.
    numIdxClasses = zeros(size(options.classes));
    for i = 1:numClasses
        numIdxClasses(i) = numel(idxClasses{i});
        disp(['Class ' num2str(options.classes{i}) ' has ' num2str(numIdxClasses(i)) ' datasets.']);
    end
    disp('Reducing to min. dataset size.');
    minNumIdxClasses = min(numIdxClasses);
    
    % Reduce the class sizes by throwing out inidices within idxClasses.
    for i = 1:numClasses
        if numIdxClasses(i) > minNumIdxClasses
            idxClasses{i} = idxClasses{i}(randperm(minNumIdxClasses));
        end
    end
end

idxClassesComplete = []; % Stores ALL dataset indices of the datasets that 
% are valud for the classification task (after selection, mapping and 
% size equalization, and mapping)

for i = 1:numClasses
    idxClassesComplete = [idxClassesComplete; idxClasses{i}];
end

% Sort by PatientID
ageClassesComplete = zeros(size(idxClassesComplete));
patientIDClassesComplete = zeros(size(idxClassesComplete));

% Get the number values from the Strings
for i = 1:numel(idxClassesComplete)
    ageClassesComplete(i) = str2double(additional{idxClassesComplete(i), options.ageColumn});
    patientIDClassesComplete(i) = str2double(additional{idxClassesComplete(i), options.patientIDColumn});
end

% Cell vector that stores in each cell the indices that belong to one
% patient ID.
idxClassesPatientID = cell(1,1);

if options.patientSensitive
    [patientIDClassesCompleteSorted PatientIDIdx] = sort(patientIDClassesComplete);
    patientCount = 0;
    patientIDbefore = -1;
    for i = 1:numel(patientIDClassesCompleteSorted)
        if patientIDClassesCompleteSorted(i) == patientIDbefore
            idxClassesPatientID{patientCount} = [idxClassesPatientID{patientCount} idxClassesComplete(PatientIDIdx(i))];
        else
            patientCount = patientCount + 1;
            idxClassesPatientID{patientCount} = idxClassesComplete(PatientIDIdx(i));  
        end
        patientIDbefore = patientIDClassesCompleteSorted(i);
    end
else % idxClassesPatientID is just a mapping of idxClassesComplete
    for i = 1:numel(patientIDClassesComplete)
        idxClassesPatientID{i} = idxClassesComplete(i);
    end
end

disp(['Number of patients: ' num2str(numel(idxClassesPatientID))]);

% Find CrossValidation indices
splitNumbers = randperm(numel(idxClassesPatientID));
splitStep = floor(numel(splitNumbers) / options.numFold);

crossValidationIdx = cell(options.numFold, 2);
for i = 1:options.numFold
    % Indices for test data into the random index vector
    testNumbers = (((i - 1) * splitStep) + 1):(i * splitStep);
    trainingIdx = [];
    testIdx = [];
    
    % Unfold the cell array containing the PatientID sorted dataset indices
    for k = 1:testNumbers(1) - 1
        trainingIdx = [trainingIdx idxClassesPatientID{splitNumbers(k)}];
    end
    
    for k = testNumbers
        testIdx = [testIdx idxClassesPatientID{splitNumbers(k)}];
    end
    
    for k = testNumbers(end)+1:numel(splitNumbers)
        trainingIdx = [trainingIdx idxClassesPatientID{splitNumbers(k)}];
    end
    
    crossValidationIdx{i, 1} = sort(trainingIdx);
    crossValidationIdx{i, 2} = sort(testIdx);
end

CrossValidation.idx = crossValidationIdx;