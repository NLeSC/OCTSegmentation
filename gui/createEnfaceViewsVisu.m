function SloEnfaceData = createEnfaceViewsVisu(ActDataDescriptors, ActData, SloEnface, dispCorr, params)
% CREATEENFACEVIEWSVISU: Function dedicated for the use in octsegVisu.
% Loads and creates the SloEnface data for the enface views.

SloEnfaceData.data = [];     
SloEnfaceData.position = []; 

if ActDataDescriptors.Header.ScanPattern == 2
    disp('EnFace views are enabled only on volumes.');
    return;
end

if SloEnface.fullOn
    SloEnfaceData.data = createEnfaceView(ActData.bScans);
elseif SloEnface.nflOn
    onflData = loadMetaDataEnfaceVisu(ActDataDescriptors, dispCorr, getMetaTag('ONFL','both'));
    inflData = loadMetaDataEnfaceVisu(ActDataDescriptors, dispCorr, getMetaTag('INFL','both'));
    
    border = inflData;
    border(:,:,2) = onflData;
    SloEnfaceData.data = createEnfaceView(ActData.bScans, border);
elseif SloEnface.skleraOn
    rpeData = loadMetaDataEnfaceVisu(ActDataDescriptors, dispCorr, getMetaTag('RPE','both'));
    
    border = rpeData;
    border(:,:,2) = rpeData + 20;
    SloEnfaceData.data = createEnfaceView(ActData.bScans, border);
elseif SloEnface.rpeOn
    rpeData = loadMetaDataEnfaceVisu(ActDataDescriptors, dispCorr, getMetaTag('RPE','both'));
    
    border = rpeData - 10;
    border(:,:,2) = rpeData;
    SloEnfaceData.data = createEnfaceView(ActData.bScans, border);
elseif (SloEnface.rpePositionOn || SloEnface.inflPositionOn || SloEnface.onflPositionOn || SloEnface.skleraPositionOn)
    if SloEnface.rpePositionOn
        SloEnfaceData.data = loadMetaDataEnfaceVisu(ActDataDescriptors, dispCorr, getMetaTag('RPE','both'));
    elseif SloEnface.inflPositionOn
        SloEnfaceData.data = loadMetaDataEnfaceVisu(ActDataDescriptors, dispCorr, getMetaTag('INFL','both'));
    elseif SloEnface.onflPositionOn
        SloEnfaceData.data = loadMetaDataEnfaceVisu(ActDataDescriptors, dispCorr, getMetaTag('ONFL','both'));
    elseif SloEnface.skleraPositionOn
        SloEnfaceData.data = loadMetaDataEnfaceVisu(ActDataDescriptors, dispCorr, getMetaTag('Sklera','both'));
    end
    if numel(SloEnfaceData.data) ~= 0
        SloEnfaceData.data = flipdim(SloEnfaceData.data,1);
        SloEnfaceData.data = SloEnfaceData.data - min(min(SloEnfaceData.data(:, 5:end-5)));
        SloEnfaceData.data = SloEnfaceData.data ./ max(max(SloEnfaceData.data(:, 5:end-5)));
        SloEnfaceData.data(SloEnfaceData.data < 0) = 0;
        SloEnfaceData.data(SloEnfaceData.data > 1) = 1;
    else
        disp('Data not complete');
        SloEnface.rpePositionOn = 0;
        set(hMenSloRPEPosition, 'Checked', 'off');
        SloEnface.inflPositionOn = 0;
        set(hMenSloINFLPosition, 'Checked', 'off');
        SloEnface.onflPositionOn = 0;
        set(hMenSloONFLPosition, 'Checked', 'off');
        SloEnface.skleraPositionOn = 0;
        set(hMenSloSkleraPosition, 'Checked', 'off');
    end
end

if (SloEnface.skleraOn       || ...
    SloEnface.rpeOn          || ...
    SloEnface.nflOn          || ...
    SloEnface.fullOn         || ...
    SloEnface.inflPositionOn || ...
    SloEnface.onflPositionOn || ...
    SloEnface.rpePositionOn)
    [SloEnfaceData.data SloEnfaceData.position] = registerEnfaceView(SloEnfaceData.data, ActDataDescriptors);
end
