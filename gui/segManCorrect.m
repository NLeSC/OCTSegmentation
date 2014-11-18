function segManCorrect(ActDataDescriptors, guiMode)
% segManCORRECT Manual correction of the automated RPE segmentations

disp('Starting manual correction of boundaries...');

%--------------------------------------------------------------------------
% GLOBAL CONST
%--------------------------------------------------------------------------

global PARAMETER_FILENAME;
PARAMETERS = loadParameters('VISU', PARAMETER_FILENAME);

INFLPOS = 1;
ONFLPOS = 2;
IPLPOS = 3;
OPLPOS = 4;
ICLPOS = 5;
RPEPOS = 6;
NUMBOUNDS = 6;

RPETAGS = getMetaTag('RPE', 'both');
INFLTAGS = getMetaTag('INFL', 'both');
ONFLTAGS = getMetaTag('ONFL', 'both');
ICLTAGS = getMetaTag('ICL', 'both');
IPLTAGS = getMetaTag('IPL', 'both');
OPLTAGS = getMetaTag('OPL', 'both');

segColorAuto = [PARAMETERS.VISU_COLOR_INFLAUTO; PARAMETERS.VISU_COLOR_ONFLAUTO; ...
    PARAMETERS.VISU_COLOR_IPLAUTO; PARAMETERS.VISU_COLOR_OPLAUTO; PARAMETERS.VISU_COLOR_ICLAUTO; ...
    PARAMETERS.VISU_COLOR_RPEAUTO];

segColorMan = [PARAMETERS.VISU_COLOR_INFLMAN; PARAMETERS.VISU_COLOR_ONFLMAN; ...
    PARAMETERS.VISU_COLOR_IPLMAN; PARAMETERS.VISU_COLOR_OPLMAN; PARAMETERS.VISU_COLOR_ICLMAN; ...
    PARAMETERS.VISU_COLOR_RPEMAN];

%--------------------------------------------------------------------------
% GLOBAL VARIABLES
%--------------------------------------------------------------------------

activeDispSqrt = 1;
activeDispBorder = 2;
activeModeNum = 2;

mouseStart = [];
mouseEnd = [];
errVec = [];
pointBF = [];
errVecPos = 1;
activeBound = 1;

segAuto = [];
segMan = [];

ActDataDescriptors.fileNumber = 1;
ActDataDescriptors.bScanNumber = 1;

ActDataDescriptors.Header = [];
ActDataDescriptors.BScanHeader = [];
actBScans = [];
actSlo = [];

dispOct = []; % Actual BScan to be displayed. Stored in RGB format.
dispOctAct = [];

dispScale = 1; % Scales the OCT image down in transversal direction;    
dispZoomOct = 0; % Zooms to a certain point in the OCT image;
% Half the windowsize for zooming
dispOctZoomWindowSize = PARAMETERS.VISU_ZOOM_WINDOWSIZE;

ActDataDescriptors.evaluatorName = 'Default';

loadSegStat = zeros(NUMBOUNDS, 2, 'uint8');

drawActive = 0;

%--------------------------------------------------------------------------
% GUI Components
%--------------------------------------------------------------------------

hMain = figure('Visible','off','Position',[10,10,1015,620],...
    'WindowButtonDownFcn', @hButtonDownFcn,...
    'WindowButtonUpFcn', @hButtonUpFcn,...
    'ResizeFcn', @hResizeFcn,...
    'Color', 'white',...
    'Units','pixels',...
    'MenuBar', 'none',...
    'WindowStyle', 'normal',...
    'CloseRequestFcn', {@hCloseRequestFcn},...
    'WindowButtonMotionFcn', @hButtonMotionFcn);
movegui(hMain,'center');

set(hMain,'Name','OCTSEG BOUNDARY CORRECTION');

% Control Buttons ---------------------------------------------------------

hUndo = uicontrol('Style','pushbutton','String','Undo',...
    'BackgroundColor', [1 0.4 0.4],...
    'FontSize', 10,...
    'Units','pixels',...
    'Callback',{@hUndoCallback});

hNextImg = uicontrol('Style','pushbutton','String','Next & Save',...
    'FontSize', 10,...
    'Units','pixels',...
    'Callback',{@hNextImgCallback});

hBeforeImg = uicontrol('Style','pushbutton','String','Before & Save',...
    'FontSize', 10,...
    'Units','pixels',...
    'Callback',{@hBeforeImgCallback});

hNumText = uicontrol('Style','text','String','No Info',...
    'BackgroundColor', [1 1 1],...
    'FontSize', 12,...
    'HorizontalAlignment', 'center',...
    'Units','pixels',...
    'Position',[80,15,40,25]);

hManPerformedText = uicontrol(hMain, 'Style','text',...
    'Units','pixels',...
    'String','No Info',...
    'BackgroundColor', 'green',...
    'FontSize', 12,...
    'HorizontalAlignment', 'center', ...
    'Visible', 'off');

hInfo = uicontrol('Style','text','String','No Info',...
    'BackgroundColor', [1 1 1],...
    'FontSize', 10,...
    'HorizontalAlignment', 'left',...
    'Units','pixels',...
    'Position',[15,55,170,100]);

hSqrt = uicontrol('Style','pushbutton','String','Dsqrt',...
    'FontSize', 10,...
    'BackgroundColor', [0.7 0.7 0.9],...
    'Units','pixels',...
    'Callback',{@hSqrtCallback});

hScale = uicontrol('Style','pushbutton','String','Scale 1:1',...
    'FontSize', 10,...
    'BackgroundColor', [0.7 0.7 0.9],...
    'Units','pixels',...
    'Callback',{@hScaleCallback});

hDispBorder = uicontrol('Style','pushbutton','String','OFF',...
    'FontSize', 10,...
    'BackgroundColor', [0.7 0.7 0.9],...
    'Units','pixels',...
    'Callback',{@hDispBorderCallback});

hStartOver = uicontrol('Style','pushbutton','String','Start Over',...
    'FontSize', 10,...
    'BackgroundColor', [1 0.6 0.4],...
    'Units','pixels',...
    'Callback',{@hStartOverCallback});

hSelector = uicontrol(hMain, 'Style', 'slider',...
    'Units','pixels',...
    'Callback', @hSelectorCallback, ...
    'Visible', 'off');

% Images ------------------------------------------------------------------

hOct = axes('Units','Pixels', ...
    'Parent', hMain,...
    'Position',[200,15,775,500]);

hSlo = axes('Units','pixels',...
    'Parent', hMain,...
    'Visible', 'off');

% Boundary Selectors ------------------------------------------------------

hShowInfo = uicontrol('Style','text','String','Show',...
    'BackgroundColor', [1 1 1],...
    'FontSize', 10,...
    'HorizontalAlignment', 'center',...
    'Units','pixels');

hEditInfo = uicontrol('Style','text','String','Edit',...
    'BackgroundColor', [1 1 1],...
    'FontSize', 10,...
    'HorizontalAlignment', 'left',...
    'Units','pixels');

hRPEshow = uicontrol('Style','togglebutton','String','RPE',...
    'Max', 1, 'Min', 0, ...
    'Value', 1, ...
    'Units','pixels',...
    'Callback',{@hShowCallback},...
    'Visible', 'off');

hRPEedit = uicontrol('Style','checkbox',...
    'Units','pixels',...
    'Max', 1, 'Min', 0, ...
    'Value', 1, ...
    'Callback',{@hEditCallback},...
    'Visible', 'off');

hINFLshow = uicontrol('Style','togglebutton','String','INFL',...
    'Max', 1, 'Min', 0, ...
    'Value', 1, ...
    'Units','pixels',...
    'Callback',{@hShowCallback},...
    'Visible', 'off');

hINFLedit = uicontrol('Style','checkbox',...
    'Units','pixels',...
    'Max', 1, 'Min', 0, ...
    'Value', 1, ...
    'Callback',{@hEditCallback},...
    'Visible', 'off');

hONFLshow = uicontrol('Style','togglebutton','String','ONFL',...
    'Max', 1, 'Min', 0, ...
    'Value', 1, ...
    'Units','pixels',...
    'Callback',{@hShowCallback},...
    'Visible', 'off');

hONFLedit = uicontrol('Style','checkbox',...
    'Units','pixels',...
    'Max', 1, 'Min', 0, ...
    'Value', 1, ...
    'Callback',{@hEditCallback},...
    'Visible', 'off');

hICLshow = uicontrol('Style','togglebutton','String','ICL',...
    'Max', 1, 'Min', 0, ...
    'Value', 1, ...
    'Units','pixels',...
    'Callback',{@hShowCallback},...
    'Visible', 'off');

hICLedit = uicontrol('Style','checkbox',...
    'Units','pixels',...
    'Max', 1, 'Min', 0, ...
    'Value', 1, ...
    'Callback',{@hEditCallback},...
    'Visible', 'off');

hIPLshow = uicontrol('Style','togglebutton','String','IPL',...
    'Max', 1, 'Min', 0, ...
    'Value', 1, ...
    'Units','pixels',...
    'Callback',{@hShowCallback},...
    'Visible', 'off');

hIPLedit = uicontrol('Style','checkbox',...
    'Units','pixels',...
    'Max', 1, 'Min', 0, ...
    'Value', 1, ...
    'Callback',{@hEditCallback},...
    'Visible', 'off');

hOPLshow = uicontrol('Style','togglebutton','String','OPL',...
    'Max', 1, 'Min', 0, ...
    'Value', 1, ...
    'Units','pixels',...
    'Callback',{@hShowCallback},...
    'Visible', 'off');

hOPLedit = uicontrol('Style','checkbox',...
    'Units','pixels',...
    'Max', 1, 'Min', 0, ...
    'Value', 1, ...
    'Callback',{@hEditCallback},...
    'Visible', 'off');

%--------------------------------------------------------------------------
% GUI Init
%--------------------------------------------------------------------------
 
ActDataDescriptors.fileNumber = 1;
ActDataDescriptors.bScanNumber = 1;
loadDispFile();
loadSeg();

setSelectorSize(hSelector, guiMode, ActDataDescriptors);
refreshLayout();
refreshDispComplete;

% uiwait(hMain);

%--------------------------------------------------------------------------
% GUI Mouse functions
%--------------------------------------------------------------------------

function hButtonDownFcn(hObject, eventdata)
    if (ancestor(gco,'axes') == hOct)
        if strcmp(get(hObject, 'SelectionType'), 'normal')
            if activeModeNum == 2
                mouseStart = get(hOct,'currentpoint');
                drawActive = true;
                errVec(errVecPos, 1) = round(borderCheckY(mouseStart(1,1)));
                errVec(errVecPos, 2) = errVec(errVecPos, 1);

                idxBounds = segMan(:,errVec(errVecPos, 1)) ~= 0;
                idxEdit = getActiveBounds();
                idx = find(idxBounds & idxEdit);

                if numel(idx) == 0
                    drawActive = false;
                    return;
                end

                bounds = segMan(idx,errVec(errVecPos, 1));
                dist = abs(bounds - mouseStart(1,2));

                [sortDist, IX] = sort(dist, 'ascend');

                activeBound = idx(IX(1));
                errVec(errVecPos, 3) = activeBound;

                % disp(activeBound);

                pointBF = [errVec(errVecPos, 1) round(mouseStart(1,2))];
            end
        elseif strcmp(get(hObject, 'SelectionType'), 'alt')
            mousePoint = get(hOct,'currentpoint');

            if ActDataDescriptors.Header.ScanPattern == 2
                [octPos sloPos] = convertPosition([mousePoint(1,1) ActDataDescriptors.bScanNumber mousePoint(1,2) ], ...
                    'OctToSloCirc', ActDataDescriptors);
            else
                [octPos sloPos] = convertPosition([mousePoint(1,1) ActDataDescriptors.bScanNumber mousePoint(1,2) ], ...
                    'OctToSloVol', ActDataDescriptors);
            end

            if numel(dispZoomOct) == 1
                dispZoomOct = octPos;
            else
                dispZoomOct = 0;
            end
            
            refreshLayout();
        end
    end
end


function hButtonUpFcn(hObject, eventdata)
    if activeModeNum == 2
        if drawActive ==  true
            actPoint = get(hOct,'currentpoint');
            
            if actPoint(1) < errVec(errVecPos, 1)
                errVec(errVecPos, 1) = actPoint(1);
            elseif actPoint(1) > errVec(errVecPos, 2)
                errVec(errVecPos, 2) = actPoint(1);
            end

            errVecPos = errVecPos + 1;
        end
        drawActive = false;
    end

end


function hButtonMotionFcn(hObject, eventdata)
    if activeModeNum == 2
        if drawActive == true
            localMousePoint();
        end
    end
end

% Mouse moving function
%------------------------------------------------------------------
function localMousePoint 
    switched = 0;
    pt = get(hOct,'currentpoint');
           
    actPoint = [round(borderCheckY(pt(1,1))) round(pt(1,2))];
    
    if actPoint(1) < errVec(errVecPos, 1)
        errVec(errVecPos, 1) = actPoint(1);
    elseif actPoint(1) > errVec(errVecPos, 2)
        errVec(errVecPos, 2) = actPoint(1);
    end
    
    if actPoint(1) < pointBF(1)
        temp = pointBF;
        pointBF = actPoint;
        actPoint = temp;
        switched = 1;
    end

    diff = actPoint(2) - pointBF(2);
    diffY = actPoint(1) - pointBF(1);
    updateColumns = pointBF(1):1:actPoint(1);
    if diffY == 0
        for i = updateColumns
            segMan(activeBound, i) = pointBF(2);
        end
    else
        for i = updateColumns
            segMan(activeBound, i) = pointBF(2) + diff * ((i - pointBF(1)) / abs(diffY));
        end
    end
    
    if pointBF(1) == 1
        updateColumns = pointBF(1):1:actPoint(1) + 1;
    elseif actPoint(1) == ActDataDescriptors.Header.SizeX;
        updateColumns = pointBF(1)-1:1:actPoint(1);
    else
        updateColumns = pointBF(1)-1:1:actPoint(1) + 1;
    end
    
    if switched == 0
        pointBF = actPoint;
    end
    
    refreshDispOct(updateColumns);
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

function hUndoCallback(hObject, eventdata)
    if errVecPos ~= 1 && activeModeNum == 2
        errVecPos = errVecPos - 1;

        segMan(errVec(errVecPos,3), min(errVec(errVecPos,1:2)):max(errVec(errVecPos,1:2))) = ...
            segAuto(errVec(errVecPos,3), min(errVec(errVecPos,1:2)):max(errVec(errVecPos,1:2)));
        errVec = errVec(1:errVecPos - 1, :);

    else
        disp('No Undo Available!');
    end
    refreshDispOct();
end


function hStartOverCallback(hObject, eventdata)
    activeModeNum = 1;
    loadSeg();
    segMan = segAuto;
    refreshDispOct()
    activeModeNum = 2;
end


function hNextImgCallback(hObject, eventdata)
    activeModeNum = 3;
    writesegManSeg();
    
    if guiMode == 1 || guiMode == 4
        ActDataDescriptors.bScanNumber = ActDataDescriptors.bScanNumber + 1;
        if ActDataDescriptors.bScanNumber > ActDataDescriptors.Header.NumBScans
            ActDataDescriptors.bScanNumber = 1;
        end
    elseif guiMode == 2 || guiMode == 3
        ActDataDescriptors.fileNumber = ActDataDescriptors.fileNumber + 1;
        if ActDataDescriptors.fileNumber > numel(ActDataDescriptors.filenameList)
            ActDataDescriptors.fileNumber = 1;
        end
    end
   
    activeModeNum = 1;
    
    if guiMode == 1 || guiMode == 4   
        prepareDispOctGuiMode1()
        loadSeg();
        refreshDispOct();
        set(hSelector, 'Value', ActDataDescriptors.bScanNumber);
    elseif guiMode == 2 || guiMode == 3
        ActDataDescriptors.filename = [ActDataDescriptors.filenameList{ActDataDescriptors.fileNumber}  ActDataDescriptors.filenameEnding];
        loadDispFile();
        loadSeg();
        set(hSelector, 'Value', ActDataDescriptors.fileNumber);
        refreshDispComplete;
    end
    refreshDispInfoText()
    activeModeNum = 2;
end


function hBeforeImgCallback(hObject, eventdata)
    activeModeNum = 3;
    writesegManSeg();
    
    if guiMode == 1 || guiMode == 4
        ActDataDescriptors.bScanNumber = ActDataDescriptors.bScanNumber - 1;
        if ActDataDescriptors.bScanNumber < 1
            ActDataDescriptors.bScanNumber = ActDataDescriptors.Header.NumBScans;
        end
    elseif guiMode == 2 || guiMode == 3
        ActDataDescriptors.fileNumber = ActDataDescriptors.fileNumber - 1;
        if ActDataDescriptors.fileNumber < 1
            ActDataDescriptors.fileNumber = numel(ActDataDescriptors.filenameList);
        end
    end
    activeModeNum = 1;
    
    if guiMode == 1 || guiMode == 4    
        prepareDispOctGuiMode1()
        loadSeg();
        refreshDispOct();
        set(hSelector, 'Value', ActDataDescriptors.bScanNumber);
    elseif guiMode == 2|| guiMode == 3
        ActDataDescriptors.filename = [ActDataDescriptors.filenameList{ActDataDescriptors.fileNumber}  ActDataDescriptors.filenameEnding];
        loadDispFile();
        loadSeg();
        set(hSelector, 'Value', ActDataDescriptors.fileNumber);
        refreshDispComplete;
    end
    refreshDispInfoText()
    activeModeNum = 2;
end


function hSqrtCallback(hObject, eventdata)
    if activeDispSqrt == 0
        activeDispSqrt = 1;
        set(hSqrt, 'String','sqrt');
    elseif activeDispSqrt == 1
        activeDispSqrt = 0;
        set(hSqrt, 'String','Dsqrt');
    else
    end

    if guiMode == 2|| guiMode == 3
        dispOct = single(actBScans);
    else
        dispOct = single(actBScans(:,:,ActDataDescriptors.bScanNumber));
    end

    dispOct = sqrt(dispOct);

    if activeDispSqrt
        dispOct = sqrt(dispOct);
    end

    dispOct(dispOct > 1) = 0;
    dispOct(:,:,2) = dispOct;
    dispOct(:,:,3) = dispOct(:,:,1);

    refreshDispOct()
end

function hDispBorderCallback(hObject, eventdata)
    if activeDispBorder == 0
        % disp('0 to 1');
        activeDispBorder = 1;
        set(hDispBorder, 'String','Bold');
    elseif activeDispBorder == 1
        % disp('1 to 2');
        activeDispBorder = 2;
        set(hDispBorder, 'String','OFF');
    elseif activeDispBorder == 2
        % disp('2 to 0');
        activeDispBorder = 0;
        set(hDispBorder, 'String','Thin');
    else
    end
    refreshDispOct()
end

function hScaleCallback(hObject, eventdata)
    if dispScale == 1
        dispScale = 2;
        set(hScale, 'String','Scale 1:2');
    elseif dispScale == 2
        dispScale = 3;
        set(hScale, 'String','Scale 1:3');
    elseif dispScale == 3
        dispScale = 1;
        set(hScale, 'String','Scale 1:1');
    else
    end
    
    refreshLayout();
end

function hSelectorCallback(hObject, eventdata)
    if guiMode == 1|| guiMode == 4
        ActDataDescriptors.bScanNumber = round(get(hSelector, 'Value'));
    elseif guiMode == 2|| guiMode == 3
        ActDataDescriptors.fileNumber = round(get(hSelector, 'Value'));
    end

    if guiMode == 1|| guiMode == 4
        prepareDispOctGuiMode1()
        loadSeg();
        refreshDispOct();
    elseif guiMode == 2|| guiMode == 3
        ActDataDescriptors.filename = [ActDataDescriptors.filenameList{ActDataDescriptors.fileNumber}  ActDataDescriptors.filenameEnding];
        loadDispFile();
        loadSeg();
        refreshDispComplete;
    end   
    refreshDispInfoText();
end

function hEditCallback(hObject, eventdata)
    refreshDispInfoText();
end

function hShowCallback(hObject, eventdata)
    refreshDispOct();
end

%--------------------------------------------------------------------------
% Other functions and algorithms
%--------------------------------------------------------------------------

% Functions for loading & manipulating data and images
%------------------------------------------------------------------
function loadDispFile()
    if guiMode == 2|| guiMode == 3
        [numDescriptor openFuncHandle] = examineOctFile(ActDataDescriptors.pathname, [ActDataDescriptors.filenameList{ActDataDescriptors.fileNumber}  ActDataDescriptors.filenameEnding]);
        [ActDataDescriptors.Header, ActDataDescriptors.BScanHeader, actSlo, actBScans] = openFuncHandle([ActDataDescriptors.pathname ActDataDescriptors.filenameList{ActDataDescriptors.fileNumber}  ActDataDescriptors.filenameEnding]);
    elseif guiMode == 1|| guiMode == 4
        [numDescriptor openFuncHandle] = examineOctFile(ActDataDescriptors.pathname, ActDataDescriptors.filename);
        [ActDataDescriptors.Header, ActDataDescriptors.BScanHeader, actSlo, actBScans] = openFuncHandle([ActDataDescriptors.pathname ActDataDescriptors.filename]);
    end
    if numDescriptor == 0
        disp('Refresh Disp File: File is no OCT file.');
        return;
    end
    
    if guiMode == 2|| guiMode == 3
        dispOct = single(actBScans);
    else
        dispOct = single(actBScans(:,:,ActDataDescriptors.bScanNumber));
    end

    dispOct = sqrt(dispOct);
    
    if activeDispSqrt
        dispOct = sqrt(dispOct);
    end

    dispOct(dispOct > 1) = 0;
    dispOct(:,:,2) = dispOct;
    dispOct(:,:,3) = dispOct(:,:,1);
    
    dispOctAct = dispOct();
    refreshLayout();

    disp(['Display file loaded: ' ActDataDescriptors.pathname ActDataDescriptors.filename]);
end

function loadSeg()
    loadSegStat = zeros(NUMBOUNDS, 2, 'uint8');
    segAuto = zeros(NUMBOUNDS, ActDataDescriptors.Header.SizeX, 'single');
    segMan = zeros(NUMBOUNDS, ActDataDescriptors.Header.SizeX, 'single');
    
    [segAutoSingle segManSingle] = loadSingleSeg(RPETAGS, RPEPOS);
    segAuto(RPEPOS, :) = segAutoSingle;
    segMan(RPEPOS, :) = segManSingle;
    
    [segAutoSingle segManSingle] = loadSingleSeg(INFLTAGS, INFLPOS);
    segAuto(INFLPOS, :) = segAutoSingle;
    segMan(INFLPOS, :) = segManSingle;
    
    [segAutoSingle segManSingle] = loadSingleSeg(ONFLTAGS, ONFLPOS);
    segAuto(ONFLPOS, :) = segAutoSingle;
    segMan(ONFLPOS, :) = segManSingle;
    
    [segAutoSingle segManSingle] = loadSingleSeg(ICLTAGS, ICLPOS);
    segAuto(ICLPOS, :) = segAutoSingle;
    segMan(ICLPOS, :) = segManSingle;
    
    [segAutoSingle segManSingle] = loadSingleSeg(IPLTAGS, IPLPOS);
    segAuto(IPLPOS, :) = segAutoSingle;
    segMan(IPLPOS, :) = segManSingle;
    
    [segAutoSingle segManSingle] = loadSingleSeg(OPLTAGS, OPLPOS);
    segAuto(OPLPOS, :) = segAutoSingle;
    segMan(OPLPOS, :) = segManSingle;
    
end

function setLoadSegStat(pos, segAutoSingle, segManSingle)
    if numel(segAutoSingle) ~= 0
        loadSegStat(pos, 1) = 1;
    end

    if numel(segManSingle) ~= 0
        loadSegStat(pos, 2) = 1;
    end
end

function [segAutoSingle segManSingle] = loadSingleSeg(tags, pos)
    if nargin < 2
        pos = 0;
    end
    
    if guiMode == 1|| guiMode == 4
        segAutoSingle =  readOctMeta([ActDataDescriptors.pathname ActDataDescriptors.filenameList{ActDataDescriptors.bScanNumber}], [ActDataDescriptors.evaluatorName tags{1} 'Data']);
        segManSingle = readOctMeta([ActDataDescriptors.pathname ActDataDescriptors.filenameList{ActDataDescriptors.bScanNumber}], [ActDataDescriptors.evaluatorName tags{2} 'Data']);
    elseif guiMode == 2|| guiMode == 3
        segAutoSingle =  readOctMeta([ActDataDescriptors.pathname ActDataDescriptors.filenameList{ActDataDescriptors.fileNumber}], [ActDataDescriptors.evaluatorName tags{1} 'Data']);
        segManSingle =  readOctMeta([ActDataDescriptors.pathname ActDataDescriptors.filenameList{ActDataDescriptors.fileNumber}], [ActDataDescriptors.evaluatorName tags{2} 'Data']);
    end

    setLoadSegStat(pos, segAutoSingle, segManSingle)
    
    if numel(segAutoSingle) == 0
        segAutoSingle = zeros(1, ActDataDescriptors.Header.SizeX, 'single');
    end
    
    if numel(segManSingle) == 0
        segManSingle = segAutoSingle;
    end
end


function createDispOct(updateColumns)
    if(nargin == 0)
        updateColumns = 1:size(dispOct,2);
    end
    
    dispOctAct(:,updateColumns,:) = dispOct(:,updateColumns,:);
    
    segManDisp = segMan(:,updateColumns);
    segAutoDisp = segAuto(:,updateColumns);
    
    segManDisp(segManDisp == segAutoDisp) = 0;
    segAutoDisp(segManDisp ~= 0) = segManDisp(segManDisp ~= 0);
    
    segManDisp(~getShowBounds(), :) = 0;
    segAutoDisp(~getShowBounds(), :) = 0;
    
    if activeDispBorder == 2
        dispOctAct(:,updateColumns,:) = drawLinesOct(dispOctAct(:,updateColumns,:), segAutoDisp, 'LineColors', segColorAuto, 'double', 1);
        dispOctAct(:,updateColumns,:) = drawLinesOct(dispOctAct(:,updateColumns,:), segManDisp, 'LineColors', segColorMan, 'double', 1);
    elseif activeDispBorder == 1
        dispOctAct(:,updateColumns,:) = drawLinesOct(dispOctAct(:,updateColumns,:), segAutoDisp, 'LineColors', segColorAuto);
        dispOctAct(:,updateColumns,:) = drawLinesOct(dispOctAct(:,updateColumns,:), segManDisp, 'LineColors', segColorMan);
    end
end


function writesegManSeg()
    idx = getActiveBounds();

    if idx(RPEPOS)
        writesegManSegSingle(RPETAGS, RPEPOS);
    end

    if idx(INFLPOS)
        writesegManSegSingle(INFLTAGS, INFLPOS);
    end

    if idx(ONFLPOS)
        writesegManSegSingle(ONFLTAGS, ONFLPOS);
    end

    if idx(OPLPOS)
        writesegManSegSingle(OPLTAGS, OPLPOS);
    end

    if idx(IPLPOS)
        writesegManSegSingle(IPLTAGS, IPLPOS);
    end

    if idx(ICLPOS)
        writesegManSegSingle(ICLTAGS, ICLPOS);
    end
end

function writesegManSegSingle(tags, num)
    if numel(find(segMan(num, :))) ~= 0
        if guiMode == 1|| guiMode == 4
            writeOctMeta([ActDataDescriptors.pathname ActDataDescriptors.filenameList{ActDataDescriptors.bScanNumber}], [ActDataDescriptors.evaluatorName tags{2}], 1, '%d');
            writeOctMeta([ActDataDescriptors.pathname ActDataDescriptors.filenameList{ActDataDescriptors.bScanNumber}], [ActDataDescriptors.evaluatorName tags{2} 'Data'], segMan(num, :), '%.2f');
        elseif guiMode == 2|| guiMode == 3
            writeOctMeta([ActDataDescriptors.pathname ActDataDescriptors.filenameList{ActDataDescriptors.fileNumber}], [ActDataDescriptors.evaluatorName tags{2}], 1, '%d');
            writeOctMeta([ActDataDescriptors.pathname ActDataDescriptors.filenameList{ActDataDescriptors.fileNumber}], [ActDataDescriptors.evaluatorName tags{2} 'Data'], segMan(num, :), '%.2f');
        end
    end
end

% Functions used for layout & display
%-----------------------------------------------------------------

function refreshLayout()
    if guiMode == 0
        set(hMain, 'Visible', 'on');

        set(hUndo, 'Visible', 'off');
        set(hBeforeImg, 'Visible', 'off');
        set(hNextImg, 'Visible', 'off');
        set(hNumText, 'Visible', 'off');
        set(hInfo, 'Visible', 'off');
        set(hSqrt, 'Visible', 'off');
        set(hDispBorder, 'Visible', 'off');
        set(hStartOver, 'Visible', 'off');
        set(hSelector, 'Visible', 'off');
        set(hOct, 'Visible', 'off');
        set(hSlo, 'Visible', 'off');
        
        set(hShowInfo, 'Visible', 'off');
        set(hEditInfo, 'Visible', 'off');
        
        set(hRPEshow, 'Visible', 'off');
        set(hRPEedit, 'Visible', 'off');
        
        set(hINFLshow, 'Visible', 'off');
        set(hINFLedit, 'Visible', 'off');
        
        set(hONFLshow, 'Visible', 'off');
        set(hONFLedit, 'Visible', 'off');
        
        set(hICLshow, 'Visible', 'off');
        set(hICLedit, 'Visible', 'off');
        
        set(hIPLshow, 'Visible', 'off');
        set(hIPLedit, 'Visible', 'off');
        
        set(hOPLshow, 'Visible', 'off');
        set(hOPLedit, 'Visible', 'off');
    else
        set(hMain, 'Visible', 'on');

        fpos = get(hMain, 'position');

        % Define all widths & heights
        
        width = fpos(3);
        height = fpos(4);

        border = 5;
        buttonHeight = 40;
        bigButtonHeight = 60;
        selectorHeight = 20;
        sloWidth = 250;
        sloHeight = 250;
        
        editButtonWidth = 80;
        editTextHeight = 15;
        editBoxWidth = 40;
        
        infotextHeight = 40;
        infoNumWidth = 40;

        % display images and infotext
        if guiMode == 3
            set(hSlo, 'Visible', 'off');
            sloHeight = 0;
        else
            set(hSlo, 'Position', [border (height - border - sloHeight) sloWidth sloHeight]);
        end
        set(hInfo, 'Position', [border (height - 2 * border - sloHeight - infotextHeight) sloWidth infotextHeight]);
           
        if numel(ActDataDescriptors.Header) ~= 0 && numel(dispZoomOct) == 1
            if (ActDataDescriptors.Header.SizeX / dispScale) > ActDataDescriptors.Header.SizeZ
                octWidth = (width - sloWidth - editButtonWidth - editBoxWidth - 7 * border);
                octHeight = round(octWidth * ActDataDescriptors.Header.SizeZ / (ActDataDescriptors.Header.SizeX / dispScale));
                if octHeight > (height - 2 * border)
                    octHeight = (height - 2 * border);
                    octWidth = round(octHeight / ActDataDescriptors.Header.SizeZ * ActDataDescriptors.Header.SizeX / dispScale);
                end
            else
                octHeight = height - 2 * border;
                octWidth = round(octHeight / ActDataDescriptors.Header.SizeZ * (ActDataDescriptors.Header.SizeX / dispScale));
            end
        else
            octWidth = (width - sloWidth - editButtonWidth - editBoxWidth - 7 * border);
            octHeight = height - 2 * border;
        end      
        
        set(hOct, 'Position', [(3 * border + sloWidth) (height - border - octHeight) octWidth octHeight]);

        % Display Main buttons 
        
        set(hStartOver, 'Position', [border (height - 3 * border - sloHeight - infotextHeight - buttonHeight) ...
            sloWidth buttonHeight]);
        set(hUndo, 'Position', [border (height - 4 * border - sloHeight - infotextHeight - 2 * buttonHeight) ...
            sloWidth buttonHeight]);

        set(hSqrt, 'Position', [border (height - 6 * border - sloHeight - infotextHeight - 3 * buttonHeight) ...
            floor((sloWidth - 2 * border) / 3) buttonHeight]);
        set(hScale, 'Position', [(2*border + floor((sloWidth - 2 * border) / 3)) (height - 6 * border - sloHeight - infotextHeight - 3 * buttonHeight) ...
            floor((sloWidth - 2 * border) / 3) buttonHeight]);
        set(hDispBorder, 'Position', [(3*border + 2 * floor((sloWidth - 2 * border) / 3)) (height - 6 * border - sloHeight - infotextHeight - 3 * buttonHeight) ...
            ceil((sloWidth -  2 * border) / 3) buttonHeight]);

        set(hBeforeImg, 'Position', [border (height - 8 * border - sloHeight - infotextHeight - 3 * buttonHeight - bigButtonHeight) ...
            floor((sloWidth - infoNumWidth) / 2) ...
            bigButtonHeight]);
        set(hNumText, 'Position', [(border + floor((sloWidth - infoNumWidth) / 2)) ...
            (height - 8 * border - sloHeight - infotextHeight - 3 * buttonHeight - bigButtonHeight) ...
            infoNumWidth buttonHeight]);
        set(hNextImg, 'Position', [(border + infoNumWidth + floor((sloWidth - infoNumWidth) / 2)) ...
            (height - 8 * border - sloHeight - infotextHeight - 3 * buttonHeight - bigButtonHeight) ...
            ceil((sloWidth - infoNumWidth) / 2) bigButtonHeight]);
        
        set(hManPerformedText, 'Position', [border ...
            (height - 9 * border - sloHeight - infotextHeight - 3 * buttonHeight - bigButtonHeight - selectorHeight) ...
            sloWidth selectorHeight]);

        set(hSelector, 'Position', [border ...
            (height - 10 * border - sloHeight - infotextHeight - 4 * buttonHeight - bigButtonHeight - selectorHeight) ...
            sloWidth selectorHeight]);
        
        % Display edit & show buttons
        
        set(hShowInfo, 'Position', [(5 * border + sloWidth + octWidth) (height - border - editTextHeight) ...
            editButtonWidth editTextHeight]); 
        set(hEditInfo, 'Position', [(6 * border + sloWidth + editButtonWidth + octWidth) (height - border - editTextHeight) ...
            editBoxWidth editTextHeight]);
        
        set(hINFLshow, 'Position', [(5 * border + sloWidth + octWidth) (height - 2 * border - buttonHeight - editTextHeight) ...
            editButtonWidth buttonHeight]); 
        set(hINFLedit, 'Position', [(6 * border + sloWidth + editButtonWidth + octWidth) (height - 2 * border - buttonHeight - editTextHeight) ...
            editBoxWidth buttonHeight]); 
        
        set(hONFLshow, 'Position', [(5 * border + sloWidth + octWidth) (height - 3 * border - 2 * buttonHeight - editTextHeight) ...
            editButtonWidth buttonHeight]); 
        set(hONFLedit, 'Position', [(6 * border + sloWidth + editButtonWidth + octWidth) (height - 3 * border - 2 * buttonHeight - editTextHeight) ...
            editBoxWidth buttonHeight]); 
        
        set(hIPLshow, 'Position', [(5 * border + sloWidth + octWidth) (height - 4 * border - 3 * buttonHeight - editTextHeight) ...
            editButtonWidth buttonHeight]); 
        set(hIPLedit, 'Position', [(6 * border + sloWidth + editButtonWidth + octWidth) (height - 4 * border - 3 * buttonHeight - editTextHeight) ...
            editBoxWidth buttonHeight]); 
        
        set(hOPLshow, 'Position', [(5 * border + sloWidth + octWidth) (height - 5 * border - 4 * buttonHeight - editTextHeight) ...
            editButtonWidth buttonHeight]); 
        set(hOPLedit, 'Position', [(6 * border + sloWidth + editButtonWidth + octWidth) (height - 5 * border - 4 * buttonHeight - editTextHeight) ...
            editBoxWidth buttonHeight]); 
        
        set(hICLshow, 'Position', [(5 * border + sloWidth + octWidth) (height - 6 * border - 5 * buttonHeight - editTextHeight) ...
            editButtonWidth buttonHeight]); 
        set(hICLedit, 'Position', [(6 * border + sloWidth + editButtonWidth + octWidth) (height - 6 * border - 5 * buttonHeight - editTextHeight) ...
            editBoxWidth buttonHeight]); 
        
        set(hRPEshow, 'Position', [(5 * border + sloWidth + octWidth) (height - 7 * border - 6 * buttonHeight - editTextHeight) ...
            editButtonWidth buttonHeight]); 
        set(hRPEedit, 'Position', [(6 * border + sloWidth + editButtonWidth + octWidth) (height - 7 * border - 6 * buttonHeight - editTextHeight) ...
            editBoxWidth buttonHeight]);         

        % Set everything to vissible
        set(hUndo, 'Visible', 'on');
        set(hBeforeImg, 'Visible', 'on');
        set(hNextImg, 'Visible', 'on');
        set(hNumText, 'Visible', 'on');
        set(hInfo, 'Visible', 'on');
        set(hSqrt, 'Visible', 'on');
        set(hDispBorder, 'Visible', 'on');
        set(hStartOver, 'Visible', 'on');
        set(hSelector, 'Visible', 'on');
        set(hManPerformedText, 'Visible', 'on');
        set(hOct, 'Visible', 'on');
        
        if guiMode ~= 3
            set(hSlo, 'Visible', 'on');
        end
        
        set(hShowInfo, 'Visible', 'on');
        set(hEditInfo, 'Visible', 'on');
        
        set(hRPEshow, 'Visible', 'on');
        set(hRPEedit, 'Visible', 'on');
        
        set(hINFLshow, 'Visible', 'on');
        set(hINFLedit, 'Visible', 'on');
        
        set(hONFLshow, 'Visible', 'on');
        set(hONFLedit, 'Visible', 'on');
        
        set(hICLshow, 'Visible', 'on');
        set(hICLedit, 'Visible', 'on');
        
        set(hIPLshow, 'Visible', 'on');
        set(hIPLedit, 'Visible', 'on');
        
        set(hOPLshow, 'Visible', 'on');
        set(hOPLedit, 'Visible', 'on');

        refreshDispOctAxis();
        
        set(hMain,'CurrentAxes',hSlo);
        axis image;
        axis off;
        colormap gray;
    end
end

function refreshDispOct(updateColumns)
    if nargin == 0
        createDispOct();
    else
        createDispOct(updateColumns);
    end
    set(hMain,'CurrentAxes',hOct);
    imagesc(dispOctAct);
    
    refreshDispOctAxis()
end

function refreshDispOctAxis()
    set(hMain,'CurrentAxes',hOct);
    axis image; 
    set(hOct, 'DataAspectRatio', [dispScale 1 1]);
    if numel(dispZoomOct) ~= 1
        set(hOct, 'XLim', [dispZoomOct(1)- dispScale * dispOctZoomWindowSize, dispZoomOct(1) + dispScale * dispOctZoomWindowSize]);
        set(hOct, 'YLim', [dispZoomOct(3)-dispOctZoomWindowSize, dispZoomOct(3)+dispOctZoomWindowSize]);
    end
    axis off;
end

function refreshDispSlo() 
    if guiMode ~= 3
        set(hMain,'CurrentAxes',hSlo);
        imagesc(actSlo);
        axis image;
        axis off;
        colormap gray;
    end
end


function refreshDispInfoText()
    if guiMode == 1|| guiMode == 4
        set(hNumText, 'String', [num2str(ActDataDescriptors.bScanNumber) '/' num2str(ActDataDescriptors.Header.NumBScans)]);
    elseif guiMode == 2 || guiMode == 3 
        set(hNumText, 'String', [num2str(ActDataDescriptors.fileNumber) '/' num2str(numel(ActDataDescriptors.filenameList))]);
    end
    
    text = cell(1,1);
    if guiMode == 1|| guiMode == 4
        text{1} = ['File: ' ActDataDescriptors.filename ' - #BScan: ' num2str(ActDataDescriptors.bScanNumber) ' - Pos: ' deblank(ActDataDescriptors.Header.ScanPosition)];
    elseif guiMode == 2 || guiMode == 3
        text{1} = ['File: ' ActDataDescriptors.filename ' - Pos: ' deblank(ActDataDescriptors.Header.ScanPosition)];
    end

    text{2} = ['ID: ' deblank(ActDataDescriptors.Header.ID) ' - PatientID: ' deblank(ActDataDescriptors.Header.PatientID) ' - VisitID: ' deblank(ActDataDescriptors.Header.VisitID)];

    set(hInfo, 'String', text);
    
    if manSegPerformed()
        set(hManPerformedText, 'String','Already corrected',...
        'BackgroundColor', 'green');
    else
        set(hManPerformedText, 'String','No correction yet',...
        'BackgroundColor', 'red');
    end
end


function status = manSegPerformed()
    status = 1;

    if get(hRPEedit, 'Value') == 1 && loadSegStat(RPEPOS, 1) == 1 && loadSegStat(RPEPOS,2) == 0
        status = 0;
        return;
    end

    if get(hINFLedit, 'Value') == 1 && loadSegStat(INFLPOS, 1) == 1 && loadSegStat(INFLPOS,2) == 0
        status = 0;
        return;
    end

    if get(hONFLedit, 'Value') == 1 && loadSegStat(ONFLPOS, 1) == 1 && loadSegStat(ONFLPOS,2) == 0
        status = 0;
        return;
    end

    if get(hIPLedit, 'Value') == 1 && loadSegStat(IPLPOS, 1) == 1 && loadSegStat(IPLPOS,2) == 0
        status = 0;
        return;
    end

    if get(hOPLedit, 'Value') == 1 && loadSegStat(OPLPOS, 1) == 1 && loadSegStat(OPLPOS,2) == 0
        status = 0;
        return;
    end

    if get(hICLedit, 'Value') == 1 && loadSegStat(ICLPOS, 1) == 1 && loadSegStat(ICLPOS,2) == 0
        status = 0;
        return;
    end
end

function refreshDispComplete()
    refreshDispInfoText();
    refreshDispSlo();
    refreshDispOct();
end


function idx = getActiveBounds()
    idx = zeros(NUMBOUNDS, 1, 'uint8');
    if get(hRPEedit, 'Value') == 1
        idx(RPEPOS) = 1;
    end
    if get(hONFLedit, 'Value') == 1
        idx(ONFLPOS) = 1;
    end
    if get(hINFLedit, 'Value') == 1
        idx(INFLPOS) = 1;
    end
    if get(hICLedit, 'Value') == 1
        idx(ICLPOS) = 1;
    end
    if get(hIPLedit, 'Value') == 1
        idx(IPLPOS) = 1;
    end
    if get(hOPLedit, 'Value') == 1
        idx(OPLPOS) = 1;
    end

    idx = idx == 1;
end

function idx = getShowBounds()
    idx = zeros(NUMBOUNDS, 1, 'uint8');
    if get(hRPEshow, 'Value') == 1
        idx(RPEPOS) = 1;
    end
    if get(hONFLshow, 'Value') == 1
        idx(ONFLPOS) = 1;
    end
    if get(hINFLshow, 'Value') == 1
        idx(INFLPOS) = 1;
    end
    if get(hICLshow, 'Value') == 1
        idx(ICLPOS) = 1;
    end
    if get(hIPLshow, 'Value') == 1
        idx(IPLPOS) = 1;
    end
    if get(hOPLshow, 'Value') == 1
        idx(OPLPOS) = 1;
    end

    idx = idx == 1;
end

function prepareDispOctGuiMode1()
    dispOct = single(actBScans(:,:,ActDataDescriptors.bScanNumber));
    dispOct = sqrt(dispOct);

    if activeDispSqrt
        dispOct = sqrt(dispOct);
    end

    dispOct(dispOct > 1) = 0;
    dispOct(:,:,2) = dispOct;
    dispOct(:,:,3) = dispOct(:,:,1);
end


% Small helper functions
%---------------------------
function ret = borderCheckY(val)
    if val > size(segAuto,2)
        val = size(segAuto,2);
    elseif val < 1
        val = 1;
    end
    ret = round(val);
end

end

