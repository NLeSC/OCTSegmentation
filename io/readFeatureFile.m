function [features, classes, additional, description] = readFeatureFile(filename)
% Read a feature file. The feature file is defined as follows:
% First line: #AdditionalInformation #Features
% Second line: Names of AdditionalInformation - Name of the class - 
% Names of Features (separated by tabs). 
% Following lines: AdditionalInformation, class and features. Additional
% Information is read in as Strings, features as double value.
% Output is:
% features: The feaure matrix. One line is one data set)
% classes: The class for the respective features (a column vector)
% additional: A cell array with strings. One row is the addtional
% information for one dataset.
% description: The names of the additional information, class and features
% in one cell row vector.

fid = fopen(filename);

% Read in numbers of additonal information and features.
num = textscan(fid, '%f %f\n', 1);
numAdditional = num{1};
numFeatures = num{2};

% Read in the additional information and feature names (stored in
% description)
desString = '';
for i = 1:numAdditional + 1 + numFeatures
    desString = [desString '%s\t'];
end
desString = [desString '\n'];

descriptionTemp = textscan(fid, desString, 1);
description = cell(1, numel(descriptionTemp));
for i = 1:numel(descriptionTemp)
    description{i} = descriptionTemp{i}{1};
end

% Read in additional information and features. 
% First: Construct line appearance, to use the textscan method.
tableString = '';
for i = 1:numAdditional
    tableString = [tableString '%s\t'];
end
tableString = [tableString '%f\t'];
for i = 1:numFeatures
    tableString = [tableString '%f\t'];
end
tableString = [tableString '\n'];

data = textscan(fid, tableString);

classes = data{1,numAdditional + 1};

additional = cell(numel(classes), numAdditional);
for i = 1:numel(classes)
    for j = 1:numAdditional
        additional{i,j} = data{1,j}{i};
    end
end

features = zeros(numel(classes), numFeatures);
for i = 1:numel(classes)
    for j = numAdditional + 2:numAdditional + 1 + numFeatures
        features(i,j - (numAdditional + 1)) = data{1,j}(i);
    end
end