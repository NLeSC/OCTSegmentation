function medline = segmentMedlineVolume(volume, params)
% SEGMENTMEDLINEVOLUME 
%
% Writen by Markus Mayer, Pattern Recognition Lab, University of
% Erlangen-Nuremberg

medline = zeros(size(volume, 3), size(volume, 2), 'double');

for i = 1:size(volume, 3)
    medlineLin = segmentMedlineLin(volume(:,:,i), params);
    medline(i,:) = medlineLin;
    disp(['Medline of BScan ' num2str(i) ' segmented automatically in 2D.']);
end

medline = medfilt2(medline, params.MEDLINEVOL_MEDFILT, 'symmetric');

end