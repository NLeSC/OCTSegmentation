function SloRegionData = createRegionViewsVisu(ActDataDescriptors, SloRegion, dispCorr, params)
% CREATEREGIONVIEWSVISU: Function dedicated for the use in octsegVisu.
% Loads and creates the SloRegion data for the region views.

SloRegionData.onhCenter = []; 
SloRegionData.data = [];     
SloRegionData.position = []; 
SloRegionData.opacity = []; 

if ActDataDescriptors.Header.ScanPattern == 2
    disp('Region views are enabled only on volumes.');
    return;
end    

if SloRegion.onhOn || SloRegion.onhCircleOn
    SloRegionData.onhCenter = readOctMeta([ActDataDescriptors.pathname ActDataDescriptors.filenameList{1}], ...
                                          [ActDataDescriptors.evaluatorName getMetaTag('ONHCenter','autoData')]);
    [octPos sloPos] = convertPosition([SloRegionData.onhCenter(2) SloRegionData.onhCenter(1) 1], ...
                                      'OctToSloVol', ActDataDescriptors);
    SloRegionData.onhCenter = sloPos;

    if SloRegion.onhOn
        SloRegionData.data = loadMetaDataEnfaceVisu(ActDataDescriptors, dispCorr, getMetaTag('ONH','both'));
    elseif SloRegion.onhCircleOn
        SloRegionData.data = loadMetaDataEnfaceVisu(ActDataDescriptors, dispCorr, getMetaTag('ONHCircle','both'));
    end

    SloRegionData.data(SloRegionData.data < 0) = 0;
    SloRegionData.opacity = zeros(size(SloRegionData.data, 1), size(SloRegionData.data, 2), 'single');

    SloRegionData.opacity(SloRegionData.data ~= 0) =  params.VISU_OPACITY_REGIONMAP;

    SloRegionData.data = flipdim(SloRegionData.data,1);
    SloRegionData.opacity = flipdim(SloRegionData.opacity,1);
    
    %SloRegionData.data = rot90(SloRegionData.data,1);
    %SloRegionData.opacity = rot90(SloRegionData.opacity,1);

    [SloRegionData.data SloRegionData.position] = registerEnfaceView(SloRegionData.data, ActDataDescriptors);
    SloRegionData.opacity = registerEnfaceView(SloRegionData.opacity, ActDataDescriptors);

    SloRegionData.data = grayToColor(SloRegionData.data, 'twocolors', 'colors', ...
        [params.VISU_COLOR_ONHMAP_LOW; params.VISU_COLOR_ONHMAP_HIGH], ...
        'cutoff', [0 1]);  
elseif SloRegion.bvOn 
    SloRegionData.data = loadMetaDataEnfaceVisu(ActDataDescriptors, dispCorr, getMetaTag('Blood Vessels','both'));

    SloRegionData.data(SloRegionData.data < 0) = 0;
    SloRegionData.opacity = zeros(size(SloRegionData.data, 1), size(SloRegionData.data, 2), 'single');

    SloRegionData.opacity(SloRegionData.data ~= 0) = params.VISU_OPACITY_REGIONMAP;

    SloRegionData.data = flipdim(SloRegionData.data,1);
    SloRegionData.opacity = flipdim(SloRegionData.opacity,1);

    [SloRegionData.data SloRegionData.position] = registerEnfaceView(SloRegionData.data, ActDataDescriptors);
    SloRegionData.opacity = registerEnfaceView(SloRegionData.opacity, ActDataDescriptors, 'linear');

    SloRegionData.data = grayToColor(SloRegionData.data, 'twocolors', 'colors', ...
        [params.VISU_COLOR_BVMAP_LOW; params.VISU_COLOR_BVMAP_HIGH], ...
        'cutoff', [0 1]);    
end
