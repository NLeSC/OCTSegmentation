function import_oct_csv_file(input_file)
%IMPORT_OCT_CSV_FILE(INPUT_FILE)
%  Imports OCT CSV data from the specified file and converts it to a
%  gray-level image according to formula new_value = 10.^(oct_value/20)
%  INPUT_FILE:  file to read

%  author: ELena Ranguelova
%  date created: 03-Nov-2014 
%  last modificaiton date: 07-Nov-2014
%  modification note: additional rescaling to range [0..255]

% parameters
DELIMITER = ',';
HEADERLINES = 11;
OUT_FMT = 'png';
CROP = 1;
FACTOR
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
    less_rows = floor(rows/factor);
    image_data = image_data(1:half_rows,:);
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
imwrite(image_data,output_file,OUT_FMT);
