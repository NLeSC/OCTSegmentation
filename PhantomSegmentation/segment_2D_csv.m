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
% Enter the full filename of the phantom data saved in CSV  format: ../../Data/Phantom/2D_CSV/fantoom0.csv
%
% REFERENCES
%
% NOTES
%--------------------------------------------------------------------------

%% import the data
data_file = input('Enter the full filename of the phantom data saved in CSV  format: ', 's');

raw_data = import_oct_csv_file_raw(data_file); 

