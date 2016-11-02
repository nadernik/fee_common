function varargout = aSAP_FileBrowser(varargin)
% ASAP_FILEBROWSER M-file for aSAP_FileBrowser.fig
%      ASAP_FILEBROWSER, by itself, creates a new ASAP_FILEBROWSER or raises the existing
%      singleton*.
%
%      H = ASAP_FILEBROWSER returns the handle to a new ASAP_FILEBROWSER or the handle to
%      the existing singleton*.
%
%      ASAP_FILEBROWSER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ASAP_FILEBROWSER.M with the given input
%      arguments.
%
%      ASAP_FILEBROWSER('Property','Value',...) creates a new ASAP_FILEBROWSER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before aSAP_FileBrowser_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to aSAP_FileBrowser_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Copyright 2002-2003 The MathWorks, Inc.

% Edit the above text to modify the response to help aSAP_FileBrowser

% Last Modified by GUIDE v2.5 07-Apr-2006 15:38:42

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @aSAP_FileBrowser_OpeningFcn, ...
                   'gui_OutputFcn',  @aSAP_FileBrowser_OutputFcn, ...
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


% --- Executes just before aSAP_FileBrowser is made visible.
function aSAP_FileBrowser_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to aSAP_FileBrowser (see VARARGIN)

% Choose default command line output for aSAP_FileBrowser
handles.output = hObject;

%Init root directory
if(length(varargin) > 0)
    rootDir = varargin{1};
else
    rootDir = 'C:\aarecordings';
end
set(handles.editRootDir, 'String', rootDir)

%Setup gui
linkaxes([handles.axesSpecDeriv, handles.axesFeature],'x');

%Init data
handles.currFile = '';
handles.aSAPFileList = {};

%Update popups;
handles = updateBirdPopup(handles);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes aSAP_FileBrowser wait for user response (see UIRESUME)
% uiwait(handles.aSAP_FileBrowser);


% --- Outputs from this function are returned to the command line.
function varargout = aSAP_FileBrowser_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function editRootDir_Callback(hObject, eventdata, handles)
% hObject    handle to editRootDir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editRootDir as text
%        str2double(get(hObject,'String')) returns contents of editRootDir as a double
handles = updateBirdPopup(handles);
guidata(hObject, handles);


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


% --- Executes on selection change in popupBird.
function popupBird_Callback(hObject, eventdata, handles)
% hObject    handle to popupBird (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupBird contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupBird
handles = handleBirdPopupChange(handles);
guidata(hObject, handles);


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


% --- Executes on selection change in popupDate.
function popupDate_Callback(hObject, eventdata, handles)
% hObject    handle to popupDate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupDate contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupDate
handles = handleDatePopupChange(handles);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function popupDate_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupDate (see GCBO)
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
mouseClickType = get(handles.aSAP_FileBrowser, 'SelectionType');
if(strcmp(mouseClickType,'open'))
    handles = handleFilenamePopupChange(handles);
    guidata(hObject, handles);
end
    
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


% --- Executes on slider movement.
function sliderTimeOfDay_Callback(hObject, eventdata, handles)
% hObject    handle to sliderTimeOfDay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
nFile = round(get(hObject,'Value'));
set(handles.popupFilename,'Value',nFile);
handles = handleFilenamePopupChange(handles);
guidata(hObject, handles);


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


% --- Executes on button press in buttonPrev.
function buttonPrev_Callback(hObject, eventdata, handles)
% hObject    handle to buttonPrev (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
value = get(handles.popupFilename,'Value');
if(value-1>=1)
    set(handles.popupFilename,'Value',value-1);
    handles = handleFilenamePopupChange(handles);
end
guidata(hObject, handles);

% --- Executes on button press in buttonNext.
function buttonNext_Callback(hObject, eventdata, handles)
% hObject    handle to buttonNext (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
value = get(handles.popupFilename,'Value');
str_list = get(handles.popupFilename,'String');
if(value+1<=length(str_list))
    set(handles.popupFilename,'Value',value+1);
    handles = handleFilenamePopupChange(handles);
end
guidata(hObject, handles);

% --- Executes on slider movement.
function sliderFilePosition_Callback(hObject, eventdata, handles)
% hObject    handle to sliderFilePosition (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
handles = panSD(handles);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function sliderFilePosition_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderFilePosition (see GCBO)
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


% --- Executes on slider movement.
function sliderSDColorScale_Callback(hObject, eventdata, handles)
% hObject    handle to sliderSDColorScale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function sliderSDColorScale_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderSDColorScale (see GCBO)
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



function editColorScale_Callback(hObject, eventdata, handles)
% hObject    handle to editColorScale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editColorScale as text
%        str2double(get(hObject,'String')) returns contents of editColorScale as a double
handles = plotSpectralDerivativeAxes(handles);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function editColorScale_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editColorScale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on button press in buttonSaveDisplayedSD.
function buttonSaveDisplayedSD_Callback(hObject, eventdata, handles)
% hObject    handle to buttonSaveDisplayedSD (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
startPos = getFilePosition(handles);
endPos = startPos + getSDWidthSecs(handles);
handles = printSD(handles, startPos, endPos);
guidata(hObject, handles);

% --- Executes on button press in buttonSaveEntireSD.
function buttonSaveEntireSD_Callback(hObject, eventdata, handles)
% hObject    handle to buttonSaveEntireSD (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = printSD(handles, 0, Inf);
guidata(hObject, handles);

function editDispInchPerSec_Callback(hObject, eventdata, handles)
% hObject    handle to editDispInchPerSec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editDispInchPerSec as text
%        str2double(get(hObject,'String')) returns contents of editDispInchPerSec as a double
handles = computeAndSetFilePositionMinMax(handles);
handles = panSD(handles);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function editDispInchPerSec_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editDispInchPerSec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function editSaveInchPerSec_Callback(hObject, eventdata, handles)
% hObject    handle to editSaveInchPerSec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editSaveInchPerSec as text
%        str2double(get(hObject,'String')) returns contents of editSaveInchPerSec as a double


% --- Executes during object creation, after setting all properties.
function editSaveInchPerSec_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editSaveInchPerSec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on button press in buttonPageLeft.
function buttonPageLeft_Callback(hObject, eventdata, handles)
% hObject    handle to buttonPageLeft (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
axesWidth = getSDWidthInches(handles);
inchPerSec = getDispInchPerSec(handles);
timeShift = -(axesWidth/inchPerSec)/2;
startPos = getFilePosition(handles);
handles = setFilePosition(handles, startPos + timeShift);
handles = panSD(handles);
guidata(hObject, handles);

% --- Executes on button press in buttonPageRight.
function buttonPageRight_Callback(hObject, eventdata, handles)
% hObject    handle to buttonPageRight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
axesWidth = getSDWidthInches(handles);
inchPerSec = getDispInchPerSec(handles);
timeShift = (axesWidth/inchPerSec)/2;
startPos = getFilePosition(handles);
handles = setFilePosition(handles, startPos + timeShift);
handles = panSD(handles);
guidata(hObject, handles);

% --- Executes on button press in buttonPlay.
function buttonPlay_Callback(hObject, eventdata, handles)
% hObject    handle to buttonPlay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
wavplay(handles.currAudio, handles.currRawAudioFS, 'async');

% --- Executes on button press in checkboxAutoscale.
function checkboxAutoscale_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxAutoscale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkboxAutoscale
handles = plotSpectralDerivativeAxes(handles);
guidata(hObject, handles);

% --- Executes on button press in checkboxSigmoid.
function checkboxSigmoid_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxSigmoid (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkboxSigmoid
handles = plotSpectralDerivativeAxes(handles);
guidata(hObject, handles);


% --- Executes on selection change in popupFeature.
function popupFeature_Callback(hObject, eventdata, handles)
% hObject    handle to popupFeature (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupFeature contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupFeature
plotFeatureAxes(handles);


% --- Executes during object creation, after setting all properties.
function popupFeature_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupFeature (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
set(hObject,'String', {'m_Entropy', 'm_AM', 'm_FM', 'm_amplitude', 'gravity_center', 'm_PitchGoodness', 'm_Pitch', 'Pitch_chose', 'Pitch_weight'});


% --- Executes on button press in checkboxAutocalc.
function checkboxAutocalc_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxAutocalc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkboxAutocalc


% --- Executes on button press in checkboxQuick.
function checkboxQuick_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxQuick (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkboxQuick


% --- Executes on button press in buttonCalculate.
function buttonCalculate_Callback(hObject, eventdata, handles)
% hObject    handle to buttonCalculate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
aSAP_generateASAPFeatureFileFromWav(getFullFilename(handles));
handles = updateCurrFileFeatures(handles);
handles = plotSpectralDerivativeAxes(handles);
guidata(hObject,handles);

function editWrapWidth_Callback(hObject, eventdata, handles)
% hObject    handle to editWrapWidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editWrapWidth as text
%        str2double(get(hObject,'String')) returns contents of
%        editWrapWidth as a double

% --- Executes during object creation, after setting all properties.
function editWrapWidth_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editWrapWidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function editSaveDirectory_Callback(hObject, eventdata, handles)
% hObject    handle to editSaveDirectory (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editSaveDirectory as text
%        str2double(get(hObject,'String')) returns contents of editSaveDirectory as a double


% --- Executes during object creation, after setting all properties.
function editSaveDirectory_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editSaveDirectory (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function editSaveFileName_Callback(hObject, eventdata, handles)
% hObject    handle to editSaveFileName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editSaveFileName as text
%        str2double(get(hObject,'String')) returns contents of editSaveFileName as a double


% --- Executes during object creation, after setting all properties.
function editSaveFileName_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editSaveFileName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



% --- Executes on selection change in popupSaveDevice.
function popupSaveDevice_Callback(hObject, eventdata, handles)
% hObject    handle to popupSaveDevice (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupSaveDevice contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupSaveDevice


% --- Executes during object creation, after setting all properties.
function popupSaveDevice_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupSaveDevice (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on button press in buttonAddFile.
function buttonAddFile_Callback(hObject, eventdata, handles)
% hObject    handle to buttonAddFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.aSAPFileList = [handles.aSAPFileList, {getFullFilename(handles)}];
guidata(hObject, handles);

% --- Executes on button press in buttonSaveList.
function buttonSaveList_Callback(hObject, eventdata, handles)
% hObject    handle to buttonSaveList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
aSAPFileList = handles.aSAPFileList;
uisave('aSAPFileList','aSAP_FileList.mat');
handles.aSAPFileList = {};
guidata(hObject, handles);



% ||||||||||||||||||||||||||||||||||||||||||||||
% AA HELPER FUNCTION
% |||||||||||||||||||||||||||||||||||||||||||||

function handles = updateBirdPopup(handles)
birdIds = {}
nBirdCount = 0;
rootDir = getRootDir(handles);
d = dir(rootDir);
for(nD = 1:length(d))
    if(d(nD).isdir & ~strcmp(d(nD).name,'.') & ~strcmp(d(nD).name,'..'))
        nBirdCount = nBirdCount+1;
        birdIds{nBirdCount} = d(nD).name;
    end
end
set(handles.popupBird, 'Value', 1);
set(handles.popupBird, 'String', birdIds);
if(nBirdCount > 0)
    handles = handleBirdPopupChange(handles);
end

%--------------------------------------------------

function handles = updateDatePopup(handles)
dateDirs = {}
nDateCount = 0;

rootDir = getRootDir(handles);
birdId = getBirdId(handles);
d = dir([rootDir, filesep, birdId]);
for(nD = 1:length(d))
    if(d(nD).isdir & ~strcmp(d(nD).name,'.') & ~strcmp(d(nD).name,'..'))
        nDateCount = nDateCount+1;
        dateDirs{nDateCount} = d(nD).name;
    end
end
set(handles.popupDate, 'Value', 1);
set(handles.popupDate, 'String', dateDirs);
if(nDateCount>0)    
    handles = handleDatePopupChange(handles);
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
    fileNames{nFileCount} = d(nD).name;
end
set(handles.popupFilename, 'Value', 1);
set(handles.popupFilename, 'String', fileNames);
set(handles.sliderTimeOfDay, 'Value',1);
set(handles.sliderTimeOfDay, 'Min',1);
set(handles.sliderTimeOfDay, 'Max',nFileCount);
set(handles.editSaveDirectory, 'String', [rootDir, filesep, birdId, filesep, dateDir]);
if(nFileCount > 0)
    handles = handleFilenamePopupChange(handles);
end

%--------------------------------------------------

function handles = handleBirdPopupChange(handles)
handles = updateDatePopup(handles);

%--------------------------------------------------

function handles = handleDatePopupChange(handles)
handles = plotSongProductivityAxes(handles);
handles = updateFilenamePopup(handles);

%--------------------------------------------------

function handles = handleFilenamePopupChange(handles)
if(~strcmp(getFullFilename(handles), handles.currFile))
    %Reposition the time of day slider.
    set(handles.sliderTimeOfDay, 'Value', get(handles.popupFilename, 'Value'));

    handles = updateCurrFileData(handles);
    
    %Reset the file position slider
    handles = computeAndSetFilePositionMinMax(handles);
    handles = setFilePosition(handles, 0);
    handles = plotSpectralDerivativeAxes(handles);
    plotFeatureAxes(handles);
end

%---------------------------------------------------

function handles = updateCurrFileData(handles)
%handles = positionTimeOfDaySlider(handles);
%handles = getCurrentFileFeatures(handles);
wavfilename = getFullFilename(handles);

%Store current and old file settings
handles.currFile = wavfilename;

%Load Audio and filter below 300hz with hamming filter.
[audio,fs] = wavread(wavfilename);
filtOrder = 200; %suffiencity for 44100Hz of lower
filtwin = hann(filtOrder+1);
freqCutoff = 300; %Hz
hpf = fir1(filtOrder, freqCutoff/(fs/2), 'high', filtwin);
audio = filter(hpf, 1, audio);

%Store it..
handles.currAudio = audio;
handles.currRawAudioFS = fs;

%checkboxQuick plot audio
handles = plotAudioAxes(handles);
drawnow;

handles = updateCurrFileFeatures(handles);

%---------------------------------------------------

function handles = updateCurrFileFeatures(handles)
wavfilename = getFullFilename(handles);

%Load Features
[path,name,ext] = fileparts(wavfilename);
featfilename = [path,filesep,name,'.feat','.mat'];
d = dir(featfilename);
if(length(d)==0)
    if(isAutoCalculate(handles))
        %clear the spectral derivative then calculate
        setFileBrowserData('m_spec_deriv',[-1]);
        handles = plotSpectralDerivativeAxes(handles);
        drawnow;
        aSAP_generateASAPFeatureFileFromWav(wavfilename);        
    else
        %clear the spectral derivative then calculate
        handles.SAPFeats = [];
        setFileBrowserData('m_spec_deriv',[-2]);
        handles = plotSpectralDerivativeAxes(handles);
        drawnow;
        return
    end
end
load(featfilename);
handles.SAPFeats = SAPFeats;

%Load lossy spectral derivative 
try
    m_spec_deriv = aSAP_uncompressSpectralDeriv(handles.SAPFeats.specDerivFileName);
catch
    [p,t,t] = fileparts(featfilename);
    [t,n,e] = fileparts(handles.SAPFeats.specDerivFileName);
    m_spec_deriv = aSAP_uncompressSpectralDeriv([p,filesep,n,e]);
end
setFileBrowserData('m_spec_deriv',m_spec_deriv);
%BGloadAndDisplaySD(handles); 

%---------------------------------------------------

function handles = plotAudioAxes(handles)
fs = handles.currRawAudioFS;
audio = handles.currAudio;
hmm = get(handles.axesAudio, 'ButtonDownFcn')

subplot(handles.axesAudio); 
plot([0:(length(audio)/fs)/(length(audio)-1):length(audio)/fs],audio); axis tight;
%plot(audio(1:100:end)); axis tight;
set(gca, 'Color', [0 0 0]);
set(gca, 'XTickLabelMode', 'manual');
set(gca, 'XTickLabel',[]);
clearVisibleLimitsOnAudio(handles);

set(handles.axesAudio, 'DrawMode', 'fast');
set(handles.axesAudio, 'ButtonDownFcn', {@CBAudioAxesButtonPress, handles});

%---------------------------------------------------

function handles = plotSpectralDerivativeAxes(handles)
if(get(handles.checkboxDisplaySD, 'Value'))
    %don't set anything on handles within this function.
    axes(handles.axesSpecDeriv);
    m_spec_deriv = getFileBrowserData('m_spec_deriv');

    if(isequal(m_spec_deriv,[-1]))
        cla;
        text(mean(xlim)-.5*mean(xlim),mean(ylim),'Spectral derivative is being calculated.')
    elseif(isequal(m_spec_deriv,[-2]))
        cla;
        text(mean(xlim)-.5*mean(xlim),mean(ylim),'Spectral derivative has not been computed.')
    else
        %Set parameters for drawing specgram
        startTime = 0;
        startPos = getFilePosition(handles);
        endPos = -Inf;
        inchPerSec = getDispInchPerSec(handles);
        inchPerkHz = 0;
        bAutoScale = isAutoScale(handles);
        if(bAutoScale)
            fScale = 0;
        else
            fScale = getSDScale(handles);
        end
        bSigmoid = isSigmoid(handles);
        bModifyAxesW = false;
        bModifyAxesH = false;

        %Draw the specgram
        fScale = aSAP_displaySpectralDerivative(m_spec_deriv, handles.SAPFeats.param, startTime, startPos, endPos, bSigmoid, fScale, inchPerSec, inchPerkHz, bModifyAxesW, bModifyAxesH);
        if(bAutoScale)
            set(handles.editColorScale, 'String', sprintf('%0.3g',fScale));
        end

        title(datestr(handles.SAPFeats.time,0));
        xlabel('');
        set(gca, 'XTickLabelMode', 'manual');
        set(gca, 'XTickLabel',[]);
        set(gca, 'TickLength', [.0025, .025]);  
        set(gca, 'DrawMode', 'fast');
        markVisibleLimitsOnAudio(handles);
    end
end

%----------------------------------------------------

function plotFeatureAxes(handles)
axes(handles.axesFeature);
if(~isequal(handles.SAPFeats, []))
    %Draw the selected feature
    feature = getSelectedFeature(handles);
    if(isfield(handles.SAPFeats, feature))
        xlimits = xlim(handles.axesSpecDeriv);
        startTime = 0;
        featValues = getField(handles.SAPFeats, feature);
        endTime = startTime + (length(featValues)*(handles.SAPFeats.param.winstep/handles.SAPFeats.param.fs));
        stepTime = (endTime - startTime)/ (length(featValues)-1);
        time = [startTime:stepTime:endTime];
        plot(time, featValues);
        xlabel('time (s)');
        xlim(xlimits);
    else
        cla;
    end
else
    cla;
end 

%---------------------------------------------------

function handles = plotSongProductivityAxes(handles)

%get datenums for all the files in the folder:
rootDir = getRootDir(handles);
birdId = getBirdId(handles);
dateDir = getDateDir(handles);
d = dir([rootDir, filesep, birdId, filesep, dateDir,filesep,'*.wav']);
[fileDate{1:length(d)}] = deal(d.date);
fileDateNums = datenum(fileDate);

%find the range of dates
dnRange = max(fileDateNums) - min(fileDateNums);
elapsedDays = etime(datevec(max(fileDateNums)), datevec(min(fileDateNums))) / (60*60*24);
if(elapsedDays < 2)
    binPerDay = 48;
    fmt = 15;
else
    binPerDay = 2;
    fmt = 0;
end

axes(handles.axesSongProduction);
edges = [min(fileDateNums) - eps:dnRange/(elapsedDays*binPerDay):max(fileDateNums)+eps];
n = histc(fileDateNums, edges);
bar(edges, n, 'histc');
datetick('x',fmt);
axis tight;
title(['Histogram of Wav DateModified: ', datestr(median(fileDateNums),1)]); 

% ----------------------------------------------

function markVisibleLimitsOnAudio(handles)
clearVisibleLimitsOnAudio(handles);
timeLimits = xlim(handles.axesSpecDeriv);
axes(handles.axesAudio);
ylimits = ylim;
x_rect = [timeLimits(1), timeLimits(1), timeLimits(2), timeLimits(2)];
y_rect = [ylimits(1),ylimits(2),ylimits(2),ylimits(1)];
p = patch(x_rect,y_rect, 'red');
set(p, 'Tag','visRect');
set(p, 'EraseMode', 'xor');
set(p, 'HitTest', 'off');

% ----------------------------------------------

function clearVisibleLimitsOnAudio(handles)
delete(findobj(handles.axesAudio, 'Tag', 'visRect'));

% -----------------------------------------------

function saveDir = getSaveDirectory(handles)
saveDir = get(handles.editSaveDirectory, 'String');

% --------------------------------------------

function rootDir = getRootDir(handles)
rootDir = get(handles.editRootDir, 'String');

% ---------------------------------------------------

function birdId = getBirdId(handles)
birdId = getPopupString(handles.popupBird);

% ---------------------------------------------------

function dateDir = getDateDir(handles)
dateDir = getPopupString(handles.popupDate);

%-------------------------------------------------------

function filename = getFilename(handles)
filename = getPopupString(handles.popupFilename);

% ----------------------------------------------------

function fullfilename = getFullFilename(handles)
rootDir = getRootDir(handles);
birdDir = getBirdId(handles);
dateDir = getDateDir(handles);
filename = getFilename(handles);
fullfilename = fullfile(rootDir,birdDir,dateDir,filename);

% ----------------------------------------------------

function str = getPopupString(hPopup)
val = get(hPopup, 'Value');
str_list = get(hPopup, 'String');
str = str_list{val};

% ----------------------------------------------------

function inchPerSec = getDispInchPerSec(handles)
txt = get(handles.editDispInchPerSec, 'String');
inchPerSec = str2double(txt);
if(isnan(inchPerSec))
    inchPerSec = 5;
end

function handles = setDispInchPerSec(handles, inchPerSec)
set(handles.editDispInchPerSec, 'String', num2str(inchPerSec));
handles = computeAndSetFilePositionMinMax(handles);

% ----------------------------------------------------

function inchPerSec = getSaveInchPerSec(handles)
txt = get(handles.editSaveInchPerSec, 'String');
inchPerSec = str2double(txt);
if(isnan(inchPerSec))
    inchPerSec = 5;
end
if(inchPerSec == 0)
    inchPerSec = getDispInchPerSec(handles);
end

% ----------------------------------------------------

function wrapWidth = getWrapWidth(handles)
txt = get(handles.editWrapWidth, 'String');
wrapWidth = str2double(txt);
if(isnan(wrapWidth))
    wrapWidth = 8;
end

% ---------------------------------------------------

function filePos = getFilePosition(handles)
filePos = get(handles.sliderFilePosition, 'Value')/10000;

% ---------------------------------------------------

function handles = setFilePosition(handles, filePos)
value = filePos*10000;
if(value > get(handles.sliderFilePosition, 'Max'))
    value = get(handles.sliderFilePosition, 'Max') - eps;
end
if(value < get(handles.sliderFilePosition, 'Min'))
    value = get(handles.sliderFilePosition, 'Min');
end
set(handles.sliderFilePosition, 'Value', value);

% ---------------------------------------------------

function handles = computeAndSetFilePositionMinMax(handles)
minFilePos = 0;
maxFilePos = (length(handles.currAudio)/handles.currRawAudioFS);
maxFilePos = max(minFilePos + eps, maxFilePos - (getSDWidthInches(handles)/getDispInchPerSec(handles)) + eps);

%check that we're not causing an out of bounds error
filePos = getFilePosition(handles);
if(filePos > maxFilePos)
    handles = setFilePosition(handles, maxFilePos);
end

set(handles.sliderFilePosition, 'Min', minFilePos*10000);
set(handles.sliderFilePosition, 'Max', maxFilePos*10000);

% ----------------------------------------------------

function bAutoScale = isAutoScale(handles)
bAutoScale = get(handles.checkboxAutoscale,'Value');

% ----------------------------------------------------

function bAutoCalculate = isAutoCalculate(handles)
bAutoCalculate = get(handles.checkboxAutocalc,'Value');

%------------------------------------------------------

function fScale = getSDScale(handles)
txt = get(handles.editColorScale, 'String');
fScale = str2double(txt);
if(isnan(fScale))
    fScale = 7e9;
end

%------------------------------------------------------

function featureStr = getSelectedFeature(handles)
featureStr = getPopupString(handles.popupFeature);

%------------------------------------------------------

function bSigmoid = isSigmoid(handles)
bSigmoid = get(handles.checkboxSigmoid,'Value');

%------------------------------------------

function handles = panSD(handles)
axes(handles.axesSpecDeriv);

%get current settings
startPos = getFilePosition(handles);
inchPerSec = getDispInchPerSec(handles);

%get width of axes in inches
axesWidth = getSDWidthInches(handles);

%pan time axis
xlim([startPos,startPos+(axesWidth/inchPerSec)]);

%demarcate limits on AudioAxes
markVisibleLimitsOnAudio(handles);

% ------------------------------------------

function handles = printSD(handles, startPos, endPos)
m_spec_deriv = getFileBrowserData('m_spec_deriv');
if(length(m_spec_deriv) > 1)
    inchPerSec = getSaveInchPerSec(handles);
    inchPerkHz = inchPerSec/50;
    wrapWidth = getWrapWidth(handles);
    saveDir = getSaveDirectory(handles);
    bSigmoid = isSigmoid(handles);
    if(isAutoScale(handles))
        fScale = aSAP_getSDAutoscale(m_spec_deriv);
    else
        fScale = getSDScale(handles);
    end
    device = getDevice(handles);
    
    if(strcmp(device,'-dbitmap') | strcmp(device,'-dwin'))
        filename = getSaveFilename(handles, startPos, endPos, fScale, bSigmoid);
        fullfilename ='';
    else
        filename = getSaveFilename(handles, startPos, endPos, fScale, bSigmoid);
        fullfilename = [saveDir, filesep, filename];
    end
    
    aSAP_printSD(device, fullfilename, m_spec_deriv, ...
        handles.SAPFeats.param, inchPerSec, inchPerkHz, wrapWidth, ...
        0, startPos, endPos, bSigmoid, fScale, filename);
end

% ----------------------------------------------------

function filename = getSaveFilename(handles, startPos, endPos, fScale, bSigmoid)
%prefix_birdid_time_startPos_endPos_SDScale_bSigmoid

SAPFeats = handles.SAPFeats;
corefilename = [getBirdId(handles),'_',datestr(SAPFeats.time,30)];
paramsuffix = sprintf('_%2.2g_%2.2g_%g_%d', startPos, endPos, fScale, bSigmoid);
userprefix = get(handles.editSaveFilename, 'String');
if(length(userprefix)>0)
    userprefix = [userprefix,'-'];
end
filename = [userprefix,corefilename,paramsuffix];

% --------------------------------------------------

function device = getDevice(handles)
deviceTxt = getPopupString(handles.popupSaveDevice);
if(strcmp(deviceTxt,'Clipboard'))
    device = '-dbitmap';
elseif(strcmp(deviceTxt,'Bitmap'))
    device = '-dbmp';
elseif(strcmp(deviceTxt,'Jpeg'))
    device = '-djpeg';
elseif(strcmp(deviceTxt,'Default Printer'))
    device = '-dwin';
else
    device = '-dbitmap';
end

%-----------------------------------------------------

function CBAudioAxesButtonPress(hObj, event, oldhandles)
%get the rectangle
handles = guidata(hObj)
zoomRect = rbbox;
zoomRect = convertFigUnits2AxesValues(zoomRect, handles.aSAP_FileBrowser, handles.axesAudio); 
startPos = zoomRect(1);
widthPos = zoomRect(3);
if(widthPos > .005)
    handles = setDispInchPerSec(handles, getSDWidthInches(handles)/widthPos);
    handles = setFilePosition(handles, startPos);
    handles = panSD(handles);
    guidata(hObj, handles);
end


%-----------------------------------------------------
function sdWidthInches = getSDWidthInches(handles);
units = get(handles.axesSpecDeriv,'Units');
set(handles.axesSpecDeriv,'Units','inches');
axesPos = get(handles.axesSpecDeriv,'Position');
set(handles.axesSpecDeriv,'Units', units);
sdWidthInches = axesPos(3);

function sdWidthSecs = getSDWidthSecs(handles);
sdWidthSecs = getSDWidthInches(handles)/getDispInchPerSec(handles);

function value = getFileBrowserData(name)
fb = findobj('Tag','aSAP_FileBrowser');
fb = get_parent_figure(fb);
if(isappdata(fb,name))
    value = getappdata(fb, name);
else
    value = [];
end

function setFileBrowserData(name, value)
fb = findobj('Tag','aSAP_FileBrowser');
fb = get_parent_figure(fb);
setappdata(fb, name, value);

function fig = get_parent_figure(fig)
% if the object is a figure or figure descendent, return the
% figure.  Otherwise return [].
while ~isempty(fig) & ~strcmp('figure', get(fig,'type'))
  fig = get(fig,'parent');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%AA Timer functions for BG processes.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Any guidata you want to change with a timer thread
%have to be stored within seperate app data properties
%so they can be  carefully managed to prevent inferring
%threads.

%Other guidata besides those seperately stored must not
%be changed, and functions that change them must not be
%called.  (especially handles).

function BGloadAndDisplaySD(handles)
%Load and display spectral derivative as a background process.
timerLoadSD = timerfind('Tag','timeLoadSD');
if(length(timerLoadSD)~=0)
    stop(timerLoadSD);
    delete(timerLoadSD);
end

timerLoadSD = timer('Tag', 'timeLoadSD', 'TimerFcn', {'aSAP_zPrivate_FileBrowserTimerFcn', 'timer_loadAndDisplaySD', handles});
start(timerLoadSD);

function timer_loadAndDisplaySD(hObj, handles)
%All timer functions have to have a handle as there first parameter.
%Because gui_main requires it.
disp 'horray';
m_spec_deriv = aSAP_uncompressSpectralDeriv(handles.SAPFeats.specDerivFileName);
setFileBrowserData('m_spec_deriv', m_spec_deriv);
aSAP_zPrivate_plotSpectralDerivativeAxes(handles);
drawnow;








function editSaveFilename_Callback(hObject, eventdata, handles)
% hObject    handle to editSaveFilename (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editSaveFilename as text
%        str2double(get(hObject,'String')) returns contents of editSaveFilename as a double


% --- Executes during object creation, after setting all properties.
function editSaveFilename_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editSaveFilename (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end








% --- Executes on button press in checkboxDisplaySD.
function checkboxDisplaySD_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxDisplaySD (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkboxDisplaySD


