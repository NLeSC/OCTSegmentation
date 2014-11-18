function data = readOctMetaVolume(ActDataDescriptors, tag)
% READOCTMETAVOLUME Reads the meta of each A-Scan data of a complete volume
% (if available) and returns a 2D array

data = zeros(ActDataDescriptors.Header.NumBScans, ActDataDescriptors.Header.SizeX, 'double');
for i = 1:numel(ActDataDescriptors.filenameList)
    metaData = readOctMeta([ActDataDescriptors.pathname ActDataDescriptors.filenameList{i}], ...
                           [ActDataDescriptors.evaluatorName tag 'Data']);
    if numel(metaData) == ActDataDescriptors.Header.SizeX
        data(i,:) = metaData;
    end
end

