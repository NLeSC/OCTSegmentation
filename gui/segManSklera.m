function segManSklera(ActDataDescriptors, guiMode)
% segManCORRECT Manual correction of the automated RPE segmentations

disp('Starting manual sklera segmentation...');

%--------------------------------------------------------------------------
% GLOBAL CONST
%--------------------------------------------------------------------------

global PARAMETER_FILENAME;
PARAMETERS = loadParameters('SKLERA', PARAMETER_FILENAME);

SKLERATAGS = getMetaTag('Sklera', 'both');
RPETAGS = getMetaTag('RPE', 'both');

%--------------------------------------------------------------------------
% GLOBAL VARIABLES
%--------------------------------------------------------------------------

activeDispSqrt = 1; %0: single sqrt, 1: Dsqrt, 2: DDsqrt
activeDispBorder = 2; %2: Thick, 1: Thin, 0: Off

errVec = [];
errVecPos = 1;

segmentation = [];

ActDataDescriptors.fileNumber = 1;
ActDataDescriptors.bScanNumber = 1;

ActDataDescriptors.Header = [];
ActDataDescriptors.BScanHeader = [];
actBScans = [];
actSlo = [];

pointBF = [];
activeMode = 0; %0: Start, 1: Spline, 2: Free drawing

dispOct = []; % Actual BScan to be displayed. Stored in RGB format.
dispOctAct = [];

ActDataDescriptors.evaluatorName = 'Default';

drawActive = 0;
transform = [];

%--------------------------------------------------------------------------
% GUI Components
%--------------------------------------------------------------------------

hMain = figure('Visible','off','Position',[440,500,990,495],...
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

set(hMain,'Name','OCTSEG SKLERA SEGMENTATION');

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
    'String','Spline Segmentation',...
    'BackgroundColor', 'blue',...
    'FontSize', 12,...
    'HorizontalAlignment', 'center', ...
    'Visible', 'off');

hInfo = uicontrol('Style','text','String','No Info',...
    'BackgroundColor', [1 1 1],...
    'FontSize', 10,...
    'HorizontalAlignment', 'left',...
    'Units','pixels',...
    'Position',[15,55,170,100]);

hSqrt = uicontrol('Style','pushbutton','String','DDsqrt',...
    'FontSize', 10,...
    'BackgroundColor', [0.7 0.7 0.9],...
    'Units','pixels',...
    'Callback',{@hSqrtCallback});

hDispBorder = uicontrol('Style','pushbutton','String','Sklera OFF',...
    'FontSize', 10,...
    'BackgroundColor', [0.7 0.7 0.9],...
    'Units','pixels',...
    'Callback',{@hDispBorderCallback});

hStartOver = uicontrol('Style','pushbutton','String','Start Over',...
    'FontSize', 10,...
    'BackgroundColor', [1 0.6 0.4],...
    'Units','pixels',...
    'Callback',{@hStartOverCallback});

hActiveMode = uicontrol('Style','pushbutton','String','Start Freehand Correction',...
    'BackgroundColor', [0.7 1 0.7],...
    'FontSize', 10,...
    'Units','pixels',...
    'Callback',{@hActiveModeCallback});

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

%uiwait(hMain);

%--------------------------------------------------------------------------
% GUI Mouse functions
%--------------------------------------------------------------------------

function hButtonDownFcn(hObject, eventdata)
    if (ancestor(gco,'axes') == hOct)
        if activeMode == 2
            mouseStart = get(hOct,'currentpoint');
            drawActive = true;
            errVec(errVecPos, 1) = round(borderCheckY(mouseStart(1,1)));
            errVec(errVecPos, 2) = errVec(errVecPos, 1);
                  
            pointBF = [errVec(errVecPos, 1) round(mouseStart(1,2))];
        elseif activeMode == 1
            splinePoint();
            refreshDispOct();
        end
    end
end


function hButtonUpFcn(hObject, eventdata)
    if activeMode == 2
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
    if activeMode == 2
        if drawActive == true
            localMousePoint();
        end
    end
   
end

% Mouse moving function
%------------------------------------------------------------------
function localMousePoint()
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
            segmentation(i) = pointBF(2);
        end
    else
        for i = updateColumns
            segmentation(i) = pointBF(2) + diff * ((i - pointBF(1)) / abs(diffY));
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

function splinePoint()
        pt = get(hOct,'currentpoint');

        actPoint = [borderCheckY(pt(1,1)) round(pt(1,2))];
        if size(errVec, 1) > 0
        if numel(find(errVec(:,1) == actPoint(1,1))) == 0 
            errVec = [errVec; actPoint];
        else
            errVec(find(errVec(:,1)== actPoint(1,1)), :) = actPoint;
        end
        else
            errVec = actPoint;
        end
        
        calcSpline();
end

function calcSpline()
    [xSorted idx] = sort(errVec(:,1));
    errVecTemp(:,1) = xSorted;
    errVecTemp(:,2) = errVec(idx, 2);
        
    if size(errVec, 1) > 1
        segmentation = spline(errVecTemp(:,1), errVecTemp(:,2), 1:size(segmentation, 2));
        segmentation(segmentation < 1) = 0;
        segmentation(segmentation > size(dispOct, 1)) =  0;   
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

function hUndoCallback(hObject, eventdata)
    if errVecPos ~= 1 && activeMode == 2
        disp('No Undo Available!');
    elseif activeMode == 1
        if size(errVec, 1) == 1
            errVec = [];
        elseif size(errVec, 1) == 2
            errVec = errVec(1,:);
            segmentation = zeros(1, ActDataDescriptors.Header.SizeX, 'single');
        elseif size(errVec, 1) > 2
            errVec = errVec(1:end-1, :);
            calcSpline();
            refreshDispOct();
        end
    else
        disp('No Undo Available!');
    end
    refreshDispOct();
end


function hStartOverCallback(hObject, eventdata)
    segmentation = zeros(1, ActDataDescriptors.Header.SizeX, 'single');
    errVec = [];
    errVecPos = 1;
    activeMode = 1;
    set(hActiveMode, 'String','Start Freehand');
    refreshDispOct();
end


function hNextImgCallback(hObject, eventdata)
    activeMode = 0;
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
    
    if guiMode == 1 || guiMode == 4    
        prepareDispOct();
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
end


function hBeforeImgCallback(hObject, eventdata)
    activeMode = 0;
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
    
    if guiMode == 1 || guiMode == 4     
        prepareDispOct();
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
end


function hSqrtCallback(hObject, eventdata)
    if activeDispSqrt == 0
        activeDispSqrt = 1;
        set(hSqrt, 'String','DDsqrt');
    elseif activeDispSqrt == 1
        activeDispSqrt = 2;
        set(hSqrt, 'String','sqrt');
    elseif activeDispSqrt == 2
        activeDispSqrt = 0;
        set(hSqrt, 'String','Dsqrt');
    end

   prepareDispOct();
   refreshDispOct()
end


function hActiveModeCallback(hObject, eventdata)
    if activeMode == 1
        activeMode = 2;
        errVec = [];
        errVecPos = 1;
        prepareDispOct();
        set(hActiveMode, 'String','Freehand active');
    end
    
    refreshDispOct();
end

function prepareDispOct()
    if guiMode == 2 || guiMode == 3
        dispOct = single(actBScans);
    else
        dispOct = single(actBScans(:,:,ActDataDescriptors.bScanNumber));
    end

    [rpeAuto rpeMan] = loadSingleSeg(RPETAGS);
    if numel(rpeMan) == 0
        rpe = rpeAuto;
    else
        rpe = rpeMan;
    end
    
    [dispOct flatRPE transformLine] = alignAScans(dispOct, PARAMETERS, rpe);

    transform = transformLine;

    dispOct = sqrt(dispOct);

    if activeDispSqrt == 1
        dispOct = sqrt(dispOct);
    elseif activeDispSqrt == 2
        dispOct = sqrt(dispOct);
        dispOct = sqrt(dispOct);
    end

    dispOct(dispOct > 1) = 0;
    dispOct(:,:,2) = dispOct;
    dispOct(:,:,3) = dispOct(:,:,1);

    dispOctAct = dispOct;
    
    refreshLayout();
end

function hDispBorderCallback(hObject, eventdata)
    if activeDispBorder == 0
        activeDispBorder = 1;
        set(hDispBorder, 'String','Sklera Thick');
    elseif activeDispBorder == 1
        activeDispBorder = 2;
        set(hDispBorder, 'String','Sklera Off');
    elseif activeDispBorder == 2
        activeDispBorder = 0;
        set(hDispBorder, 'String','Sklera Thin');
    else
    end
    refreshDispOct()
end

function hSelectorCallback(hObject, eventdata)
    if guiMode == 1 || guiMode == 4
        ActDataDescriptors.bScanNumber = round(get(hSelector, 'Value'));
    elseif guiMode == 2 || guiMode == 3
        ActDataDescriptors.fileNumber = round(get(hSelector, 'Value'));
    end

    if guiMode == 1 || guiMode == 4
        loadSeg();
        prepareDispOct();
        refreshDispOct();
        refreshDispInfoText();
    elseif guiMode == 2 || guiMode == 3
        ActDataDescriptors.filename = [ActDataDescriptors.filenameList{ActDataDescriptors.fileNumber}  ActDataDescriptors.filenameEnding];
        loadDispFile();
        loadSeg();
        refreshDispComplete;
    end   
end

%--------------------------------------------------------------------------
% Other functions and algorithms
%--------------------------------------------------------------------------

% Functions for loading & manipulating data and images
%------------------------------------------------------------------
function loadDispFile()
    if guiMode == 2 || guiMode == 3
        [numDescriptor openFuncHandle] = examineOctFile(ActDataDescriptors.pathname, [ActDataDescriptors.filenameList{ActDataDescriptors.fileNumber}  ActDataDescriptors.filenameEnding]);
        [ActDataDescriptors.Header, ActDataDescriptors.BScanHeader, actSlo, actBScans] = openFuncHandle([ActDataDescriptors.pathname ActDataDescriptors.filenameList{ActDataDescriptors.fileNumber}  ActDataDescriptors.filenameEnding]);
    elseif guiMode == 1 || guiMode == 4
        [numDescriptor openFuncHandle] = examineOctFile(ActDataDescriptors.pathname, ActDataDescriptors.filename);
        [ActDataDescriptors.Header, ActDataDescriptors.BScanHeader, actSlo, actBScans] = openFuncHandle([ActDataDescriptors.pathname ActDataDescriptors.filename]);
    end
    if numDescriptor == 0
        disp('Refresh Disp File: File is no OCT file.');
        return;
    end
    errVec = [];
    errVecPos = 1;
    prepareDispOct();
   
    disp(['Display file loaded: ' ActDataDescriptors.pathname ActDataDescriptors.filename]);
end

function loadSeg()
    [segAutoSingle segManSingle status] = loadSingleSeg(SKLERATAGS);
    if status == 1
        segmentation = segAutoSingle;
    else
        segmentation = segManSingle;
    end
    if status ~= 0
        segmentation = segmentation - transform;
        activeMode = 2;
        errVec = [];
        errVecPos = 1;
        set(hActiveMode, 'String','Freehand active');
    else
        activeMode = 1;
        errVec = [];
        errVecPos = 1;
        set(hActiveMode, 'String','Start Freehand Correction');
    end
end

function [segAutoSingle segManSingle status] = loadSingleSeg(tags)
    status = 0;
    %status: 0: Nothing done yet, 1: Auto available: 2: Manual available
    if guiMode == 1 || guiMode == 4
        segAutoSingle =  readOctMeta([ActDataDescriptors.pathname ActDataDescriptors.filenameList{ActDataDescriptors.bScanNumber}], [ActDataDescriptors.evaluatorName tags{1} 'Data']);
        segManSingle = readOctMeta([ActDataDescriptors.pathname ActDataDescriptors.filenameList{ActDataDescriptors.bScanNumber}], [ActDataDescriptors.evaluatorName tags{2} 'Data']);
    elseif guiMode == 2 || guiMode == 3
        segAutoSingle =  readOctMeta([ActDataDescriptors.pathname ActDataDescriptors.filenameList{ActDataDescriptors.fileNumber}], [ActDataDescriptors.evaluatorName tags{1} 'Data']);
        segManSingle =  readOctMeta([ActDataDescriptors.pathname ActDataDescriptors.filenameList{ActDataDescriptors.fileNumber}], [ActDataDescriptors.evaluatorName tags{2} 'Data']);
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



function createDispOct(updateColumns)
    if(nargin == 0)
        updateColumns = 1:size(dispOct,2);
    end

    dispOctAct(:,updateColumns,:) = dispOct(:,updateColumns,:);

    if activeDispBorder == 2
        dispOctAct(:,updateColumns,:) = drawLinesOct(dispOctAct(:,updateColumns,:), segmentation(updateColumns), 'LineColors', PARAMETERS.SKLERA_COLOR_SKLERA, 'double', 1);
    elseif activeDispBorder == 1
        dispOctAct(:,updateColumns,:) = drawLinesOct(dispOctAct(:,updateColumns,:), segmentation(updateColumns), 'LineColors', PARAMETERS.SKLERA_COLOR_SKLERA);
    end
    
    if activeMode == 1 && numel(errVec) ~= 0
        temp = [errVec; errVec + 1; errVec - 1; [(errVec(:,1) + 1) (errVec(:,2) - 1 )]; [(errVec(:,1) - 1) (errVec(:,2) + 1)]];
        temp = [temp; [(errVec(:,1) + 1) (errVec(:,2))]; [(errVec(:,1) - 1) (errVec(:,2))]];
        temp = [temp; [(errVec(:,1)) (errVec(:,2) - 1 )]; [(errVec(:,1)) (errVec(:,2) + 1)]];
        temp = [temp; [(errVec(:,1) + 2) (errVec(:,2))]; [(errVec(:,1) - 2) (errVec(:,2))]];
        temp = [temp; [(errVec(:,1)) (errVec(:,2) - 2 )]; [(errVec(:,1)) (errVec(:,2) + 2)]];
        temp = [temp; [(errVec(:,1) + 3) (errVec(:,2))]; [(errVec(:,1) - 3) (errVec(:,2))]];
        temp = [temp; [(errVec(:,1)) (errVec(:,2) - 3 )]; [(errVec(:,1)) (errVec(:,2) + 3)]];
        
        temp(1,temp(:,1) > size(dispOctAct, 1)) = size(dispOctAct, 1);
        temp(2,temp(:,2) > size(dispOctAct, 2)) = size(dispOctAct, 2);
        temp(temp < 1) = 1;
        for i = 1:size(temp, 1)
            dispOctAct(temp(i, 2), temp(i,1), 1) = PARAMETERS.SKLERA_COLOR_POINTS(1);
            dispOctAct(temp(i, 2), temp(i,1), 2) = PARAMETERS.SKLERA_COLOR_POINTS(2);
            dispOctAct(temp(i, 2), temp(i,1), 3) = PARAMETERS.SKLERA_COLOR_POINTS(3);
        end
    end
end

function writesegManSeg()    
    if guiMode == 1 || guiMode == 4
        writeOctMeta([ActDataDescriptors.pathname ActDataDescriptors.filenameList{ActDataDescriptors.bScanNumber}], [ActDataDescriptors.evaluatorName SKLERATAGS{2}], 1, '%d');
        writeOctMeta([ActDataDescriptors.pathname ActDataDescriptors.filenameList{ActDataDescriptors.bScanNumber}], [ActDataDescriptors.evaluatorName SKLERATAGS{2} 'Data'], segmentation + transform, '%.2f');
    elseif guiMode == 2 || guiMode == 3
        writeOctMeta([ActDataDescriptors.pathname ActDataDescriptors.filenameList{ActDataDescriptors.fileNumber}], [ActDataDescriptors.evaluatorName SKLERATAGS{2}], 1, '%d');
        writeOctMeta([ActDataDescriptors.pathname ActDataDescriptors.filenameList{ActDataDescriptors.fileNumber}], [ActDataDescriptors.evaluatorName SKLERATAGS{2} 'Data'], segmentation + transform, '%.2f');
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
        set(hActiveMode, 'Visible', 'off');
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
           
        if numel(ActDataDescriptors.Header) ~= 0            
            if ActDataDescriptors.Header.SizeX > size(dispOct, 1)
                octWidth = (width - sloWidth  - 4 * border);
                octHeight = round(octWidth * size(dispOct, 1) / ActDataDescriptors.Header.SizeX);
                if octHeight > (height - 2 * border)
                    octHeight = (height - 2 * border);
                    octWidth = round(octHeight /  size(dispOct, 1) * ActDataDescriptors.Header.SizeX);
                end
            else
                octHeight = height - 2 * border;
                octWidth = round(octHeight /  size(dispOct, 1) * ActDataDescriptors.Header.SizeX);
            end
        else
            octWidth = (width - sloWidth - 4 * border);
            octHeight = octWidth;
        end      
        
        set(hOct, 'Position', [(3 * border + sloWidth) (height - border - octHeight) octWidth octHeight]);

        % Display Main buttons (left side)
        
        set(hActiveMode, 'Position', [border (height - 3 * border - sloHeight - infotextHeight - buttonHeight) ...
            sloWidth buttonHeight]);
        
        set(hStartOver, 'Position', [border (height - 5 * border - sloHeight - infotextHeight - 2 * buttonHeight) ...
            sloWidth buttonHeight]);
        set(hUndo, 'Position', [border (height - 6 * border - sloHeight - infotextHeight - 3 * buttonHeight) ...
            sloWidth buttonHeight]);

        set(hSqrt, 'Position', [border (height - 8 * border - sloHeight - infotextHeight - 4 * buttonHeight) ...
            floor((sloWidth - border) / 2) buttonHeight]);
        set(hDispBorder, 'Position', [(2*border + floor((sloWidth - border) / 2)) ...
            (height - 8 * border - sloHeight - infotextHeight - 4 * buttonHeight) ...
            ceil((sloWidth - border) / 2) buttonHeight]);

        
        % Display Navigation buttons (bottom of window)
        
        naviBase = height - 8 * border - sloWidth - infotextHeight - 4 * buttonHeight;
        if((naviBase + 2 * border + 2 * selectorHeight) > (height - border - octHeight))
            naviBase = height - border - octHeight - (4 * border + 2 * selectorHeight + buttonHeight);
        end
        
        set(hBeforeImg, 'Position', [(3 * border + sloWidth) ...
            naviBase + (2 * border + 2 * selectorHeight) ...
            floor((octWidth - infoNumWidth) / 2) ...
            buttonHeight]);
        set(hNumText, 'Position', [((3 * border + sloWidth) + floor((octWidth - infoNumWidth) / 2)) ...
            naviBase + (2 * border + 2 * selectorHeight) ...
            infoNumWidth floor(buttonHeight * 0.8)]);
        set(hNextImg, 'Position', [((3 * border + sloWidth) + infoNumWidth + floor((octWidth - infoNumWidth) / 2)) ...
            naviBase + (2 * border + 2 * selectorHeight) ...
            ceil((octWidth - infoNumWidth) / 2) buttonHeight]);
        
        set(hManPerformedText, 'Position', [(3 * border + sloWidth) ...
            naviBase + (border + selectorHeight) ...
            (width - 4 * border - sloWidth) selectorHeight]);

        set(hSelector, 'Position', [(3 * border + sloWidth) ...
            naviBase ...
            (width - 4 * border - sloWidth) selectorHeight]); 

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

        set(hMain,'CurrentAxes',hOct);
        axis image;
        axis off;
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
    axis image;
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
    if guiMode == 1 || guiMode == 4
        set(hNumText, 'String', [num2str(ActDataDescriptors.bScanNumber) '/' num2str(ActDataDescriptors.Header.NumBScans)]);
    elseif guiMode == 2 || guiMode == 3       
        set(hNumText, 'String', [num2str(ActDataDescriptors.fileNumber) '/' num2str(numel(ActDataDescriptors.filenameList))]);
    end
    
    text = cell(1,1);
    if guiMode == 1 || guiMode == 4
        text{1} = ['File: ' ActDataDescriptors.filename ' - #BScan: ' num2str(ActDataDescriptors.bScanNumber) ' - Pos: ' deblank(ActDataDescriptors.Header.ScanPosition)];
    elseif guiMode == 2 || guiMode == 3 
        text{1} = ['File: ' ActDataDescriptors.filename ' - Pos: ' deblank(ActDataDescriptors.Header.ScanPosition)];
    end

    text{2} = ['ID: ' deblank(ActDataDescriptors.Header.ID) ' - PatientID: ' deblank(ActDataDescriptors.Header.PatientID) ' - VisitID: ' deblank(ActDataDescriptors.Header.VisitID)];

    set(hInfo, 'String', text);
    
    if activeMode == 1
        set(hManPerformedText, 'String','Spline segmentation active',...
        'BackgroundColor', 'blue');
    elseif activeMode == 2
        set(hManPerformedText, 'String','Freehand correction',...
        'BackgroundColor', 'green');
    end
end


function refreshDispComplete()
    refreshDispInfoText();
    refreshDispSlo();
    refreshDispOct();
end


% Small helper functions
%---------------------------
function ret = borderCheckY(val)
    if val > size(segmentation,2)
        val = size(segmentation,2);
    elseif val < 1
        val = 1;
    end
    ret = round(val);
end

end

