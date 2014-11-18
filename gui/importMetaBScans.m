function  importMetaBScans(DataDescriptors)

%--------------------------------------------------------------------------
% Variables
%--------------------------------------------------------------------------

ident1stMeta = 'Patient ID';
ident2ndMeta = 'None';

data = 'Name';
dataType = 'Number'; 



%--------------------------------------------------------------------------
% GUI Components
%--------------------------------------------------------------------------

f = figure('Visible','off','Position',[360,500,500,185],...
    'WindowStyle', 'normal',...
    'MenuBar', 'none', ...
    'ResizeFcn', {@refreshLayout},...
    'CloseRequestFcn', {@hCloseRequestFcn},...
    'Color', 'white');

hText1st = uicontrol('Style','text','String','1st Identifier',...
    'BackgroundColor', 'white',...
    'FontSize', 16,...
    'HorizontalAlignment', 'left');

hPop1stMeta = uicontrol('Style','popupmenu',...
    'Callback',{@hPop1stMetaCallback}, ...
    'String',{...
    'Patient ID',... 1
    'Filename', ... 2
    'Patient ID mod.'}... 3
   );

hEdit1stColumn = uicontrol('Style','edit','String', '1',...
    'BackgroundColor', [1 1 1],...
    'FontSize', 10,...
    'Min', 1, 'Max', 1, ...
    'HorizontalAlignment', 'left',...
    'Units','pixels');

hText2nd = uicontrol('Style','text','String','2nd Identifier',...
    'BackgroundColor', 'white',...
    'FontSize', 16,...
    'HorizontalAlignment', 'left');

hPop2ndMeta = uicontrol('Style','popupmenu',...
    'Callback',{@hPop2ndMetaCallback}, ...
    'String',{...
    'None', ... 1
    'Eye'} ... 2
   );

hEdit2ndColumn = uicontrol('Style','edit','String', '2',...
    'BackgroundColor', [1 1 1],...
    'FontSize', 10,...
    'Min', 1, 'Max', 1, ...
    'HorizontalAlignment', 'left',...
    'Units','pixels');

hTextData = uicontrol('Style','text','String','Data',...
    'BackgroundColor', 'white',...
    'FontSize', 16,...
    'HorizontalAlignment', 'left');

hPopData = uicontrol('Style','popupmenu',...
    'Callback',{@hPopDataCallback}, ...
    'String',{...
    'Number',... 1
    'String'} ... 2
   );

hEditDataColumn = uicontrol('Style','edit','String', '3',...
    'BackgroundColor', [1 1 1],...
    'FontSize', 10,...
    'Min', 1, 'Max', 1, ...
    'HorizontalAlignment', 'left',...
    'Units','pixels');

hEditDataName = uicontrol('Style','edit','String', 'Name',...
    'BackgroundColor', [1 1 1],...
    'FontSize', 10,...
    'Min', 1, 'Max', 1, ...
    'HorizontalAlignment', 'left',...
    'Units','pixels');

%------------Buttons---------------
hImport = uicontrol('Style','pushbutton','String','Import',...
    'Position',[10,10,780,80],...
    'FontSize', 16,...
    'Callback',{@hImportCallback});

hCancel = uicontrol('Style','pushbutton','String','Cancel',...
    'Position',[10,10,780,80],...
    'FontSize', 16,...
    'Callback',{@hCloseRequestFcn});

%--------------------------------------------------------------------------
% GUI Init
%--------------------------------------------------------------------------



set(f,'Units','pixels');
set(f,'Name','Import Metadata');

movegui(f,'center');
set(f,'Visible','on');

%--------------------------------------------------------------------------
% GUI Component Handlers
%--------------------------------------------------------------------------

function hPop1stMetaCallback(hObject, eventdata)
    switch get(hPop1stMeta, 'Value')
        case 1
            ident1stMeta = 'Patient ID';
        case 2
            ident1stMeta = 'Filename';
        case 3
            ident1stMeta = 'Patient ID mod.';
        otherwise
            disp('Pop From Menu: This should not happen!');
    end
    
    refreshLayout();
end

function hPop2ndMetaCallback(hObject, eventdata)
    switch get(hPop2ndMeta, 'Value')
        case 1
            ident2ndMeta = 'None';
        case 2
            ident2ndMeta = 'Eye';
        otherwise
            disp('Pop From Menu: This should not happen!');
    end
    
    refreshLayout();
end

function hPopDataCallback(hObject, eventdata)
    switch get(hPop2ndMeta, 'Value')
        case 1
            dataType = 'Number';
        case 2
            dataType = 'String';
        otherwise
            disp('Pop From Menu: This should not happen!');
    end
    
    refreshLayout();
end


function hImportCallback(hObject, eventdata)
    [filename, pathname] = uigetfile({'*.csv;*.txt','Text Table Files (*.txt,*.csv)'; ...
        '*.*',  'All Files (*.*)'}, ...
        'Choose a input table') ;
    column1st = str2double(get(hEdit1stColumn, 'String'));
    column2nd = str2double(get(hEdit2ndColumn, 'String'));
    columnData =  str2double(get(hEditDataColumn, 'String'));

    fid = fopen([pathname filename]);
    firstLine = textscan(fid, '%s', 1, 'Delimiter', '');
    fclose(fid);

    num = 0;
    remain = firstLine{1}{1};
    while numel(remain) > 0
        num = num + 1;
        [token, remain] = strtok(remain);
    end

    tableString = '%s';
    for i = 2:num
        tableString = [tableString ' %s'];
    end

    fid = fopen([pathname filename]);
    table = textscan(fid, tableString);

    if strcmp(ident2ndMeta, 'Eye')
        for k = 1:size(table{1}, 1)
            if strcmp(table{column2nd}{k}, 'L')
                table{column2nd}{k} = 'OS';
            elseif strcmp(table{column2nd}{k}, 'R')
                table{column2nd}{k} = 'OD';
            end
        end
    end

    fclose(fid);

    successCount = 0;
    failList = cell(1,1);
    failCount = 0;

    for i = 1:numel(DataDescriptors.filenameList)
        [numDescriptor openFuncHandle] = examineOctFile(DataDescriptors.pathname, ...
            [DataDescriptors.filenameList{i} DataDescriptors.filenameEnding]);
        if numDescriptor == 0
            disp('File is no OCT file.');
            return;
        end

        [ActDataDescriptors.Header, ActDataDescriptors.BScanHeader, ActData.slo, ActData.bScans] = ...
            openFuncHandle([DataDescriptors.pathname DataDescriptors.filenameList{i} DataDescriptors.filenameEnding], 'header');

        hasFailed = 1;
        for k = 1:size(table{1}, 1)
            if strcmp(ident1stMeta, 'Patient ID')
                if str2double(ActDataDescriptors.Header.PatientID) == str2double(deblank(table{column1st}{k}))
                    if strcmp(ident2ndMeta, 'Eye')
                        if strcmp(deblank(ActDataDescriptors.Header.ScanPosition), table{column2nd}{k})
                            writeOctMeta([DataDescriptors.pathname DataDescriptors.filenameList{i}], ...
                                [get(hEditDataName, 'String')], table{columnData}{k}, '%s');
                            disp(['Meta Data ' get(hEditDataName, 'String') ' ' num2str(table{columnData}{k}) ' written out for ' DataDescriptors.filenameList{i}]);
                            successCount = successCount + 1;
                            hasFailed = 0;
                            break;
                        end
                    else
                        writeOctMeta([DataDescriptors.pathname DataDescriptors.filenameList{i}], ...
                            [get(hEditDataName, 'String')], table{columnData}{k}, '%s');
                        disp(['Meta Data ' get(hEditDataName, 'String') ' ' num2str(table{columnData}{k}) ' written out for ' DataDescriptors.filenameList{i}]);
                        successCount = successCount + 1;
                        hasFailed = 0;
                        break;
                    end
                end
            elseif strcmp(ident1stMeta, 'Patient ID mod.')
                patientID = str2double(ActDataDescriptors.Header.PatientID);
                if patientID > 4817 && patientID < 4973
                    patientID = patientID + 6000;
                end

                if patientID == str2double(deblank(table{column1st}{k}))
                    if strcmp(ident2ndMeta, 'Eye')
                        if strcmp(deblank(ActDataDescriptors.Header.ScanPosition), table{column2nd}{k})
                            writeOctMeta([DataDescriptors.pathname DataDescriptors.filenameList{i}], ...
                                [get(hEditDataName, 'String')], table{columnData}{k}, '%s');
                            disp(['Meta Data ' get(hEditDataName, 'String') ' ' num2str(table{columnData}{k}) ' written out for ' DataDescriptors.filenameList{i}]);
                            successCount = successCount + 1;
                            hasFailed = 0;
                            break;
                        end
                    else
                        writeOctMeta([DataDescriptors.pathname DataDescriptors.filenameList{i}], ...
                            [get(hEditDataName, 'String')], table{columnData}{k}, '%s');
                        disp(['Meta Data ' get(hEditDataName, 'String') ' ' num2str(table{columnData}{k}) ' written out for ' DataDescriptors.filenameList{i}]);
                        successCount = successCount + 1;
                        hasFailed = 0;
                        break;
                    end
                end
            elseif strcmp(ident1stMeta, 'Filename')
                if strcmp(DataDescriptors.filenameList{i}, table{column1st}{k})
                    writeOctMeta([DataDescriptors.pathname DataDescriptors.filenameList{i}], ...
                        [get(hEditDataName, 'String')], table{columnData}{k}, '%s');
                    disp(['Meta Data ' get(hEditDataName, 'String') ' ' num2str(table{columnData}{k}) ' written out for ' DataDescriptors.filenameList{i}]);
                    successCount = successCount + 1;
                    hasFailed = 0;
                    break;
                end
            end
        end

        if hasFailed
            failCount = failCount + 1;
            if strcmp(ident1stMeta, 'Patient ID') || strcmp(ident1stMeta, 'Patient ID mod.')
                failList{failCount} = ActDataDescriptors.Header.PatientID;
            elseif strcmp(ident1stMeta, 'Filename')
                failList{failCount} = DataDescriptors.filenameList{i};
            end
        end
    end

    disp('Meta data imported.');
    disp(['Number of successful imports: ' num2str(successCount) ' of ' num2str(numel(DataDescriptors.filenameList))]);

    disp('Import failed for:');
    for i = 1:failCount
        disp(failList{i});
    end

end




function hCloseRequestFcn(hObject, eventdata, handles)
    %uiresume(hObject);
    delete(f);
end

% REFRESHLAYOUT: Paints the Layout
function refreshLayout(hObject, eventdata)
    
        fpos = get(f, 'position');
        width = fpos(3);
        height = fpos(4);
        border = 5;

        stdWidth3 = (width - 4 * border) / 3;
        stdWidth4 = (width - 5 * border) / 4;
        stdHeight = 40;
        
        firstLineHeight = height - 2 * border - stdHeight;
        set(hText1st, 'Position', [border firstLineHeight stdWidth3 stdHeight]);
        set(hPop1stMeta, 'Position', [(2 * border + stdWidth3) firstLineHeight stdWidth3 stdHeight]);
        set(hEdit1stColumn, 'Position', [(3 * border + 2 * stdWidth3) firstLineHeight stdWidth3 stdHeight]);
      
        secondLineHeight = height - 3 * border - 2 * stdHeight;
        set(hText2nd, 'Position', [border secondLineHeight stdWidth3 stdHeight]);
        set(hPop2ndMeta, 'Position', [(2 * border + stdWidth3) secondLineHeight stdWidth3 stdHeight]);
        set(hEdit2ndColumn, 'Position', [(3 * border + 2 * stdWidth3) secondLineHeight stdWidth3 stdHeight]);
      
        thirdLineHeight = height - 4 * border - 3 * stdHeight;
        set(hTextData, 'Position', [border thirdLineHeight stdWidth4 stdHeight]);
        set(hPopData, 'Position', [(2 * border + stdWidth4) thirdLineHeight stdWidth4 stdHeight]);
        set(hEditDataName, 'Position', [(3 * border + 2 * stdWidth4) thirdLineHeight stdWidth4 stdHeight]);
        set(hEditDataColumn, 'Position', [(4 * border + 3 * stdWidth4) thirdLineHeight stdWidth4 stdHeight]);
        
        buttonWidth = (width - 3 * border) / 2;
        buttonHeight = 40;
        
        set(hImport, 'Position', [(2 * border + buttonWidth) border buttonWidth buttonHeight]);
        set(hCancel, 'Position', [border border buttonWidth buttonHeight]);
          
end

end
