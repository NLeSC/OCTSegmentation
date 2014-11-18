function genom = getRandomGenom(length, values)
% GETRANDOMGENOM
% Creates a genom with random entries

genom = zeros(1, length);
for i = 1:length
    pos = randi(size(values, 2));
    genom(i) = values(pos);
end
end