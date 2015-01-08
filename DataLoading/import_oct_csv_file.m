function import_oct_csv_file(input_file, out_fmt)
%import_oct_csv_file - imports OCT CSV data (2D) from AMC Mitra Almasian

%
% author: Elena Ranguelova, NLeSc
% date creation: 03.11.2014
% modification date: 07.11.2014
% modification details: correct gray-level conversion
% modification date: 07.01.2015
% modification details: output image file format is an input parameter now
% -----------------------------------------------------------------------
% SYNTAX
% import_oct_csv_file(input_file, out_fmt)
%
% INPUT
% input_file- imput CSV file 
% out_fmt - output image file format
%
% EXAMPLE
% if called from the current file's directory:
% import_oct_csv_file('..\..\..\Data\Phantom\2D_csv\fantoom0.csv','tif')
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
% the function saves the data as a gray scale image into a specified format

% parameters
DELIMITER = ',';
HEADERLINES = 11;
CROP = 0;
FACTOR = 2;

% Import the file
oct_data = importdata(input_file, DELIMITER, HEADERLINES);

% parse the filename parts
[pathstr,name,] = fileparts(input_file);
output_file = fullfile(pathstr,strcat(name,'.',out_fmt));


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
min_value =  min(min(image_data));
max_value = max(max(image_data));
image_data = (image_data - min_value).*(255/max_value);

% attach to workspace variable
assignin('base', 'image_data', image_data);

% visulaise
image(image_data);
map = gray(255);
colormap(map);

% save the image as a file of the desired format
imwrite(image_data,output_file,out_fmt);
