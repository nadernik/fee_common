function varargout = aSAP_Browser(varargin)
% aSAP_SONGBROWSER M-file for aaSAP_SongBrowser.fig
%      aSAP_SONGBROWSER, by itself, creates a new aSAP_SONGBROWSER or raises the existing
%      singleton*.
%
%      H = aSAP_SONGBROWSER returns the handle to a new aSAP_SONGBROWSER or the handle to
%      the existing singleton*.
%
%      aSAP_SONGBROWSER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in aSAP_SONGBROWSER.M with the given input arguments.
%
%      aSAP_SONGBROWSER('Property','Value',...) creates a new aSAP_SONGBROWSER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before aSAP_Browser_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to aSAP_Browser_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Copyright 2002-2003 The MathWorks, Inc.

% Edit the above text to modify the response to help aSAP_Browser

% Last Modified by GUIDE v2.5 01-Feb-2006 01:09:50

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @aSAP_Browser_OpeningFcn, ...
                   'gui_OutputFcn',  @aSAP_Browser_OutputFcn, ...
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


% --- Executes just before aSAP_Browser is made visible.
function aSAP_Browser_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to aSAP_Browser (see VARARGIN)

% Choose default command line output for aSAP_Browser
handles.output = hObject;

if(length(varargin) > 0)
    rootDir = varargin{1};
else
    rootDir = 'C:\aarecordings';
end

set(handles.editRootDir, 'String', rootDir)
handles = updateBirdPopup(handles);

% Update handles structure
guidata(hObject, handles);
    
% UIWAIT makes aSAP_Browser wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = aSAP_Browser_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on slider movement.
function sliderTime_Callback(hObject, eventdata, handles)
% hObject    handle to sliderTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function sliderTime_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background, change
%       'usewhitebg' to 0 to use default.  See ISPC and COMPUTER.
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor',[.9 .9 .9]);
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function txtSecPerInch_Callback(hObject, eventdata, handles)
% hObject    handle to txtSecPerInch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtSecPerInch as text
%        str2double(get(hObject,'String')) returns contents of txtSecPerInch as a double


% --- Executes during object creation, after setting all properties.
function txtSecPerInch_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtSecPerInch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on slider movement.
function sliderTimeOfDay_Callback(hObject, eventdata, handles)
% hObject    handle to sliderTimeOfDay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function sliderTimeOfDay_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderTimeOfDay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background, change
%       'usewhitebg' to 0 to use default.  See ISPC and COMPUTER.
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor',[.9 .9 .9]);
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in popupmenu2.
function popupmenu2_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu2


% --- Executes during object creation, after setting all properties.
function popupmenu2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in popupFilename.
function popupFilename_Callback(hObject, eventdata, handles)
% hObject    handle to popupFilename (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupFilename contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupFilename


% --- Executes during object creation, after setting all properties.
function popupFilename_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupFilename (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on button press in buttonPrev.
function buttonPrev_Callback(hObject, eventdata, handles)
% hObject    handle to buttonPrev (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in buttonNext.
function buttonNext_Callback(hObject, eventdata, handles)
% hObject    handle to buttonNext (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function editRootDir_Callback(hObject, eventdata, handles)
% hObject    handle to editRootDir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editRootDir as text
%        str2double(get(hObject,'String')) returns contents of editRootDir as a double


% --- Executes during object creation, after setting all properties.
function editRootDir_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editRootDir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on slider movement.
function sliderColorRange_Callback(hObject, eventdata, handles)
% hObject    handle to sliderColorRange (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function sliderColorRange_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderColorRange (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background, change
%       'usewhitebg' to 0 to use default.  See ISPC and COMPUTER.
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor',[.9 .9 .9]);
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function editColorRange_Callback(hObject, eventdata, handles)
% hObject    handle to editColorRange (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editColorRange as text
%        str2double(get(hObject,'String')) returns contents of editColorRange as a double


% --- Executes during object creation, after setting all properties.
function editColorRange_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editColorRange (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end




% --- Executes on button press in buttonSaveImage.
function buttonSaveImage_Callback(hObject, eventdata, handles)
% hObject    handle to buttonSaveImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




% --- Executes on selection change in popupBird.
function popupBird_Callback(hObject, eventdata, handles)
% hObject    handle to popupBird (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupBird contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupBird


% --- Executes during object creation, after setting all properties.
function popupBird_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupBird (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% ||||||||||||||||||||||||||||||||||||||||||||||
% AA HELPER FUNCTION
% |||||||||||||||||||||||||||||||||||||||||||||

function handles = updateBirdPopup(handles)
birdIds = {}
nBirdCount = 0;
rootDir = getRootDir(handles);
d = dir(rootDir);
for(nD = 1:length(d))
    if(d(nD).isdir)
        nBirdCount = nBirdCount+1;
        birdIds{nBirdCount} = d(nD).name;
    end
end
set(handles.popupBird, 'String', birdIds);
if(nBirdCount > 0)
    handles = setBirdPopup(handles, 1);
end

%--------------------------------------------------

function handles = updateDatePopup(handles)
dateDirs = {}
nDateCount = 0;

rootDir = getRootDir(handles);
birdId = getBirdId(handles);
d = dir([rootDir, filesep, birdId]);
for(nD = 1:length(d))
    if(d(nD).isdir)
        nDateCount = nDateCount+1;
        dateDirs{nDateCount} = d(nD).name;
    end
end
set(handles.popupDate, 'String', dateDirs);
if(nDateCount>0)    
    handles = setDatePopup(handles, 1);
end

%--------------------------------------------------

function handles = updateFilenamePopup(handles)
fileNames = {}
nFileCount = 0;

rootDir = getRootDir(handles);
birdId = getBirdId(handles);
dateDir = getDateDir(handles);
d = dir([rootDir, filesep, birdId, filesep, dateDir,filesep,'*.wav']);
for(nD = 1:length(d))
    nFileCount = nFileCount+1;
    fileName{nFileCount} = d(nD).name;
end
set(handles.popupFilename, 'String', fileNames)
if(nFileCount > 0)
    handles = setFilenamePopup(handles, 1);
end
%--------------------------------------------------

function handles = setBirdPopup(handles, value)
set(handles.popupBird, 'Value', 1);
handles = updateDatePopup(handles);

%--------------------------------------------------

function handles = setDatePopup(handles, value)
set(handles.popupFilename, 'Value', value);
%handles = plotSongProductivityAxes(handles);
handles = updateFilenamePopup(handles);

%--------------------------------------------------

function handles = setFilenamePopup(handles, vlaue)
set(handles.popupFilename, 'Value', value);
%handles = positionTimeOfDaySlider(handles);
%handles = plotSpectralDerivitiveAxes(handles);

% ---------------------------------------------------

function rootDir = getRootDir(handles)
rootDir = handles.rootDir;

% ---------------------------------------------------

function birdId = getBirdId(handles)
birdId = getPopupString(handles.popupBird);

% ---------------------------------------------------

function dateDir = getDateDir(handles)
dateDir = getPopupString(handles.popupDate);

% ----------------------------------------------------

function str = getPopupString(hPopup)
val = get(hPopup, 'Value');
str_list = get(hPopup, 'String');
str = str_list{val};




