function  csvSaveBScans(DataDescriptors)

octsegConstantVariables;
global PARAMETER_FILENAME;
Params = loadParameters('EXPORT', PARAMETER_FILENAME);

%--------------------------------------------------------------------------
% GUI Components
%--------------------------------------------------------------------------

f = figure('Visible','off','Position',[360,500,800,690],...
    'WindowStyle', 'normal',...
    'MenuBar', 'none', ...
    'Color', 'white');


htextHeader = uicontrol('Style','text','String','Header Information',...
    'BackgroundColor', 'white',...
    'FontSize', 16,...
    'HorizontalAlignment', 'center',...
    'Position',[10,630,780,40]);

htextBScan = uicontrol('Style','text','String','BScan Information',...
    'BackgroundColor', 'white',...
    'FontSize', 16,...
    'HorizontalAlignment', 'center',...
    'Position',[10,290,780,40]);

htextData = uicontrol('Style','text','String','Data',...
    'BackgroundColor', 'white',...
    'FontSize', 16,...
    'HorizontalAlignment', 'center',...
    'Position',[10,150,780,40]);


%---------Block 1----------------
hSizeX = uicontrol('Style','checkbox','String', 'SizeX',...
    'Value', 0, ...
    'BackgroundColor', 'white',...
    'FontSize', 12,...
    'Position',[10,590,180,40]);

hNumBScans = uicontrol('Style','checkbox','String', 'NumBScans',...
    'Value', 0, ...
    'BackgroundColor', 'white',...
    'FontSize', 12,...
    'Position',[210,590,180,40]);

hSizeZ = uicontrol('Style','checkbox','String', 'SizeZ',...
    'Value', 0, ...
    'BackgroundColor', 'white',...
    'FontSize', 12,...
    'Position',[410,590,180,40]);


%---------Block 2----------------
hScaleX = uicontrol('Style','checkbox','String', 'ScaleX',...
    'Value', 0, ...
    'BackgroundColor', 'white',...
    'FontSize', 12,...
    'Position',[10,550,180,40]);

hDistance = uicontrol('Style','checkbox','String', 'Distance',...
    'Value', 0, ...
    'BackgroundColor', 'white',...
    'FontSize', 12,...
    'Position',[210,550,180,40]);

hScaleZ = uicontrol('Style','checkbox','String', 'ScaleZ',...
    'Value', 0, ...
    'BackgroundColor', 'white',...
    'FontSize', 12,...
    'Position',[410,550,180,40]);

%---------Block 3----------------
hSizeXSlo = uicontrol('Style','checkbox','String', 'SizeXSlo',...
    'Value', 0, ...
    'BackgroundColor', 'white',...
    'FontSize', 12,...
    'Position',[10,510,180,40]);

hSizeYSlo = uicontrol('Style','checkbox','String', 'SizeYSlo',...
    'Value', 0, ...
    'BackgroundColor', 'white',...
    'FontSize', 12,...
    'Position',[210,510,180,40]);

hScaleXSlo = uicontrol('Style','checkbox','String', 'ScaleXSlo',...
    'Value', 0, ...
    'BackgroundColor', 'white',...
    'FontSize', 12,...
    'Position',[410,510,180,40]);

hScaleYSlo = uicontrol('Style','checkbox','String', 'ScaleYSlo',...
    'Value', 0, ...
    'BackgroundColor', 'white',...
    'FontSize', 12,...
    'Position',[610,510,180,40]);

%---------Block 4----------------
hFieldSizeSlo = uicontrol('Style','checkbox','String', 'FieldSizeSlo',...
    'Value', 0, ...
    'BackgroundColor', 'white',...
    'FontSize', 12,...
    'Position',[10,470,180,40]);

hScanFocus = uicontrol('Style','checkbox','String', 'ScanFocus',...
    'Value', 0, ...
    'BackgroundColor', 'white',...
    'FontSize', 12,...
    'Position',[210,470,180,40]);


hScanPosition = uicontrol('Style','checkbox','String', 'ScanPosition',...
    'Value', 1, ...
    'BackgroundColor', 'white',...
    'FontSize', 12,...
    'Position',[410,470,180,40]);

%---------Block 5----------------
hExamTime = uicontrol('Style','checkbox','String', 'ExamTime',...
    'Value', 0, ...
    'BackgroundColor', 'white',...
    'FontSize', 12,...
    'Position',[10,430,180,40]);

hScanPattern = uicontrol('Style','checkbox','String', 'ScanPattern',...
    'Value', 0, ...
    'BackgroundColor', 'white',...
    'FontSize', 12,...
    'Position',[210,430,180,40]);

hID = uicontrol('Style','checkbox','String', 'ID',...
    'Value', 1, ...
    'BackgroundColor', 'white',...
    'FontSize', 12,...
    'Position',[410,430,180,40]);


hReferenceID = uicontrol('Style','checkbox','String', 'ReferenceID',...
    'Value', 0, ...
    'BackgroundColor', 'white',...
    'FontSize', 12,...
    'Position',[610,430,180,40]);

%---------Block 6----------------
hPID = uicontrol('Style','checkbox','String', 'PID',...
    'Value', 0, ...
    'BackgroundColor', 'white',...
    'FontSize', 12,...
    'Position',[10,390,180,40]);

hPatientID = uicontrol('Style','checkbox','String', 'PatientID',...
    'Value', 1, ...
    'BackgroundColor', 'white',...
    'FontSize', 12,...
    'Position',[210,390,180,40]);

hDOB = uicontrol('Style','checkbox','String', 'DOB',...
    'Value', 1, ...
    'BackgroundColor', 'white',...
    'FontSize', 12,...
    'Position',[410,390,180,40]);

hVID = uicontrol('Style','checkbox','String', 'VID',...
    'Value', 0, ...
    'BackgroundColor', 'white',...
    'FontSize', 12,...
    'Position',[610,390,180,40]);

%---------Block 7----------------
hVisitID = uicontrol('Style','checkbox','String', 'VisitID',...
    'Value', 1, ...
    'BackgroundColor', 'white',...
    'FontSize', 12,...
    'Position',[10,350,180,40]);

hVisitDate = uicontrol('Style','checkbox','String', 'VisitDate',...
    'Value', 1, ...
    'BackgroundColor', 'white',...
    'FontSize', 12,...
    'Position',[210,350,180,40]);

hGridType = uicontrol('Style','checkbox','String', 'GridType',...
    'Value', 0, ...
    'BackgroundColor', 'white',...
    'FontSize', 12,...
    'Position',[410,350,180,40]);

%---------Block 8 BScan Header----------------
hStartX = uicontrol('Style','checkbox','String', 'StartX',...
    'Value', 0, ...
    'BackgroundColor', 'white',...
    'FontSize', 12,...
    'Position',[10,250,180,40]);

hStartY = uicontrol('Style','checkbox','String', 'StartY',...
    'Value', 0, ...
    'BackgroundColor', 'white',...
    'FontSize', 12,...
    'Position',[210,250,180,40]);

hEndX = uicontrol('Style','checkbox','String', 'EndX',...
    'Value', 0, ...
    'BackgroundColor', 'white',...
    'FontSize', 12,...
    'Position',[410,250,180,40]);

hEndY = uicontrol('Style','checkbox','String', 'EndY',...
    'Value', 0, ...
    'BackgroundColor', 'white',...
    'FontSize', 12,...
    'Position',[610,250,180,40]);

%---------Block 9 BScan Header----------------
hQuality = uicontrol('Style','checkbox','String', 'Quality',...
    'Value', 0, ...
    'BackgroundColor', 'white',...
    'FontSize', 12,...
    'Position',[10,210,180,40]);

hShift = uicontrol('Style','checkbox','String', 'Shift',...
    'Value', 0, ...
    'BackgroundColor', 'white',...
    'FontSize', 12,...
    'Position',[210,210,180,40]);

%-----------Data Block-----------------

hDataPop = uicontrol('Style','popupmenu',...
    'String',{...
    '<None>',... 1
    '<ForceColumns>',... 2
    'ILM HE', ... 3
    'RPE HE', ... 4
    'ONFL HE',  ... 5
    'Retina Thickness HE', ... 6
    'RNFL Thickness HE', ... 7
    'ILM OCTSEG', ... 8
    'RPE OCTSEG', ... 9
    'ONFL OCTSEG', ... 10
    'ICL OCTSEG',... 11
    'OPL OCTSEG',... 12
    'IPL OCTSEG', ... 13
    'SKLERA OCTSEG',... 14 
    'Retina Thickness OCTSEG', ... 15
    'RNFL Thickness OCTSEG',... 16
    'IPL + GCL Thickness OCTSEG',... 17
    'OPL + INL Thickness OCTSEG',... 18
    'ONL Thickness OCTSEG',... 19
    'RPE + Photoreceptors Thickness OCTSEG',... 20
    'SKLERA Thickness OCTSEG',... 21
    'Blood Vessel Positions OCTSEG',... 22
    'Reflection RNFL', ... 23  %NOTPUBLIC
    'Reflection RPE', ... 24   %NOTPUBLIC
    },...
    'Position',[10,100,380,40]);

hInterp = uicontrol('Style','checkbox','String', 'Interpolate to 768 values',...
    'Value', 0, ...
    'BackgroundColor', 'white',...
    'FontSize', 12,...
    'Position',[410,110,210,40]);

hFormat = uicontrol('Style','checkbox','String', 'European formating',...
    'Value', 1, ...
    'BackgroundColor', 'white',...
    'FontSize', 12,...
    'Position',[630,110,160,40]);

%------------Save Button---------------
hSave = uicontrol('Style','pushbutton','String','Save Table',...
    'Position',[10,10,780,80],...
    'FontSize', 16,...
    'Callback',{@hSave_Callback});

%--------------------------------------------------------------------------
% GUI Init
%--------------------------------------------------------------------------

set([f, htextHeader, htextBScan, htextData, ...
    hSizeX, hNumBScans, hSizeZ, ...
    hScaleX, hDistance, hScaleZ, ...
    hSizeXSlo, hSizeYSlo, hScaleXSlo, hScaleYSlo,...
    hFieldSizeSlo, hScanFocus, hScanPosition, hExamTime, ...
    hScanPattern, hID, hReferenceID, ...
    hPID, hPatientID, hDOB, hVID, ...
    hVisitID, hVisitDate, hGridType, ...
    hStartX, hStartY, hEndX, hEndY, ...
    hQuality, hShift,...
    hDataPop, hInterp, hFormat,...
    hSave],'Units','normalized');
set(f,'Name','Export CSV');

movegui(f,'center');
set(f,'Visible','on');

%--------------------------------------------------------------------------
% GUI Component Handlers
%--------------------------------------------------------------------------

    function hSave_Callback(hObject, eventdata)
        i = 1;
        singleTag = cell(1,1);
        singleTagFormat = cell(1,1);
        dataTag = '';
        dataTagFormat = cell(1,1);
        
        if get(hFormat, 'Value')
            printFormat = 'ptoc';
        else
            printFormat = ''; 
        end
        
        %%------------Block 1 Check--------------------
        if get(hSizeX, 'Value')
            singleTag{i,1} = 'SizeX';
            singleTagFormat{i,1} = 'SizeX';
            singleTagFormat{i,2} = '%d';
            singleTagFormat{i,3} = '';
            i = i+1;
        end
        
        if get(hNumBScans, 'Value')
            singleTag{i,1} = 'NumBScans';
            singleTagFormat{i,1} = 'NumBScans';
            singleTagFormat{i,2} = '%d';
            singleTagFormat{i,3} = '';
            i = i+1;
        end
        
        if get(hSizeZ, 'Value')
            singleTag{i,1} = 'SizeZ';
            singleTagFormat{i,1} = 'SizeZ';
            singleTagFormat{i,2} = '%d';
            singleTagFormat{i,3} = '';
            i = i+1;
        end
        
        %%------------Block 2 Check--------------------
        if get(hScaleX, 'Value')
            singleTag{i,1} = 'ScaleX';
            singleTagFormat{i,1} = 'ScaleX';
            singleTagFormat{i,2} = '%f';
            singleTagFormat{i,3} = printFormat;
            i = i+1;
        end
        
        if get(hDistance, 'Value')
            singleTag{i,1} = 'Distance';
            singleTagFormat{i,1} = 'Distance';
            singleTagFormat{i,2} = '%f';
            singleTagFormat{i,3} = printFormat;
            i = i+1;
        end
        
        
        if get(hScaleZ, 'Value')
            singleTag{i,1} = 'ScaleZ';
            singleTagFormat{i,1} = 'ScaleZ';
            singleTagFormat{i,2} = '%f';
            singleTagFormat{i,3} = printFormat;
            i = i+1;
        end
        
        %%------------Block 3 Check--------------------
        if get(hSizeXSlo, 'Value')
            singleTag{i,1} = 'SizeXSlo';
            singleTagFormat{i,1} = 'SizeXSlo';
            singleTagFormat{i,2} = '%d';
            singleTagFormat{i,3} = '';
            i = i+1;
        end
        
        if get(hSizeYSlo, 'Value')
            singleTag{i,1} = 'SizeYSlo';
            singleTagFormat{i,1} = 'SizeYSlo';
            singleTagFormat{i,2} = '%d';
            singleTagFormat{i,3} = '';
            i = i+1;
        end
        
        if get(hScaleXSlo, 'Value')
            singleTag{i,1} = 'ScaleXSlo';
            singleTagFormat{i,1} = 'ScaleXSlo';
            singleTagFormat{i,2} = '%f';
            singleTagFormat{i,3} = printFormat;
            i = i+1;
        end
        
        if get(hScaleYSlo, 'Value')
            singleTag{i,1} = 'ScaleYSlo';
            singleTagFormat{i,1} = 'ScaleYSlo';
            singleTagFormat{i,2} = '%f';
            singleTagFormat{i,3} = printFormat;
            i = i+1;
        end
        
        %%------------Block 4 Check--------------------
        if get(hFieldSizeSlo, 'Value')
            singleTag{i,1} = 'FieldSizeSlo';
            singleTagFormat{i,1} = 'FieldSizeSlo';
            singleTagFormat{i,2} = '%d';
            singleTagFormat{i,3} = '';
            i = i+1;
        end
        
        if get(hScanFocus, 'Value')
            singleTag{i,1} = 'ScanFocus';
            singleTagFormat{i,1} = 'ScanFocus';
            singleTagFormat{i,2} = '%f';
            singleTagFormat{i,3} = printFormat;
            i = i+1;
        end
        
        if get(hScanPosition, 'Value')
            singleTag{i,1} = 'ScanPosition';
            singleTagFormat{i,1} = 'augseit';
            singleTagFormat{i,2} = '%d';
            singleTagFormat{i,3} = '';
            i = i+1;
        end
        
        if get(hExamTime, 'Value')
            singleTag{i,1} = 'ExamTime';
            singleTagFormat{i,1} = 'ExamTime';
            singleTagFormat{i,2} = '%s';
            singleTagFormat{i,3} = '';
            i = i+1;
        end
        
        %%------------Block 5 Check--------------------
        if get(hScanPattern, 'Value')
            singleTag{i,1} = 'ScanPattern';
            singleTagFormat{i,1} = 'ScanPattern';
            singleTagFormat{i,2} = '%d';
            singleTagFormat{i,3} = '';
            i = i+1;
        end
        
        if get(hID, 'Value')
            singleTag{i,1} = 'ID';
            singleTagFormat{i,1} = 'SOCTID';
            singleTagFormat{i,2} = '%s';
            singleTagFormat{i,3} = printFormat;
            i = i+1;
            singleTag{i,1} = 'ID';
            singleTagFormat{i,1} = 'SOCTID';
            singleTagFormat{i,2} = '%s';
            singleTagFormat{i,3} = 'ptou';
            i = i+1;
        end
        
        if get(hReferenceID, 'Value')
            singleTag{i,1} = 'ReferenceID';
            singleTagFormat{i,1} = 'SOCTRefID';
            singleTagFormat{i,2} = '%s';
            singleTagFormat{i,3} = printFormat;
            i = i+1;
            singleTag{i,1} = 'ReferenceID';
            singleTagFormat{i,1} = 'SOCTRefID';
            singleTagFormat{i,2} = '%s';
            singleTagFormat{i,3} = 'ptou';
            i = i+1;
        end
        
        %%------------Block 6 Check--------------------
        if get(hPID, 'Value')
            singleTag{i,1} = 'PID';
            singleTagFormat{i,1} = 'PID';
            singleTagFormat{i,2} = '%d';
            singleTagFormat{i,3} = '';
            i = i+1;
        end
        
        if get(hPatientID, 'Value')
            singleTag{i,1} = 'PatientID';
            singleTagFormat{i,1} = 'patnr';
            singleTagFormat{i,2} = '%s';
            singleTagFormat{i,3} = '';
            i = i+1;
        end
        
        if get(hDOB, 'Value')
            singleTag{i,1} = 'DOB';
            singleTagFormat{i,1} = 'DOB';
            singleTagFormat{i,2} = '%s';
            singleTagFormat{i,3} = '';
            i = i+1;
        end
        
        if get(hVID, 'Value')
            singleTag{i,1} = 'VID';
            singleTagFormat{i,1} = 'VID';
            singleTagFormat{i,2} = '%d';
            singleTagFormat{i,3} = '';
            i = i+1;
        end
        
        %%------------Block 7 Check--------------------
        if get(hVisitID, 'Value')
            singleTag{i,1} = 'VisitID';
            singleTagFormat{i,1} = 'VisitID';
            singleTagFormat{i,2} = '%s';
            singleTagFormat{i,3} = '';
            i = i+1;
        end
        
        if get(hVisitDate, 'Value')
            singleTag{i,1} = 'VisitDate';
            singleTagFormat{i,1} = 'SOCT_VisitDate';
            singleTagFormat{i,2} = '%s';
            singleTagFormat{i,3} = '';
            i = i+1;
        end
        
        
        if get(hGridType, 'Value')
            singleTag{i,1} = 'GridType';
            singleTagFormat{i,1} = 'gridType';
            singleTagFormat{i,2} = '%d';
            singleTagFormat{i,3} = '';
            i = i+1;
        end
        
        
        if get(hStartX, 'Value')
            singleTag{i,1} = 'StartX';
            singleTagFormat{i,1} = 'StartX';
            singleTagFormat{i,2} = '%f';
            singleTagFormat{i,3} = printFormat;
            i = i+1;
        end
        
        if get(hStartY, 'Value')
            singleTag{i,1} = 'StartY';
            singleTagFormat{i,1} = 'StartY';
            singleTagFormat{i,2} = '%f';
            singleTagFormat{i,3} = printFormat;
            i = i+1;
        end
        
        if get(hEndX, 'Value')
            singleTag{i,1} = 'EndX';
            singleTagFormat{i,1} = 'EndX';
            singleTagFormat{i,2} = '%f';
            singleTagFormat{i,3} = printFormat;
            i = i+1;
        end
        
        if get(hEndY, 'Value')
            singleTag{i,1} = 'EndY';
            singleTagFormat{i,1} = 'EndY';
            singleTagFormat{i,2} = '%f';
            singleTagFormat{i,3} = printFormat;
            i = i+1;
        end
        
        if get(hQuality, 'Value')
            singleTag{i,1} = 'Quality';
            singleTagFormat{i,1} = 'Quality';
            singleTagFormat{i,2} = '%f';
            singleTagFormat{i,3} = printFormat;
            i = i+1;
        end
        
        if get(hShift, 'Value')
            singleTag{i,1} = 'Shift';
            singleTagFormat{i,1} = 'Shift';
            singleTagFormat{i,2} = '%d';
            singleTagFormat{i,3} = printFormat;;
            i = i+1;
        end
        
        
        %     '<ForceColumns>',... 2
        %     'ILM HE', ... 3
        %     'RPE HE', ... 4
        %     'ONFL HE',  ... 5
        %     'Retina Thickness HE', ... 6
        %     'RNFL Thickness HE', ... 7
        %     'ILM OCTSEG', ... 8
        %     'RPE OCTSEG', ... 9
        %     'ONFL OCTSEG', ... 10
        %     'ICL OCTSEG',... 11
        %     'OPL OCTSEG',... 12
        %     'IPL OCTSEG', ... 13
        %     'SKLERA OCTSEG',... 14 
        %     'Retina Thickness OCTSEG', ... 15
        %     'RNFL Thickness OCTSEG',... 16
        %     'IPL + GCL Thickness OCTSEG',... 17
        %     'OPL + INL Thickness OCTSEG',... 18
        %     'ONL Thickness OCTSEG',... 19
        %     'RPE + Photoreceptors Thickness OCTSEG',... 20
        %     'SKLERA Thickness OCTSEG',... 21
        %     'Blood Vessel Positions OCTSEG'},... 22
        if get(hDataPop, 'Value') == 3
            dataTag = 'ILMHE';
            dataTagFormat{1,1} = 'ILM_HE';
            dataTagFormat{1,2} = '%.0f';
            dataTagFormat{1,3} = '';
        elseif get(hDataPop, 'Value') == 4
            dataTag = 'RPEHE';
            dataTagFormat{1,1} = 'RPE_HE';
            dataTagFormat{1,2} = '%.0f';
            dataTagFormat{1,3} = '';
        elseif get(hDataPop, 'Value') == 5
            dataTag = 'ONFLHE';
            dataTagFormat{1,1} = 'ONFL_HE';
            dataTagFormat{1,2} = '%.0f';
            dataTagFormat{1,3} = '';
        elseif get(hDataPop, 'Value') == 6
            dataTag = 'RetinaHE';
            dataTagFormat{1,1} = 'Retina_HE';
            dataTagFormat{1,2} = '%f';
            dataTagFormat{1,3} = printFormat;
        elseif get(hDataPop, 'Value') == 7
            dataTag = 'RNFLHE';
            dataTagFormat{1,1} = 'RNFL_HE';
            dataTagFormat{1,2} = '%f';
            dataTagFormat{1,3} = printFormat;
        elseif get(hDataPop, 'Value') == 8
            dataTag = 'ILMOCTSEG';
            dataTagFormat{1,1} = 'ILM_OCTSEG';
            dataTagFormat{1,2} = '%.2f';
            dataTagFormat{1,3} = printFormat;
        elseif get(hDataPop, 'Value') == 9
            dataTag = 'RPEOCTSEG';
            dataTagFormat{1,1} = 'RPE_OCTSEG';
            dataTagFormat{1,2} = '%.2f';
            dataTagFormat{1,3} = printFormat;
        elseif get(hDataPop, 'Value') == 10
            dataTag = 'ONFLOCTSEG';
            dataTagFormat{1,1} = 'ONFL_OCTSEG';
            dataTagFormat{1,2} = '%.2f';
            dataTagFormat{1,3} = printFormat;
            
            
        elseif get(hDataPop, 'Value') == 11
            dataTag = 'ICLOCTSEG';
            dataTagFormat{1,1} = 'ICL_OCTSEG';
            dataTagFormat{1,2} = '%.2f';
            dataTagFormat{1,3} = printFormat;
        elseif get(hDataPop, 'Value') == 12
            dataTag = 'OPLOCTSEG';
            dataTagFormat{1,1} = 'OPL_OCTSEG';
            dataTagFormat{1,2} = '%.2f';
            dataTagFormat{1,3} = printFormat;
        elseif get(hDataPop, 'Value') == 13
            dataTag = 'IPLOCTSEG';
            dataTagFormat{1,1} = 'IPL_OCTSEG';
            dataTagFormat{1,2} = '%.2f';
            dataTagFormat{1,3} = printFormat;
            
        elseif get(hDataPop, 'Value') == 14
            dataTag = 'SKLERAPOS';
            dataTagFormat{1,1} = 'SKLERA_OCTSEG';
            dataTagFormat{1,2} = '%.2f';
            dataTagFormat{1,3} = printFormat;
            
        elseif get(hDataPop, 'Value') == 15
            dataTag = 'RetinaOCTSEG';
            dataTagFormat{1,1} = 'Retina_OCTSEG';
            dataTagFormat{1,2} = '%.2f';
            dataTagFormat{1,3} = printFormat;
        elseif get(hDataPop, 'Value') == 16
            dataTag = 'RNFLOCTSEG';
            dataTagFormat{1,1} = 'RNFL_OCTSEG';
            dataTagFormat{1,2} = '%.2f';
            dataTagFormat{1,3} = printFormat;
        elseif get(hDataPop, 'Value') == 17
            dataTag = 'INNERPLEXGANGLIONOOCTSEG';
            dataTagFormat{1,1} = 'IPL_GCL_OCTSEG';
            dataTagFormat{1,2} = '%.2f';
            dataTagFormat{1,3} = printFormat;
        elseif get(hDataPop, 'Value') == 18
            dataTag = 'OUTERPLEXIINNERNUCLEAROOCTSEG';
            dataTagFormat{1,1} = 'OPL_INL_OCTSEG';
            dataTagFormat{1,2} = '%.2f';
            dataTagFormat{1,3} = printFormat;
        elseif get(hDataPop, 'Value') == 19
            dataTag = 'OUTERNUCLEAROOCTSEG';
            dataTagFormat{1,1} = 'ONL_OCTSEG';
            dataTagFormat{1,2} = '%.2f';
            dataTagFormat{1,3} = printFormat;    
        elseif get(hDataPop, 'Value') == 20
            dataTag = 'RPEPHOTOOCTSEG';
            dataTagFormat{1,1} = 'RPE_PHOTO_OCTSEG';
            dataTagFormat{1,2} = '%.2f';
            dataTagFormat{1,3} = printFormat;     
            
        elseif get(hDataPop, 'Value') == 21
            dataTag = 'SKLERATHICK';
            dataTagFormat{1,1} = 'SKLERA_OCTSEG';
            dataTagFormat{1,2} = '%.2f';
            dataTagFormat{1,3} = printFormat;
        elseif get(hDataPop, 'Value') == 22
            dataTag = 'BVPOSOCTSEG';
            dataTagFormat{1,1} = 'BVPOS_OCTSEG';
            dataTagFormat{1,2} = '%.0f';
            dataTagFormat{1,3} = [printFormat 'round'];
            
         elseif get(hDataPop, 'Value') == 23
            dataTag = 'REFLECTIONRNFL';
            dataTagFormat{1,1} = 'REFLECTION_RNFL';
            dataTagFormat{1,2} = '%.5f';
            dataTagFormat{1,3} = printFormat;     
        elseif get(hDataPop, 'Value') == 24
            dataTag = 'REFLECTIONRPE';
            dataTagFormat{1,1} = 'REFLECTION_RPE';
            dataTagFormat{1,2} = '%.5f';
            dataTagFormat{1,3} = printFormat;  
            dataTagFormat{1,4} = Params.EXPORT_REFLECTION_WIDTH;
        end
        
        
        if get(hInterp, 'Value')
            dataTagFormat{1,3} = [dataTagFormat{1,3} ' interp'];
        end
               
        filelist = cell(numel(DataDescriptors.filenameList),1);
        for i = 1:numel(DataDescriptors.filenameList)
            filelist{i} = [DataDescriptors.pathname DataDescriptors.filenameList{i} DataDescriptors.filenameEnding];
        end
        
        [filename, pathname] = uiputfile({'*.txt;*.csv','Text Table File Formats';...
            '*.csv','CSV Files';...
            '*.txt','TXT Files';...
            '*.*','All Files' },'Export Meta Information to File',...
            'export.txt');
        
        if isequal(filename,0)
            disp('Save OCT Image: Chancelled.');
            return;
        else
            disp(['Save OCT Image: ' pathname filename]);
        end
        
        csvName = [pathname filename];
        
        if numel(dataTag) == 0 && get(hDataPop, 'Value') ~= 2
            csvSaveRowsDirect(filelist, csvName, singleTag, singleTagFormat);
        else
            csvSaveColumnsDirectBScans(filelist, csvName, singleTag, singleTagFormat, dataTag, dataTagFormat);
        end
    end


    function figure_CloseRequestFcn(hObject, eventdata, handles)
        uiresume(hObject);
        delete(hObject);
    end

end
