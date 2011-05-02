function varargout = annorealtime(varargin)
% ANNOREALTIME M-file for annorealtime.fig
%      ANNOREALTIME, by itself, creates a new ANNOREALTIME or raises the existing
%      singleton*.
%
%      H = ANNOREALTIME returns the handle to a new ANNOREALTIME or the handle to
%      the existing singleton*.
%
%      ANNOREALTIME('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ANNOREALTIME.M with the given input arguments.
%
%      ANNOREALTIME('Property','Value',...) creates a new ANNOREALTIME or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before annorealtime_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to annorealtime_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help annorealtime

% Last Modified by GUIDE v2.5 05-Apr-2011 11:38:52

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @annorealtime_OpeningFcn, ...
                   'gui_OutputFcn',  @annorealtime_OutputFcn, ...
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


% --- Executes just before annorealtime is made visible.
function annorealtime_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to annorealtime (see VARARGIN)

% Choose default command line output for annorealtime
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes annorealtime wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = annorealtime_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in listExper.
function listExper_Callback(hObject, eventdata, handles)
% hObject    handle to listExper (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns listExper contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listExper


% --- Executes during object creation, after setting all properties.
function listExper_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listExper (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in buttonAddExper.
function buttonAddExper_Callback(hObject, eventdata, handles)
% hObject    handle to buttonAddExper (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function editInterval_Callback(hObject, eventdata, handles)
% hObject    handle to editInterval (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editInterval as text
%        str2double(get(hObject,'String')) returns contents of editInterval as a double


% --- Executes during object creation, after setting all properties.
function editInterval_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editInterval (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in buttonRemoveExper.
function buttonRemoveExper_Callback(hObject, eventdata, handles)
% hObject    handle to buttonRemoveExper (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in buttonStart.
function buttonStart_Callback(hObject, eventdata, handles)
% hObject    handle to buttonStart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in buttonStop.
function buttonStop_Callback(hObject, eventdata, handles)
% hObject    handle to buttonStop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


