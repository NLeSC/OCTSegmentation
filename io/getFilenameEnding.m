function filenameEnding = getFilenameEnding(filename)
% GETFILENAMEENDING: Returns the filename ending of the filename without 
% the '.'.

[token, remain] = strtok(filename, '.');
while numel(remain) ~= 0
    [token, remain] = strtok(remain, '.');
end

filenameEnding = token;