function writeOctMeta(filename, mode, data, typemode)
%WRITEOCTMETA Write meta information to a OCTSEG meta file
% writeOctMeta(FILENAME, MODE, DATA, TYPEMODE)
% Writes data to a meta file.
% FILENAME: Name of the metafile without ".meta" ending
% MODE: Name of the metatag to write
% DATA: Data to write
% TYPEMODE (OPTIONAL): Determines if the data is writen
%   as a number or string
%   Options:
%   'num' (default): Write as number
%   'str': Write as string
%
% Structure of the meta file ahould be:
% Each line consists of a tag (= MODE) followed by one or more data values
% separated by a whitespace
%
% Behaviour: If the tag already exists, the data is replaced. Else the data
% tag is created at the end of the meta file
% A temporary file is created during the writing process, so the user needs
% to have file write permission.
%
% Author: Markus A. Mayer, Pattern Recognition Lab,
%   University of Erlangen-Nuremberg
% Modified by: Kris Sheets, Retinal Cell Biology Lab, Neuroscience Center 
%   of Excellence, LSU Health Sciences Center, New Orleans, LA
%
% First final Version: May 2010

% Changelog: 14 July 2011 1215 PST 
% Author: Kris Sheets
% Created fIn and fOut variables to hold filepaths to filename.meta and 
% filename.metaX respectively.  fIn and fOut subsequently used in fidR and
% fidW.  Moreover, fIn, fOut used in modified method of writing meta data 
% to file

%fidR = fopen([filename '.meta'], 'r');
%fidW = fopen([filename '.metaX'], 'wt');

if nargin < 4
    typemode = 'num';
end

fIn = [filename '.meta'];
fOut = [filename '.metaX'];

fidR = fopen(fIn, 'r');
fidW = fopen(fOut, 'wt');

written = 0;

if fidR ~= -1
    line = fgetl(fidR);
    
    if strcmp(line, 'BINARY META FILE') % Binary meta file
        fprintf(fidW, '%s\n', line);
        modeTemp = 'temp';
        while ~feof(fidR) 
            [modeTemp output] = binReadHelper(fidR);
            if numel(modeTemp) == 0
                break;
            end
            
            if strcmp(modeTemp, mode)
                binWriteHelper(fidW, mode, data);
                written = 1;
            else
                binWriteHelper(fidW, modeTemp, output);
            end
        end
        
        if written == 0
            binWriteHelper(fidW, mode, data);
        end
    else % Text meta file
        
        if strcmp(typemode, 'str')
            str = sprintf('%s ', data);
        elseif numel(typemode) ~= 0
            str = sprintf([typemode ' '], data);
        else
            str = sprintf('%d ', data);
        end
        
        outputstring = [mode ' ' str];
        outputstring = deblank(outputstring);
        
        while ischar(line)
            [des rem] = strtok(line);
            if strcmp(des, mode)
                fprintf(fidW, '%s\n', outputstring);
                written = 1;
            else
                fprintf(fidW, '%s\n', line);
            end
            line = fgetl(fidR);
        end
        
        if written == 0
            fprintf(fidW, '%s\n', outputstring);
        end
        
    end
    
    fclose(fidR);
end

fclose(fidW);

% Changelog: 14 July 2011 1215 PST
% Author: Kris Sheets
% Modified file write procedure.  Remmed out usage of system commands.  Now
% using MATLAB's movefile() method to overwrite .meta file with .metaX file
% Because it is a rename operation on .metaX, no .metaX is left to delete.
% Platform shouldn't make a difference in this operation
if ispc     
    movefile(fOut,fIn, 'f');
    %system(['del "' filename '.meta"']);
    %system(['move "' filename '.metaX" "' filename '.meta"']);
else
    movefile(fOut,fIn, 'f');
    %system(['rm -f ' filename '.meta']);
    %system(['mv ' filename '.metaX ' filename '.meta']);
end
end

function binWriteHelper(fid, mode, data)
    fwrite(fid, uint32(numel(mode)), 'uint32');
    fwrite(fid, uint32(numel(data)), 'uint32');
    if ischar(data)
        fwrite(fid, 1, 'uint8');
        fwrite(fid, uint8(mode), 'uint8');
        fwrite(fid, uint8(data), 'uint8');
    else
        fwrite(fid, 0, 'uint8');
        fwrite(fid, uint8(mode), 'uint8');
        fwrite(fid, data, 'float64');
    end
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
