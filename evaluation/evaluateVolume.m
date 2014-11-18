function evaluateVolume(DataDescriptor)

actName = 'Default';

fido = fopen([DataDescriptor.pathname DataDescriptor.filename '_eval.txt'] , 'w');

fprintf(fido, ['--------------------------------------------------' '\n']);
fprintf(fido, ['                ID: %s \n'], DataDescriptor.Header.ID);
fprintf(fido, ['       ReferenceID: %s\n'],  DataDescriptor.Header.ReferenceID);
fprintf(fido, ['               PID: ' num2str(DataDescriptor.Header.PID) '\n']);
fprintf(fido, ['         PatientID: %s\n'],  DataDescriptor.Header.PatientID);
fprintf(fido, ['               VID: ' num2str(DataDescriptor.Header.VID) '\n']);
fprintf(fido, ['           VisitID: %s\n'],  DataDescriptor.Header.VisitID);
fprintf(fido, ['      ScanPosition: %s\n'],  DataDescriptor.Header.ScanPosition);
fprintf(fido, ['--------------------------------------------------' '\n']);
fprintf(fido, ['             SizeX: ' num2str(DataDescriptor.Header.SizeX) '\n']);
fprintf(fido, ['         NumBScans: ' num2str(DataDescriptor.Header.NumBScans) '\n']);
fprintf(fido, ['             SizeZ: ' num2str(DataDescriptor.Header.SizeZ) '\n']);
fprintf(fido, ['            ScaleX: ' num2str(DataDescriptor.Header.ScaleX) ' mm' '\n']);
fprintf(fido, ['          Distance: ' num2str(DataDescriptor.Header.Distance) ' mm' '\n']);
fprintf(fido, ['            ScaleZ: ' num2str(DataDescriptor.Header.ScaleZ) ' mm' '\n']);
fprintf(fido, ['--------------------------------------------------' '\n\n' ]);

onhCenter = readOctMeta([DataDescriptor.pathname DataDescriptor.filenameList{1}], ...
                        [actName 'ONHCenterAutoData']);
[octPos sloPos] = convertPosition([onhCenter(2) onhCenter(1) 1], 'OctToSloVol', DataDescriptor);
onhCenter = sloPos;

maskOut = createONHCircle(DataDescriptor, onhCenter);

[rpeAuto rpeMan] = readTagAutoManVolume('RPEautoData', 'RPEmanData');
evalBoundary(fido, 'RPE', rpeAuto, rpeMan, maskOut);

[inflAuto inflMan] = readTagAutoManVolume('INFLautoData', 'INFLmanData');
evalBoundary(fido, 'INFL', rpeAuto, rpeMan, maskOut);

[onflAuto onflMan] = readTagAutoManVolume('ONFLautoData', 'ONFLmanData');
evalBoundary(fido, 'ONFL', rpeAuto, rpeMan, maskOut);

evalBoundary(fido, 'RNFL', onflAuto - inflAuto, onflMan - inflMan, maskOut);

fclose(fido);

% Helper for reading metaData for the segment functions
function [dataAutoBScan dataManBScan] = readTagAutoMan(filename, autoTag, manTag)
    dataManBScan = readOctMeta([DataDescriptor.pathname filename], [actName manTag]);
    dataAutoBScan = readOctMeta([DataDescriptor.pathname filename], [actName autoTag]);
    if numel(dataManBScan) == 0
        dataManBScan = dataAutoBScan; 
    end
end

function [dataAuto dataMan] = readTagAutoManVolume(autoTag, manTag)
    dataAuto = zeros(DataDescriptor.Header.NumBScans, DataDescriptor.Header.SizeX, 'single');
    dataMan = zeros(DataDescriptor.Header.NumBScans, DataDescriptor.Header.SizeX, 'single');
    for i = 1:DataDescriptor.Header.NumBScans
        [dataAutoBScan dataManBScan] = readTagAutoMan(DataDescriptor.filenameList{i,1}, autoTag, manTag);  
            dataAuto(i,:) = dataAutoBScan;  
            dataMan(i,:) = dataManBScan;
    end
end

function evalBoundary(fileID, name, autoData, manData, notValidRegion)
    diff = (autoData - manData) * DataDescriptor.Header.ScaleZ * 1000;
    ascansValid = double(numel(find(notValidRegion == 0)));
    diff(notValidRegion == 1) = 0;
    
    meanAbsDiff = mean(mean(abs(diff))) ./ ascansValid;
    
    segErr5mum = numel(find(abs(diff)  > 5)) ./ ascansValid;
    segErr10mum = numel(find(abs(diff)  > 10)) ./ ascansValid;
    
    fprintf(fido, '--------------------------------------------------\n');
    fprintf(fido, ['Evaluation results for the ' name ' boundary:\n']);
    fprintf(fido, 'Mean abs. difference: %.5f\n', meanAbsDiff);
    fprintf(fido, 'Area of segmentation errors (5 mum): %1.5f\n', segErr5mum);    
    fprintf(fido, 'Area of segmentation errors (10 mum): %1.5f\n', segErr10mum);
    fprintf(fido, '--------------------------------------------------\n\n');
end

end