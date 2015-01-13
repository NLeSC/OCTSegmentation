% import_oct_bin_file - function to load AMC raw volumetric data from file
%
% author: Elena Ranguelova, NLeSc
% date creation: 05-12-2014
% last modification date: 08-12-2014
% modification details: loading the data and displaying every display_number-th slice
%                       output of also image_data- converted to gray scale
% -----------------------------------------------------------------------
% SYNTAX
% [data, image_data]=import_oct_bin_file(filename_data, filename_metadata)
%
% INPUT
% filename_data- the filename of the raw data 
% filename_metadata- the filename of the metadata 
% display_number - slice number divisable by display_number will be displayed

% OUPTPUT
% data- 3D output array of voxel values of type uint8
% image_data- the data convertedto gray scale for visualization
% EXAMPLE
% Called form the current file's directory:
% import_oct_bin_file('..\..\..\Data\Phantom\3D_bin\Data.bin',...
%                   '..\..\..\Data\Phantom\3D_bin\DataInfo.ini', 100)
%
% SEE ALSO
% import_oct_csv_file, ini2struct (from MATLAB file exchange) 
%
% REFERENCES
% e-mail correspondence with Martin and Dirk from AMC
%
% NOTES
% Every Nth slice is displayed in a figure for manual verification

%------------------------------------------------------------------------------

function [data, image_data] = import_oct_bin_file(filename_data, filename_metadata, display_number)

	% Check syntax.  Must have three arguments.
	if (nargin ~= 3)
		error('Usage: [data] = import_oct_bin_file(filename_data, filename_metadata, display_number)');
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
		error(['import_oct_bin-file reports error opening ', filename_data, ' for input.']);
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
    
    % convert to gray scale
    image_data = 10.^(data./20);
%    image_data = data;
    % rescale to [0..255]
    max_value = max(max(max(image_data)));
    image_data = image_data.*(255/max_value);

    disp('--------------------------------');    
    disp('Converting the data to gray scale ...');
    % dsiplay some of the gray scale data
    fig = figure;
    display_counter = 0;
    for z = 1 : (display_number) : z_size
        % find if the slice_number is divisable by display_number and show
        % it-  NOT GENERIC ENOUGH CODE YET!
        if ~rem(z-1,display_number)
            display_counter = display_counter + 1;
            figure(fig);
            subplot(2,5,display_counter);
            map = colormap(gray(256));
            imshow(image_data(:,:,z),map);
            s = sprintf('Slice #: %d',z-1);
            title(s);
        end
    end
        
    disp('Done converting the data.');   
	% Close the file.
	fclose(file_handle);

    disp('--------------------------------');
    disp('Done.');    
    disp('--------------------------------');
