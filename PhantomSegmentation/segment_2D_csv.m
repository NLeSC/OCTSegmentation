%% segment_2D_csv - script to segment 2D csv file with phantom OCT data
%
% author: Elena Ranguelova, NLeSc
% date creation: 13-01-2015
% modification date:
% modification details:
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
%data_file = input('Enter the full filename of the phantom data saved in CSV  format: ', 's');
data_file = '..\..\Data\Phantom\2D_CSV\fantoom0.csv';

raw_data = import_oct_csv_file_raw(data_file); 

%% parameters file
%params_file = input('Enter the full filename of the parameters file: ', 's');
params_file = '.\gui\octseg.param';
 
params_infl = loadParameters('INFL', params_file);
params_rpe = loadParameters('RPELIN', params_file);

%% segment the borders between the layers
lines = segment_phantom_lines(raw_data, params_infl, params_rpe);

%% display some steps
f1 = figure;
figure(f1);

rows = 2; cols = 4;
subplot(rows,cols,1); imagesc(raw_data);colormap(gray(256));title('raw data');axis on; grid on
subplot(rows,cols,2); imagesc(scaled_data);colormap(gray(256));title('scaled data');axis on; grid on
subplot(rows,cols,3); imagesc(filtered_data);colormap(gray(256));title('filtered\_data');axis on; grid on
subplot(rows,cols,4); imagesc(thresh_data);colormap(gray(256));title('thersh\_data');axis on; grid on
[size_x, size_y] = size(raw_data);
subplot(rows,cols,5); plot(1:size_y,lines(1,:));title('some layer border (max)');axis on, grid on
axis([0 size_y 0 size_x]);axis ij
subplot(rows,cols,6); plot(1:size_y,lines(2,:));title('some layer border (min)');axis on, grid on
axis([0 size_y 0 size_x]);axis ij


% f2 = figure;
% figure(f2);
% subplot(2,2,1); hist(raw_data(:));title('raw_data');
% %subplot(2,2,1); hist(data(:));title('data');axis on
% subplot(2,2,2); hist(scaled_data(:));title('scaled\_data');axis on
% subplot(2,2,3); hist(filtered_data(:));title('filtered\_data');axis on
% subplot(2,2,4); hist(thresh_data(:));title('thresh\_data');axis on

% f2 = figure;
% figure(f2);
% col=  200;
% %subplot(2,2,1); plot(raw_data(:,col));title(['raw\_data at column ', num2str(col)]);axis on; grid on;
% %subplot(2,2,1); hist(data(:));title('data');axis on
% %subplot(2,2,2); plot(scaled_data(:,col));title(['scaled\_data at column ', num2str(col)]);axis on; grid on;
% subplot(2,2,1); plot(filtered_data(:,col));title(['filtered\_data at column ', num2str(col)]);axis on; grid on;
% subplot(2,2,2); plot(thresh_data(:,col));title(['thresh\_data at column ', num2str(col)]);axis on; grid on;
% subplot(2,2,3); plot(lines(1,:));title('lines');axis on, grid on; axis([0 size_y 0 size_x])
% %subplot(2,2,4); plot(lines(2,:));title('lines');axis on, grid on
% %
