function [filenameList filenameWithoutEnding] = createFileNameList(dispFilename, dispPathname, actHeader)
% CREATEFILENAMELIST
% Creates the flenamelist/filename out of dispPathname and dispFilename
% Suitable only for guiMode 1
% It stores a list with the original filename followed by
% an "_XXX" extension representing the BScan # for volumes.
% For lists, it creates the filenamelist without endings.

% Find out the file ending
[token, remain] = strtok(dispFilename, '.');
while numel(remain) ~= 0
    [token, remain] = strtok(remain, '.');
end
filenameEnding = token;

if strcmp(filenameEnding, 'vol')
    filenameWithoutEnding = [dispFilename(1:end-(numel(filenameEnding) +1))];
    
    filenameList = cell(actHeader.NumBScans, 1);
    
    for i = 1:actHeader.NumBScans
        if i < 10
            filenameBScan = [filenameWithoutEnding '_00' num2str(i)];
        elseif i < 100
            filenameBScan = [filenameWithoutEnding '_0' num2str(i)];
        else
            filenameBScan = [filenameWithoutEnding '_' num2str(i)];
        end
        
        filenameList{i,1} = filenameBScan;
    end
elseif strcmp(filenameEnding, 'list')
    filenameList = cell(1,1);
    fid = fopen([dispPathname dispFilename], 'r');
    filename = fgetl(fid);
    fcount = 0;
    while ischar(filename)
        fcount = fcount + 1;
        [token, remain] = strtok(filename, '.');
        while numel(remain) ~= 0
            [token, remain] = strtok(remain, '.');
        end
        filenameEnding = token;
        
        filenameWithoutEnding = [filename(1:end-(numel(filenameEnding) +1))];
        filenameList{fcount,1} = filenameWithoutEnding;
        filename = fgetl(fid);
    end
    fclose(fid);
else 
    filenameWithoutEnding = [dispFilename(1:end-(numel(filenameEnding) +1))];
    filenameList = cell(1, 1);
    filenameList{1} = filenameWithoutEnding;
end

end