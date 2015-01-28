function varargout = vc_cmf_temp(varargin)
%VC_CMF_TEMP M-file for vc_cmf_temp.fig
%      VC_CMF_TEMP, by itself, creates a new VC_CMF_TEMP or raises the existing
%      singleton*.
%
%      H = VC_CMF_TEMP returns the handle to a new VC_CMF_TEMP or the handle to
%      the existing singleton*.
%
%      VC_CMF_TEMP('Property','Value',...) creates a new VC_CMF_TEMP using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to vc_cmf_temp_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      VC_CMF_TEMP('CALLBACK') and VC_CMF_TEMP('CALLBACK',hObject,...) call the
%      local function named CALLBACK in VC_CMF_TEMP.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help vc_cmf_temp

% Last Modified by GUIDE v2.5 14-Jul-2009 15:37:43

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @vc_cmf_temp_OpeningFcn, ...
                   'gui_OutputFcn',  @vc_cmf_temp_OutputFcn, ...
                   'gui_LayoutFcn',  [], ...
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


% --- Executes just before vc_cmf_temp is made visible.
function vc_cmf_temp_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)

% Choose default command line output for vc_cmf_temp
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes vc_cmf_temp wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = vc_cmf_temp_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on key press with focus on figure1 and no controls selected.
function figure1_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(hObject);


% --- Executes on button press in buttonCompute.
function buttonCompute_Callback(hObject, eventdata, handles)
% hObject    handle to buttonCompute (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in buttonCancel.
function buttonCancel_Callback(hObject, eventdata, handles)
% hObject    handle to buttonCancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in popupVector.
function popupVector_Callback(hObject, eventdata, handles)
% hObject    handle to popupVector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupVector contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupVector


% --- Executes during object creation, after setting all properties.
function popupVector_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupVector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function text_Start_Callback(hObject, eventdata, handles)
% hObject    handle to text_Start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of text_Start as text
%        str2double(get(hObject,'String')) returns contents of text_Start as a double


% --- Executes during object creation, after setting all properties.
function text_Start_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text_Start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function text_End_Callback(hObject, eventdata, handles)
% hObject    handle to text_End (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of text_End as text
%        str2double(get(hObject,'String')) returns contents of text_End as a double


% --- Executes during object creation, after setting all properties.
function text_End_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text_End (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


