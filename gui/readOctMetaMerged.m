function data = readOctMetaMerged(DataDescriptors, tags, filenameNumber)
% READOCTMETAMERGED: 
% Helper for reading metaData for the segment functions in octsegMain
% reads the manual-Data if available, otherwise the auto-Data
% DataDescriptors: see octsegMain
% tags: Cell structure, created by getMetaTag if type 'both...' is used
% filenameNumber (optional): File in the filenameList if set, otherwise
%   filenameWithoutEnding will be used from the DataDescriptors

if nargin < 3
    dataMan = readOctMeta([DataDescriptors.pathname DataDescriptors.filenameWithoutEnding], ...
        [DataDescriptors.evaluatorName tags{2}]);
else
    dataMan = readOctMeta([DataDescriptors.pathname DataDescriptors.filenameList{filenameNumber, 1}],...
        [DataDescriptors.evaluatorName tags{2}]);
end

if numel(dataMan) ~= 0
    data = dataMan;
else
    if nargin < 3
        data = readOctMeta([DataDescriptors.pathname DataDescriptors.filenameWithoutEnding], ...
            [DataDescriptors.evaluatorName tags{1}]);
    else
        data = readOctMeta([DataDescriptors.pathname DataDescriptors.filenameList{filenameNumber, 1}],...
            [DataDescriptors.evaluatorName tags{1}]);
    end
end
