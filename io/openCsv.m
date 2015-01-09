function [header, BScanHeader, slo, BScans] = openCsv(path, options)
% OPENCSV Reads an image file showing a 2D OCT Bscan, log scaled, but saved as a CSV file.
% [HEADER, BSCANHEADER, SLO, BSCANS] = OPEN(PATH, OPTIONS)
% This function performs oct 2D image (xxxx.csv) reading.
% HEADER: Artificial header information, to make a struct similar
%   to HE .vol files
% BSCANHEADER: B-scan header information.
% SLO: In the case of openOctImg, this will be empty.
% BScans: One BScan. 2D matrix with floating point data of the B-Scan.
%   The data is min-max scaled and the exponent is taken to make it similar
%   to HE .vol files for firther processing.
% PATH: Filename of the image file to read, with ending.
% Requires calling of the octsegConstantVariables function somewhere
%   beforehand.
% OPTIONS: Various output possibilites,
%   written in the options variable as string text, i.e. 'visu writemeta'
%   Possibilities:
%       metawrite: A metafile with the header and B-scan header information
%           is written out (if it does not exist already)
%       metawriteforce: An existing metafile is replaced
%       header: Only the Header and BScansHeader Information is read,
%            not the image data
%       nodisp: nothing is diplayed during read in
%
% Written by Elena Ranguelova, NLeSc, based on similar code by 
% Markus Mayer, Pattern Recognition Lab, University of
% Erlangen-Nuremberg
%
% First Version: January 2015

% octsegConstantVariables;
% global CSVSETTINGS;

%% If only one argument is defined
if nargin==1,
    options = '';
end
%% Open file
delimiter = ',';
headerlines = 11;

oct_data = importdata(path, delimiter, headerlines);
data = oct_data.data;

%% File header read
header.Version = 0;
header.SizeX = size(data,2);
header.NumBScans = 1;
header.SizeZ = size(data,1);
header.ScaleX = 1;
header.Distance = 1;
header.ScaleZ = 0.001;
header.SizeXSlo = 0;
header.SizeYSlo = 0;
header.ScaleXSlo = 1;
header.ScaleYSlo = 1;
header.FieldSizeSlo = 0;
header.ScanFocus = 0;
header.ScanPosition = '';
header.ExamTime = 0;
header.ScanPattern = 2; % All images are treated as circular scans by default.
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
    disp(['---------------------------------------------']);
end

BScanHeader.StartX = zeros(1, header.NumBScans, 'single');
BScanHeader.StartY = zeros(1, header.NumBScans, 'single');
BScanHeader.EndX = zeros(1, header.NumBScans, 'single');
BScanHeader.EndY = zeros(1, header.NumBScans, 'single');
BScanHeader.NumSeg = zeros(1, header.NumBScans, 'single');
BScanHeader.Quality = zeros(1, header.NumBScans, 'single');
BScanHeader.Shift = zeros(1, header.NumBScans, 'single');
BScanHeader.ILM = zeros(header.NumBScans,header.SizeX, 'single');
BScanHeader.RPE = zeros(header.NumBScans,header.SizeX, 'single');
BScanHeader.NFL = zeros(header.NumBScans,header.SizeX, 'single');

if numel(strfind(options, 'header')) == 0
    data = single(data);
    if size(data, 3) == 3
        data = mean(data, 3);
    end
 
    data = data - min(min(data));
    data = data ./ max(max(data));
    BScans = data .^ 4;
    BScans = BScans - min(min(BScans));
    BScans = BScans ./ max(max(BScans));
end
slo = [];


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
