function csvSaveColumnsDirectVolume(dispPathname, dispFilename, actFilenameList, csvName, singleTag, singleTagFormat, dataTag, dataTagFormat)

% CSVSAVECOLUMNS
% Saves OCT Meta Data into a csv file, where the single columns correspond
% to a B-Scan of a OCT Volume
% Parameters:
% dispPathname: Path to the volume
% dispFilename: Volume name (including the ending)
% actFilenamelist: Filenamelist of the B-Scan meta files
% csvName: csv filename
% singleTags: Nx2 cell Array. First Column: HE Raw name
% singleTagsFormat: Nx3 cell array. How should the data be written out
%    First Column: headline
%    Second Columns: printf format
%    Third columns: Special Options - Possibilities:
%       'ptoc' - Point to Comma
%       'ptou' - Point to underscore
% dataTag (optional): Data tag name (Only available: HE Segmentation Tags,
%      or BScan values when Volume Scans are used)
% dataTagFormat (optional): Data tag format
%       in addition to the singleTagsFormat: 'interp' - interpolates the
%       data to 768 values

% Evaluator name is stored. Currently set to a default variable, but all
% functions are prepared to be used with multiple evaluators.
actName = 'Default';

fcount = 1;
maxfcount = numel(actFilenameList)

data = cell(1,1);

idx = strfind(dispFilename, '.');
dispFilenameWoEnding = dispFilename(1:idx(end));


[numDescriptor openFuncHandle] = examineOctFile(dispPathname, dispFilename);
if numDescriptor == 0
    disp('Refresh Disp File: File is no OCT file.');
    return;
end

[header, BScanHeader] = openFuncHandle([dispPathname dispFilename], 'header');

while fcount <= maxfcount;
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
        elseif strcmp(singleTag{i,1}, 'StartX')
            data{fcount, i} = BScanHeader.StartX(fcount);
        elseif strcmp(singleTag{i,1}, 'StartY')
            data{fcount, i} = BScanHeader.StartY(fcount);
        elseif strcmp(singleTag{i,1}, 'EndX')
            data{fcount, i} = BScanHeader.EndX(fcount);
        elseif strcmp(singleTag{i,1}, 'EndY')
            data{fcount, i} = BScanHeader.EndY(fcount);
        elseif strcmp(singleTag{i,1}, 'NumSeg')
            data{fcount, i} = BScanHeader.NumSeg(fcount);
        elseif strcmp(singleTag{i,1}, 'Quality')
            data{fcount, i} = BScanHeader.Quality(fcount);
        elseif strcmp(singleTag{i,1}, 'Shift')
            data{fcount, i} = BScanHeader.Shift(fcount);
        end
        
        i = i + 1;
    end
    fcount = fcount + 1;
end

if numel(dataTag) ~= 0
    fcount = 1;
    while fcount <= maxfcount;
        if strcmp(dataTag, 'ILMHE')
            data{fcount, i} = BScanHeader.ILM(fcount, :);
        elseif strcmp(dataTag, 'RPEHE')
            data{fcount, i} = BScanHeader.RPE(fcount, :);
        elseif strcmp(dataTag, 'ONFLHE')
            data{fcount, i} = BScanHeader.NFL(fcount, :);
        elseif strcmp(dataTag, 'RetinaHE')
            ilm = BScanHeader.ILM(fcount, :);
            rpe = BScanHeader.RPE(fcount, :);
            if numel(ilm) == numel(rpe)
                data{fcount, i} = (ilm - rpe) * header.ScaleZ * 1000;
            end
        elseif strcmp(dataTag, 'RNFLHE')
            ilm = BScanHeader.ILM(fcount, :);
            nfl = BScanHeader.NFL(fcount, :);
            if numel(ilm) == numel(nfl)
                data{fcount, i} = (ilm - nfl) * header.ScaleZ * 1000;
            end
        elseif strcmp(dataTag, 'ILMOCTSEG')
            data{fcount, i} = readData('INFLautoData', 'INFLmanData', dispPathname, actFilenameList{fcount});
        elseif strcmp(dataTag, 'RPEOCTSEG')
            data{fcount, i} = readData('RPEautoData', 'RPEmanData', dispPathname, actFilenameList{fcount});
        elseif strcmp(dataTag, 'ONFLOCTSEG')
            data{fcount, i} = readData('ONFLautoData', 'ONFLmanData', dispPathname, actFilenameList{fcount});
        elseif strcmp(dataTag, 'ICLOCTSEG')
            data{fcount, i} = readData('ICLautoData', 'ICLmanData', dispPathname, actFilenameList{fcount});
        elseif strcmp(dataTag, 'IPLOCTSEG')
            data{fcount, i} = readData('IPLautoData', 'IPLmanData', dispPathname, actFilenameList{fcount});
        elseif strcmp(dataTag, 'OPLOCTSEG')
            data{fcount, i} = readData('OPLautoData', 'OPLmanData', dispPathname, actFilenameList{fcount});
        elseif strcmp(dataTag, 'SKLEARAPOS')
            data{fcount, i} = readData('SkleraAutoData', 'SkleraManData', dispPathname, actFilenameList{fcount});
        elseif strcmp(dataTag, 'RetinaOCTSEG')
            ilm = readData('INFLautoData', 'INFLmanData', dispPathname, actFilenameList{fcount});
            rpe = readData('RPEautoData', 'RPEmanData', dispPathname, actFilenameList{fcount});
            if numel(ilm) == numel(rpe)
                data{fcount, i} = (rpe - ilm) * header.ScaleZ * 1000;
            end
        elseif strcmp(dataTag, 'RNFLOCTSEG')
            ilm = readData('INFLautoData', 'INFLmanData', dispPathname, actFilenameList{fcount});
            nfl = readData('ONFLautoData', 'ONFLmanData', dispPathname, actFilenameList{fcount});
            if numel(ilm) == numel(nfl)
                data{fcount, i} = (nfl - ilm) * header.ScaleZ * 1000;
            end
        elseif strcmp(dataTag, 'RPEPHOTOOCTSEG')
            icl = readData('ICLautoData', 'ICLManData', dispPathname, actFilenameList{fcount});
            rpe = readData('RPEautoData', 'RPEmanData', dispPathname, actFilenameList{fcount});
            if numel(icl) == numel(rpe)
                data{fcount, i} = (rpe - icl) * header.ScaleZ * 1000;
            end
        elseif strcmp(dataTag, 'OUTERNUCLEAROOCTSEG')
            icl = readData('ICLautoData', 'ICLManData', dispPathname, actFilenameList{fcount});
            opl = readData('OPLautoData', 'OPLmanData', dispPathname, actFilenameList{fcount});
            if numel(icl) == numel(opl)
                data{fcount, i} = (icl - opl) * header.ScaleZ * 1000;
            end
        elseif strcmp(dataTag, 'OUTERPLEXIINNERNUCLEAROOCTSEG')
            ipl = readData('IPLautoData', 'IPLManData', dispPathname, actFilenameList{fcount});
            opl = readData('OPLautoData', 'OPLmanData', dispPathname, actFilenameList{fcount});
            if numel(ipl) == numel(opl)
                data{fcount, i} = (opl - ipl) * header.ScaleZ * 1000;
            end
        elseif strcmp(dataTag, 'INNERPLEXGANGLIONOOCTSEG')
            ipl = readData('IPLautoData', 'IPLManData', dispPathname, actFilenameList{fcount});
            nfl = readData('ONFLautoData', 'ONFLmanData', dispPathname, actFilenameList{fcount});
            if numel(nfl) == numel(ipl)
                data{fcount, i} = (ipl - nfl) * header.ScaleZ * 1000;
            end
        elseif strcmp(dataTag, 'SKLERATHICK')
            sklera = readData('SkleraAutoData', 'SkleraManData', dispPathname, actFilenameList{fcount});
            rpe = readData('RPEautoData', 'RPEmanData', dispPathname, actFilenameList{fcount});
            if numel(sklera) == numel(rpe)
                data{fcount, i} = (sklera - rpe) * header.ScaleZ * 1000;
            end
        end
        
        fcount = fcount + 1;
    end
end

fcount = fcount - 1;

% Write out data in a csv file
fido = fopen([csvName], 'w');

% Number for counting the data sets
fprintf(fido, 'Nr');
for i = 1:fcount
    fprintf(fido, '\t%d', i);
end
fprintf(fido, '\n');


j = 1;
while j <= size(singleTag, 1)
    % patnr
    fprintf(fido, singleTagFormat{j, 1});
    for i = 1:fcount
        temp = sprintf(['\t' singleTagFormat{j, 2}],  data{i, j});
        
        if strfind(singleTagFormat{j, 3}, 'ptoc')
            k = strfind(temp, '.');
            temp(k) = ',';
        elseif  strfind(singleTagFormat{j, 3}, 'ptou')
            k = strfind(temp, '.');
            temp(k) = '_';
        end
        
        fprintf(fido, '%s',  temp);
    end
    fprintf(fido, '\n');
    j = j + 1;
end

% Interpolate data to 768 values (optional)
if (numel(dataTagFormat) > 1) && numel(strfind(dataTagFormat{1, 3}, 'interp')) > 0
    bscanwidth = 768;
    for i = 1:fcount
        scalingFactor = (bscanwidth - 1) / (numel(data{i, j}) - 1);
        data{i, j} = interp1(1:scalingFactor:bscanwidth,data{i, j},1:bscanwidth,'linear');
    end
end

if numel(dataTag) ~= 0
    for k = 1:numel(data{1, j})
        if k < 10
            fprintf(fido, [dataTagFormat{1,1} '_00' num2str(k)]);
        elseif k < 100
            fprintf(fido, [dataTagFormat{1,1} '_0' num2str(k)]);
        else
            fprintf(fido, [dataTagFormat{1,1} '_' num2str(k)]);
        end
        for i = 1:fcount
            if(numel(data{i, j}) ~= 0)
                temp = sprintf(['\t' dataTagFormat{1,2}],  data{i, j}(k));
                
                if strfind(dataTagFormat{1, 3}, 'ptoc')
                    x = strfind(temp, '.');
                    temp(x) = ',';
                elseif  strfind(dataTagFormat{1, 3}, 'ptou')
                    x = strfind(temp, '.');
                    temp(x) = '_';
                end
                
                fprintf(fido, '%s',  temp);
            else
                fprintf(fido, '\t0');
            end
        end
        fprintf(fido, '\n');
    end
end

fclose(fido);

function data = readData(tagAuto, tagMan, pathname, filename)
    data = readOctMeta([pathname filename], [actName tagMan]);
    if numel(data) == 0
        data = readOctMeta([pathname filename], [actName tagAuto]);
    end
end
end