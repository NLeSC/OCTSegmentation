function import_oct_csv_file(input_file)
%import_oct_csv_file - imports OCT CSV data (2D) from AMC Mitra Almasian

%
% author: Elena Ranguelova, NLeSc
% date creation: 03.11.2014
% last modification date: 07.11.2014
% modification details: correct gray-level conversion
% -----------------------------------------------------------------------
% SYNTAX
% import_oct_csv_file(input_file)
%
% INPUT
% input_file- imput CSV file 
%
% EXAMPLE
% import_oct_csv_file('..\..\..\Data\Phantom\fantoom0.csv')
%
% SEE ALSO
% import_oct_bin_file for loading the full volume of OCT data
%
% REFERENCES
% e-mail correspondence wth Mitra and Martin
%
% NOTES
% Sometimes the conversion to gray scale is done extra notes
% according to formula new_value = 10.^(oct_value/20)
% the function saves the data as a gray scale image into an PNG file

% parameters
DELIMITER = ',';
HEADERLINES = 11;
OUT_FMT = 'png';
CROP = 1;
FACTOR = 2;

% Import the file
oct_data = importdata(input_file, DELIMITER, HEADERLINES);

% parse the filename parts
[pathstr,name,] = fileparts(input_file);
output_file = fullfile(pathstr,strcat(name,'.',OUT_FMT));


% Create new variables in the base workspace from those fields.
vars = fieldnames(oct_data);
for i = 1:length(vars)
    assignin('base', vars{i}, oct_data.(vars{i}));
end

image_data = oct_data.data;

if CROP 
    [rows, ] = size(image_data);
    less_rows = floor(rows/FACTOR);
    image_data = image_data(1:less_rows,:);
end
% convert to gray levels
image_data = 10.^(image_data./20);
% rescale to [0..255]
max_value = max(max(image_data));
image_data = image_data.*(255/max_value);

% attach to workspace variable
assignin('base', 'image_data', image_data);

% visulaise
image(image_data);
map = gray(255);
colormap(map);

% save the image as a Tiff
%imwrite(image_data,output_file,OUT_FMT);
