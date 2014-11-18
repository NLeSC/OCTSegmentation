function saveDisplayedFile(img, pathname, filename, filenameEnding)
% SAVEDISPLAYEDIMAGE: Stores the RGB image given by img into a file given
% by pathname and filename.
% Out of the ending of the filename, the options are determined:
% - .jpg: Always store in 100% quality
% - .tif: Always store without compression
% - Other: Standard matlab values
% img: Double valued 3 layer image (RGB)
% pathname and filename: Eplain themself the values perhaps given by
%   uiputfile. Folder separators already included in the path.

% Find out the file ending, if not already given
if nargin < 4
    filenameEnding = getFilenameEnding(filename);
end

if numel(strfind(filenameEnding, 'tif')) ~= 0
    imwrite(double(img), [pathname filename], 'Compression', 'none');
elseif numel(strfind(filenameEnding, 'jpg')) ~= 0
    imwrite(double(img), [pathname filename], 'Quality', 100);
else
    imwrite(double(img), [pathname filename]);
end