function data = import_oct_csv_file_raw(input_file)
%import_oct_csv_file_raw - imports OCT CSV data (2D) from AMC Mitra Almasian

%
% author: Elena Ranguelova, NLeSc
% date creation: 13.01.2015
% modification date:
% modification details: 
% -----------------------------------------------------------------------
% SYNTAX
% data = import_oct_csv_file_raw(input_file)
%
% INPUT
% input_file- input CSV file 
% 
% OUTPUT
% data- raw data values
%
% EXAMPLE
% if called from the current file's directory:
% data = import_oct_csv_file_raw('..\..\..\Data\Phantom\2D_CSV\fantoom0.csv');
%
% SEE ALSO
% import_oct_bin_file_raw for loading the full volume of OCT data from .bin
%
% REFERENCES
% e-mail correspondence wth Mitra and Martin
%
% NOTES

% parameters
DELIMITER = ',';
HEADERLINES = 11;
CROP = 0;
FACTOR = 2;

% Import the file
oct_data = importdata(input_file, DELIMITER, HEADERLINES);

% get the relevant data
data = oct_data.data;

if CROP 
    [rows, ] = size(data);
    less_rows = floor(rows/FACTOR);
    data = data(1:less_rows,:);
end

% % visulaise
% imshow(data);
% map = gray(255);
% colormap(map);

