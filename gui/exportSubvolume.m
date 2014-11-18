function  exportSubvolume(DataDescriptors)

%--------------------------------------------------------------------------
% Variables
%--------------------------------------------------------------------------

fromPos = 'fixed';
toPos = 'fixed';

%--------------------------------------------------------------------------
% GUI Components
%--------------------------------------------------------------------------

f = figure('Visible','off','Position',[360,500,500,185],...
    'WindowStyle', 'normal',...
    'MenuBar', 'none', ...
    'ResizeFcn', {@refreshLayout},...
    'CloseRequestFcn', {@hCloseRequestFcn},...
    'Color', 'white');

hTextFrom = uicontrol('Style','text','String','From',...
    'BackgroundColor', 'white',...
    'FontSize', 16,...
    'HorizontalAlignment', 'left');

hTextTo = uicontrol('Style','text','String','To',...
    'BackgroundColor', 'white',...
    'FontSize', 16,...
    'HorizontalAlignment', 'left');

hTextPixelFrom = uicontrol('Style','text','String','px',...
    'BackgroundColor', 'white',...
    'FontSize', 16,...
    'HorizontalAlignment', 'left');

hTextPixelTo = uicontrol('Style','text','String','px',...
    'BackgroundColor', 'white',...
    'FontSize', 16,...
    'HorizontalAlignment', 'left');

hEditPixelFrom = uicontrol('Style','edit','String', '100',...
    'BackgroundColor', [1 1 1],...
    'FontSize', 10,...
    'Min', 1, 'Max', 1, ...
    'HorizontalAlignment', 'left',...
    'Units','pixels');

hEditPixelTo = uicontrol('Style','edit','String', '100',...
    'BackgroundColor', [1 1 1],...
    'FontSize', 10,...
    'Min', 1, 'Max', 1, ...
    'HorizontalAlignment', 'left',...
    'Units','pixels');

hCheckAlignFrom = uicontrol('Style','checkbox','String', 'Align',...
    'Value', 1, ...
    'BackgroundColor', 'white',...
    'FontSize', 12,...
    'Callback',{@hAlignFromCallback});

hCheckAlignTo = uicontrol('Style','checkbox','String', 'Align',...
    'Value', 0, ...
    'BackgroundColor', 'white',...
    'FontSize', 12,...
    'Callback',{@hAlignToCallback});

hPopFrom = uicontrol('Style','popupmenu',...
    'Callback',{@hPopFromCallback}, ...
    'String',{...
    'Fixed Depth',... 1
    'RPE', ... 2
    'ICL',  ... 3
    'OPL', ... 4
    'IPL', ... 5
    'ONFL', ... 6
    'INFL'}... 7
   );

hPopTo = uicontrol('Style','popupmenu',...
    'Callback',{@hPopToCallback}, ...
    'String',{...
    'Fixed Depth',... 1
    'Relative Depth', ... 2
    'RPE', ... 3
    'ICL',  ... 4
    'OPL', ... 5
    'IPL', ... 6
    'ONFL', ... 7
    'INFL'}... 8
   );

hCheckBlacken = uicontrol('Style','checkbox','String', 'Blacken out exteriors',...
    'Value', 1, ...
    'BackgroundColor', 'white',...
    'FontSize', 12);

%------------Buttons---------------
hExport = uicontrol('Style','pushbutton','String','Export',...
    'Position',[10,10,780,80],...
    'FontSize', 16,...
    'Callback',{@hExportCallback});

hCancel = uicontrol('Style','pushbutton','String','Cancel',...
    'Position',[10,10,780,80],...
    'FontSize', 16,...
    'Callback',{@hCloseRequestFcn});

%--------------------------------------------------------------------------
% GUI Init
%--------------------------------------------------------------------------



set(f,'Units','pixels');
set(f,'Name','Export Subvolume');

movegui(f,'center');
set(f,'Visible','on');

%--------------------------------------------------------------------------
% GUI Component Handlers
%--------------------------------------------------------------------------

function hPopFromCallback(hObject, eventdata)
    switch get(hPopFrom, 'Value')
        case 1
            fromPos = 'fixed';
        case 2
            fromPos = 'RPE';
        case 3
            fromPos = 'ICL';
        case 4
            fromPos = 'OPL';
        case 5
            fromPos = 'IPL';
        case 6
            fromPos = 'ONFL';
        case 7
            fromPos = 'INFL';
        otherwise
            disp('Pop From Menu: This should not happen!');
    end
    
    refreshLayout();
end

function hPopToCallback(hObject, eventdata)
    switch get(hPopTo, 'Value')
        case 1
            toPos = 'fixed';
        case 2
            toPos = 'relative';
        case 3
            toPos = 'RPE';
        case 4
            toPos = 'ICL';
        case 5
            toPos = 'OPL';
        case 6
            toPos = 'IPL';
        case 7
            toPos = 'ONFL';
        case 8
            toPos = 'INFL';
        otherwise
            disp('Pop From Menu: This should not happen!');
    end
    
    refreshLayout();
end

function hAlignFromCallback(hObject, eventdata)
    if get(hCheckAlignTo, 'Value') && get(hCheckAlignFrom, 'Value');
        set(hCheckAlignTo, 'Value', 0);
    end 
end

function hAlignToCallback(hObject, eventdata)
    if get(hCheckAlignFrom, 'Value') && get(hCheckAlignTo, 'Value');
        set(hCheckAlignFrom, 'Value', 0);
    end 
end

function hExportCallback(hObject, eventdata)
    [filename, pathname] = uiputfile({'*.vol','Heidelberg Engineering RAW OCT File';...
        '*.*','All Files' },'Save RAW OCT Image',...
        'subvolume.vol');
    
    disp(['Subvolume export to ' pathname filename ]);

    if isequal(filename,0)
        disp('Save Subvolume: Chancelled.');
        return;
    else
        disp(['Save Subvolume Image: ' pathname filename]);
    end

    [header, BScanHeader, slo, bScans] = openVol ([DataDescriptors.pathname DataDescriptors.filename]);

    boundaries = createBoundaries();

    Data.bScans = bScans;
    Data.slo = slo;
    
    if get(hCheckAlignFrom, 'Value')
        align = 1;
    elseif get(hCheckAlignTo, 'Value')
        align = 2;
    else
        align = 0;
    end
    
    blacken = get(hCheckBlacken, 'Value');
    
    [subHeader subBScanHeader subSlo subBScans] = createSubvolume(DataDescriptors, Data, boundaries, align, blacken);
    
    saveVol([pathname filename], subHeader, subBScanHeader, subSlo, subBScans);
    
    disp('Subvolume succesfully exported.');
end


function hCloseRequestFcn(hObject, eventdata, handles)
    %uiresume(hObject);
    delete(f);
end

function boundaries = createBoundaries()
    boundaries = zeros(DataDescriptors.Header.NumBScans, DataDescriptors.Header.SizeX, 2, 'single');
    fromRelative = 0;

    switch fromPos
        case 'fixed'
            boundaries(:,:,1) = str2double(get(hEditPixelFrom, 'String'));
        case 'RPE'
            boundaries(:,:,1) = loadMetaDataEnfaceVisu(DataDescriptors, 1, getMetaTag('RPE','both'));
        case 'ICL'
            boundaries(:,:,1) = loadMetaDataEnfaceVisu(DataDescriptors, 1, getMetaTag('ICL','both'));
        case 'OPL'
            boundaries(:,:,1) = loadMetaDataEnfaceVisu(DataDescriptors, 1, getMetaTag('OPL','both'));
        case 'IPL'
            boundaries(:,:,1) = loadMetaDataEnfaceVisu(DataDescriptors, 1, getMetaTag('IPL','both'));
        case 'ONFL'
            boundaries(:,:,1) = loadMetaDataEnfaceVisu(DataDescriptors, 1, getMetaTag('ONFL','both'));
        case 'INFL'
            boundaries(:,:,1) = loadMetaDataEnfaceVisu(DataDescriptors, 1, getMetaTag('INFL','both'));
    end

    switch toPos
        case 'fixed'
            boundaries(:,:,2) = str2double(get(hEditPixelTo, 'String'));
        case 'relative'
            adder = str2double(get(hEditPixelTo, 'String'));
            if adder >= 0
                boundaries(:,:,2) = boundaries(:,:,1) + str2double(get(hEditPixelTo, 'String'));
            else
                boundaries(:,:,2) = boundaries(:,:,1);
                boundaries(:,:,1) = boundaries(:,:,2) + str2double(get(hEditPixelTo, 'String'));
            end
        case 'RPE'
            boundaries(:,:,2) = loadMetaDataEnfaceVisu(DataDescriptors, 1, getMetaTag('RPE','both'));
        case 'ICL'
            boundaries(:,:,2) = loadMetaDataEnfaceVisu(DataDescriptors, 1, getMetaTag('ICL','both'));
        case 'OPL'
            boundaries(:,:,2) = loadMetaDataEnfaceVisu(DataDescriptors, 1, getMetaTag('OPL','both'));
        case 'IPL'
            boundaries(:,:,2) = loadMetaDataEnfaceVisu(DataDescriptors, 1, getMetaTag('IPL','both'));
        case 'ONFL'
            boundaries(:,:,2) = loadMetaDataEnfaceVisu(DataDescriptors, 1, getMetaTag('ONFL','both'));
        case 'INFL'
            boundaries(:,:,2) = loadMetaDataEnfaceVisu(DataDescriptors, 1, getMetaTag('INFL','both'));
    end
end

% REFRESHLAYOUT: Paints the Layout
function refreshLayout(hObject, eventdata)
    
        fpos = get(f, 'position');
        width = fpos(3);
        height = fpos(4);
        border = 5;

        textFromToWidth = 80;
        popWidth = (width - 3 * border - 2 * textFromToWidth) / 2;
        
        stdHeight = 40;
        
        firstLineHeight = height - 2 * border - stdHeight;
        set(hTextFrom, 'Position', [border firstLineHeight textFromToWidth stdHeight]);
        set(hTextTo, 'Position', [(2 * border + popWidth +  textFromToWidth) firstLineHeight textFromToWidth stdHeight]);
        
        set(hPopFrom, 'Position', [(border + textFromToWidth) firstLineHeight popWidth stdHeight]);
        set(hPopTo, 'Position', [(2 * border + popWidth + 2 * textFromToWidth) firstLineHeight popWidth stdHeight]);
        
        secondLineHeight = height - 3 * border - 2 * stdHeight;
        secondLineWidth = (width - 5 * border) / 4;
        if strcmp(fromPos, 'fixed') || strcmp(fromPos, 'relative')
            set(hTextPixelFrom , 'Visible', 'on');
            set(hEditPixelFrom , 'Visible', 'on');
            set(hCheckAlignFrom , 'Visible', 'off');
            
            set(hEditPixelFrom, 'Position', [border secondLineHeight secondLineWidth stdHeight]);
            set(hTextPixelFrom, 'Position', [(2*border + secondLineWidth) secondLineHeight secondLineWidth stdHeight]);
        else
            set(hTextPixelFrom , 'Visible', 'off');
            set(hEditPixelFrom , 'Visible', 'off');
            set(hCheckAlignFrom , 'Visible', 'on');            
            set(hCheckAlignFrom, 'Position', [border secondLineHeight secondLineWidth stdHeight]);
         end
        
        if strcmp(toPos, 'fixed') || strcmp(toPos, 'relative')
            set(hTextPixelTo , 'Visible', 'on');
            set(hEditPixelTo , 'Visible', 'on');
            set(hCheckAlignTo , 'Visible', 'off');
            
            set(hEditPixelTo, 'Position', [(2 * border + popWidth +  textFromToWidth) secondLineHeight secondLineWidth stdHeight]);
            set(hTextPixelTo, 'Position', [(3 * border + popWidth +  textFromToWidth + secondLineWidth) secondLineHeight secondLineWidth stdHeight]);
        else
            set(hTextPixelTo , 'Visible', 'off');
            set(hEditPixelTo , 'Visible', 'off');
            set(hCheckAlignTo , 'Visible', 'on');
            set(hCheckAlignTo, 'Position', [(2 * border + popWidth +  textFromToWidth) secondLineHeight secondLineWidth stdHeight]);
        end
        
        thirdLineHeight = height - 4 * border - 3 * stdHeight;
        set(hCheckBlacken, 'Position', [border thirdLineHeight (width - 2 * border) stdHeight]);
              
        buttonWidth = (width - 3 * border) / 2;
        
        buttonHeight = 40;
        
        set(hExport, 'Position', [(2 * border + buttonWidth) border buttonWidth buttonHeight]);
        set(hCancel, 'Position', [border border buttonWidth buttonHeight]);
          
end

end
