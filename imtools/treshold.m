function bscan = treshold(bscan, mode, factor)

if strcmp(mode, 'ascanmax')
    for i = 1:size(bscan, 2)
        ascan = bscan(:,i);
        val = sort(ascan);
        firstTreshold = val(round(end * factor(1)));
        ascan(ascan > firstTreshold) = firstTreshold;
        ascan(ascan < firstTreshold * factor(2)) = 0;
        bscan(:,i) = ascan;
    end
end