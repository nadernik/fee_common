function varargout = booleanGUI(varargin)
% BOOLEANGUI M-file for booleanGUI.fig
%      BOOLEANGUI, by itself, creates a new BOOLEANGUI or raises the existing
%      singleton*.
%
%      H = BOOLEANGUI returns the handle to a new BOOLEANGUI or the handle to
%      the existing singleton*.
%
%      BOOLEANGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BOOLEANGUI.M with the given input arguments.
%
%      BOOLEANGUI('Property','Value',...) creates a new BOOLEANGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before booleanGUI_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to booleanGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help booleanGUI

% Last Modified by GUIDE v2.5 16-Sep-2010 15:15:26

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @booleanGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @booleanGUI_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before booleanGUI is made visible.
function booleanGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to booleanGUI (see VARARGIN)

if nargin > 3
    % we were passed handles from rulesGUI
    rulesHandles = varargin{1};
    handles.rules = rulesHandles.rules;
    handles.list2rule = rulesHandles.list2rule;
    for n = 1:length(handles.list2rule)
        str{n} = handles.rules(handles.list2rule(n)).name;
    end
    set(handles.popupRule,'String',str)
    thisRule = rulesHandles.rules(rulesHandles.rSel);
    try
        set(handles.editQuery,'String',thisRule.params.queryString)
        set(handles.editTimeAbove,'String',num2str(thisRule.params.timeAbove))
        set(handles.editTimeDelay,'String',num2str(thisRule.params.timeDelay))
        set(handles.editTimeOn,'String',num2str(thisRule.params.timeHigh))
        handles.params = thisRule.params;
    catch
        e = lasterror;
        if strcmp(e.identifier,'MATLAB:nonExistentField') || ...
                strcmp(e.identifier,'MATLAB:nonStrucReference')
            % params field or one of its subfields doesn't exist. Recover
            % by using some default values.
            handles.params.dependencies = [];
            handles.params.query = struct('func',{},'rule',{});
            handles.params.queryString = '';
            handles.params.timeAbove = str2double(get(handles.editTimeAbove,'String'));
            handles.params.timeDelay = str2double(get(handles.editTimeDelay,'String'));
            handles.params.timeHigh  = str2double(get(handles.editTimeOn,'String'));
            set(handles.editQuery,'String','');
            % first statement must be AND
            set(handles.panelAndOr,'SelectedObject',handles.radioAnd)
            set(handles.radioOr,'Enable','off')
        else
            rethrow(e)
        end
    end
end
handles.params.filterFunc = @booleanFilterFunc;
handles.params.Fs = 24414; %Hz
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes booleanGUI wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = booleanGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.params.queryString = get(handles.editQuery,'String');
handles.params.stepsAbove = floor(handles.params.timeAbove/1000 * handles.params.Fs)+1;
handles.params.stepsDelay = floor(handles.params.timeDelay/1000 * handles.params.Fs)+1;
handles.params.stepsHigh = floor(handles.params.timeHigh/1000 * handles.params.Fs)+1;
varargout{1} = handles.params;
delete(handles.figure1)



function editQuery_Callback(hObject, eventdata, handles)
% hObject    handle to editQuery (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editQuery as text
%        str2double(get(hObject,'String')) returns contents of editQuery as a double


% --- Executes during object creation, after setting all properties.
function editQuery_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editQuery (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupRule.
function popupRule_Callback(hObject, eventdata, handles)
% hObject    handle to popupRule (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupRule contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupRule


% --- Executes during object creation, after setting all properties.
function popupRule_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupRule (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in buttonAdd.
function buttonAdd_Callback(hObject, eventdata, handles)
% hObject    handle to buttonAdd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isempty(handles.params.query)
    handles.params.query(end+1).func = 'and';
    newstr = '';
else
    if get(handles.panelAndOr,'SelectedObject') == handles.radioOr
        handles.params.query(end+1).func = 'or';
        newstr = ' | ';
    else
        handles.params.query(end+1).func = 'and';
        newstr = ' & ';
    end
end

% if 1, will use ~rule ("not rule"). if 0 will use rule.
handles.params.query(end).invert = get(handles.checkNot,'Value');
if handles.params.query(end).invert
    newstr = [newstr '~'];
end
r = handles.list2rule(get(handles.popupRule,'Value'));
handles.params.query(end).rule = r;
handles.params.dependencies(end+1) = r;
newstr = [newstr handles.rules(r).name]; % like ' & rulename'
oldstr = get(handles.editQuery,'String');
set(handles.editQuery,'String',[oldstr newstr])
% set(handles.radioAnd,'Enable','on')
set(handles.radioOr,'Enable','on')
guidata(hObject,handles)


% --- Executes on button press in buttonClear.
function buttonClear_Callback(hObject, eventdata, handles)
% hObject    handle to buttonClear (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.params.query = struct('func',{},'rule',{});
set(handles.editQuery,'String','');
handles.params.dependencies = [];
% first statement must be AND
set(handles.panelAndOr,'SelectedObject',handles.radioAnd)
% set(handles.radioAnd,'Enable','off')
set(handles.radioOr,'Enable','off')
guidata(hObject,handles)

% --- Executes on button press in buttonDone.
function buttonDone_Callback(hObject, eventdata, handles)
% hObject    handle to buttonDone (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
uiresume


function editTimeAbove_Callback(hObject, eventdata, handles)
% hObject    handle to editTimeAbove (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editTimeAbove as text
%        str2double(get(hObject,'String')) returns contents of editTimeAbove as a double
handles.params.timeAbove = str2double(get(hObject,'String'));
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function editTimeAbove_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editTimeAbove (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





function editTimeDelay_Callback(hObject, eventdata, handles)
% hObject    handle to editTimeDelay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editTimeDelay as text
%        str2double(get(hObject,'String')) returns contents of editTimeDelay as a double
handles.params.timeDelay = str2double(get(hObject,'String'));
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function editTimeDelay_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editTimeDelay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editTimeOn_Callback(hObject, eventdata, handles)
% hObject    handle to editTimeOn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editTimeOn as text
%        str2double(get(hObject,'String')) returns contents of editTimeOn as a double
handles.params.timeHigh = str2double(get(hObject,'String'));
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function editTimeOn_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editTimeOn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on button press in checkNot.
function checkNot_Callback(hObject, eventdata, handles)
% hObject    handle to checkNot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkNot


