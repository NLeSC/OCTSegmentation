%  Read_RAW_3DArray
%  Reads a RAW file from disk into a 3D array with control over cropping and subsampling.
%
%  Usage:
%	[data3D, stHeader] = Read_RAW_3DArray(fullFileName, stInputParameters);
%
%  Inputs:
%    fullFileName - full path and filename of the RAW file.
%    stInputParameters - a MATLAB structure that is dynamically created.
%                        defaults get applied for the missing structure members.
%                        See example below.
%  Output:
%    data3D - 3-D array of voxel values, either uint8 or uint16.
%
%  Example usage:
%	Create a MATLAB structure dynamically to hold the parameters.
%	stInputParameters.XStart = 1;
%	stInputParameters.XEnd = 1024;
%	stInputParameters.YStart = 1;
%	stInputParameters.YEnd = 1024;
%	stInputParameters.ZStart = 10;
%	stInputParameters.ZEnd = 50;
%	stInputParameters.Subsample = 4;
%	fullFileName_RAW = 'SimulatedData_Distance8Bit.RAW';
%	[data3D, stHeader] = Read_RAW_3DArray(fullFileName_RAW, stInputParameters);
%
% NOTE: functions Read_RAW_Header and ValidateInputParameters are
%       NOT provided,one needs to implement them!
%------------------------------------------------------------------------------

function [data3D, stHeader] = Read_RAW_3DArray(fullFileName, stInputParameters)

	% Check syntax.  Must have two arguments.
	if (nargin ~= 2)
		error('Usage: [data3D, stHeader] = Read_RAW_3DArray(fullFileName, stInputParameters)');
	end 
	if (ischar(fullFileName) ~= 1)
		error('Requires a string filename as an argument.');
	end
	if ~exist(fullFileName, 'file')
		error('Error: file passed in to Read_RAW_3DArray\n%s\ndoes not exist.', fullFileName);
	end

	% Read in header and get 3D image array dimensions.
	stHeader = Read_RAW_Header(fullFileName);
	% Extract out sizes to more conveniently-named local variables.
	% Note: fread() requires that x_size and y_size be doubles.
	x_size = double(stHeader.x_size);
	y_size = double(stHeader.y_size);
	z_size = double(stHeader.z_size);

	% They passed in a structure for stInputParameters.  Make sure they passed in valid numbers.
	% Assign defaults to any fields in stInputParameters that they didn't set.
	% Make sure the starting and ending parameters they passed in (via stInputParameters) 
	% are in range 1 to x_size, 1 to y_size, and 1 to z_size.
	stValidParameters = ValidateInputParameters(stInputParameters, x_size, y_size, z_size);

	% Get size of output array.  It may be subsampled and be a different size than the input array.
	if stValidParameters.Subsample ~= 1
		subsampledXSize = ceil(double(stValidParameters.XEnd - stValidParameters.XStart + 1) / double(stInputParameters.Subsample));
		subsampledYSize = ceil(double(stValidParameters.YEnd - stValidParameters.YStart + 1) / double(stInputParameters.Subsample));
		subsampledZSize = ceil(double(stValidParameters.ZEnd - stValidParameters.ZStart + 1) / double(stInputParameters.Subsample));
	else
		subsampledXSize = stValidParameters.XEnd - stValidParameters.XStart + 1;
		subsampledYSize = stValidParameters.YEnd - stValidParameters.YStart + 1;
		subsampledZSize = stValidParameters.ZEnd - stValidParameters.ZStart + 1;
	end

	% Open the image data file for reading.
	fileHandle = fopen(fullFileName, 'rb', stHeader.EndianArg);
	if (fileHandle == -1)
		error(['Read_RAW_3DArray() reports error opening ', fullFileName, ' for input.']);
	end

	% Skip past header of stHeader.HeaderSize bytes.
	bytesToSkip = int32(stHeader.HeaderSize);

	% Now, additionally, skip past (ZStart - 1) slices before the ZStart slice begins
	% so that we end up at the beginning byte of the slice that we want, which is ZStart.
	bytesToSkip = bytesToSkip + int32(x_size * y_size * stHeader.BytesPerVoxel * (stValidParameters.ZStart - 1));
	fseek(fileHandle, bytesToSkip, 'bof');

	if(stHeader.BytesPerVoxel == 1)
		dataLengthString = '*uint8';	% You need the *, otherwise fread returns doubles.
		% Initialize a 3D data array.
		data3D = uint8(zeros([subsampledXSize, subsampledYSize, subsampledZSize]));
	
	elseif(stHeader.BytesPerVoxel == 2)
		dataLengthString = '*uint16';	% You need the *, otherwise fread returns doubles.
		% Initialize a 3D data array.
		data3D = uint16(zeros([subsampledXSize, subsampledYSize, subsampledZSize]));
	
	else
		error('Unsupported BytesPerVoxel %d', stHeader.BytesPerVoxel);
	end
	bytesPerVoxel = stHeader.BytesPerVoxel;

	% We'll always first read in the full slice.
	% Now determine if we need to subsample or crop that full slice.
	if subsampledXSize ~= x_size || subsampledYSize ~= y_size || subsampledZSize ~= z_size
		needToCropOrSubsample = 1;
	else
		needToCropOrSubsample = 0;
	end

	% Read in data slice by slice to avoid out of memory error.
	% We'll build up the 3D array slice by slice along the Z direction.
	sliceNumber = 1;
	for z = stValidParameters.ZStart : stValidParameters.Subsample : stValidParameters.ZEnd
		% Read in slice z from input image and put into slice sliceNumber of output image.
		% Reads from the current file pointer position.
		% Note: fread requires that x_size and y_size be doubles.
		oneFullSlice = fread(fileHandle, [x_size, y_size], dataLengthString);
		if needToCropOrSubsample == 1
			% Crop it and subsample it.
			croppedSlice = oneFullSlice(stValidParameters.XStart:stValidParameters.Subsample:stValidParameters.XEnd, stValidParameters.YStart:stValidParameters.Subsample:stValidParameters.YEnd);
			% Assign it, but don't transpose it like in some other formats.
			data3D(:, :, sliceNumber) = croppedSlice;
		else
			% Take the full slice, (not transposed like in some other formats).
			data3D(:, :, sliceNumber) = oneFullSlice;
		end
		%disp(['Read in slice ' num2str(z) ' of input, slice ' num2str(sliceNumber) ' of output']);
		% Skip the next slices if we are subsampling.
		% For example, if we just read slice 1 and the subsampling is 3, the next slice we should
		% read is 4, so we need to skip slices 2 and 3 (skip subsampling-1 slices).
		if stValidParameters.Subsample > 1
			% Calculate how many bytes to skip.
			bytesToSkip = int32(x_size * y_size * bytesPerVoxel * (stValidParameters.Subsample - 1));
			% Skip that many past the current position, which is at the end of the slice we just read.
			fseek(fileHandle, bytesToSkip, 'cof');
		end
		% Increment the slice we are on in the output array.
		sliceNumber = sliceNumber + 1;
	end

	% Close the file.
	fclose(fileHandle);
