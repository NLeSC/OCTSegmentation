function segManBV(ActDataDescriptors, guiMode)
% segManBV Manual correction of the automated BV position segmentation

disp('Starting manual correction of blood vessel segmentation...');

%--------------------------------------------------------------------------
% GLOBAL CONST
%--------------------------------------------------------------------------

global PARAMETER_FILENAME;
PARAMETERS = loadParameters('VISU', PARAMETER_FILENAME);

BVTAGS = getMetaTag('Blood Vessels', 'both');

%--------------------------------------------------------------------------
% GLOBAL VARIABLES
%--------------------------------------------------------------------------

activeDispSqrt = 1;
activeDispBorder = 1;
activeModeNum = 2;

errVec = [];
errVecPos = 1;

segAuto = [];
segMan = [];
segManTemp = [];

ActDataDescriptors.fileNumber = 1;
ActDataDescriptors.bScanNumber = 1;

ActDataDescriptors.Header = [];
ActDataDescriptors.BScanHeader = [];

actBScans = [];
actSlo = [];

activePaintMode = 0; %0: Invert, 1: BV, 2: Delete

dispOct = []; % Actual BScan to be displayed. Stored in RGB format.
dispOctAct = [];

ActDataDescriptors.evaluatorName = 'Default';

drawActive = 0;
drawColor = 0;

dispScale = 1; % Scales the OCT image down in transversal direction;    
dispZoomOct = 0; % Zooms to a certain point in the OCT image;
% Half the windowsize for zooming
dispOctZoomWindowSize = PARAMETERS.VISU_ZOOM_WINDOWSIZE;

%--------------------------------------------------------------------------
% GUI Components
%--------------------------------------------------------------------------

hMain = figure('Visible','off','Position',[440,500,990,620],...
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

set(hMain,'Name','OCTSEG BLOOD VESSEL CORRECTION');

% Control Buttons ---------------------------------------------------------

% hUndo = uicontrol('Style','pushbutton','String','Undo',...
%     'BackgroundColor', [1 0.4 0.4],...
%     'FontSize', 10,...
%     'Units','pixels',...
%     'Callback',{@hUndoCallback});

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

hSqrt = uicontrol('Style','pushbutton','String','sqrt',...
    'FontSize', 10,...
    'BackgroundColor', [0.7 0.7 0.9],...
    'Units','pixels',...
    'Callback',{@hSqrtCallback});

hScale = uicontrol('Style','pushbutton','String','Scale 1:1',...
    'FontSize', 10,...
    'BackgroundColor', [0.7 0.7 0.9],...
    'Units','pixels',...
    'Callback',{@hScaleCallback});

hDispBorder = uicontrol('Style','pushbutton','String','BV RED',...
    'FontSize', 10,...
    'BackgroundColor', [0.7 0.7 0.9],...
    'Units','pixels',...
    'Callback',{@hDispBorderCallback});

hStartOver = uicontrol('Style','pushbutton','String','Start Over',...
    'FontSize', 10,...
    'BackgroundColor', [1 0.6 0.4],...
    'Units','pixels',...
    'Callback',{@hStartOverCallback});

hPaintMode = uicontrol('Style','pushbutton','String','Invert Active',...
    'BackgroundColor', [0.7 1 0.7],...
    'FontSize', 10,...
    'Units','pixels',...
    'Callback',{@hPaintModeCallback});

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

uiwait(hMain);

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

                if activePaintMode == 0
                    drawColor = 1 - segMan(errVec(errVecPos, 1));
                elseif activePaintMode == 1
                    drawColor = 1;
                elseif activePaintMode == 2
                    drawColor = 0;
                end
                segManTemp = segMan;
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
    pt = get(hOct,'currentpoint');
           
    actPoint = [round(borderCheckY(pt(1,1))) round(pt(1,2))];
    
    errVec(errVecPos, 2) = actPoint(1);
    
    if actPoint(1) < errVec(errVecPos, 1)
       updateColumns = actPoint(1):1:errVec(errVecPos, 1);
    else
       updateColumns = errVec(errVecPos, 1):1:actPoint(1);
    end
 
    segMan = segManTemp;
    segMan(updateColumns) = drawColor;
    
    refreshDispOct();
end

function hResizeFcn(hObject, eventdata)
    refreshLayout();
end

function hCloseRequestFcn(hObject, eventdata, handles)
    complete = 1;
    uiresume;
    delete(hObject);
end

%--------------------------------------------------------------------------
% GUI Button Functions
%--------------------------------------------------------------------------

% function hUndoCallback(hObject, eventdata)
%     if errVecPos ~= 1 && activeModeNum == 2
%         errVecPos = errVecPos - 1;
% 
%         segMan(min(errVec(errVecPos,1:2)):max(errVec(errVecPos,1:2))) = ...
%             segAuto(min(errVec(errVecPos,1:2)):max(errVec(errVecPos,1:2)));
%         errVec = errVec(1:errVecPos - 1, :);
% 
%     else
%         disp('No Undo Available!');
%     end
%     refreshDispOct();
% end


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


function hSqrtCallback(hObject, eventdata)
    if activeDispSqrt == 0
        activeDispSqrt = 1;
        set(hSqrt, 'String','sqrt');
    elseif activeDispSqrt == 1
        activeDispSqrt = 0;
        set(hSqrt, 'String','Dsqrt');
    else
    end

    if guiMode == 2 || guiMode == 3
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

function hPaintModeCallback(hObject, eventdata)
    if activePaintMode == 0
        activePaintMode = 1;
        set(hPaintMode, 'String','BV active');
    elseif activePaintMode == 1
        activePaintMode = 2;
        set(hPaintMode, 'String','Delete active');
    elseif activePaintMode == 2
        activePaintMode = 0;
        set(hPaintMode, 'String','Invert active');
    end

    if guiMode == 2 || guiMode == 3
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
        activeDispBorder = 1;
        set(hDispBorder, 'String','BV RED');
    elseif activeDispBorder == 1
        activeDispBorder = 2;
        set(hDispBorder, 'String','BV OFF');
    elseif activeDispBorder == 2
        activeDispBorder = 0;
        set(hDispBorder, 'String','BV OPAQUE');
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
        prepareDispOctGuiMode1()
        loadSeg();
        refreshDispOct();
    elseif guiMode == 2 || guiMode == 3
        ActDataDescriptors.filename = [ActDataDescriptors.filenameList{ActDataDescriptors.fileNumber}  ActDataDescriptors.filenameEnding];
        loadDispFile();
        loadSeg();
        refreshDispComplete;
    end   
    refreshDispInfoText();
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
    
    if guiMode == 2 || guiMode == 3
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
    
    dispOctAct = dispOct;

    refreshLayout();
    
    disp(['Display file loaded: ' ActDataDescriptors.pathname ActDataDescriptors.filename]);
end

function loadSeg()
    if guiMode == 1 || guiMode == 4
        segAuto =  readOctMeta([ActDataDescriptors.pathname ActDataDescriptors.filenameList{ActDataDescriptors.bScanNumber}], [ActDataDescriptors.evaluatorName BVTAGS{1} 'Data']);
        segMan = readOctMeta([ActDataDescriptors.pathname ActDataDescriptors.filenameList{ActDataDescriptors.bScanNumber}], [ActDataDescriptors.evaluatorName BVTAGS{2} 'Data']);
    elseif guiMode == 2 || guiMode == 3
        segAuto =  readOctMeta([ActDataDescriptors.pathname ActDataDescriptors.filenameList{ActDataDescriptors.fileNumber}], [ActDataDescriptors.evaluatorName BVTAGS{1} 'Data']);
        segMan =  readOctMeta([ActDataDescriptors.pathname ActDataDescriptors.filenameList{ActDataDescriptors.fileNumber}], [ActDataDescriptors.evaluatorName BVTAGS{2} 'Data']);
    end

    if numel(segAuto) == 0
        segAuto = zeros(1, ActDataDescriptors.Header.SizeX, 'single');
    end
    
    if numel(segMan) == 0
        segMan = segAuto;
    end
end


function createDispOct(updateColumns)
    if(nargin == 0)
        updateColumns = 1:size(dispOct,2);
    end

    dispOctAct(:,updateColumns,:) = dispOct(:,updateColumns,:);

    if activeDispBorder == 1
        dispOctAct(:,updateColumns,:) =  drawIdxOct(dispOctAct(:,updateColumns,:), segMan(updateColumns), PARAMETERS.VISU_COLOR_BV, PARAMETERS.VISU_OPACITY_BV);
    elseif activeDispBorder == 2
        dispOctAct(:,updateColumns,:) =  drawIdxOct(dispOctAct(:,updateColumns,:), segMan(updateColumns), PARAMETERS.VISU_COLOR_BV, PARAMETERS.VISU_OPACITY_BV, 'max');
    end
end

function writesegManSeg()
    if guiMode == 1 || guiMode == 4
        writeOctMeta([ActDataDescriptors.pathname ActDataDescriptors.filenameList{ActDataDescriptors.bScanNumber}], [ActDataDescriptors.evaluatorName BVTAGS{2}], 1, '%d');
        writeOctMeta([ActDataDescriptors.pathname ActDataDescriptors.filenameList{ActDataDescriptors.bScanNumber}], [ActDataDescriptors.evaluatorName BVTAGS{2} 'Data'], segMan, '%d');
    elseif guiMode == 2 || guiMode == 3
        writeOctMeta([ActDataDescriptors.pathname ActDataDescriptors.filenameList{ActDataDescriptors.fileNumber}], [ActDataDescriptors.evaluatorName BVTAGS{2}], 1, '%d');
        writeOctMeta([ActDataDescriptors.pathname ActDataDescriptors.filenameList{ActDataDescriptors.fileNumber}], [ActDataDescriptors.evaluatorName BVTAGS{2} 'Data'], segMan, '%d');
    end
end

% Functions used for layout & display
%-----------------------------------------------------------------

function refreshLayout()
    if guiMode == 0
        set(hMain, 'Visible', 'on');

        % set(hUndo, 'Visible', 'off');
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
           
        if numel(ActDataDescriptors.Header) ~= 0 && numel(dispZoomOct) == 1
            if (ActDataDescriptors.Header.SizeX / dispScale) > ActDataDescriptors.Header.SizeZ
                octWidth = (width - sloWidth  - 4 * border);
                octHeight = round(octWidth * ActDataDescriptors.Header.SizeZ / (ActDataDescriptors.Header.SizeX / dispScale));
                if octHeight > (height - 2 * border)
                    octHeight = (height - 2 * border);
                    octWidth = round(octHeight / ActDataDescriptors.Header.SizeZ * (ActDataDescriptors.Header.SizeX / dispScale));
                end
            else
                octHeight = height - 2 * border;
                octWidth = round(octHeight / ActDataDescriptors.Header.SizeZ * (ActDataDescriptors.Header.SizeX / dispScale));
            end
        else
            octWidth = (width - sloWidth - 4 * border);
            octHeight = octWidth;
        end      
        
        set(hOct, 'Position', [(3 * border + sloWidth) (height - border - octHeight) octWidth octHeight]);

        % Display Main buttons 
        
        set(hPaintMode, 'Position', [border (height - 3 * border - sloHeight - infotextHeight - buttonHeight) ...
            sloWidth buttonHeight]);
        
        set(hStartOver, 'Position', [border (height - 5 * border - sloHeight - infotextHeight - 2 * buttonHeight) ...
            sloWidth buttonHeight]);

        set(hSqrt, 'Position', [border (height - 8 * border - sloHeight - infotextHeight - 3 * buttonHeight) ...
            floor((sloWidth - 2 * border) / 3) buttonHeight]);
        set(hScale, 'Position', [(2*border + floor((sloWidth - 2 * border) / 3)) (height - 8 * border - sloHeight - infotextHeight - 3 * buttonHeight) ...
            floor((sloWidth - 2 * border) / 3) buttonHeight]);
        set(hDispBorder, 'Position', [(3*border + 2 * floor((sloWidth - 2 * border) / 3)) (height - 8 * border - sloHeight - infotextHeight - 3 * buttonHeight) ...
            ceil((sloWidth -  2 * border) / 3) buttonHeight]);

        set(hBeforeImg, 'Position', [border (height - 10 * border - sloHeight - infotextHeight - 3 * buttonHeight - bigButtonHeight) ...
            floor((sloWidth - infoNumWidth) / 2) ...
            bigButtonHeight]);
        set(hNumText, 'Position', [(border + floor((sloWidth - infoNumWidth) / 2)) ...
            (height - 10 * border - sloHeight - infotextHeight - 3 * buttonHeight - bigButtonHeight) ...
            infoNumWidth buttonHeight]);
        set(hNextImg, 'Position', [(border + infoNumWidth + floor((sloWidth - infoNumWidth) / 2)) ...
            (height - 10 * border - sloHeight - infotextHeight - 3 * buttonHeight - bigButtonHeight) ...
            ceil((sloWidth - infoNumWidth) / 2) bigButtonHeight]);
        
        set(hManPerformedText, 'Position', [border ...
            (height - 11 * border - sloHeight - infotextHeight - 3 * buttonHeight - bigButtonHeight - selectorHeight) ...
            sloWidth selectorHeight]);

        set(hSelector, 'Position', [border ...
            (height - 12 * border - sloHeight - infotextHeight - 3 * buttonHeight - bigButtonHeight - 2* selectorHeight) ...
            sloWidth selectorHeight]); 

        % Set everything to vissible
        % set(hUndo, 'Visible', 'on');
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
    if guiMode == 1 || guiMode == 4
        bvMan = readOctMeta([ActDataDescriptors.pathname ActDataDescriptors.filenameList{ActDataDescriptors.bScanNumber}], [ActDataDescriptors.evaluatorName BVTAGS{2}]);
    elseif guiMode == 2 || guiMode == 3 
        bvMan = readOctMeta([ActDataDescriptors.pathname ActDataDescriptors.filenameList{ActDataDescriptors.fileNumber}], [ActDataDescriptors.evaluatorName BVTAGS{2}]);
    end

    if numel(bvMan) == 0
        status = 0;
        return;
    end
    
    if bvMan(1) == 0
        status = 0;
    end
end

function refreshDispComplete()
    refreshDispInfoText();
    refreshDispSlo();
    refreshDispOct();
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

