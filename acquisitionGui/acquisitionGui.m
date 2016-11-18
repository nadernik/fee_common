function varargout = acquisitionGui(varargin)
% ACQUISITIONGUI M-file for acquisitionGui.fig
%      ACQUISITIONGUI, by itself, creates a new ACQUISITIONGUI or raises the existing
%      singleton*
%
%      H = ACQUISITIONGUI returns the handle to a new ACQUISITIONGUI or the handle to
%      the existing singleton*.
%
%      ACQUISITIONGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ACQUISITIONGUI.M with the given input arguments.
%
%      ACQUISITIONGUI('Prdaeoperty','Value',...) creates a new ACQUISITIONGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before acquisitionGui_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to acquisitionGui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menuSutterMovement.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help acquisitionGui

% Last Modified by GUIDE v2.5 20-Apr-2010 13:17:11

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @acquisitionGui_OpeningFcn, ...
                   'gui_OutputFcn',  @acquisitionGui_OutputFcn, ...
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


% --- Executes just before acquisitionGui is made visible.
function acquisitionGui_OpeningFcn(hObject, ~, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to acquisitionGui (see VARARGIN
handles.GuiModel = AcqGuiModel(varargin{:});
handles.Views = AcqGuiViews(handles.GuiModel, hObject, varargin{:});
guidata(hObject, handles);

% --- Outputs from this function are returned to the command line.
function varargout = acquisitionGui_OutputFcn(~, ~, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.GuiModel.output;


% --- Executes on button press in buttonRecord.
function buttonRecord_Callback(~, ~, handles)
% hObject    handle to buttonRecord (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.GuiModel.record_button();

% --- Executes on button press in pushbutton1.
function buttonTrigOnSong_Callback(~, ~, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.GuiModel.detect_button();

function editSongDensity_Callback(~, ~, handles)
% hObject    handle to editSongThreshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editSongThreshold as text
%        str2double(get(hObject,'String')) returns contents of editSongThreshold as a double

%If currently triggering on song, then we have to update parameters
%directly.  If not currently triggering then no worries.

%If currently triggering on song, then we have to update parameters
%directly.  If not currently triggering then no worries.
value = str2double(handles.editSongDensity.String);
handles.GuiModel.change_song_parameters('songDensity', value);

% --- Executes during object creation, after setting all properties.
function editSongDensity_CreateFcn(hObject, ~, ~)
% hObject    handle to editSongThreshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function editPowerThres_Callback(~, ~, handles)
% hObject    handle to editPowerThres (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editPowerThres as text
%        str2double(get(hObject,'String')) returns contents of editPowerThres as a double

%If currently triggering on song, then we have to update parameters
%directly.  If not currently triggering then no worries.
value = str2double(handles.editPowerThres.String);
handles.GuiModel.change_song_parameters('ratioThreshold', value);

% --- Executes during object creation, after setting all properties.
function editPowerThres_CreateFcn(hObject, ~, ~)
% hObject    handle to editPowerThres (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function editSongLength_Callback(~, ~, handles)
% hObject    handle to editSongLength (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editSongLength as text
%        str2double(get(hObject,'String')) returns contents of
%        editSongLength as a double
value = str2double(handles.editSongLength.String);
handles.GuiModel.change_song_parameters('songDuration', value);

% --- Executes during object creation, after setting all properties.
function editSongLength_CreateFcn(hObject, ~, ~)
% hObject    handle to editSongLength (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in buttonAntidromic.
function buttonAntidromic_Callback(~, ~, handles)
% hObject    handle to buttonAntidromic (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.Views.request_stim();

% --- Executes on selection change in popupChannel.
function popupChannel_Callback(~, ~, handles)
% hObject    handle to popupChannel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = get(hObject,'String') returns popupChannel contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupChannel
hwChannel = handles.GuiModel.CurrentExper.inChannels(handles.popupChannel.Value);
handles.GuiModel.change_displayed_channel(2, hwChannel);

% --- Executes during object creation, after setting all properties.
function popupChannel_CreateFcn(hObject, ~, ~)
% hObject    handle to popupChannel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in popupAudio.
function popupAudio_Callback(~, ~, handles)
% hObject    handle to popupAudio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupAudio contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupAudio
% hObject    handle to popupChannel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = get(hObject,'String') returns popupChannel contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupChannel
hwChannel = handles.GuiModel.CurrentExper.inChannels(handles.popupAudio.Value);
handles.GuiModel.change_displayed_channel(1, hwChannel);

% --- Executes during object creation, after setting all properties.
function popupAudio_CreateFcn(hObject, ~, ~)
% hObject    handle to popupAudio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupChannel2.
function popupChannel2_Callback(~, ~, handles)
% hObject    handle to popupChannel2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupChannel2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupChannel2
hwChannel = handles.GuiModel.CurrentExper.inChannels(handles.popupChannel2.Value);
handles.GuiModel.change_displayed_channel(3, hwChannel);

% --- Executes during object creation, after setting all properties.
function popupChannel2_CreateFcn(hObject, ~, ~)
% hObject    handle to popupChannel2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupChannel3.
function popupChannel3_Callback(~, ~, handles)
% hObject    handle to popupChannel3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupChannel3 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupChannel3
hwChannel = handles.GuiModel.CurrentExper.inChannels(handles.popupChannel3.Value);
handles.GuiModel.change_displayed_channel(4, hwChannel);

% --- Executes during object creation, after setting all properties.
function popupChannel3_CreateFcn(hObject, ~, ~)
% hObject    handle to popupChannel3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in buttonCreateExper.
function buttonCreateExper_Callback(~, ~, handles)
% hObject    handle to buttonCreateExper (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
goAhead = handles.Views.ok_to_modify();
if goAhead
    status = handles.GuiModel.create_experiment();
    if ~status
        warning('Could not create experiment');
    end
end

% --- Executes on button press in buttonLoadExperiment.
function buttonLoadExperiment_Callback(~, ~, handles)
% hObject    handle to buttonLoadExperiment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
goAhead = handles.Views.ok_to_modify();
if goAhead
    status = handles.GuiModel.load_experiment();
    if ~status
        warning('Could not load experiment');
    end
end

% --- Executes on button press in buttonCloseExper.
function buttonCloseExper_Callback(~, ~, handles)
% hObject    handle to buttonCloseExper (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
goAhead = handles.Views.ok_to_modify();
if goAhead
    status = self.GuiModel.close_experiment();
    if ~status
        warning('Could not close experiment');
    end
end



% --- Executes on selection change in popupExperiments.
function popupExperiments_Callback(~, ~, handles)
% hObject    handle to popupExperiments (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupExperiments contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupExperiments
newNdx = handles.popupExperiments.Value;
handles.GuiModel.change_current_experiment(newNdx);

% --- Executes during object creation, after setting all properties.
function popupExperiments_CreateFcn(hObject, ~, ~)
% hObject    handle to popupExperiments (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function editFilenum_Callback(~, ~, handles)
% hObject    handle to editFilenum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editFilenum as text
%        str2double(get(hObject,'String')) returns contents of editFilenum as a double
dispFile = get(handles.editFilenum, 'String');
dispFileNum = str2double(dispFile); % nan if not valid
if dispFileNum > 0 && round(dispFileNum) == dispFileNum %Check that it's an integer, implicitly check for nan
    self.GuiModel.change_recording(dispFileNum);
end

% --- Executes on button press in buttonPrevFile.
function buttonPrevFile_Callback(~, ~, handles)
% hObject    handle to buttonPrevFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
dispFile = get(handles.editFilenum, 'String');
dispFileNum = str2double(dispFile); % nan if not valid
newFileNum = dispFileNum - 1;
if newFileNum > 0 && round(newFileNum) == newFileNum %Check that it's an integer, implicitly check for nan
    self.GuiModel.change_recording(newFileNum);
end

% --- Executes on button press in buttonNextFile.
function buttonNextFile_Callback(~, ~, handles)
% hObject    handle to buttonNextFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
dispFile = get(handles.editFilenum, 'String');
dispFileNum = str2double(dispFile); % nan if not valid
newFileNum = dispFileNum + 1;
if newFileNum > 0 && round(newFileNum) == newFileNum %Check that it's an integer, implicitly check for nan
    self.GuiModel.change_recording(newFileNum);
end


% --- Executes during object creation, after setting all properties.
function editFilenum_CreateFcn(hObject, ~, ~)
% hObject    handle to editFilenum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in checkboxAutoDisplay.
function checkboxAutoDisplay_Callback(~, ~, handles)
% hObject    handle to checkboxAutoDisplay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkboxAutoDisplay
handles.GuiModel.autoUpdate = ~handles.GuiModel.autoUpdate;

% --- Executes on button press in buttonShowSongScore.
function buttonShowSongScore_Callback(~, ~, handles)
% hObject    handle to buttonShowSongScore (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.Views.running_song_score();

% --- Executes on button press in checkboxAutostart.
function checkboxAutostart_Callback(~, ~, handles)
% hObject    handle to checkboxAutostart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkboxAutostart
handles.GuiModel.AcqObj.RestartManager.change_restart();

function editStartTime_Callback(~, ~, handles)
% hObject    handle to editStartTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editStartTime as text
%        str2double(get(hObject,'String')) returns contents of editStartTime as a double
startHour = str2double(get(handles.editStartTime, 'String'));
stopHour = str2double(get(handles.editStopTime, 'String'));
if ~isnan(startHour) && ~isnan(stopHour)
    handles.GuiModel.AcqObj.RestartManager.change_restart_hours(startHour, stopHour);
end

% --- Executes during object creation, after setting all properties.
function editStartTime_CreateFcn(hObject, ~, ~)
% hObject    handle to editStartTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function editStopTime_Callback(~, ~, handles)
% hObject    handle to editStopTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editStopTime as text
%        str2double(get(hObject,'String')) returns contents of editStopTime as a double
startHour = str2double(get(handles.editStartTime, 'String'));
stopHour = str2double(get(handles.editStopTime, 'String'));
if ~isnan(startHour) && ~isnan(stopHour)
    handles.GuiModel.AcqObj.RestartManager.change_restart_hours(startHour, stopHour);
end

% --- Executes during object creation, after setting all properties.
function editStopTime_CreateFcn(hObject, ~, ~)
% hObject    handle to editStopTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in buttonRecordRegIntervals.
function buttonRecordRegIntervals_Callback(hObject, eventdata, handles)
% hObject    handle to buttonRecordRegIntervals (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
for nrec = 1:50
buttonRecord_Callback(hObject, eventdata, handles)
pause(15)
buttonRecord_Callback(hObject, eventdata, handles)
pause(15)
end


function MenuStartTrigOnSong_Callback(~, ~, ~)
% hObject    handle to MenuStartTrigOnSong (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


function dlgRecordingParameters_Callback(~, ~, handles)
% hObject    handle to dlgRecordingParameters (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.Views.change_recording_params();

% --------------------------------------------------------------------
function MenuStartRecording_Callback(~, ~, ~)
% hObject    handle to MenuStartRecording (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function dlgForcedRecordingProperties_Callback(~, ~, ~)
% hObject    handle to dlgForcedRecordingProperties (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in listboxDatafileProperties.
function listboxDatafileProperties_Callback(~, ~, ~)
% hObject    handle to listboxDatafileProperties (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns listboxDatafileProperties contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listboxDatafileProperties


% --- Executes during object creation, after setting all properties.
function listboxDatafileProperties_CreateFcn(hObject, ~, ~)
% hObject    handle to listboxDatafileProperties (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editDatafileComment_Callback(~, ~, ~)
% hObject    handle to editDatafileComment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editDatafileComment as text
%        str2double(get(hObject,'String')) returns contents of editDatafileComment as a double


% --- Executes during object creation, after setting all properties.
function editDatafileComment_CreateFcn(hObject, ~, ~)
% hObject    handle to editDatafileComment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in buttonAddDatafileComment.
function buttonAddDatafileComment_Callback(~, ~, handles)
% hObject    handle to buttonAddDatafileComment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.Views.make_comment();

% --------------------------------------------------------------------
function MenuAudioAxis_Callback(~, ~, ~)
% hObject    handle to MenuAudioAxis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function playAudio_Callback(~, ~, handles)
% hObject    handle to playAudio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.Views.play_audio(1);
 

% --------------------------------------------------------------------
function MenuSignalAxis_Callback(~, ~, ~)
% hObject    handle to MenuSignalAxis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function playSignal_Callback(~, ~, handles)
% hObject    handle to playSignal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.Views.play_audio(2);

% --------------------------------------------------------------------
function setAudioColorRange_Callback(~, ~, handles)
% hObject    handle to setAudioColorRange (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.Views.set_spectrogram_clim();

% --- Executes on button press in buttonDisplayFilesPerHour.
function buttonDisplayFilesPerHour_Callback(~, ~, ~)
% hObject    handle to buttonDisplayFilesPerHour (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
self.Views.display_filesperhour();

% --------------------------------------------------------------------
function viewSignalIFR_Callback(~, ~, ~)
% hObject    handle to viewSignalIFR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function viewSignalRaw_Callback(~, ~, ~)
% hObject    handle to viewSignalRaw (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)