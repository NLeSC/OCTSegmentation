function csvSaveColumnsDirectBScans(filelist, filename, singleTag, singleTagFormat, dataTag, dataTagFormat)

% CSVSAVECOLUMNS
% Saves OCT Meta Data into a csv file, where the single columns correspond
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
% dataTag (optional): Data tag name (Only available: HE Segmentation Tags,
%      or BScan values when Volume Scans are used)
% dataTagFormat (optional): Data tag format
%       in addition to the singleTagsFormat: 'interp' - interpolates the
%       data to 768 values

% Evaluator name is stored. Currently set to a default variable, but all
% functions are prepared to be used with multiple evaluators.
actName = 'Default';

fcount = 1;
maxfcount = numel(filelist);

data = cell(1,1);
filenameList = cell(1,1);

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
    dispFilenameWoEnding = dispFilename(1:idx(end)-1);
    filenameList{fcount} = dispFilenameWoEnding;
    
    [numDescriptor openFuncHandle] = examineOctFile(dispPathname, dispFilename);
    if numDescriptor == 0
        disp('Refresh Disp File: File is no OCT file.');
        return;
    end

    %[header, BScanHeader] = openFuncHandle([dispPathname dispFilename], 'header');
    [header, BScanHeader, slo, bScans] = openFuncHandle([dispPathname dispFilename], '');
    
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
    
    if numel(dataTag) ~= 0
        if strcmp(dataTag, 'StartX')
            data{fcount, i} = BScanHeader.StartX;
        elseif strcmp(dataTag, 'StartY')
            data{fcount, i} = BScanHeader.StartY;
        elseif strcmp(dataTag, 'EndX')
            data{fcount, i} = BScanHeader.EndX;
        elseif strcmp(dataTag, 'EndY')
            data{fcount, i} = BScanHeader.EndY;
        elseif strcmp(dataTag, 'NumSeg')
            data{fcount, i} = BScanHeader.NumSeg;
        elseif strcmp(dataTag, 'Quality')
            data{fcount, i} = BScanHeader.Quality;
        elseif strcmp(dataTag, 'Shift')
            data{fcount, i} = BScanHeader.Shift;
        elseif strcmp(dataTag, 'ILMHE')
            data{fcount, i} = BScanHeader.ILM;
        elseif strcmp(dataTag, 'RPEHE')
            data{fcount, i} = BScanHeader.RPE;
        elseif strcmp(dataTag, 'ONFLHE')
            data{fcount, i} = BScanHeader.NFL;
        elseif strcmp(dataTag, 'RetinaHE')
            ilm = BScanHeader.ILM;
            rpe = BScanHeader.RPE;
            if numel(ilm) == numel(rpe)           
                data{fcount, i} = (ilm - rpe) * header.ScaleZ * 1000;
            end
        elseif strcmp(dataTag, 'RNFLHE')
            ilm = BScanHeader.ILM;
            nfl = header.SizeZ - BScanHeader.NFL;
            if numel(ilm) == numel(nfl)           
                data{fcount, i} = (ilm - nfl) * header.ScaleZ * 1000;
            end
        elseif strcmp(dataTag, 'ILMOCTSEG') 
            data{fcount, i} = readData('INFLautoData', 'INFLmanData', dispPathname, dispFilenameWoEnding);
        elseif strcmp(dataTag, 'RPEOCTSEG')  
            data{fcount, i} = readData('RPEautoData', 'RPEmanData', dispPathname, dispFilenameWoEnding);
        elseif strcmp(dataTag, 'ONFLOCTSEG')  
            data{fcount, i} = readData('ONFLautoData', 'ONFLmanData', dispPathname, dispFilenameWoEnding);
        elseif strcmp(dataTag, 'ICLOCTSEG')  
            data{fcount, i} = readData('ICLautoData', 'ICLmanData', dispPathname, dispFilenameWoEnding);
        elseif strcmp(dataTag, 'IPLOCTSEG')  
            data{fcount, i} = readData('IPLautoData', 'IPLmanData', dispPathname, dispFilenameWoEnding);
        elseif strcmp(dataTag, 'OPLOCTSEG')  
            data{fcount, i} = readData('OPLautoData', 'OPLmanData', dispPathname, dispFilenameWoEnding);    
        elseif strcmp(dataTag, 'SKLERAPOS')  
            data{fcount, i} = readData('SkleraAutoData', 'SkleraManData', dispPathname, dispFilenameWoEnding);   
        elseif strcmp(dataTag, 'RetinaOCTSEG')
            ilm = readData('INFLautoData', 'INFLmanData', dispPathname, dispFilenameWoEnding);
            rpe = readData('RPEautoData', 'RPEmanData', dispPathname, dispFilenameWoEnding);
            if numel(ilm) == numel(rpe)           
                data{fcount, i} = (rpe - ilm) * header.ScaleZ * 1000;
            end
        elseif strcmp(dataTag, 'RNFLOCTSEG')
            ilm = readData('INFLautoData', 'INFLmanData', dispPathname, dispFilenameWoEnding);
            nfl = readData('ONFLautoData', 'ONFLmanData', dispPathname, dispFilenameWoEnding);
            if numel(ilm) == numel(nfl)           
                data{fcount, i} = (nfl - ilm) * header.ScaleZ * 1000;
            end
        elseif strcmp(dataTag, 'RPEPHOTOOCTSEG')
            icl = readData('ICLautoData', 'ICLmanData', dispPathname, dispFilenameWoEnding);
            rpe = readData('RPEautoData', 'RPEmanData', dispPathname, dispFilenameWoEnding);
            if numel(icl) == numel(rpe)
                data{fcount, i} = (rpe - icl) * header.ScaleZ * 1000;
            end
        elseif strcmp(dataTag, 'OUTERNUCLEAROOCTSEG')
            icl = readData('ICLautoData', 'ICLmanData', dispPathname, dispFilenameWoEnding);
            opl = readData('OPLautoData', 'OPLmanData', dispPathname, dispFilenameWoEnding);
            if numel(icl) == numel(opl)
                data{fcount, i} = (icl - opl) * header.ScaleZ * 1000;
            end
        elseif strcmp(dataTag, 'OUTERPLEXIINNERNUCLEAROOCTSEG')
            ipl = readData('IPLautoData', 'IPLmanData', dispPathname, dispFilenameWoEnding);
            opl = readData('OPLautoData', 'OPLmanData', dispPathname, dispFilenameWoEnding);
            if numel(ipl) == numel(opl)
                data{fcount, i} = (opl - ipl) * header.ScaleZ * 1000;
            end
        elseif strcmp(dataTag, 'INNERPLEXGANGLIONOOCTSEG')
            ipl = readData('IPLautoData', 'IPLmanData', dispPathname, dispFilenameWoEnding);
            nfl = readData('ONFLautoData', 'ONFLmanData', dispPathname, dispFilenameWoEnding);
            if numel(nfl) == numel(ipl)
                data{fcount, i} = (ipl - nfl) * header.ScaleZ * 1000;
            end    
        elseif strcmp(dataTag, 'SKLERATHICK')
            sklera = readData('SkleraAutoData', 'SkleraManData', dispPathname, dispFilenameWoEnding);   
            rpe = readData('RPEautoData', 'RPEmanData', dispPathname, dispFilenameWoEnding);
            if numel(sklera) == numel(rpe)           
                data{fcount, i} = (sklera - rpe) * header.ScaleZ * 1000;
            end
        elseif strcmp(dataTag, 'BVPOSOCTSEG')
            data{fcount, i} = readData('BVautoData', 'BVmanData', dispPathname, dispFilenameWoEnding);
            
        elseif strcmp(dataTag, 'REFLECTIONRNFL')
            ilm = readData('INFLautoData', 'INFLmanData', dispPathname, dispFilenameWoEnding);
            nfl = readData('ONFLautoData', 'ONFLmanData', dispPathname, dispFilenameWoEnding);
            if numel(ilm) == numel(nfl)
                data{fcount, i} = getReflection(bScans, ilm, nfl);
            end   
        elseif strcmp(dataTag, 'REFLECTIONRPE')
            rpe = readData('RPEautoData', 'RPEmanData', dispPathname, dispFilenameWoEnding);
            data{fcount, i} = getReflection(bScans, rpe, dataTagFormat{1, 4});    
        end
    end
    
    fcount = fcount + 1;
end
fcount = fcount - 1;


% Write out data in a csv file
fido = fopen([filename], 'w');

% Number for counting the data sets
fprintf(fido, 'Nr');
for i = 1:fcount
    fprintf(fido, '\t%d', i);
end
fprintf(fido, '\n');

% Filenames
fprintf(fido, 'filename');
for i = 1:fcount
    fprintf(fido, '\t%s', filenameList{i});
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

if (numel(dataTagFormat) > 1) && numel(strfind(dataTagFormat{1, 3}, 'round')) > 0
    for i = 1:fcount
        data{i, j} = round(data{i, j});
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