function octsegVisuPublic(ActDataDescriptors, guiMode)
% OCTSEGVISU Visualization tool of the OCTSEG GUI
% Loads and displays OCT data (HE or Raw or image lists).
% Allows visualization of segmentations and enface views.

disp('Starting OCTSEG Visualizer...');

%--------------------------------------------------------------------------
% Parameters
%%--------------------------------------------------------------------------

octsegConstantVariables;
global PARAMETER_FILENAME;
global FILETYPE;

PARAMETERS = loadParameters('VISU', PARAMETER_FILENAME);

if ispc()
    FONTSIZE = 10;
else
    FONTSIZE = 12;
end

%--------------------------------------------------------------------------
% GUI Global Variables
%--------------------------------------------------------------------------

% Global variables with "disp" prefix:
% Data that is actually displayed, and variables that affect the display of
% both OCT & SLO data.

dispOct = []; % Actual BScan to be displayed. Stored in RGB format.
dispSlo = []; % Actual SLO to be displayed. Stored in RGB format.

dispMarkerOn = 0; % Show position marker in both SLO and OCT image
dispJumpToMarkerOn = 1; % Clicking in a SLO/Enface-image of a volume 
                        % switches the OCT BScan image to the one on the 
                        % marker position

dispCorr = 1;   % Show the corrections made to the automated segmentations 
                % (holds for all possible visualizations 
                % on the OCT and SLO images)
dispScale = 1; % Scales the OCT image down in transversal direction;    
dispZoomOct = 0; % Zooms to a certain point in the OCT image;
% Half the windowsize for zooming
dispOctZoomWindowSize = PARAMETERS.VISU_ZOOM_WINDOWSIZE; 

                
% Global variables with "act" prefix:
% Data that is loaded with each image, but not displayed (e.g. raw image
% data, header information, etc...)
ActDataDescriptors.Header = []; % The current OCT file header 
                % (format similar to HE-Raw data specifications)
ActDataDescriptors.BScanHeader = []; % The B-Scan header informations. 

% ActData structure: Stores the raw data from the files
ActData.slo = []; % SLO raw image data
ActData.bScans = []; % OCT raw image data

if nargin == 0
    ActDataDescriptors.filenameEnding = '.vol'; % Filenameending of the current filenames 
    ActDataDescriptors.filenameList = []; % Filename cell array for 
            % reading the .meta files  
            % (and OCT data in case of guiMode == 2)
            % Stored without path and without ending
            
    ActDataDescriptors.filename = 0; % Filename of currently displayed OCT data
                      % (without path but with ending)
    ActDataDescriptors.pathname = 0; % Path to currently displayed OCT data
end

ActDataDescriptors.fileNumber = 1; % Which file is currently displayed from the list?
ActDataDescriptors.bScanNumber = 1; % Which B-Scan is displayed from the volume?                
                
ActDataDescriptors.evaluatorName = 'Default'; % Evaluator name is stored. 
        % Currently set to a default variable, but all functions are 
        % (should be) prepared to be used with multiple evaluators.

% Global variables with "disp" prefix:
% They determine how the OCT image is visualized and store the data of 
% OCT segmentations

octIntensityScale = 1;  % 0 = single sqrt of the data for display
                        % 1 = double sqrt of the data for display
                        % 2 = logarithmic scaling
                        % 3 = linear scaling
                    
% The following variables determine if a segmentation line is drawn (...On)
% (1 = show, 0 = not show), the data is stored in the ...Line variables

octINFLOn = 1;
octINFLLine = [];

octONFLOn = 1;
octONFLLine = [];

octInnerLayersOn = 1;
octICLLine = [];
octIPLLine = [];
octOPLLine = [];

octRPEOn = 1;
octRPELine = [];

octSkleraOn = 0;
octSkleraLine = [];

octMedlineOn = 0;
octMedlineLine = [];

octBVOn = 0; % Blood vessel display
octBVLine = [];

octAdditionalOn = 0; % Additional data for debugging reasons
octAdditionalData = [];

octMarker = [1 1 1]; % Position of the marker in the OCT image
     % [x y z] pixel Value according to HE Specs. 
     % In the case of circular scans, y is missing
     
octONHOn = 0; % Position of the left and right boundary of the ONH circle
octONH = [1 1 1; 1 1 1];

% Global variables with "slo" prefix:
% They determine how the SLO image is visualized and store the data of 
% SLO visualizations
% Currently, there are the following visualizations possible:
% - Marker
% - Scanposition
% - Region data in an opaque view (e.g. ONH)
% - En face views (Z-summarized values, intensity coded positions)
% - Overlay data in an opaque view (e.g. retina thickness)

sloMarker = [1 1];  % Position of the marker in the SLO image
                    % [x y] value in pixel

% SloScan structure: visualization information for the OCT scan pattern
SloScan.positionOn = 1;    % Shows the scanpattern of the CURRENT BScan
SloScan.patternOn = 0;     % Shows the scanpattern of the COMPLETE Volume
SloScan.areaOn = 1;        % Shows the scan area for volumes

% SloEnface structure: visualization information for the enface views
SloEnface.fullOn = 0;    % A complete z-direction OCT enface image 
SloEnface.skleraOn = 0;  % An enface image of the region below the sklera
SloEnface.rpeOn = 0;     % An enface image of the region above the RPE
SloEnface.nflOn = 0;     % A summation of the intensities in between 
                        % the ONFL and INFL

SloEnface.rpePositionOn = 0;   % Intensity coded image of the RPEauto position
SloEnface.inflPositionOn = 0;  % Intensity coded image of the INFLauto position
SloEnface.onflPositionOn = 0;  % Intensity coded image of the ONFLauto position
SloEnface.skleraPositionOn = 0; % Intensity coded image of the Sklera position

% SloEnfaceData structure: data for the enface views
SloEnfaceData.data = [];     % Data of the enface view
SloEnfaceData.position = []; % Position of the enface view

% SloRegion structure: visualization information for the region views
SloRegion.onhOn = 0;       % Show segmented region of the ONH
SloRegion.onhCircleOn = 0; % Show circle region around the ONH
SloRegion.bvOn = 0;

% SloRegionData structure: Data for the region views
SloRegionData.onhCenter = [];  % Center of the circle region around the ONH
SloRegionData.data = [];     % Region data
SloRegionData.position = []; % Position of the region data
SloRegionData.opacity = [];  % Pixelwise opacity of the region data

% SloOverlay structure: visualization information for the overlay views
SloOverlay.retinaFullOn = 0;    % Color coded opaque view of the retina thickness 
SloOverlay.nflThicknessOn = 0;  % Color coded opaque view of the NFL thickness

% SloOverlayData structure: Data for the overlay views
SloOverlayData.data = [];    % Overlay data (e.g. thickness visualization)
SloOverlayData.position = []; % Position of the overlay data
SloOverlayData.opacity = [];  % Pixelwise opacity of the overlay data

% Global variables with "gui" prefix:
% Determine the functionality and appearance of the GUI window.

% guiLayout: Tells which GUI layout to use.
% Possible values are:
% 0: Show nothing (Default)
% 1: HE view with OCT BScan and SLO displayed (for guiModes 1&2)
% 2: Image view. Only OCT Scan is displayed.
guiLayout = 0;

% guiMode: Tells in which operating mode the gui is currently running.
% Possible values are:
% 0:    Show nothing (Default)
% 1:    HE single file edit (includes volumes). Works also for image lists.
% 2:    HE directory batch processing. Assumes, that in the directory only
%       circular or 2D linear scans are located
% 3:    Image directory batch viewing. Only one image file type allowed
% 4:    Image volume (list) viewing. 
%       per directory. 
if nargin == 0
    guiMode = 0;
end

%--------------------------------------------------------------------------
% GUI Components
%--------------------------------------------------------------------------

% Main window
hMain = figure(...
    'Visible','off',...
    'Position',[200,200,500,380],...
    'WindowStyle', 'normal',...
    'Color', 'white',...
    'HandleVisibility','callback', ...
    'WindowButtonDownFcn', @hButtonDownFcn,...
    'ResizeFcn', @hResizeCallback,...
    'MenuBar', 'none');
movegui(hMain,'center');

% Menu: File Menu (Load & Save of data)
hMenFile = uimenu(hMain, 'Label', 'File');
hMenFileOpenFile = uimenu(hMenFile, ...
    'Label', 'Open File', ...
    'Callback',{@hMenFileOpenFileCallback});
hMenFileOpenDir = uimenu(hMenFile, ...
    'Label', 'Open Directory', ...
    'Callback',{@hMenFileOpenDirCallback});
hMenFileSaveOct = uimenu(hMenFile, ...
    'Separator', 'On',...
    'Label', 'Save current OCT view', ...
    'Callback',{@hMenFileSaveOctCallback});
hMenFileSaveSlo = uimenu(hMenFile, ...
    'Label', 'Save current SLO view', ...
    'Callback',{@hMenFileSaveSloCallback});
hMenFileSaveBatchOct = uimenu(hMenFile, ...
    'Label', 'Save all OCT views', ...
    'Callback',{@hMenFileSaveBatchOctCallback});
hMenFileSaveBatchSlo = uimenu(hMenFile, ...
    'Label', 'Save all SLO views', ...
    'Callback',{@hMenFileSaveBatchSloCallback});
hMenFileQuit = uimenu(hMenFile, 'Label', 'Quit',...
    'Separator', 'On',...
    'Callback',{@hMenFileQuitCallback});

% Menu: Display Menu (General display options)
hMenDisp = uimenu(hMain, 'Label', 'Display');
hMenDispScale = uimenu(hMenDisp, ...
    'Label', 'Width Scale');
hMenDispScale1to1 = uimenu(hMenDispScale, ...
    'Label', '1:1',...
    'Callback',{@hMenDispXScaleCallback});
hMenDispScale1to2 = uimenu(hMenDispScale, ...
    'Label', '1:2',...
    'Callback',{@hMenDispXScaleCallback});
hMenDispScale1to3 = uimenu(hMenDispScale, ...
    'Label', '1:3',...
    'Callback',{@hMenDispXScaleCallback});
hMenDispIntensityScale = uimenu(hMenDisp, ...
    'Label', 'Intensity Scale');
hMenDispIntensityScaleLinear = uimenu(hMenDispIntensityScale, ...
    'Label', 'linear',...
    'Callback',{@hMenDispIntensityScaleCallback});
hMenDispIntensityScaleSqrt = uimenu(hMenDispIntensityScale, ...
    'Label', 'sqrt',...
    'Callback',{@hMenDispIntensityScaleCallback});
hMenDispIntensityScaleDSqrt = uimenu(hMenDispIntensityScale, ...
    'Label', 'double sqrt',...
    'Callback',{@hMenDispIntensityScaleCallback});
hMenDispIntensityScaleLog = uimenu(hMenDispIntensityScale, ...
    'Label', 'log',...
    'Callback',{@hMenDispIntensityScaleCallback});
hMenDispCorr = uimenu(hMenDisp, ...
    'Label', 'Show Corrections',...
    'Callback',{@hMenDispCorrCallback});
hMenDispShowMarker = uimenu(hMenDisp, ...
    'Label', 'Show Marker',...
    'Callback',{@hMenDispShowMarkerCallback});
hMenDispJumpToMarker = uimenu(hMenDisp, ...
    'Label', 'Jump to Marker',...
    'Callback',{@hMenDispJumpToMarkerCallback});

% Menu: OCT Menu - Show OCT segmentations
hMenOct = uimenu(hMain, 'Label', 'OCT');
hMenOctRPE = uimenu(hMenOct, ...
    'Label', 'RPEauto',...
    'Callback',{@hMenOctRPECallback});
hMenOctONH = uimenu(hMenOct, ...
    'Label', 'ONH Boundary',...
    'Callback',{@hMenOctONHCallback});
hMenOctBV = uimenu(hMenOct, ...
    'Label', 'Blood Vessels',...
    'Callback',{@hMenOctBVCallback});
hMenOctINFL = uimenu(hMenOct, ...
    'Label', 'INFL',...
    'Callback',{@hMenOctINFLCallback});
hMenOctInnerLayers = uimenu(hMenOct, ...
    'Label', 'Inner Layers',...
    'Callback',{@hMenOctInnerLayersCallback});
hMenOctONFL = uimenu(hMenOct, ...
    'Label', 'ONFL',...
    'Callback',{@hMenOctONFLCallback});
% hMenOctSklera = uimenu(hMenOct, ...                                             %NOTPUBLIC
%     'Label', 'Sklera', 'Callback',{@hMenOctSkleraCallback});                    %NOTPUBLIC
% hMenOctMedline = uimenu(hMenOct, ...                                            %NOTPUBLIC
%     'Separator', 'On', 'Label', 'Medline', 'Callback',{@hMenOctMedlineCallback}); %NOTPUBLIC
% hMenOctAdditional = uimenu(hMenOct, 'Label', 'Additional', ...                  %NOTPUBLIC
%      'Callback',{@hMenOctAdditionalCallback});                                  %NOTPUBLIC

% Menu: SLO Menu - SLO visulizations
hMenSlo = uimenu(hMain, 'Label', 'SLO');

hMenSloScanPath = uimenu(hMenSlo, ...
    'Label', 'Scan Path');
hMenSloScanPosition = uimenu(hMenSloScanPath, ...
    'Label', 'Scan Position',...
    'Callback',{@hMenSloScanPositionCallback});
hMenSloScanPattern  = uimenu(hMenSloScanPath, ...
    'Label', 'Scan Pattern',...
    'Callback',{@hMenSloScanPatternCallback});
hMenSloScanArea = uimenu(hMenSloScanPath, ...
    'Label', 'Scan Area',...
    'Callback',{@hMenSloScanAreaCallback});

hMenSloEnface = uimenu(hMenSlo, ...
    'Label', 'Enface');
hMenSloFullEnface = uimenu(hMenSloEnface, ...
    'Label', 'Full Enface',...
    'Callback',{@hMenSloFullEnfaceCallback});
hMenSloSkleraEnface = uimenu(hMenSloEnface, ...
    'Label', 'Sklera Enface',...
    'Callback',{@hMenSloSkleraEnfaceCallback});
hMenSloRPEEnface = uimenu(hMenSloEnface, ...
    'Label', 'RPE Enface',...
    'Callback',{@hMenSloRPEEnfaceCallback});
hMenSloNFLEnface = uimenu(hMenSloEnface, ...
    'Label', 'NFL Enface',...
    'Callback',{@hMenSloNFLEnfaceCallback});

hMenSloPosition = uimenu(hMenSlo, ...
    'Label', 'Positions');
hMenSloRPEPosition = uimenu(hMenSloPosition, ...
    'Label', 'RPE Position',...
    'Callback',{@hMenSloRPEPositionCallback});
hMenSloINFLPosition = uimenu(hMenSloPosition, ...
    'Label', 'INFL Position',...
    'Callback',{@hMenSloINFLPositionCallback});
hMenSloONFLPosition = uimenu(hMenSloPosition, ...
    'Label', 'ONFL Position',...
    'Callback',{@hMenSloONFLPositionCallback});
% hMenSloSkleraPosition = uimenu(hMenSloPosition, ...                             %NOTPUBLIC
%     'Label', 'Sklera Position', 'Callback',{@hMenSloSkleraPositionCallback});   %NOTPUBLIC

hMenSloRegions = uimenu(hMenSlo, ...
    'Label', 'Regions');
hMenSloONH = uimenu(hMenSloRegions, ...
    'Label', 'ONH',...
    'Callback',{@hMenSloONHCallback});
hMenSloONHCircle = uimenu(hMenSloRegions, ...
    'Label', 'ONH Circle',...
    'Callback',{@hMenSloONHCircleCallback});
hMenSloBV = uimenu(hMenSloRegions, ...
    'Label', 'Blood Vessels',...
    'Callback',{@hMenSloBVCallback});

hMenSloMaps = uimenu(hMenSlo, ...
    'Label', 'Maps');
hMenSloRetinaFull = uimenu(hMenSloMaps, ...
    'Label', 'Complete Retina',...
    'Callback',{@hMenSloRetinaFullCallback});
hMenSloNFLThickness = uimenu(hMenSloMaps, ...
    'Label', 'NFL Thickness',...
    'Callback',{@hMenSloNFLThicknessCallback});

% Menu: Help Menu - Shows not much at this point 
hMenHelp = uimenu(hMain, 'Label', '?');
hMenHelpInfo = uimenu(hMenHelp, 'Label', 'Info', ...
    'Callback',{@infoCallback});  % Uses outsourced callback function for 
                                  % displaying the info text.

% Information text about the current dataset, 
% usually displayed on top of the images                                
hInfoText = uicontrol(hMain, 'Style','text',...
    'Units','pixels',...
    'String','No Info',...
    'BackgroundColor', 'white',...
    'FontSize', FONTSIZE,...
    'HorizontalAlignment', 'center', ...
    'Visible', 'off');

% Selector for moving through the B-Scans of a volume or 2D B-Scans in a
% directory/list. Usually displayed in the bottom of the window
hSelector = uicontrol(hMain, 'Style', 'slider',...
    'Units','pixels',...
    'Callback', @hSelectorCallback, ...
    'Min', 0, ...
    'Max', 1, ...
    'Visible', 'off');

% Figure for displaying the SLO image
hSlo = axes('Units','pixels',...
    'Parent', hMain,...
    'Visible', 'off');

% Figure for displaying the OCT image
hOct = axes('Units','pixels',...
    'Parent', hMain,...
    'Visible', 'off');


%--------------------------------------------------------------------------
% GUI Init & Parameter Intiliatization
%--------------------------------------------------------------------------

if nargin > 0 % Intialization if started with parameters   
    switchMode(guiMode);
    ActDataDescriptors.fileNumber = 1;
    ActDataDescriptors.bScanNumber = 1;
    loadDispFile();
    createAllSLOViews();
    refreshLayout();
    
    if guiMode == 1 || guiMode == 4 || guiMode == 4
        setSelectorSize(hSelector, guiMode, ActDataDescriptors);
    end
    
    setSelectorSize(hSelector, guiMode, ActDataDescriptors);
    refreshLayout();
    reloadMetaData();
    createAllSLOViews();
    refreshDispComplete;       
end

% Set the main window name, centered and visible!
set(hMain,'Units','pixels');
set(hMain,'Name','OCTSEG VISUALIZER');
movegui(hMain,'center');
set(hMain,'Visible','on');

% Out of the global variables, set the corresponding menu entries 'checked'
% sign to the correct value.
setMenuEntryChecked(hMenDispCorr, dispCorr);
setMenuEntryChecked(hMenDispShowMarker, dispMarkerOn);
setMenuEntryChecked(hMenDispJumpToMarker, dispJumpToMarkerOn);

setMenuEntryChecked(hMenDispScale1to1, dispScale == 1);
setMenuEntryChecked(hMenDispScale1to2, dispScale == 2);
setMenuEntryChecked(hMenDispScale1to3, dispScale == 3);

setMenuEntryChecked(hMenDispIntensityScaleSqrt, octIntensityScale == 0);
setMenuEntryChecked(hMenDispIntensityScaleDSqrt, octIntensityScale == 1);
setMenuEntryChecked(hMenDispIntensityScaleLog, octIntensityScale == 2);
setMenuEntryChecked(hMenDispIntensityScaleLinear, octIntensityScale == 3);

setMenuEntryChecked(hMenOctINFL, octINFLOn);
setMenuEntryChecked(hMenOctONFL, octONFLOn);
setMenuEntryChecked(hMenOctInnerLayers, octInnerLayersOn);
setMenuEntryChecked(hMenOctRPE, octRPEOn);
setMenuEntryChecked(hMenOctONH, octONHOn);
% setMenuEntryChecked(hMenOctSklera, octSkleraOn); %NOTPUBLIC
% setMenuEntryChecked(hMenOctMedline, octMedlineOn); %NOTPUBLIC
% setMenuEntryChecked(hMenOctAdditional, octAdditionalOn); %NOTPUBLIC

setMenuEntryChecked(hMenSloScanPosition, SloScan.positionOn);
setMenuEntryChecked(hMenSloScanPattern, SloScan.patternOn);
setMenuEntryChecked(hMenSloScanArea, SloScan.areaOn);

setMenuEntryChecked(hMenSloFullEnface, SloEnface.fullOn);
% setMenuEntryChecked(hMenSloSkleraEnface, SloEnface.skleraOn);   %NOTPUBLIC
setMenuEntryChecked(hMenSloRPEEnface, SloEnface.rpeOn);
setMenuEntryChecked(hMenSloNFLEnface, SloEnface.nflOn);
setMenuEntryChecked(hMenSloRPEPosition, SloEnface.rpePositionOn);
setMenuEntryChecked(hMenSloINFLPosition, SloEnface.inflPositionOn);
setMenuEntryChecked(hMenSloONFLPosition, SloEnface.onflPositionOn);
% setMenuEntryChecked(hMenSloSkleraPosition, SloEnface.skleraPositionOn);  %NOTPUBLIC

setMenuEntryChecked(hMenSloONH, SloRegion.onhOn);
setMenuEntryChecked(hMenSloONHCircle, SloRegion.onhCircleOn);
setMenuEntryChecked(hMenSloBV, SloRegion.bvOn);

setMenuEntryChecked(hMenSloRetinaFull, SloOverlay.retinaFullOn);
setMenuEntryChecked(hMenSloNFLThickness, SloOverlay.nflThicknessOn);


%--------------------------------------------------------------------------
% GUI Component Handlers
%--------------------------------------------------------------------------

% Menu handlers - FILE Menu
%--------------------------------------------------------------------------

% HMENFILEOPENFILECALLBACK:
% Opens single images/B-Scans/volumes/lists
function hMenFileOpenFileCallback(hObject, eventdata)
    [filename,pathname] = uigetfile( ...
        {'*.vol;*.oct;*.list;*.pgm;*.tif;*.jpg', 'OCT Files (*.vol, *.oct, *.list, *.pgm, *.tif, *.jpg)';...
        '*.vol', 'Heidelberg Engineering RAW-Files (*.vol)'; ...
        '*.list', 'OCT Volume Image List (*.list)'; ...
        '*.pgm;*.tif;*.jpg', 'Image Files (*.pgm; *.tif; *.jpg)'; ...
        '*.oct', 'OCTSEG RAW-Files (*.oct)'},...
        'Select OCT file');
    
    if isequal(filename,0)
        disp('Open File: Chancelled.');
        return;
    else
        disp(['Open File: ' pathname filename]);
    end
    
    [numDescriptor openFuncHandle filenameEnding] = examineOctFile(pathname, filename);

    
    if numDescriptor == 0
        disp('Open File: File is no OCT file.');
        return;
    end
    
    ActDataDescriptors.filenameEnding = filenameEnding;
    ActDataDescriptors.filename = filename;
    ActDataDescriptors.pathname = pathname;
    if numDescriptor == FILETYPE.HE || numDescriptor == FILETYPE.LIST       
        switchMode(1);
    else
        switchMode(3);
        filenameWoEnding = [filename(1:end-(numel(filenameEnding)))];
        ActDataDescriptors.filenameList = cell(1, 1);
        ActDataDescriptors.filenameList{1} = filenameWoEnding;
    end
   
    disp('Open File: OCT file check OK.');
    loadDispFile();
    
    ActDataDescriptors.fileNumber = 1;
    ActDataDescriptors.bScanNumber = 1; 
    if guiMode == 1 || guiMode == 4 || guiMode == 4
        setSelectorSize(hSelector, guiMode, ActDataDescriptors);
    end
    
    reloadMetaData();
    createAllSLOViews();

    refreshLayout();  
    refreshDispComplete;
end


% HMENFILEOPENDIRCALLBACK:
% Opens all B-Scans/images in a directory
function hMenFileOpenDirCallback(hObject, eventdata)
    pathname = uigetdir('.', 'Select Folder for Batch Viewing. Only HE circular scans!');
    
    if isequal(pathname,0)
        disp('Open Directory: Chancelled.');
        return;
    else
        disp(['Open Directory: ' pathname]);
    end
    
    % Check if there are HE Raw data files in the directory
    if ispc
        pathname = [pathname '\'];
    else
        pathname = [pathname '/'];
    end
    ActDataDescriptors.filenameEnding = '.vol';
    suggestedMode = 2;
    
    files = dir([pathname '*.vol']);

    if isempty(files)
        disp('Open Directory: Directory contains no VOL files. \nTrying to find image files instead.');
        files = dir([pathname '*.pgm']);
        suggestedMode = 3;
        ActDataDescriptors.filenameEnding = '.pgm';
    end
    
    if isempty(files)
        disp('Open Directory: Directory contains no OCT files or images.');
        return;
    end
    
    setAllEnfaceViewsOff();
    setAllRegionViewsOff();
    setAllOverlayViewsOff();
    
    actFilenameListTemp = cell(1,1);
    for i = 1:length(files)
        actFilenameListTemp{i,1} = (files(i).name);
        actFilenameListTemp{i,1} = actFilenameListTemp{i,1}(1:end-4);
    end
    [ActDataDescriptors.filenameList IX] = sort(actFilenameListTemp);

    switchMode(suggestedMode);
    
    ActDataDescriptors.filename = [ActDataDescriptors.filenameList{1} ActDataDescriptors.filenameEnding];
    ActDataDescriptors.pathname = pathname;
    
    loadDispFile();
    
    ActDataDescriptors.fileNumber = 1;
    ActDataDescriptors.bScanNumber = 1;
    
    setSelectorSize(hSelector, guiMode, ActDataDescriptors);
  
    reloadMetaData();
    createAllSLOViews();
    
    refreshLayout();
    refreshDispComplete;
end


% HMENFILESAVEOCTCALLBACK: Saves the current OCT image (as it is displayed)
function hMenFileSaveOctCallback(hObject, eventdata)
    [filename, pathname] = uiputfile({'*.jpg;*.tif;*.png;','Image Files';...
        '*.*','All Files' },'Save OCT Image',...
        'octimage.tif');

    if isequal(filename,0)
        disp('Save OCT Image: Chancelled.');
        return;
    else
        disp(['Save OCT Image: ' pathname filename]);
    end

    saveDisplayedFile(dispOct, pathname, filename);
end


% HMENFILESAVESLOCALLBACK: Saves the current SLO image (as it is displayed)
function hMenFileSaveSloCallback(hObject, eventdata)
    [filename, pathname] = uiputfile({'*.jpg;*.tif;*.png;','Image Files';...
        '*.*','All Files' },'Save SLO Image',...
        'sloimage.tif');

    if isequal(filename,0)
        disp('Save SLO Image: Chancelled.');
        return;
    else
        disp(['Save SLO Image: ' pathname filename]);
    end

    saveDisplayedFile(dispSlo, pathname, filename);
end


% HMENFILESAVEBATCHOCTCALLBACK: 
% Goes through all OCT files in either the directory/volume/list and saves
% the OCT image (as they would be displayed with the current settings)
function hMenFileSaveBatchOctCallback(hObject, eventdata)
    [filenameadder, pathname] = uiputfile({'*.jpg;*.tif;*.png;','Image Files';...
        '*.*','All Files' },'Save Batch OCT Image Ending',...
        '_oct.tif');

    if isequal(filenameadder,0)
        disp('Save Batch OCT Image: Chancelled.');
        return;
    else
        disp(['Save Batch OCT Image: ' pathname filenameadder]);
    end

    batchSaveStepper('oct', filenameadder, pathname)
end


% HMENFILESAVEBATCHSLOCALLBACK: 
% Goes through all OCT files in either the directory/volume/list and saves
% the SLO image (as they would be displayed with the current settings)
function hMenFileSaveBatchSloCallback(hObject, eventdata)
    [filenameadder, pathname] = uiputfile({'*.jpg;*.tif;*.png;','Image Files';...
        '*.*','All Files' },'Save Batch SLO Image Ending',...
        '_slo.tif');

    if isequal(filenameadder,0)
        disp('Save Batch SLO Image: Chancelled.');
        return;
    else
        disp(['Save Batch SLO Image: ' pathname filenameadder]);
    end

    batchSaveStepper('slo', filenameadder, pathname)
end


% BATCHSAVESTEPPER: Steps through all possible selector steps, loads the
% data, and save the type of data wanted.
% type: either 'oct' or 'slo'
% filenameadder, pathname: as given by the uiputfile in the
%   SaveBatch-Callbacks
function batchSaveStepper(type, filenameadder, pathname)
     % Find out the file ending
    filenameEnding = getFilenameEnding(filenameadder);

    % Get all the values from the selector to completely step through it.
    minSelector =  get(hSelector, 'Min');
    maxSelector =  get(hSelector, 'Max');
    stepSelector =  get(hSelector, 'SliderStep');
    stepSelector = stepSelector(1) * (maxSelector - minSelector - 1);
    currentSelector = get(hSelector, 'Value');
    visSelector = get(hSelector, 'Visible');

    % Step through the selector values
    if strcmp(visSelector, 'on')
        for i = minSelector:stepSelector:maxSelector
            set(hSelector, 'Value', i);
            
            % Load the data for the current selector value
            hSelectorCallback([], []); 

            % get filename
            if guiMode == 1 || guiMode == 4
                if ActDataDescriptors.Header.ScanPattern ~= 2
                    filename = ActDataDescriptors.filenameList{ActDataDescriptors.bScanNumber};
                else
                    filename = ActDataDescriptors.filename(1:end-4);
                end
            elseif guiMode == 2 || guiMode == 3
                filename = ActDataDescriptors.filenameList{ActDataDescriptors.fileNumber};
            end

            % save image
            switch type
                case 'oct'
                    saveDisplayedFile(dispOct, pathname, [filename filenameadder], filenameEnding);
                case 'slo'
                    saveDisplayedFile(dispSlo, pathname, [filename filenameadder], filenameEnding);
                otherwise
            end
        end

        % Set the selector value back to the original value
        set(hSelector, 'Value', currentSelector);
        hSelectorCallback([], []);
    else
        disp('Save Batch Image: Nothing to save.');
        return;
    end
end

% HMENFILEQUITCALLBACK: Main figure delete
function hMenFileQuitCallback(hObject, eventdata)
   delete(hMain);
end


% Menu handlers - DISPLAY Menu
%--------------------------------------------------------------------------

function hMenDispXScaleCallback(hObject, eventdata)
    if hObject == hMenDispScale1to1
        set(hMenDispScale1to1, 'Checked', 'on');
        set(hMenDispScale1to2, 'Checked', 'off');
        set(hMenDispScale1to3, 'Checked', 'off');
        dispScale = 1;
    elseif hObject == hMenDispScale1to2
        set(hMenDispScale1to1, 'Checked', 'off');
        set(hMenDispScale1to2, 'Checked', 'on');
        set(hMenDispScale1to3, 'Checked', 'off');
        dispScale = 2;
    else
        set(hMenDispScale1to1, 'Checked', 'off');
        set(hMenDispScale1to2, 'Checked', 'off');
        set(hMenDispScale1to3, 'Checked', 'on');
        dispScale = 3;
    end

    refreshDispOct();
    refreshLayout();
end

function hMenDispIntensityScaleCallback(hObject, eventdata)
    if hObject == hMenDispIntensityScaleSqrt
        set(hMenDispIntensityScaleLinear, 'Checked', 'off');
        set(hMenDispIntensityScaleSqrt, 'Checked', 'on');
        set(hMenDispIntensityScaleDSqrt, 'Checked', 'off');
        set(hMenDispIntensityScaleLog, 'Checked', 'off');
        octIntensityScale = 0;
    elseif hObject == hMenDispIntensityScaleDSqrt
        set(hMenDispIntensityScaleLinear, 'Checked', 'off');
        set(hMenDispIntensityScaleSqrt, 'Checked', 'off');
        set(hMenDispIntensityScaleDSqrt, 'Checked', 'on');
        set(hMenDispIntensityScaleLog, 'Checked', 'off');
        octIntensityScale = 1;
    elseif hObject == hMenDispIntensityScaleLog
        set(hMenDispIntensityScaleLinear, 'Checked', 'off');
        set(hMenDispIntensityScaleSqrt, 'Checked', 'off');
        set(hMenDispIntensityScaleDSqrt, 'Checked', 'off');
        set(hMenDispIntensityScaleLog, 'Checked', 'on');
        octIntensityScale = 2;
    else 
        set(hMenDispIntensityScaleLinear, 'Checked', 'on');
        set(hMenDispIntensityScaleSqrt, 'Checked', 'off');
        set(hMenDispIntensityScaleDSqrt, 'Checked', 'off');
        set(hMenDispIntensityScaleLog, 'Checked', 'off');
        octIntensityScale = 3;
    end
    
    refreshDispOct();
end

function hMenDispCorrCallback(hObject, eventdata)
    if dispCorr == 1
        dispCorr = 0;
        set(hMenDispCorr, 'Checked', 'off');
    else
        dispCorr = 1;
        set(hMenDispCorr, 'Checked', 'on');
    end
    
    reloadMetaData();
    createAllSLOViews();
    refreshDispOct();
    refreshDispSlo();
end

function hMenDispShowMarkerCallback(hObject, eventdata)
    if dispMarkerOn == 1
        dispMarkerOn = 0;
        set(hMenDispShowMarker, 'Checked', 'off');
    else
        dispMarkerOn = 1;
        set(hMenDispShowMarker, 'Checked', 'on');
    end
    
    refreshDispOct();
    refreshDispSlo();
end

function hMenDispJumpToMarkerCallback(hObject, eventdata)
    if dispJumpToMarkerOn == 1
        dispJumpToMarkerOn = 0;
        set(hMenDispJumpToMarker, 'Checked', 'off');
    else
        dispJumpToMarkerOn = 1;
        set(hMenDispJumpToMarker, 'Checked', 'on');
    end
end


% Menu handlers - OCT Menu
%--------------------------------------------------------------------------

function hMenOctRPECallback(hObject, eventdata)
    octRPEOn = invertMenuEntryChecked(hMenOctRPE, octRPEOn);
    
    if octRPEOn          
       reloadMetaData('RPE');
    end
    refreshDispOct();
end

function hMenOctBVCallback(hObject, eventdata)
    octBVOn = invertMenuEntryChecked(hMenOctBV, octBVOn);
    
    if octBVOn
       reloadMetaData('Blood Vessels');
    end
    refreshDispOct();
end

function hMenOctONHCallback(hObject, eventdata)
    octONHOn = invertMenuEntryChecked(hMenOctONH, octONHOn);
    
    if octONHOn
       reloadMetaData('ONH');
    end
    refreshDispOct();
end

function hMenOctINFLCallback(hObject, eventdata)
    octINFLOn = invertMenuEntryChecked(hMenOctINFL, octINFLOn);
    
    if octINFLOn
       reloadMetaData('INFL');
    end
    refreshDispOct();
end

function hMenOctInnerLayersCallback(hObject, eventdata)
    octInnerLayersOn = invertMenuEntryChecked(hMenOctInnerLayers, octInnerLayersOn);
    
    if octInnerLayersOn
       reloadMetaData('Inner Layers');
    end
    refreshDispOct();
end

function hMenOctONFLCallback(hObject, eventdata)
    octONFLOn = invertMenuEntryChecked(hMenOctONFL, octONFLOn);
    
    if octONFLOn
       reloadMetaData('ONFL');
    end
    refreshDispOct();
end

function hMenOctSkleraCallback(hObject, eventdata)
    octSkleraOn = invertMenuEntryChecked(hMenOctSklera, octSkleraOn);
    
    if octSkleraOn
       reloadMetaData('Sklera');
    end
    refreshDispOct();
end

function hMenOctMedlineCallback(hObject, eventdata)
    octMedlineOn = invertMenuEntryChecked(hMenOctMedline, octMedlineOn);
    
    if octMedlineOn
       reloadMetaData('Medline');
    end
    refreshDispOct();
end

function hMenOctAdditionalCallback(hObject, eventdata)
    octAdditionalOn = invertMenuEntryChecked(hMenOctAdditional, octAdditionalOn);
    
    if octAdditionalOn
        reloadMetaData('Additional');
    end
    refreshDispOct();
end


% Menu handlers - SLO Menu
%--------------------------------------------------------------------------
function hMenSloScanPositionCallback(hObject, eventdata)
    SloScan.positionOn = invertMenuEntryChecked(hMenSloScanPosition, SloScan.positionOn);
    refreshDispSlo();
end

function hMenSloScanPatternCallback(hObject, eventdata)
    SloScan.patternOn = invertMenuEntryChecked(hMenSloScanPattern, SloScan.patternOn);
    refreshDispSlo();
end

function hMenSloScanAreaCallback(hObject, eventdata)
    SloScan.areaOn = invertMenuEntryChecked(hMenSloScanArea, SloScan.areaOn);
    refreshDispSlo();
end


% Enface views. Only one can be active at a time
function hMenSloFullEnfaceCallback(hObject, eventdata)
    remind = SloEnface.fullOn;
    setAllEnfaceViewsOff();
    SloEnface.fullOn = invertMenuEntryChecked(hMenSloFullEnface, remind);
    
    if SloEnface.fullOn == 1
        SloEnfaceData = createEnfaceViewsVisu(ActDataDescriptors, ActData, SloEnface, dispCorr, PARAMETERS);
    end
    refreshDispSlo();
end

function hMenSloSkleraEnfaceCallback(hObject, eventdata)
    remind = SloEnface.skleraOn;
    setAllEnfaceViewsOff();
    SloEnface.skleraOn = invertMenuEntryChecked(hMenSloSkleraEnface, remind);
    
    if SloEnface.skleraOn == 1
        SloEnfaceData = createEnfaceViewsVisu(ActDataDescriptors, ActData, SloEnface, dispCorr, PARAMETERS);
    end
    refreshDispSlo();
end

function hMenSloRPEEnfaceCallback(hObject, eventdata)
    remind = SloEnface.rpeOn;
    setAllEnfaceViewsOff();
    SloEnface.rpeOn = invertMenuEntryChecked(hMenSloRPEEnface, remind);
    
    if SloEnface.rpeOn == 1
        SloEnfaceData = createEnfaceViewsVisu(ActDataDescriptors, ActData, SloEnface, dispCorr, PARAMETERS);
    end
    refreshDispSlo();
end

function hMenSloNFLEnfaceCallback(hObject, eventdata)
    remind = SloEnface.nflOn;
    setAllEnfaceViewsOff();
    SloEnface.nflOn = invertMenuEntryChecked(hMenSloNFLEnface, remind);
    
    if SloEnface.nflOn == 1
        SloEnfaceData = createEnfaceViewsVisu(ActDataDescriptors, ActData, SloEnface, dispCorr, PARAMETERS);
    end
    refreshDispSlo();
end

function hMenSloRPEPositionCallback(hObject, eventdata)
    remind = SloEnface.rpePositionOn;
    setAllEnfaceViewsOff();
    SloEnface.rpePositionOn = invertMenuEntryChecked(hMenSloRPEPosition, remind);
    
    if SloEnface.rpePositionOn == 1
        SloEnfaceData = createEnfaceViewsVisu(ActDataDescriptors, ActData, SloEnface, dispCorr, PARAMETERS);
    end
    refreshDispSlo();
end

function hMenSloINFLPositionCallback(hObject, eventdata)
    remind = SloEnface.inflPositionOn;
    setAllEnfaceViewsOff();
    SloEnface.inflPositionOn = invertMenuEntryChecked(hMenSloINFLPosition, remind);
    
    if SloEnface.inflPositionOn == 1
        SloEnfaceData = createEnfaceViewsVisu(ActDataDescriptors, ActData, SloEnface, dispCorr, PARAMETERS);
    end
    refreshDispSlo();
end

function hMenSloONFLPositionCallback(hObject, eventdata)
    remind = SloEnface.onflPositionOn;
    setAllEnfaceViewsOff();
    SloEnface.onflPositionOn = invertMenuEntryChecked(hMenSloONFLPosition, remind);
    
    if SloEnface.onflPositionOn == 1
        SloEnfaceData = createEnfaceViewsVisu(ActDataDescriptors, ActData, SloEnface, dispCorr, PARAMETERS);
    end
    refreshDispSlo();
end

function hMenSloSkleraPositionCallback(hObject, eventdata)
    remind = SloEnface.skleraPositionOn;
    setAllEnfaceViewsOff();
    SloEnface.skleraPositionOn = invertMenuEntryChecked(hMenSloSkleraPosition, remind);
    
    if SloEnface.skleraPositionOn == 1
        SloEnfaceData = createEnfaceViewsVisu(ActDataDescriptors, ActData, SloEnface, dispCorr, PARAMETERS);
    end
    refreshDispSlo();
end

function setAllEnfaceViewsOff()
    SloEnface.fullOn = setMenuEntryChecked(hMenSloFullEnface, 0);
    SloEnface.skleraOn = setMenuEntryChecked(hMenSloSkleraEnface, 0);
    SloEnface.rpeOn = setMenuEntryChecked(hMenSloRPEEnface, 0);
    SloEnface.nflOn = setMenuEntryChecked(hMenSloNFLEnface, 0);
    
    SloEnface.rpePositionOn = setMenuEntryChecked(hMenSloRPEPosition, 0);
    SloEnface.inflPositionOn = setMenuEntryChecked(hMenSloINFLPosition, 0);
    SloEnface.onflPositionOn = setMenuEntryChecked(hMenSloONFLPosition, 0);
%     SloEnface.skleraPositionOn = setMenuEntryChecked(hMenSloSkleraPosition, 0); %NOTPUBLIC
end


% Slo overlays. Only one can be active at a time.
function hMenSloRetinaFullCallback(hObject, eventdata)
    remind = SloOverlay.retinaFullOn;
    setAllOverlayViewsOff();
    SloOverlay.retinaFullOn = invertMenuEntryChecked(hMenSloRetinaFull, remind);

    if SloOverlay.retinaFullOn == 1
        SloOverlayData = createOverlayViewsVisu(ActDataDescriptors, SloOverlay, dispCorr, PARAMETERS);
    end
    refreshDispSlo();
end

function hMenSloNFLThicknessCallback(hObject, eventdata)
    remind = SloOverlay.nflThicknessOn;
    setAllOverlayViewsOff();
    SloOverlay.nflThicknessOn = invertMenuEntryChecked(hMenSloNFLThickness, remind);

    if SloOverlay.nflThicknessOn == 1
        SloOverlayData = createOverlayViewsVisu(ActDataDescriptors, SloOverlay, dispCorr, PARAMETERS);
    end
    refreshDispSlo();
end


function setAllOverlayViewsOff()
    SloOverlay.retinaFullOn = setMenuEntryChecked(hMenSloRetinaFull, 0);
    SloOverlay.nflThicknessOn = setMenuEntryChecked(hMenSloNFLThickness, 0);
end


% Slo region views. Only one can be active at a time.
function hMenSloONHCallback(hObject, eventdata)
    remind = SloRegion.onhOn;
    setAllRegionViewsOff();
    SloRegion.onhOn = invertMenuEntryChecked(hMenSloONH, remind);

    if SloRegion.onhOn == 1
        SloRegionData = createRegionViewsVisu(ActDataDescriptors, SloRegion, dispCorr, PARAMETERS);
    end
    refreshDispSlo();
end

function hMenSloONHCircleCallback(hObject, eventdata)
    remind = SloRegion.onhCircleOn;
    setAllRegionViewsOff();
    SloRegion.onhCircleOn = invertMenuEntryChecked(hMenSloONHCircle, remind);

    if SloRegion.onhCircleOn == 1
        SloRegionData = createRegionViewsVisu(ActDataDescriptors, SloRegion, dispCorr, PARAMETERS);
    end
    refreshDispSlo();
end

function hMenSloBVCallback(hObject, eventdata)
    remind = SloRegion.bvOn;
    setAllRegionViewsOff();
    SloRegion.bvOn = invertMenuEntryChecked(hMenSloBV, remind);

    if SloRegion.bvOn == 1
        SloRegionData = createRegionViewsVisu(ActDataDescriptors, SloRegion, dispCorr, PARAMETERS);
    end
    refreshDispSlo();
end

function setAllRegionViewsOff()
    SloRegion.onhOn = setMenuEntryChecked(hMenSloONH, 0);
    SloRegion.onhCircleOn = setMenuEntryChecked(hMenSloONHCircle, 0);
    SloRegion.bvOn = setMenuEntryChecked(hMenSloBV, 0);
end


% Uicontrol handlers
%--------------------------------------------------------------------------

% HSELECTORCALLBACK: If the selector is moved, this function is executed.
% The image content is changed.
% On volumes, the B-Scan is changed, on directories the image.
function hSelectorCallback(hObject, eventdata)
    if guiMode == 1 || guiMode == 4
        ActDataDescriptors.bScanNumber = round(get(hSelector, 'Value'));
    elseif guiMode == 2 || guiMode == 3
        ActDataDescriptors.fileNumber = round(get(hSelector, 'Value'));
    end

    if guiMode == 1 || guiMode == 4 || guiMode == 4
        reloadMetaData();
        refreshDispOct();
        if SloScan.positionOn
            refreshDispSlo();
        end
        refreshDispInfoText();
    elseif guiMode == 2 || guiMode == 3
        ActDataDescriptors.filename = [ActDataDescriptors.filenameList{ActDataDescriptors.fileNumber} ActDataDescriptors.filenameEnding];
        loadDispFile();
        reloadMetaData();
        createAllSLOViews();    
        refreshLayout(); % refreshLayout needed: Perhaps the image size changed.
        refreshDispComplete;
    end
end
   

% Mouse control handlers
%--------------------------------------------------------------------------

% HBUTTONDOWNFUNCTION: Callback called when mouse is pressed on one of the 
% figures. Changes the marker position and eventually (in case
% "dispJumpToMarker" is on) changes the displayed B-Scan.
function hButtonDownFcn(hObject, eventdata)
    if ancestor(gco,'axes') == hOct
        mousePoint = get(hOct,'currentpoint');

        if ActDataDescriptors.Header.ScanPattern == 2
            [octPos sloPos] = convertPosition([mousePoint(1,1) ActDataDescriptors.bScanNumber mousePoint(1,2) ], ...
                'OctToSloCirc', ActDataDescriptors);
        else
            [octPos sloPos] = convertPosition([mousePoint(1,1) ActDataDescriptors.bScanNumber mousePoint(1,2) ], ...
                'OctToSloVol', ActDataDescriptors);
        end

        if strcmp(get(hObject, 'SelectionType'), 'normal')
            sloMarker = sloPos;
            octMarker = octPos;
        elseif strcmp(get(hObject, 'SelectionType'), 'alt')
            if numel(dispZoomOct) == 1       
                dispZoomOct = octPos;
                disp('Zoom on');
            else
                dispZoomOct = 0;
                disp('Zoom off');
            end
            refreshDispOctAxis();
        end
    elseif ancestor(gco,'axes') == hSlo
        mousePoint = get(hSlo,'currentpoint');

        if ActDataDescriptors.Header.ScanPattern == 2
            [octPos sloPos] = convertPosition([mousePoint(1,2) mousePoint(1,1)], ...
                'SloToOctCirc', ActDataDescriptors);
        else
            [octPos sloPos] = convertPosition([mousePoint(1,2) mousePoint(1,1)], ...
                'SloToOctVol', ActDataDescriptors);
        end
        
        if strcmp(get(hObject, 'SelectionType'), 'normal')
            sloMarker = sloPos;
            octMarker = octPos;
        end       
    end

    if dispJumpToMarkerOn
        if guiMode == 1 || guiMode == 4
            if ActDataDescriptors.bScanNumber ~= octMarker(2);
                ActDataDescriptors.bScanNumber = octMarker(2);
                set(hSelector, 'Value', ActDataDescriptors.bScanNumber);
                reloadMetaData();
                refreshDispInfoText();
                refreshDispOct();
                if SloScan.positionOn
                    refreshDispSlo();
                end
            end
        end
    end

    if dispMarkerOn
        refreshDispOct();
        refreshDispSlo();
    end
end

% HRESIZE: If the window size is changed -> Refresh the layout.
function hResizeCallback(hObject, eventdata)
    refreshLayout();
end
 

%--------------------------------------------------------------------------
% Functionality
%--------------------------------------------------------------------------

% SWITCHMODE: Changes the guiMode variable and sets the guiLayout variable
% accordingly. Should be used as early as possible when a new 
% dataset/directory is loaded
function switchMode(newMode)   
    if newMode == 0
        disp('Switching to default mode.');
        guiMode = 0;
        guiLayout = 0;
    elseif newMode == 1
        disp('Switching to HE single file mode.');
        guiMode = 1;
        guiLayout = 1;
    elseif newMode == 2
        disp('Switching to HE directory batch viewing mode.');
        guiMode = 2;
        guiLayout = 1;
     elseif newMode == 3
        disp('Switching to image batch viewing mode.');
        guiMode = 3;
        guiLayout = 2;
    elseif newMode == 4
        disp('Switching to image volume (list) batch processing mode.');
        guiMode = 4;
        guiLayout = 1;
    else
        disp('Mode does not exist. Switching to default mode.');
        guiMode = 0;
        guiLayout = 0;
    end   
end

% REFRESHLAYOUT: Paints the Layout given by the guiLayout variable. 
% Sets all sizes and positions of buttons, figures etc...
% As a reference, the following things are used:
%   width & height of the image window 
%   width & height of OCT & SLO images
% => this function should be called every time the window changes or other
% image data is loaded. 
% Exception: Moving through a volume does not change any sizes.
function refreshLayout()
    if guiLayout == 0
        set(hInfoText, 'Visible', 'off');
        set(hSlo, 'Visible', 'off');
        set(hOct, 'Visible', 'off');
        set(hSelector, 'Visible', 'off');
    elseif guiLayout == 1 % The standard layout with an OCT and SLO image
        fpos = get(hMain, 'position');
        
        width = fpos(3);
        height = fpos(4);
        
        infoTextHeight = 20;
        selectorHeight = 20;
        borderWidth = 5;
        
        if numel(ActDataDescriptors.Header) == 0
            octRatio = 1;
        else
            octRatio = (ActDataDescriptors.Header.SizeX / dispScale) / ActDataDescriptors.Header.SizeZ;
        end
        
        octWidth = round((width - 3 * borderWidth) * octRatio / (octRatio + 1));
        sloWidth = width - 3 * borderWidth - octWidth;
        
        if sloWidth > octWidth
            sloWidth = floor((width - borderWidth * 3) / 2);
            octWidth = width - 3 * borderWidth - sloWidth;
        end
            
        set(hInfoText, 'Position', [borderWidth (height - infoTextHeight) (width - borderWidth) infoTextHeight]);
        
        set(hOct, 'Position', [borderWidth selectorHeight octWidth (height - selectorHeight - infoTextHeight)]);
        set(hSlo, 'Position', [(borderWidth * 2 + octWidth) selectorHeight sloWidth (height - selectorHeight - infoTextHeight)]);
        set(hSelector, 'Position', [0 0 width selectorHeight]);

        set(hInfoText, 'Visible', 'on');
        set(hSlo, 'Visible', 'on');
        set(hOct, 'Visible', 'on');
        
        if numel(ActDataDescriptors.Header) ~= 0 
            if ActDataDescriptors.Header.ScanPattern ~= 2
                set(hSelector, 'Visible', 'on'); 
            else
                if guiMode == 2
                    set(hSelector, 'Visible', 'on'); 
                end
            end
        end
        
        set(hMain,'CurrentAxes',hSlo);    
        axis image;
        axis off;
        refreshDispOctAxis();
        
    elseif guiLayout == 2 % Only an OCT image 
        set(hSelector, 'Visible', 'off');
        set(hSlo, 'Visible', 'off');
        
        fpos = get(hMain, 'position');
        
        width = fpos(3);
        height = fpos(4);
        
        infoTextHeight = 20;
        selectorHeight = 20;
        borderWidth = 5;
            
        set(hInfoText, 'Position', [borderWidth (height - infoTextHeight) (width - borderWidth) infoTextHeight]);
        
        set(hOct, 'Position', [borderWidth selectorHeight (width - 2 * borderWidth) (height - selectorHeight - infoTextHeight)]);
        set(hSelector, 'Position', [0 0 width selectorHeight]);

        set(hInfoText, 'Visible', 'on');
        set(hOct, 'Visible', 'on');
        
        if numel(ActDataDescriptors.Header) ~= 0    
                if guiMode == 3 && numel(ActDataDescriptors.filenameList) > 1
                    set(hSelector, 'Visible', 'on'); 
                end
        end
    
        set(hMain,'CurrentAxes',hOct);
        axis image;
        axis off;
    end
end


% LOADDISPFILE: Takes the ActDataDescriptors.pathname & ActDataDescriptors.filename variables and loads
% all the 'act' variables (ActDataDescriptors.Header, ActDataDescriptors.BScanHeader, ActData.slo, ActData.bScans, 
% ActDataDescriptors.filenameList); 
% If the loading is succesfull, all data variables are deleted.
function loadDispFile()
    [numDescriptor openFuncHandle] = examineOctFile(ActDataDescriptors.pathname, ActDataDescriptors.filename);
    if numDescriptor == 0
        disp('Refresh Disp File: File is no OCT file.');
        return;
    end

    deleteVariables();
    [ActDataDescriptors.Header, ActDataDescriptors.BScanHeader, ActData.slo, ActData.bScans] = openFuncHandle([ActDataDescriptors.pathname ActDataDescriptors.filename]);
    
    if guiMode == 1 || guiMode == 4
        ActDataDescriptors.filenameList = createFileNameList(ActDataDescriptors.filename, ActDataDescriptors.pathname, ActDataDescriptors.Header);
    end
    
    disp(['Display file loaded: ' ActDataDescriptors.pathname ActDataDescriptors.filename]);
end


% DELETEVARIABLES: Deletes ALL stored DATA variables
% Currently used in the loadDispFile function
function deleteVariables() 
    octRPELine = [];
    octBVLine = [];
    octINFLLine = [];
    octICLLine = [];
    octIPLLine = [];
    octOPLLine = [];
    octONFLLine = [];
    octSkleraLine = [];
    octAdditionalData = [];
    octONH = [1 1 1; 1 1 1];

    octMarker = [1 1 1];
    sloMarker = [1 1];

    SloEnfaceData.data = [];
    SloEnfaceData.position = [];

    SloRegionData.onhCenter = [];

    SloOverlayData.data = [];
    SloOverlayData.position = [];
    SloOverlayData.opacity = [];

    SloRegionData.data = [];
    SloRegionData.position = [];
    SloRegionData.opacity = [];
end


% CREATEDISPSLO: Creates an RGB SLO image (dispSlo) out of
% - The stored raw SLO file (ActData.slo)
% - The information on what should be displayed (all the "slo...On")
%       variables
% - The data associated with the variables
% - The information if the marker should be drawn
function createDispSlo()
    dispSlo = single(ActData.slo);
    dispSlo = dispSlo ./ single(max(max(ActData.slo)));
    dispSlo(:,:,2) = dispSlo;
    dispSlo(:,:,3) = dispSlo(:,:,1);
    
    if (SloEnface.nflOn || SloEnface.skleraOn || SloEnface.rpeOn ||SloEnface.fullOn || ...
        SloEnface.rpePositionOn || SloEnface.inflPositionOn || SloEnface.onflPositionOn || SloEnface.skleraPositionOn) ...
        && ActDataDescriptors.Header.ScanPattern ~= 2
    
        dispSlo = combineSloEnface(dispSlo, SloEnfaceData.data, SloEnfaceData.position);
    end
    
    if (SloOverlay.retinaFullOn || SloOverlay.nflThicknessOn) && ActDataDescriptors.Header.ScanPattern ~= 2
         dispSlo = combineSloEnface(dispSlo, SloOverlayData.data, SloOverlayData.position, ...
                    'overlay', SloOverlayData.opacity);
    end
    
    if (SloRegion.onhOn || SloRegion.onhCircleOn || SloRegion.bvOn) && ActDataDescriptors.Header.ScanPattern ~= 2
        dispSlo = combineSloEnface(dispSlo, SloRegionData.data, SloRegionData.position, ...
            'overlay', SloRegionData.opacity);
        
        if (SloRegion.onhOn || SloRegion.onhCircleOn)
            dispSlo = drawMarkerSlo(dispSlo, SloRegionData.onhCenter);
        end
    end
    
   if SloScan.areaOn
        if ActDataDescriptors.Header.ScanPattern == 2
            dispSlo = drawScanpattern(ActDataDescriptors.Header, ActDataDescriptors.BScanHeader, dispSlo, ...
                        'solid', 'Colorline', PARAMETERS.VISU_COLOR_SCANAREA);
        else
            dispSlo = drawScanpattern(ActDataDescriptors.Header, ActDataDescriptors.BScanHeader, dispSlo, ...
                        'area', 'Colorline', PARAMETERS.VISU_COLOR_SCANAREA, 'Linewidth', 1);
        end
    end
    
    if SloScan.patternOn
        if ActDataDescriptors.Header.ScanPattern == 2
            dispSlo = drawScanpattern(ActDataDescriptors.Header, ActDataDescriptors.BScanHeader, dispSlo, ...
                        'solid', 'Colorline', PARAMETERS.VISU_COLOR_SCANPATTERN);
        else
            dispSlo = drawScanpattern(ActDataDescriptors.Header, ActDataDescriptors.BScanHeader, dispSlo, ...
                        'pattern', 'Colorline', PARAMETERS.VISU_COLOR_SCANPATTERN, 'Linewidth', 1);
        end
    end
    
    if SloScan.positionOn
        if ActDataDescriptors.Header.ScanPattern == 2
            dispSlo = drawScanpattern(ActDataDescriptors.Header, ActDataDescriptors.BScanHeader, dispSlo, ...
                        'solid', 'Colorline', PARAMETERS.VISU_COLOR_SCANPOSITION);
        else
            dispSlo = drawScanpattern(ActDataDescriptors.Header, ActDataDescriptors.BScanHeader, dispSlo, ...
                        'position', 'Colorline', PARAMETERS.VISU_COLOR_SCANPOSITION, ...
                        'BScanNum', ActDataDescriptors.bScanNumber, 'Linewidth', 1);
        end
    end   
    
    if dispMarkerOn
        if ActDataDescriptors.Header.ScanPattern == 2
            dispSlo = drawMarkerSlo(dispSlo, sloMarker, 'Circle', 1, ...
                      'Header', ActDataDescriptors.Header, 'BScanHeader', ActDataDescriptors.BScanHeader);
        else
            dispSlo = drawMarkerSlo(dispSlo, sloMarker);
        end
    end
end


% CREATEDISPOCT: Creates an RGB OCT image (dispOCT) out of
% - The stored raw OCT file (actOct)
% - The information on what should be displayed (all the "oct...On")
%       variables
% - The data associated with the variables
% - The information if the marker should be drawn
function createDispOct()
    if guiMode == 2 || guiMode == 3
         dispOct = single(ActData.bScans);
    else
         dispOct = single(ActData.bScans(:,:,ActDataDescriptors.bScanNumber));
    end
   
    if octIntensityScale == 0
        dispOct = sqrt(dispOct);
    elseif octIntensityScale == 1
        dispOct = sqrt(sqrt(dispOct));
    elseif octIntensityScale == 2
        dispOct = mat2gray(log(double(dispOct).*255 + 1));
    end
    
    dispOct(dispOct > 1) = 0;
    dispOct(:,:,2) = dispOct;
    dispOct(:,:,3) = dispOct(:,:,1);
    
    if octRPEOn && size(octRPELine, 2) == ActDataDescriptors.Header.SizeX
        dispOct = drawLinesOct(dispOct, octRPELine, 'LineColors', ...
                    [PARAMETERS.VISU_COLOR_RPEAUTO; PARAMETERS.VISU_COLOR_RPEMAN], 'double', 1);
    end
    
    if octBVOn && size(octBVLine, 2) == ActDataDescriptors.Header.SizeX
        dispOct = drawIdxOct(dispOct, octBVLine, ...
                    PARAMETERS.VISU_COLOR_BV, PARAMETERS.VISU_OPACITY_BV);
    end
    
    if octINFLOn && size(octINFLLine, 2) == ActDataDescriptors.Header.SizeX
        dispOct = drawLinesOct(dispOct, octINFLLine, 'LineColors', ...
                    [PARAMETERS.VISU_COLOR_INFLAUTO; PARAMETERS.VISU_COLOR_INFLMAN], 'double', 1);
    end
    
    if octInnerLayersOn
        if size(octICLLine, 2) == ActDataDescriptors.Header.SizeX
            dispOct = drawLinesOct(dispOct, octICLLine, 'LineColors', ...
                [PARAMETERS.VISU_COLOR_ICLAUTO; PARAMETERS.VISU_COLOR_ICLMAN], 'double', 1);
        end
        if size(octIPLLine, 2) == ActDataDescriptors.Header.SizeX
            dispOct = drawLinesOct(dispOct, octIPLLine, 'LineColors', ...
                [PARAMETERS.VISU_COLOR_IPLAUTO; PARAMETERS.VISU_COLOR_IPLMAN], 'double', 1);
        end
        if size(octOPLLine, 2) == ActDataDescriptors.Header.SizeX
            dispOct = drawLinesOct(dispOct, octOPLLine, 'LineColors', ...
                [PARAMETERS.VISU_COLOR_OPLAUTO; PARAMETERS.VISU_COLOR_OPLMAN], 'double', 1);
        end
    end
    
    if octONFLOn && size(octONFLLine, 2) == ActDataDescriptors.Header.SizeX
        dispOct = drawLinesOct(dispOct, octONFLLine, 'LineColors', ...
            [PARAMETERS.VISU_COLOR_ONFLAUTO; PARAMETERS.VISU_COLOR_ONFLMAN], 'double', 1);
    end
    
    if octSkleraOn && size(octSkleraLine, 2) == ActDataDescriptors.Header.SizeX
        dispOct = drawLinesOct(dispOct, octSkleraLine, 'LineColors', ...
            [PARAMETERS.VISU_COLOR_SKLERAAUTO; PARAMETERS.VISU_COLOR_SKLERAMAN], 'double', 1);
    end
    
    if octMedlineOn && size(octMedlineLine, 2) == ActDataDescriptors.Header.SizeX
        dispOct = drawLinesOct(dispOct, octMedlineLine, 'LineColors', ...
            [PARAMETERS.VISU_COLOR_MEDLINEAUTO; PARAMETERS.VISU_COLOR_MEDLINEMAN], 'double', 1);
    end
    
    if octAdditionalOn && size(octAdditionalData,2) == ActDataDescriptors.Header.SizeX
        dispOct = drawLinesOct(dispOct, octAdditionalData, 'LineColors', ...
            [PARAMETERS.VISU_COLOR_ADDITIONAL1; PARAMETERS.VISU_COLOR_ADDITIONAL2], 'double', 1);
    end
    
    if octONHOn && ActDataDescriptors.Header.ScanPattern ~= 2 && numel(octONH) ~= 0
            dispOct = drawMarkerOct(dispOct, octONH(1,:), ...
                PARAMETERS.VISU_COLOR_ONH_BOUNDARY, PARAMETERS.VISU_ONH_BOUNDARY_WIDTH, PARAMETERS.VISU_OPACITY_ONH_BOUNDARY);
            dispOct = drawMarkerOct(dispOct, octONH(2,:), ...
                PARAMETERS.VISU_COLOR_ONH_BOUNDARY, PARAMETERS.VISU_ONH_BOUNDARY_WIDTH, PARAMETERS.VISU_OPACITY_ONH_BOUNDARY);
    end
    
    if dispMarkerOn
        if ActDataDescriptors.Header.ScanPattern == 2
            dispOct = drawMarkerOct(dispOct, octMarker, ...
                PARAMETERS.VISU_COLOR_MARKER, PARAMETERS.VISU_MARKER_OCTWIDTH, PARAMETERS.VISU_OPACITY_MARKER);
        else
            if octMarker(2) == ActDataDescriptors.bScanNumber
                dispOct = drawMarkerOct(dispOct, octMarker, ...
                PARAMETERS.VISU_COLOR_MARKER, PARAMETERS.VISU_MARKER_OCTWIDTH, PARAMETERS.VISU_OPACITY_MARKER);
            end
        end
    end
end


% REFRESHDISPSLO: Refreshes the content of the SLO figure.
function refreshDispSlo() 
    if guiLayout == 1
        createDispSlo();
        set(hMain,'CurrentAxes',hSlo);
        imagesc(dispSlo);
        axis image;
        axis off;
    end
end


% REFRESHDISPOCT: Refreshes the content of the OCT figure.
function refreshDispOct()
    createDispOct();
    set(hMain,'CurrentAxes',hOct);
    imagesc(dispOct);
    
    refreshDispOctAxis();
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


% REFRESHDISPINFOTEXT: Refreshes all the text displayed
function refreshDispInfoText()
    if guiMode == 1 || guiMode == 4
        set(hInfoText, 'String', [ActDataDescriptors.filename ...
                ' (Bscan#: ' num2str(ActDataDescriptors.bScanNumber) ...
                ', PatientID: ' deblank(ActDataDescriptors.Header.PatientID) ...
                ', Position: ' deblank(ActDataDescriptors.Header.ScanPosition) ...
                ', ID: ' deblank(ActDataDescriptors.Header.ID) ...
                ', VisitID: ' deblank(ActDataDescriptors.Header.VisitID) ...
                ')']);
    elseif guiMode == 2 || guiMode == 3
        set(hInfoText, 'String', [ActDataDescriptors.filename ...
                ' (PatientID: ' deblank(ActDataDescriptors.Header.PatientID) ...
                ', Position: ' deblank(ActDataDescriptors.Header.ScanPosition) ...
                ', ID: ' deblank(ActDataDescriptors.Header.ID) ...
                ', VisitID: ' deblank(ActDataDescriptors.Header.VisitID) ...
                ')']);
    end
end


% REFRESHDISPCOMPLETE: Refreshes the text, the SLO figure and the OCT
% figure alltogether
function refreshDispComplete()
    refreshDispInfoText();
    refreshDispSlo();
    refreshDispOct();
end


% RELOADMETADATA: Loads all the meta data (segmentations) for the OCT
% image. Either the meta data of all active displayed segmentations is
% reloaded (no parameters given), or only the meta data of the given
% descriptor.
function reloadMetaData(descriptor)
    % If no arguments are diven, the loading depends on active
    % visualizations
    if nargin < 1
        loadRPE = octRPEOn;
        loadONH = octONHOn;
        loadBV = octBVOn;
        loadINFL = octINFLOn;
        loadONFL = octONFLOn;
        loadSklera = octSkleraOn;
        loadInnerLayers = octInnerLayersOn;
        loadMedline = octMedlineOn;
        loadAdditional = octAdditionalOn;
    % If a descriptor is given, only the associated data is loaded.
    else
        loadRPE = 0;
        loadBV = 0;
        loadINFL = 0;
        loadONFL = 0;
        loadSklera = 0;
        loadInnerLayers = 0;
        loadAdditional = 0;
        loadMedline = 0;
        loadONH = 0;
        
        switch descriptor
            case 'RPE'
                loadRPE = 1;
            case 'ONH'
                loadONH = 1;
            case 'Blood Vessels'
                loadBV = 1;
            case 'INFL'
                loadINFL = 1;
            case 'ONFL'
                loadONFL = 1;
            case 'Sklera'
                loadSklera = 1;
            case 'Inner Layers'
                loadInnerLayers = 1;
            case 'Medline'
                loadMedline = 1;
            case 'Additional'
                loadAdditional = 1;
            otherwise
                disp('reloadMetaData: descriptor not known!');
                return;
        end
    end
    
    if loadRPE
        octRPELine = loadMetaDataVisu(guiMode, ActDataDescriptors, ...
                                      dispCorr, getMetaTag('RPE','bothData'));
    end
    
    if loadONH
        octONHLine = loadMetaDataVisu(guiMode, ActDataDescriptors, ...
            dispCorr, getMetaTag('ONH','bothData'));
        if sum(octONHLine(1,:)) ~= 0
            octONHIdx = find(octONHLine(1,:));
            octONH(1,1) = octONHIdx(1);
            octONH(2,1) = octONHIdx(end);
        else
            octONH = [];
        end
    end

    if loadBV
        octBVLine = loadMetaDataVisu(guiMode, ActDataDescriptors, ...
                                     dispCorr, {getMetaTag('Blood Vessels','autoData')});
    end

    if loadINFL
        octINFLLine = loadMetaDataVisu(guiMode, ActDataDescriptors, ...
                                       dispCorr, getMetaTag('INFL','bothData'));
    end

    if loadONFL
        octONFLLine = loadMetaDataVisu(guiMode, ActDataDescriptors, ...
                                       dispCorr, getMetaTag('ONFL','bothData'));
    end
    
    if loadSklera
        octSkleraLine = loadMetaDataVisu(guiMode, ActDataDescriptors, ...
                                         dispCorr, getMetaTag('Sklera','bothData'));
    end
    
    if loadMedline
        octMedlineLine = loadMetaDataVisu(guiMode, ActDataDescriptors, ...
                                         dispCorr, getMetaTag('Medline','bothData'));
    end

    if loadInnerLayers
        octICLLine = loadMetaDataVisu(guiMode, ActDataDescriptors, ...
                                      dispCorr, getMetaTag('ICL','bothData'));
        octIPLLine = loadMetaDataVisu(guiMode, ActDataDescriptors, ...
                                      dispCorr, getMetaTag('IPL','bothData'));
        octOPLLine = loadMetaDataVisu(guiMode, ActDataDescriptors, ...
                                      dispCorr, getMetaTag('OPL','bothData'));
    end

    if loadAdditional
        octAdditionalData = zeros(1,ActDataDescriptors.Header.SizeX, 'single');
        octAdditionalData(1,:) = loadMetaDataVisu(guiMode, ActDataDescriptors, ...
                                                  dispCorr, {'AdditionalInfo1'});
    end
end


% CREATEALLSLOVIEWS: Loads and creates all the Enface/Region/Overlay views
function createAllSLOViews()
    if guiMode == 1 || guiMode == 4
        SloEnfaceData = createEnfaceViewsVisu(ActDataDescriptors, ActData, SloEnface, dispCorr, PARAMETERS);
        SloRegionData = createRegionViewsVisu(ActDataDescriptors, SloRegion, dispCorr, PARAMETERS);
        SloOverlayData = createOverlayViewsVisu(ActDataDescriptors, SloOverlay, dispCorr, PARAMETERS);
    end
end


end