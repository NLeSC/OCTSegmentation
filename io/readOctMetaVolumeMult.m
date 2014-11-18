function data = readOctMetaVolumeMult(ActDataDescriptors, tag, number)
% READOCTMETAVOLUME Reads the meta of each A-Scan data of a complete volume
% (if available) and returns a 2D array

data = zeros(ActDataDescriptors.Header.NumBScans, ActDataDescriptors.Header.SizeX, number, 'double');
for i = 1:numel(ActDataDescriptors.filenameList)
    metaData = readOctMeta([ActDataDescriptors.pathname ActDataDescriptors.filenameList{i}], ...
        [ActDataDescriptors.evaluatorName tag 'Data']);
    
    
    
    if numel(metaData) == ActDataDescriptors.Header.SizeX * number
        metaDataFormat = zeros(1, ActDataDescriptors.Header.SizeX, number, 'double');
        for n = 1:number
            metaDataFormat(1, :, n) = metaData((((n - 1) * ActDataDescriptors.Header.SizeX) + 1): ...
                (((n - 1) * ActDataDescriptors.Header.SizeX) + ActDataDescriptors.Header.SizeX));
        end
        data(i,:,:) = metaDataFormat;
    end
    
end

