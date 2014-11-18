function res = mirrorCirc(data, mode, width)

if strcmp(mode, 'add') 
    res = [data(:, width+1:-1:2) data data(:, end-1:-1:end-width)];
else
    res = data(:, width+1:end-width);
end

