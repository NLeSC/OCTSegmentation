function answer = processAllQuestion(questiontext)
% PROCESSALLQUESTION A little GUI question box
% Provides a standard question and three buttons.
% QUESTIONTEXT: The question text can be changed. A string.
% Three buttons are displayed:
% ALL 
% REMAINING 
% CHANCEL or window Close 

global PROCESSEDFILESANSWER;

if ispc()
    FONTSIZE = 10;
else
    FONTSIZE = 12;
end

if nargin < 1
    questiontext = 'Should all files be processed again or only the remaining ones?';
end

%--------------------------------------------------------------------------
% GUI Components
%--------------------------------------------------------------------------

f = figure('Visible','off','Position',[360,500,310,120],...
    'WindowStyle', 'Modal',...
    'Color', 'white');
movegui(f,'center');

htext = uicontrol('Style','text',...
    'String', 'notext',...
    'BackgroundColor', 'white',...
    'FontSize', FONTSIZE,...
    'HorizontalAlignment', 'left',...
    'Position',[10,60,290,35]);

temp = cell(1,1);
temp{1} = questiontext;
[outstring,newpos] = textwrap(htext,temp);
set(htext,...
   'String', outstring,...
   'Position', newpos);

hAll = uicontrol('Style','pushbutton','String','All',...
    'Position',[10,10,90,40],...
    'Callback',{@hAll_Callback});

hRemaining = uicontrol('Style','pushbutton','String','Remaining',...
    'Position',[110,10,90,40],...
    'Callback',{@hRemaining_Callback});

hChancel = uicontrol('Style','pushbutton','String','Chancel',...
    'Position',[210,10,90,40],...
    'Callback',{@hChancel_Callback});

%--------------------------------------------------------------------------
% GUI Init
%--------------------------------------------------------------------------

set([f, htext, hAll, hRemaining, hChancel],'Units','normalized');
set(f,'Name','Question')

movegui(f,'center')
set(f,'Visible','on');

uiwait(f);

%--------------------------------------------------------------------------
% GUI Component Handlers
%--------------------------------------------------------------------------

    function hAll_Callback(hObject, eventdata)
        answer = PROCESSEDFILESANSWER.ALL;
        uiresume(f);
        delete(f);
    end

    function hRemaining_Callback(hObject, eventdata)
        answer = PROCESSEDFILESANSWER.REMAINING;
        uiresume(f);
        delete(f);
    end

    function hChancel_Callback(hObject, eventdata)
        answer = PROCESSEDFILESANSWER.CANCEL;
        uiresume(f);
        delete(f);
    end

    function figure_CloseRequestFcn(hObject, eventdata, handles)
        answer = PROCESSEDFILESANSWER.CANCEL;
        uiresume(hObject);
        delete(hObject);
    end

end
