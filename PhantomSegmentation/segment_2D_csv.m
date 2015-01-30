%% segment_2D_csv - script to segment 2D csv file with phantom OCT data
%
% author: Elena Ranguelova, NLeSc
% date creation: 13-01-2015
% modification date: 29-01-2015 
% modification details: Commented out fixed paths and file names
% -----------------------------------------------------------------------
% SYNTAX
% segment_2D_csv
%
% SEE ALSO
% import_oct_csv_file_raw, segment_phantom_lines
%
% EXAMPLE
% segment_2D_csv
% Enter the full filename of the phantom data saved in CSV  format: ..\..\Data\Phantom\2D_CSV\fantoom0.csv
%
% REFERENCES
%
% NOTES
%--------------------------------------------------------------------------

%% import the data
data_file = input('Enter the full filename of the phantom data saved in CSV  format: ', 's');
%data_file = '..\..\..\Data\Phantom\2D_CSV\fantoom0.csv';

if exist(data_file)
    raw_data = import_oct_csv_file_raw(data_file); 
else
    error('Raw CSV data file not found!');
end

%% parameters file
params_file = input('Enter the full filename of the parameters file: ', 's');
%params_file = 'octseg_phantom.param';
 
params_infl = loadParameters('INFL', params_file);
params_rpe = loadParameters('RPELIN', params_file);

%% segment the borders between the layers
lines = segment_phantom_lines(raw_data, params_infl, params_rpe);

%% display some steps
f1 = figure;
figure(f1);

rows = 2; cols = 2;
subplot(rows,cols,1); imagesc(raw_data);colormap(gray(256));title('raw data');axis on; grid on
%subplot(rows,cols,2); imagesc(scaled_data);colormap(gray(256));title('scaled data');axis on; grid on
subplot(rows,cols,2); imagesc(filtered_data);colormap(gray(256));title('filtered\_data');axis on; grid on
subplot(rows,cols,3); imagesc(thresh_data);colormap(gray(256));title('thersh\_data');axis on; grid on
[size_x, size_y] = size(raw_data);

subplot(rows,cols,4); imagesc(raw_data);colormap(gray(256));title('raw data');axis on; grid on
hold on
plot(1:size_y,lines(1,:),'r', 1:size_y,lines(2,:),'g',...
    1:size_y,lines(3,:),'y', 1:size_y,lines(4,:),'b');
title('top 2 layer borders ');axis on, grid on
axis([0 size_y 0 size_x]);axis ij


