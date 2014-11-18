function success = writeCompleteOctMeta(path, header, BScanHeader, options, name)
% WRITECOMPLETEOCTMETA Writes the basic oct meta data into a new file
% The file is only written out if no meta file with that name exists (a
% force option overrides this behaviour).
% SUCCESS = writeCompleteOctMeta(PATH, HEADER, BSCANHEADER, SLO, BSCANS, OPTIONS)
% PATH: The meta filename path, including the directory without the .meta
%       ending
% HEADER: The OCT header information (see openVol)
% BSCANHEADER: The OCT BScan header information (see openVol)
% OPTIONS: A string with options. Possible options are:
%   'force': A existing meta file is replaces
%   'noheader': no header nor BScan header information is written out
%   'octseg': Various meta tags used in the OCTSEG environment are written
%             out and set to their default value
%   'binary': Write a binary meta file instead of text
% NAME: Optional. Name of the current evaluator.
% SUCCESS: If the file was written out or replaced, 1 is returned, 0 else


% Default parameters
if nargin < 4
    options = '';
end
if nargin < 5
    name = '';
end

binMode = 1;
if numel(strfind(options, 'binary')) == 0
    binMode = 0;
end

success = 0;

if((exist([path '.meta'], 'file') == 0) || numel(strfind(options, 'force')) ~= 0)
    fidW = fopen([path '.meta'], 'w');
    
    if numel(strfind(options, 'binary')) ~= 0
        fprintf(fidW, 'BINARY META FILE\n');
    end
    
    if numel(strfind(options, 'noheader')) == 0
        metaWriteHelper(fidW, 'ExamTime', header.ExamTime, 'num', binMode);
        metaWriteHelper(fidW, 'ScanFocus', header.ScanFocus, 'num', binMode);
        metaWriteHelper(fidW, 'ScanPosition', header.ScanPosition, 'str', binMode);
        metaWriteHelper(fidW, 'ScanPattern', header.ScanPattern(), 'num', binMode);
        metaWriteHelper(fidW, 'ID', header.ID, 'str', binMode);
        metaWriteHelper(fidW, 'ReferenceID', header.ReferenceID, 'str', binMode);
        metaWriteHelper(fidW, 'PID', header.PID(), 'num', binMode);
        metaWriteHelper(fidW, 'PatientID', header.PatientID, 'str', binMode);
        metaWriteHelper(fidW, 'DOB', header.DOB, 'num', binMode);
        metaWriteHelper(fidW, 'VID', header.VID, 'num', binMode);
        metaWriteHelper(fidW, 'VisitID', header.VisitID, 'str', binMode);
        metaWriteHelper(fidW, 'VisitDate', header.VisitDate, 'num', binMode);
        metaWriteHelper(fidW, 'OctSize', [header.SizeX header.SizeZ header.NumBScans], 'num', binMode);
        metaWriteHelper(fidW, 'OctScale', [header.ScaleX header.ScaleZ header.Distance], 'num', binMode);
        metaWriteHelper(fidW, 'SloSize', [header.SizeXSlo header.SizeYSlo], 'num', binMode);
        metaWriteHelper(fidW, 'SloScale', [header.ScaleXSlo header.ScaleYSlo], 'num', binMode);
        metaWriteHelper(fidW, 'SloFieldSize', header.FieldSizeSlo, 'num', binMode);
        metaWriteHelper(fidW, 'BScanStartX', BScanHeader.StartX, 'num', binMode);
        metaWriteHelper(fidW, 'BScanStartY', BScanHeader.StartY, 'num', binMode);
        metaWriteHelper(fidW, 'BScanEndX', BScanHeader.EndX, 'num', binMode);
        metaWriteHelper(fidW, 'BScanEndY', BScanHeader.EndY, 'num', binMode);  
    end
    
    if numel(strfind(options, 'octseg')) ~= 0
        metaWriteHelper(fidW, 'OCTSEG', 1, 'num', binMode);
        metaWriteHelper(fidW, [name 'RPEauto'], 0, 'num', binMode);
        metaWriteHelper(fidW, [name 'RPEman'], 0, 'num', binMode);
        metaWriteHelper(fidW, [name 'INFLauto'], 0, 'num', binMode);
        metaWriteHelper(fidW, [name 'INFLman'], 0, 'num', binMode);
        metaWriteHelper(fidW, [name 'ONFLauto'], 0, 'num', binMode);
        metaWriteHelper(fidW, [name 'ONFLman'], 0, 'num', binMode);
    end
    
    fclose( fidW );
    success = 1;
end

end

function metaWriteHelper(fidW, tag, data, mode, binMode)
    if binMode
        binWriteHelper(fidW, tag, data);
    else
        textWriteHelper(fidW, tag, data, mode);
    end
end

function textWriteHelper(fidW, tag, data, mode)
    if nargin < 4
        mode = 'num';
    end

    if strcmp(mode, 'num')
        str = sprintf('%g ', data);
    else
        str = sprintf('%s ', data);
    end

    outputstring = [tag ' ' str];
    outputstring = deblank(outputstring);

    fprintf(fidW, '%s\n', outputstring);
end

function binWriteHelper(fid, mode, data)
    fwrite(fid, uint32(numel(mode)), 'uint32');
    fwrite(fid, uint32(numel(data)), 'uint32');
    if ischar(data)
        fwrite(fid, 1, 'uint8');
        fwrite(fid, mode, 'char');
        fwrite(fid, data, 'char');
    else
        fwrite(fid, 0, 'uint8');
        fwrite(fid, mode, 'char');
        fwrite(fid, data, 'double');
    end
end