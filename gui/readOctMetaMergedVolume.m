function data = readOctMetaMergedVolume(DataDescriptors, tags)
% READOCTMETAMERGEDVOLUME: Helper for reading metaData for the segment
% functions in octsegMain from a volume
% Reads the manual-Data if available, otherwise the auto-Data
% DataDescriptors: see octsegMain
% tags: Cell structure, created by getMetaTag if type 'both...' is used

data = zeros(DataDescriptors.Header.NumBScans, DataDescriptors.Header.SizeX, 'double');
for i = 1:DataDescriptors.Header.NumBScans
    temp  = readOctMetaMerged(DataDescriptors, tags, i);
    if numel(temp) ~= 0
        data(i,:) = readOctMetaMerged(DataDescriptors, tags, i);
    else
        disp('Meta data load failed!');
        return;
    end
end
