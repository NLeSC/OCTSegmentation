function [header, BScanHeader, slo, BScans] = openOctList (path, options)
% OPENOCTLIST Reads multiple log scaledimage files. Their absolute paths
%   are listed a text file. An artificial SLO-image is created
%   (en-face view)
% [HEADER, BSCANHEADER, SLO, BSCANS] = OPENOCTList(PATH, OPTIONS)
% This function performs oct 3D volume (xxxx.list) reading. The single
%   B-Scans are stored in 2D log scaled images with standard image endings.
% HEADER: Artificial header information, to make a struct similar
%   to HE .vol files
% BSCANHEADER: B-scan header information.
% SLO: In the case of openOctList, this will be an artificially created
%   en-face view.
% BScans: 3D volume with floating point data of the B-Scans.
%   The data is min-max scaled and the exponent is taken to make it similar
%   to HE .vol files for firther processing.
% PATH: Filename of the list file to read, with ending.
%
% OPTIONS: Various output possibilites,
%   written in the options variable as string text, i.e. 'visu writemeta'
%   Possibilities:
%       metawrite: A metafile with the header and B-scan header information
%           is written out (if it does not exist already)
%       metawriteforce: An existing metafile is replaced
%       header: Only the Header and BScansHeader Information is read,
%            not the image data
%       nodisp: nothing is diplayed during read in
%       nocut: Because its mostly dark, the region below 800 pixel is cut
%           off
%
% Written by Markus Mayer, Pattern Recognition Lab, University of
% Erlangen-Nuremberg
%
% First final Version: August 2010

%% If only one argument is defined
if nargin==1,
    options = 'nocut';
end

cutVal = 600;

%% Open file
flist = cell(1,1);
fid = fopen(path, 'r');
filename = fgetl(fid);
fcount = 0;
while ischar(filename)
    fcount = fcount + 1;
    flist{fcount} = filename;
    filename = fgetl(fid);
end
fclose(fid);
maxfcount = numel(flist);

k = numel(path);

if ispc
    while(k ~= 0 && path(k) ~= '\')
        k = k - 1;
    end
else
    while(k ~= 0 && path(k) ~= '/')
        k = k - 1;
    end
end

pathOnly = path(1:k);

dataFirst = imread([pathOnly flist{1}]);
if size(dataFirst, 3) == 3
    dataFirst = mean(single(dataFirst), 3);
end

%% File header read
header.Version = 0;
header.SizeX = size(dataFirst,2);
header.NumBScans = maxfcount;
header.SizeZ = size(dataFirst,1);
header.SizeXSlo = maxfcount;
header.SizeYSlo = size(dataFirst,2);

if numel(strfind(options, 'header')) == 0
    
    if size(dataFirst,1) < cutVal || numel(strfind(options, 'nocut')) ~= 0
        BScans = zeros(size(dataFirst,1), size(dataFirst,2), maxfcount, 'single');
        BScans(:,:,1) = dataFirst;
    else
        BScans = zeros(cutVal, size(dataFirst,2), maxfcount, 'single');
        BScans(:,:,1) = dataFirst(1:cutVal, :);
        header.SizeZ = cutVal;
    end
    
    for i = 2:maxfcount
        dataAkt = single(imread([pathOnly flist{i}]));
        if size(dataAkt, 3) == 3
            dataAkt = mean(single(dataAkt), 3);
        end
        if size(dataAkt,1) < cutVal ||  numel(strfind(options, 'nocut')) ~= 0
            BScans(:,:,i) = dataAkt;
        else
            BScans(:,:,i) = dataAkt(1:cutVal, :);
        end
    end
    
    BScans = single(BScans);
    BScans = BScans - min(min(min(BScans)));
    BScans = BScans ./ max(max(max(BScans)));
    
    BScans = BScans .^ 4;
    BScans = BScans - min(min(min(BScans)));
    BScans = BScans ./ max(max(max(BScans)));
    
    slo = createEnfaceView(BScans);
    slo = slo - min(min(slo));
    slo = slo ./ max(max(slo));
end

header.ScaleX = 1;
header.Distance = 1;
header.ScaleZ = 0.002;
header.ScaleXSlo = 1;
header.ScaleYSlo = 1;
header.FieldSizeSlo = 0;
header.ScanFocus = 0;
header.ScanPosition = '';
header.ExamTime = 0;
header.ScanPattern = 3;
header.BScanHdrSize = 0;
header.ID = '';
header.ReferenceID = '';
header.PID = 0;
header.PatientID = '';
header.Padding = 0;
header.DOB = 0;
header.VID = 0;
header.VisitID = '';
header.VisitDate = 0;
header.GridType = 0;
header.GridOffset = 0;
header.Spare = 0;

if numel(strfind(options, 'nodisp')) == 0
    disp(['---------------------------------------------']);
    disp(['             SizeX: ' num2str(header.SizeX)]);
    disp(['         NumBScans: ' num2str(header.NumBScans)]);
    disp(['             SizeZ: ' num2str(header.SizeZ)]);
    disp(['          SizeXSlo: ' num2str(header.SizeXSlo)]);
    disp(['          SizeYSlo: ' num2str(header.SizeYSlo)]);
    disp(['---------------------------------------------']);
end

BScanHeader.StartX = zeros(1, header.NumBScans, 'single') + 1;
BScanHeader.StartY = zeros(1, header.NumBScans, 'single') + [size(BScans,3):-1:1];
BScanHeader.EndX = zeros(1, header.NumBScans, 'single') + size(BScans,2);
BScanHeader.EndY = zeros(1, header.NumBScans, 'single') + [size(BScans,3):-1:1];
BScanHeader.NumSeg = zeros(1, header.NumBScans, 'single');
BScanHeader.Quality = zeros(1, header.NumBScans, 'single');
BScanHeader.Shift = zeros(1, header.NumBScans, 'single');
BScanHeader.ILM = zeros(header.NumBScans,header.SizeX, 'single');
BScanHeader.RPE = zeros(header.NumBScans,header.SizeX, 'single');
BScanHeader.NFL = zeros(header.NumBScans,header.SizeX, 'single');


if numel(strfind(options, 'metawrite')) ~= 0
    metafilename = [path(1:end-3) 'meta'];
    
    if((exist(metafilename) == 0) || numel(strfind(options, 'metawriteforce')) ~= 0)
        fidW = fopen(metafilename, 'w');
        
        metaWriteHelper(fidW, 'ExamTime', header.ExamTime);
        metaWriteHelper(fidW, 'ScanFocus', header.ScanFocus);
        metaWriteHelper(fidW, 'ScanPosition', header.ScanPosition, 'str');
        metaWriteHelper(fidW, 'ScanPattern', header.ScanPattern());
        metaWriteHelper(fidW, 'ID', header.ID, 'str');
        metaWriteHelper(fidW, 'ReferenceID', header.ReferenceID, 'str');
        metaWriteHelper(fidW, 'PID', header.PID()  );
        metaWriteHelper(fidW, 'PatientID', header.PatientID, 'str');
        metaWriteHelper(fidW, 'DOB', header.DOB);
        metaWriteHelper(fidW, 'VID', header.VID);
        metaWriteHelper(fidW, 'VisitID', header.VisitID, 'str');
        metaWriteHelper(fidW, 'VisitDate', header.VisitDate);
        metaWriteHelper(fidW, 'OctSize', [header.SizeX header.SizeZ header.NumBScans]);
        metaWriteHelper(fidW, 'OctScale', [header.ScaleX header.ScaleZ header.Distance]);
        metaWriteHelper(fidW, 'SloSize', [header.SizeXSlo header.SizeYSlo]);
        metaWriteHelper(fidW, 'SloScale', [header.ScaleXSlo header.ScaleYSlo]);
        metaWriteHelper(fidW, 'SloFieldSize', header.FieldSizeSlo);
        metaWriteHelper(fidW, 'BScanStartX', BScanHeader.StartX);
        metaWriteHelper(fidW, 'BScanStartY', BScanHeader.StartY);
        metaWriteHelper(fidW, 'BScanEndX', BScanHeader.EndX);
        metaWriteHelper(fidW, 'BScanEndY', BScanHeader.EndY);
        
        fclose( fidW );
    end
end
end

function metaWriteHelper(fidW, tag, data, mode)
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
