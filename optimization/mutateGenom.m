function genomMut = mutateGenom(genom, numMut, values)
% MUTATEGENOM
% Mutates a genom

genomIdx = randperm(numel(genom));
genomIdx = genomIdx(1:numMut);

genomMut = genom;

for g = 1:numel(genomIdx)
    pos = randi(size(values, 2) - 1);
    valuesFliped = values(values ~= genomMut(genomIdx(g)));
    genomMut(genomIdx(g)) = valuesFliped(pos);
end
end