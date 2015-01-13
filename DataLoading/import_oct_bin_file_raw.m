% import_oct_bin_file_raw - function to load AMC raw volumetric data from file
%
% author: Elena Ranguelova, NLeSc
% date creation: 13-01-2014
% modification date: 
% modification details: 
% -----------------------------------------------------------------------
% SYNTAX
% [data]=import_oct_bin_file(filename_data, filename_metadata)
%
% INPUT
% filename_data- the filename of the raw data 
% filename_metadata- the filename of the metadata 

% OUPTPUT
% data- 3D output array of raw voxel values

% EXAMPLE
% Called form the current file's directory:
% data = import_oct_bin_file_raw('..\..\..\Data\Phantom\3D_bin\Data.bin',...
%                   '..\..\..\Data\Phantom\3D_bin\DataInfo.ini')
%
% SEE ALSO
% import_oct_csv_file, ini2struct (from MATLAB file exchange) 
%
% REFERENCES
% e-mail correspondence with Martin and Dirk from AMC
%
% NOTES

%------------------------------------------------------------------------------

function [data] = import_oct_bin_file_raw(filename_data, filename_metadata)

	% Check syntax.  Must have two arguments.
	if (nargin ~= 2)
		error('Usage: [data] = import_oct_bin_file_raw(filename_data, filename_metadata)');
	end 
	if ~exist(filename_data, 'file')
		error('Error: file passed in to import_oct_bin_file\n%s does not exist.', filename_data);
    end
	if ~exist(filename_metadata, 'file')
		error('Error: file passed in to import_oct_bin_file\n %s does not exist.', filename_metadata);
    end
    
	% Read in metadata and get 3D image array dimensions.
    disp('--------------------------------');
    disp('Reading the metadata...');
	meta_struct = ini2struct(filename_metadata);
    
    % get the volume dimensions
    x_size = str2double(meta_struct.dimensions.x);
    y_size = str2double(meta_struct.dimensions.y);
    z_size = str2double(meta_struct.dimensions.z);
    
    s = sprintf('The volume dimensions are (%i x %i x %i).',x_size, y_size, z_size);
    disp(s);

    % get the size of the header
    header_size = str2double(meta_struct.header.header);
    s = sprintf('The header size is %i.',header_size);
    disp(s);

    % get the endianness- by info from Dirk- big endiaan, but still present
    % in the header- if the header value shouldbe used uncomment the row below
    % e = str2double(meta_struct.endianess.endianess);
    % s = sprintf('The endianess is %i.',e);
    % disp(s);
    e = 1;
    if e 
        machineformat = 'b';
    else
        machineformat = 'l';
    end
    
    % bytes per voxel -info not from header, but from Martin(Dirk)
    bytes_per_voxel = 4;
    
    s = sprintf('The number of bytes per voxel is %i.',bytes_per_voxel);
    disp(s)
    
    disp('Done reading the metadata.');    
    disp('--------------------------------');
    
    disp('Reading the data...');
	% Open the image data file for reading.
	file_handle = fopen(filename_data, 'rb', machineformat);
	if (file_handle == -1)
		error(['import_oct_bin_file_raw reports error opening ', filename_data, ' for input.']);
	end

	% Skip past header header_size bytes.
	bytes_to_skip = int32(header_size);

    if bytes_to_skip > 0
        fseek(file_handle, bytes_to_skip, 'bof');
    end
    
    % data format given the bytes per voxel
	if(bytes_per_voxel == 4)
		data_length_string = '*float32';	% You need the *, otherwise fread returns doubles.
		% Initialize a 3D data array.
		data = single(zeros([x_size, y_size, z_size]));	
	else
		error('Unsupported bytes_per_voxel %d', bytes_per_voxel);
	end
	 

	% Read in data slice by slice to avoid out of memory error.
	% We'll build up the 3D array slice by slice along the Z direction.

    for z = 1 : z_size
		% Read in slice z from input image and put into slice sliceNumber of output image.
		% Reads from the current file pointer position.
		% Note: fread requires that x_size and y_size be doubles.
		one_slice = fread(file_handle, [x_size, y_size], data_length_string, machineformat);
		% Take the full slice, (not transposed like in some other formats).
		data(:, :, z) = one_slice;
    end

    disp('Done reading the data.');   
    
	% Close the file.
	fclose(file_handle);

    disp('--------------------------------');
    disp('Done.');    
    disp('--------------------------------');
