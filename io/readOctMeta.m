function output = readOctMeta(filename, mode, typemode)
%READOCTMETA Read meta information from a OCTSEG meta file
% OUTPUT = readOctMeta(FILENAME, MODE, TYPEMODE)
% Reads data from a meta file.
% FILENAME: Name of the metafile without ".meta" ending
% MODE: Name of the metatag to read
% TYPEMODE (OPTIONAL): Determines if the output is a number or string
%   Options:
%   'num' (default): Number as output
%   'str': String as output
%
% Structure of the meta file ahould be:
% Each line consists of a tag (= MODE) followed by one or more data values
% separated by a whitespace
%
% Author: Markus A. Mayer, Pattern Recognition Lab,
%   University of Erlangen-Nuremberg
% First final Version: May 2010

if nargin < 3
    typemode = 'num';
end

output = [];
fid = fopen([filename '.meta'], 'r');

if fid == -1
    return;
end

modeTemp = 'temp';
line = fgetl(fid);

if strcmp(line, 'BINARY META FILE') % Binary meta file
    while ~feof(fid) && numel(modeTemp) ~= 0
        [modeTemp dataTemp] = binReadHelper(fid);
        if strcmp(modeTemp, mode)     
            output = dataTemp;
            break;
        end
    end
else
    while ischar(line) % Text meta file (standard)
        [des rem] = strtok(line);
        if strcmp(des, mode)
            if strcmp(typemode, 'str')
                output = rem;
            else
                output = str2num(rem);
            end
            break;
        end
        line = fgetl(fid);
    end
end

fclose(fid);
end

function [mode data] = binReadHelper(fid)
    numMode = fread(fid, 1, 'uint32');
    numData = fread(fid, 1, 'uint32');
    typeData = fread(fid, 1, 'uint8');
    
    if numel(numMode) == 0 || numel(numData) == 0 || numel(typeData) == 0
        mode = [];
        data = [];
        return;
    end
    
    mode = char(fread(fid, numMode, 'uint8'))';
    
    if typeData == 0
        data = fread(fid, numData, 'float64')';
    else
        data = char(fread(fid, numData, 'uint8'))';
    end
end