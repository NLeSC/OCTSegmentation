function genomMut = mutateGenomIdx(genom, genomIdx, values)
genomMut = genom;

idx = randperm(numel(genomIdx));
genomIdx = genomIdx(idx);

numMut = round(rand(1) * numel(genomIdx));
genomIdx = genomIdx(1:numMut);

for g = 1:numel(genomIdx)
    pos = randi(size(values, 2)-1);
    valuesFliped = values(values ~= genomMut(genomIdx(g)));
    genomMut(genomIdx(g)) = valuesFliped(pos);
end
end