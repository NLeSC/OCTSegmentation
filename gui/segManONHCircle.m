function segManONHCircle(ActDataDescriptors, guiMode)
% segManCORRECT Manual correction of the automated ONH segmentations (only
% center and radius)

%--------------------------------------------------------------------------
% GLOBAL CONST
%--------------------------------------------------------------------------

global PARAMETER_FILENAME;
PARAMETERS = loadParameters('VISU', PARAMETER_FILENAME);

ONHCENTERTAGS = getMetaTag('ONHCenter','both');
ONHCIRCLETAGS = getMetaTag('ONHCircle','both');
ONHRADIUSTAGS = getMetaTag('ONHRadius','both');

ONHRADIUSMIN = 0.5;
ONHRADIUSMAX = 2;

%--------------------------------------------------------------------------
% GLOBAL VARIABLES
%--------------------------------------------------------------------------

onhCenter = [];
onhRadius = [];
onhCircle = [];

sloONHCenter = [];

ActDataDescriptors.fileNumber = 1;
ActDataDescriptors.bScanNumber = 1;

ActDataDescriptors.Header = [];
ActDataDescriptors.BScanHeader = [];
actBScans = [];
actSlo = [];

enfaceOn = 0;
activeOn = 1;
sloEnfaceData = [];
sloEnfacePosition = [];

ActDataDescriptors.evaluatorName = 'Default';

%--------------------------------------------------------------------------
% GUI Components
%--------------------------------------------------------------------------

hMain = figure('Visible','off','Position',[440,500,500,640],...
    'WindowButtonDownFcn', @hButtonDownFcn,...
    'ResizeFcn', @hResizeFcn,...
    'Color', 'white',...
    'Units','pixels',...
    'MenuBar', 'none',...
    'WindowStyle', 'normal',...
    'CloseRequestFcn', {@hCloseRequestFcn});
movegui(hMain,'center');

set(hMain,'Name','OCTSEG ONH POSITION CORRECTION');

% Control Buttons ---------------------------------------------------------

hSave = uicontrol('Style','pushbutton','String','Save & Quit',...
    'FontSize', 10,...
    'Units','pixels',...
    'Callback',{@hSaveCallback});

hCancel = uicontrol('Style','pushbutton','String','Cancel',...
    'FontSize', 10,...
    'Units','pixels',...
    'Callback',{@hCancelCallback});

hInfo = uicontrol('Style','text','String','No Info',...
    'BackgroundColor', [1 1 1],...
    'FontSize', 10,...
    'HorizontalAlignment', 'left',...
    'Units','pixels',...
    'Position',[15,55,170,100]);

hEnface = uicontrol('Style','pushbutton','String','Enface On',...
    'FontSize', 10,...
    'BackgroundColor', [0.7 0.7 0.9],...
    'Units','pixels',...
    'Callback',{@hEnfaceCallback});

hActive = uicontrol('Style','pushbutton','String','Hide Segmentation',...
    'FontSize', 10,...
    'BackgroundColor', [0.7 0.7 0.9],...
    'Units','pixels',...
    'Callback',{@hActiveCallback});

minStep = 1 / (numel(ActDataDescriptors.filenameList) - 1);

hRadius = uicontrol(hMain, 'Style', 'slider',...
    'Units','pixels',...
    'Min', ONHRADIUSMIN, ...
    'Value', 1, ...
    'Max', ONHRADIUSMAX, ...
    'SliderStep', [0.01 0.25], ...
    'Callback', @hRadiusCallback, ...
    'Visible', 'on');

hRadiusEdit = uicontrol('Style','edit','String', '1.0',...
    'BackgroundColor', [1 1 1],...
    'FontSize', 10,...
    'Min', 1, 'Max', 1, ...
    'HorizontalAlignment', 'left',...
    'Units','pixels',...
    'Callback', @hRadiusEditCallback, ...
    'Position',[15,55,170,100]);

% Images ------------------------------------------------------------------
hSlo = axes('Units','pixels',...
    'Parent', hMain,...
    'Visible', 'on');

%--------------------------------------------------------------------------
% GUI Init
%--------------------------------------------------------------------------

ActDataDescriptors.fileNumber = 1;
ActDataDescriptors.bScanNumber = 1;
loadDispFile();
loadSeg();

refreshLayout();
refreshDispComplete;

%uiwait(hMain);

%--------------------------------------------------------------------------
% GUI Mouse functions
%--------------------------------------------------------------------------

function hButtonDownFcn(hObject, eventdata)
    if ancestor(gco,'axes') == hSlo
        mousePoint = get(hSlo,'currentpoint');
        
        [octPos sloPos] = convertPosition([mousePoint(1,2) mousePoint(1,1)], ...
                                          'SloToOctVol', ActDataDescriptors);
        onhCenter = [octPos(2) octPos(1)];
        
        sloONHCenter = sloPos;

        onhCircle = createONHCircle(ActDataDescriptors, onhCenter, onhRadius);
        refreshDispSlo();
    end
end

function hResizeFcn(hObject, eventdata)
    refreshLayout();
end

function hCloseRequestFcn(hObject, eventdata, handles)
    uiresume;
    delete(hObject);
end

%--------------------------------------------------------------------------
% GUI Button Functions
%--------------------------------------------------------------------------

function hSaveCallback(hObject, eventdata)
    writesegManSeg();
    uiresume;
    delete(hMain);
end


function hCancelCallback(hObject, eventdata)
    uiresume;
    delete(hMain);
end

function hActiveCallback(hObject, eventdata)
    if activeOn == 0
        activeOn = 1;
        set(hActive, 'String', 'Hide Segmentation');
    else
        activeOn = 0;
        set(hActive, 'String', 'Show Segmentation');
    end
    
    refreshDispSlo();
end

function hEnfaceCallback(hObject, eventdata)
    if enfaceOn == 0
        enfaceOn = 1;
        set(hEnface, 'String', 'Hide Enface');
    else
        enfaceOn = 0;
        set(hEnface, 'String', 'Show Enface');
    end
    
    refreshDispSlo();
end

function hRadiusEditCallback(hObject, eventdata)
    onhRadiusString = get(hRadiusEdit, 'String');
    onhRadiusTemp = str2num(onhRadiusString);
    
    if onhRadiusTemp > ONHRADIUSMIN && onhRadiusTemp < ONHRADIUSMAX
        onhRadius = onhRadiusTemp;
        set(hRadius, 'Value', onhRadius);
        onhCircle = createONHCircle(ActDataDescriptors, onhCenter, onhRadius);
    end

    refreshDispSlo();
end

function hRadiusCallback(hObject, eventdata)
    onhRadius = get(hRadius, 'Value');
    set(hRadiusEdit, 'String', num2str(onhRadius));
    onhCircle = createONHCircle(ActDataDescriptors, onhCenter, onhRadius);
    refreshDispSlo();
end

%--------------------------------------------------------------------------
% Other functions and algorithms
%--------------------------------------------------------------------------

% Functions for loading & manipulating data and images
%------------------------------------------------------------------
function loadDispFile()
        [numDescriptor openFuncHandle] = examineOctFile(ActDataDescriptors.pathname, ActDataDescriptors.filename);
        [ActDataDescriptors.Header, ActDataDescriptors.BScanHeader, actSlo, actBScans] = openFuncHandle([ActDataDescriptors.pathname ActDataDescriptors.filename]);

    if numDescriptor == 0
        disp('Refresh Disp File: File is no OCT file.');
        return;
    end
   
    disp(['Display file loaded: ' ActDataDescriptors.pathname ActDataDescriptors.filename]);
end

function loadSeg()
    [segAutoSingle segManSingle status] = loadSingleSeg(ONHRADIUSTAGS);
    if status == 2
        onhRadius = segManSingle;
    elseif status == 1
        onhRadius = segAutoSingle
    else
        disp('No ONH radius segmentation performed yet.');
        return;
    end
    
    [segAutoSingle segManSingle status] = loadSingleSeg(ONHCENTERTAGS);
    if status == 2
        onhCenter = segManSingle;
    elseif status == 1
        onhCenter = segAutoSingle
    else
        disp('No ONH center segmentation performed yet.');
        return;
    end
    
%     if onhCenter(2) < 1
%         onhCenter(2) = 1;
%     elseif onhCenter(2) > ActDataDescriptors.Header.SizeX;
%         onhCenter(2) = ActDataDescriptors.Header.SizeX;
%     end
%     
%     if onhCenter(1) < 1
%         onhCenter(1) = 1;
%     elseif onhCenter(1) > ActDataDescriptors.Header.NumBScans;
%         onhCenter(1) = ActDataDescriptors.Header.NumBScans;
%     end
        
    [octPos sloPos] = convertPosition([onhCenter(2) onhCenter(1) 1], ...
                                      'OctToSloVol', ActDataDescriptors);
    sloONHCenter = sloPos;
    
    onhCircle = reloadMetaDataTagEnface(ONHCIRCLETAGS);
end

function [segAutoSingle segManSingle status] = loadSingleSeg(tags)
    status = 0;
    %status: 0: Nothing done yet, 1: Auto available: 2: Manual available
    if guiMode == 1 || guiMode == 4
        segAutoSingle =  readOctMeta([ActDataDescriptors.pathname ActDataDescriptors.filenameList{ActDataDescriptors.bScanNumber}], [ActDataDescriptors.evaluatorName tags{1} 'Data']);
        segManSingle = readOctMeta([ActDataDescriptors.pathname ActDataDescriptors.filenameList{ActDataDescriptors.bScanNumber}], [ActDataDescriptors.evaluatorName tags{2} 'Data']);
    end

    if numel(segAutoSingle) == 0
        segAutoSingle = zeros(1, ActDataDescriptors.Header.SizeX, 'single');
    else
        status = 1;
    end
    
    if numel(segManSingle) == 0
        segManSingle = segAutoSingle;
    else
        status = 2;
    end
end

function data = reloadMetaDataTagEnface(tags)
    autoData = readOctMetaVolume(ActDataDescriptors, tags{1});

    data = readOctMetaVolume(ActDataDescriptors, tags{2});
    if sum(sum(data)) == 0
        data = autoData;
    end
end

function writesegManSeg()    
    for i = 1:numel(ActDataDescriptors.filenameList)
            writeOctMeta([ActDataDescriptors.pathname ActDataDescriptors.filenameList{i}], [ActDataDescriptors.evaluatorName getMetaTag('ONH','man');], 1);
            writeOctMeta([ActDataDescriptors.pathname ActDataDescriptors.filenameList{i}], [ActDataDescriptors.evaluatorName ONHCENTERTAGS{2} 'Data'], onhCenter);
            writeOctMeta([ActDataDescriptors.pathname ActDataDescriptors.filenameList{i}], [ActDataDescriptors.evaluatorName ONHRADIUSTAGS{2} 'Data'], onhRadius);
            writeOctMeta([ActDataDescriptors.pathname ActDataDescriptors.filenameList{i}], [ActDataDescriptors.evaluatorName ONHCIRCLETAGS{2} 'Data'], onhCircle(i, :));
    end
end

% Functions used for layout & display
%-----------------------------------------------------------------

function refreshLayout()
    set(hMain, 'Visible', 'on');
    
    fpos = get(hMain, 'position');
    
    % Define all widths & heights
    
    width = fpos(3);
    height = fpos(4);
    
    border = 5;
    
    infoHeight = 20;
    buttonHeight = 40;
    selectorHeight = 20;
    
    sloWidth = width - 2 * border;
    sloHeight = round(sloWidth * size(actSlo, 1) / size(actSlo,2));
    
    set(hInfo, 'Position', [border (height - infoHeight - border) sloWidth infoHeight]);
    sloVPos = height - infoHeight - 2 * border - sloHeight;
    set(hSlo, 'Position', [border sloVPos sloWidth sloHeight]);
    
    buttonWidth = (sloWidth - 2 * border) / 3;
    vPos1 = sloVPos - border - buttonHeight;
    set(hEnface, 'Position', [border vPos1 buttonWidth buttonHeight]);
    set(hActive, 'Position', [(2 * border + buttonWidth) vPos1 buttonWidth buttonHeight]);
    set(hRadiusEdit, 'Position', [(3 * border + 2 * buttonWidth) vPos1 buttonWidth buttonHeight]);
    
    vPos2 =  vPos1 - selectorHeight - border;
    set(hRadius, 'Position', [border vPos2 sloWidth selectorHeight]);
    
    vPos3 = vPos2 - buttonHeight - border;
    longButtonWidth = (sloWidth -  border) / 2;
    
    set(hSave, 'Position', [border vPos3 longButtonWidth buttonHeight]);
    set(hCancel, 'Position', [(2 * border + longButtonWidth) vPos3 longButtonWidth buttonHeight]);
    
    set(hMain,'CurrentAxes',hSlo);
    axis image;
    axis off;
end

function refreshDispSlo()  
    dispSlo = single(actSlo);
    dispSlo = dispSlo ./ single(max(max(actSlo)));
    dispSlo(:,:,2) = dispSlo;
    dispSlo(:,:,3) = dispSlo(:,:,1);
    
    if enfaceOn
        sloEnfaceData = createEnfaceView(actBScans);
        [sloEnfaceData sloEnfacePosition] = registerEnfaceView(sloEnfaceData, ActDataDescriptors);
        dispSlo = combineSloEnface(dispSlo, sloEnfaceData, sloEnfacePosition); 
    end
    
    if activeOn 
        onhCircle(onhCircle < 0) = 0;
        sloRegionOpacity = zeros(size(onhCircle, 1), size(onhCircle, 2), 'single');
        
        sloRegionOpacity(onhCircle ~= 0) =  PARAMETERS.VISU_OPACITY_REGIONMAP;
        
        onhCircleTemp = onhCircle;
        onhCircleTemp = flipdim(onhCircle,1);
        sloRegionOpacity = flipdim(sloRegionOpacity,1);
        
        [onhCircleTemp sloRegionPosition] = registerEnfaceView(onhCircleTemp, ActDataDescriptors);
        sloRegionOpacity = registerEnfaceView(sloRegionOpacity, ActDataDescriptors);
        
        onhCircleTemp = grayToColor(onhCircleTemp, 'twocolors', 'colors', ...
            [PARAMETERS.VISU_COLOR_ONHMAP_LOW; PARAMETERS.VISU_COLOR_ONHMAP_HIGH], ...
            'cutoff', [0 1]);
        
         dispSlo = combineSloEnface(dispSlo, onhCircleTemp, sloRegionPosition, ...
                    'overlay', sloRegionOpacity);
         dispSlo = drawMarkerSlo(dispSlo, sloONHCenter);
    end
    
    set(hMain,'CurrentAxes',hSlo);
    imagesc(dispSlo);
    axis image;
    axis off;
    colormap gray;
end


function refreshDispInfoText()   
    text = cell(1,1);
    
    text{1} = ['File: ' ActDataDescriptors.filename ' - Pos: ' deblank(ActDataDescriptors.Header.ScanPosition) ' - ID: ' deblank(ActDataDescriptors.Header.ID) ' - PatientID: ' deblank(ActDataDescriptors.Header.PatientID)];

    set(hInfo, 'String', text);
end


function refreshDispComplete()
    refreshDispInfoText();
    refreshDispSlo();
end

end