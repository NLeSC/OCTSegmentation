function setSelectorSize(hSelector, guiMode, ActDataDescriptors)
% SETSELECTORSIZE Sets the size and steps of the B-Scan/Image selector
% according to the current data, and different for eah guiMode. 
% Currently used in every gui that displays OCT images
% (octsegVisu, segManCorrect, segManBV, segManSklera)
% The names of the parameters represent their counterparts in the GUIs

if guiMode == 1 || guiMode == 4
    if ActDataDescriptors.Header.NumBScans > 1
        minStep = 1/ (ActDataDescriptors.Header.NumBScans - 1);
        maxStep = 1/ActDataDescriptors.Header.NumBScans * 10;
        if maxStep > 1
            maxStep = 1;
        end
        set(hSelector,...
            'Min', 1, ...
            'Value', ActDataDescriptors.bScanNumber, ...
            'Max', ActDataDescriptors.Header.NumBScans, ...
            'SliderStep', [minStep maxStep])
    else
        set(hSelector, 'Visible', 'off');
    end
elseif guiMode == 2  || guiMode == 3
    if numel(ActDataDescriptors.filenameList) > 1
        minStep = 1 / (numel(ActDataDescriptors.filenameList) - 1);
        maxStep = 1 / numel(ActDataDescriptors.filenameList) * 10;
        if maxStep > 1
            maxStep = 1;
        end
        set(hSelector,...
            'Min', 1, ...
            'Value', ActDataDescriptors.fileNumber, ...
            'Max', numel(ActDataDescriptors.filenameList), ...
            'SliderStep', [minStep maxStep])
    else
        set(hSelector, 'Visible', 'off');
    end
end

% disp('Selector refreshed.');

end