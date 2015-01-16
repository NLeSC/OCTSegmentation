function octimg = openPlain(filename, mode)

% Open Plain RAW-Data, which is stored as 32bit float, and the size of the
% OCT image in an additional File (name the same, with .meta ending).

if nargin < 2
    mode = 'oct';
end

if strcmp(mode, 'oct')
fidData = fopen(strcat(filename, '.oct'), 'r');
fidSize = readOctMeta(filename, 'Octsize');

raw = fread(fidData, inf, 'float32')';
temp = reshape(raw, fidSize);

%if fidSize(3) == 1
for i = 1:fidSize(3)
    octimg(:,:,i) = temp(:,:,i)';
end
%else
%    for i = 1:fidSize(3)
%    octimg(:,:,i) = temp(:,:,i);
%    end
%end

elseif strcmp(mode, 'slo')
    fidData = fopen(strcat(filename, '.slo'), 'r');
    fidSize = readOctMeta(strcat(filename), 'Slosize');
    raw = fread(fidData, inf, 'uchar')';
    octimg = reshape(raw, fidSize);
end

fclose(fidData);

end