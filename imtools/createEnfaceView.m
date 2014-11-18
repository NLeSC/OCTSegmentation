function enface = createEnfaceView(volume, border)

if nargin < 2
    border = [];
end

volume(volume > 1) = 0;

if numel(border) == 0
 enface = sum(volume, 1);
 enface = (shiftdim(enface,1))';
 enface = flipdim(enface,1);
elseif numel(border) == 2
  enface = sum(volume(border(1):border(2), :,:), 1);
  enface = (shiftdim(enface,1))';
  enface = flipdim(enface,1);
else
    border = round(border);
    border(border > size(volume,1)) = size(volume,1);
    border(border < 1) = 1;
    
    enface = zeros(size(volume, 3), size(volume,2), 'single');
    for i = 1:size(volume,2)
        for j = 1:size(volume,3)
            enface(j,i) = sum(volume(border(j,i,1):border(j,i,2),i,j));
        end
    end
    
    enface = flipdim(enface,1);
end

for i = 1:size(enface,1)
enface(i,:) = enface(i,:) - min(enface(i,:));
enface(i,:) = enface(i,:) ./ max(enface(i,:));
end

end