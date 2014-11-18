function [featuresGroup, classesGroup, additionalGroup] = selectGroup(features, classes, additional, GroupOptions)
% Selects only certain datasets from the dataset. 
% Options in GroupOptions are:
% classBased: 0 when valid is an vector of dataset indices, 1 when the
% certain classes should be selected.
% valid: When classBased is 0, a vector of indices. When it is 1, a vector
% containing the classes that should be selected.

valid = false(size(classes));

% Construct the logical vector of which the datasets should be returned.
if GroupOptions.classBased 
    for i = 1:numel(GroupOptions.valid)
        validAdder = classes == GroupOptions.valid(i);
        validCount = sum(double(validAdder));
        disp(['Group ' num2str(GroupOptions.valid(i)) ' has ' num2str(validCount) ' datasets.']);
        valid = valid | validAdder;
    end
else
    valid(GroupOptions.valid) = true(size(GroupOptions.valid));
end
    
disp(['In total: ' num2str(sum(double(valid)))]);

% Construct the return values, that only contain the selected datasets.
classesGroup = classes(valid);
featuresGroup = features(valid, :);

numEntries = sum(double(valid));
additionalGroup = cell(numEntries, size(additional, 2));

count = 1;
for i = 1:numel(valid)
    if valid(i)
        for k = 1:size(additional, 2)
            additionalGroup{count, k} = additional{i, k};
        end
        count = count + 1;
    end
end

end