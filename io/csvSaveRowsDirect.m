function csvSaveRowsDirect(filelist, filename, singleTag, singleTagFormat, dataTag)

% CSVSAVEROWSDIRECT
% Saves OCT Meta Data into a csv file, where the single rows correspond
% to an OCT Image
% Parameters:
% filelist: Cell Array of OCT filenames withou ending
% filename: csv filename
% singleTags: Nx2 cell Array. First Column: HE Raw name
% singleTagsFormat: Nx3 cell array. How should the data be written out
%    First Column: headline
%    Second Columns: printf format
%    Third columns: Special Options - Possibilities:
%       'ptoc' - Point to Comma
%       'ptou' - Point to underscore


fcount = 1;
maxfcount = numel(filelist)

data = cell(1,1);

while fcount <= maxfcount;
    line = filelist{fcount};
    
    if ispc()
        idx = strfind(line, '\');
    else
        idx = strfind(line, '/');
    end
    
    dispPathname = line(1:idx(end));
    dispFilename = line(idx(end)+1:end);
    
    idx = strfind(dispFilename, '.');
    dispFilenameWoEnding = dispFilename(1:idx(end));
    
    [numDescriptor openFuncHandle] = examineOctFile(dispPathname, dispFilename);
    if numDescriptor == 0
        disp('Refresh Disp File: File is no OCT file.');
        return;
    end

    [header, BScanHeader] = openFuncHandle([dispPathname dispFilename], 'header');
    
    i = 1;
    while i <= size(singleTag, 1)
        if strcmp(singleTag{i,1}, 'ScanPosition')
            side = header.ScanPosition;
            if findstr('OS', side)
                data{fcount, i} = 1;
            else
                data{fcount, i} = 2;
            end
        elseif strcmp(singleTag{i,1}, 'Version')
            data{fcount, i} = header.Version;
        elseif strcmp(singleTag{i,1}, 'SizeX')
            data{fcount, i} = header.SizeX;
        elseif strcmp(singleTag{i,1}, 'NumBScans')
            data{fcount, i} = header.NumBScans;
        elseif strcmp(singleTag{i,1}, 'SizeZ')
            data{fcount, i} = header.SizeZ;
        elseif strcmp(singleTag{i,1}, 'ScaleX')
            data{fcount, i} = header.ScaleX;
        elseif strcmp(singleTag{i,1}, 'Distance')
            data{fcount, i} = header.Distance;
        elseif strcmp(singleTag{i,1}, 'ScaleZ')
            data{fcount, i} = header.ScaleZ;
        elseif strcmp(singleTag{i,1}, 'SizeXSlo')
            data{fcount, i} = header.SizeXSlo;
        elseif strcmp(singleTag{i,1}, 'SizeYSlo')
            data{fcount, i} = header.SizeYSlo;
        elseif strcmp(singleTag{i,1}, 'ScaleXSlo')
            data{fcount, i} = header.ScaleXSlo;
        elseif strcmp(singleTag{i,1}, 'ScaleYSlo')
            data{fcount, i} = header.ScaleYSlo;
        elseif strcmp(singleTag{i,1}, 'FieldSizeSlo')
            data{fcount, i} = header.FieldSizeSlo;
        elseif strcmp(singleTag{i,1}, 'ScanFocus')
            data{fcount, i} = header.ScanFocus;
        elseif strcmp(singleTag{i,1}, 'ExamTime')
            data{fcount, i} = datestr(header.ExamTime(1)/(1e7*60*60*24)+584755+(2/24));
        elseif strcmp(singleTag{i,1}, 'ScanPattern')
            data{fcount, i} = header.ScanPattern;
        elseif strcmp(singleTag{i,1}, 'BScanHdrSize')
            data{fcount, i} = header.BScanHdrSize;
        elseif strcmp(singleTag{i,1}, 'ID')
            data{fcount, i} = header.ID;
        elseif strcmp(singleTag{i,1}, 'ReferenceID')
            data{fcount, i} = header.ReferenceID;
        elseif strcmp(singleTag{i,1}, 'PID')
            data{fcount, i} = header.PID;
        elseif strcmp(singleTag{i,1}, 'PatientID')
            data{fcount, i} = header.PatientID;
        elseif strcmp(singleTag{i,1}, 'DOB')
            data{fcount, i} = datestr(header.DOB+693960);
        elseif strcmp(singleTag{i,1}, 'VID')
            data{fcount, i} = header.VID;
        elseif strcmp(singleTag{i,1}, 'VisitID')
            data{fcount, i} = header.VisitID;
        elseif strcmp(singleTag{i,1}, 'VisitDate')
            data{fcount, i} = datestr(header.VisitDate+693960);
        elseif strcmp(singleTag{i,1}, 'GridType')
            data{fcount, i} = header.GridType;
        elseif strcmp(singleTag{i,1}, 'GridOffset')
            data{fcount, i} = header.GridOffset;
        end
        
        if header.NumBScans == 1
            if strcmp(singleTag{i,1}, 'StartX')
                data{fcount, i} = BScanHeader.StartX;
            elseif strcmp(singleTag{i,1}, 'StartY')
                data{fcount, i} = BScanHeader.StartY;
            elseif strcmp(singleTag{i,1}, 'EndX')
                data{fcount, i} = BScanHeader.EndX;
            elseif strcmp(singleTag{i,1}, 'EndY')
                data{fcount, i} = BScanHeader.EndY;
            elseif strcmp(singleTag{i,1}, 'NumSeg')
                data{fcount, i} = BScanHeader.NumSeg;
            elseif strcmp(singleTag{i,1}, 'Quality')
                data{fcount, i} = BScanHeader.Quality;
            elseif strcmp(singleTag{i,1}, 'Shift')
                data{fcount, i} = BScanHeader.Shift;
            end
        else
            if strcmp(singleTag{i,1}, 'StartX') || strcmp(singleTag{i,1}, 'EndX') || ...
                    strcmp(singleTag{i,1}, 'EndY') ||   strcmp(singleTag{i,1}, 'NumSeg') || ...
                    strcmp(singleTag{i,1}, 'Quality') ||  strcmp(singleTag{i,1}, 'Shift')
                data{fcount, i} = 0;
            end
        end
        
        i = i + 1;
    end  
  
    fcount = fcount + 1;
end
fcount = fcount - 1;

% Write out data in a csv file
fido = fopen([filename], 'w');

% Number for counting the data sets
fprintf(fido, 'Nr');
for j = 1:size(singleTag, 1)
    fprintf(fido, ['\t' singleTagFormat{j, 1}]);    
end
fprintf(fido, '\n');


for i = 1:fcount
    fprintf(fido, '%d', i);
    j = 1;
    while j <= size(singleTag, 1)
        temp = sprintf(['\t' singleTagFormat{j, 2}],  data{i, j});
        
        if strfind(singleTagFormat{j, 3}, 'ptoc')
            k = strfind(temp, '.');
            temp(k) = ',';
        elseif  strfind(singleTagFormat{j, 3}, 'ptou')
            k = strfind(temp, '.');
            temp(k) = '_';
        end
        
        fprintf(fido, '%s',  temp);
        j = j + 1;
    end
    fprintf(fido, '\n');   
end

fclose(fido);