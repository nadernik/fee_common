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
    status = handles.AcqModel.create_experiment();
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
    status = handles.AcqModel.load_experiment();
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
function popupExperiments_Callback(hObject, eventdata, handles)
% hObject    handle to popupExperiments (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupExperiments contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupExperiments
guifig = get(hObject,'Parent');
newExper = get(hObject, 'Value');
updateCurrentExperiment(guifig, newExper, false);
%Set value of popup according to whether experiment change stuck.
dgd = aa_getAppDataReadOnly(guifig, 'acqguidata');
set(hObject,'Value',dgd.ce);

% --- Executes during object creation, after setting all properties.
function popupExperiments_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupExperiments (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function editFilenum_Callback(hObject, eventdata, handles)
% hObject    handle to editFilenum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editFilenum as text
%        str2double(get(hObject,'String')) returns contents of editFilenum as a double
guifig = get(hObject,'Parent');
dispfile = get(handles.editFilenum, 'String');
[dispfilenum, bOk] = str2double(dispfile);
if bOk
    acqgui_updateDisplayFile(guifig, dispfilenum);
end

% --- Executes on button press in buttonPrevFile.
function buttonPrevFile_Callback(hObject, eventdata, handles)
% hObject    handle to buttonPrevFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
guifig = get(hObject,'Parent');
dispfilenum = str2double(get(handles.editFilenum,'String'));
dispfilenum = dispfilenum - 1;
acqgui_updateDisplayFile(guifig, dispfilenum);

% --- Executes on button press in buttonNextFile.
function buttonNextFile_Callback(hObject, ~, handles)
% hObject    handle to buttonNextFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
guifig = get(hObject,'Parent');
dispfilenum = str2double(get(handles.editFilenum,'String'));
dispfilenum = dispfilenum + 1;
acqgui_updateDisplayFile(guifig, dispfilenum);


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
function checkboxAutoDisplay_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxAutoDisplay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkboxAutoDisplay
guifig = get(hObject,'Parent');
value = get(hObject,'Value');
[dgd, status] = aa_checkoutAppData(guifig, 'acqguidata');
if(~status)
    set(hObject, 'Value', ~value);
    return;
end
dgd.experData(dgd.ce).autoUpdate = value;
aa_checkinAppData(guifig, 'acqguidata', dgd);
if(value)
    recinfo = aa_getAppDataReadOnly(guifig, 'acqrecordinfo');
    acqgui_updateDisplayFile(guifig, recinfo(dgd.ce).filenum);
end

% --- Executes on button press in buttonShowSongScore.
function buttonShowSongScore_Callback(hObject, eventdata, handles)
% hObject    handle to buttonShowSongScore (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
guifig = get(hObject,'Parent');
handles = guidata(guifig);
dgd = aa_getAppDataReadOnly(guifig, 'acqguidata');
ddd = aa_getAppDataReadOnly(guifig, 'acqdisplaydata');

exper = dgd.expers{dgd.ce};
dispfilenum = ddd.currFilenum;
if(dispfilenum > 0)
    audio = loadAudio(exper,dispfilenum);
    [bDetect, tElapsed, score, songRatio, songDetect] = songDetector5(audio, exper.desiredInSampRate, dgd.experData(dgd.ce).songDetection.songDuration, dgd.experData(dgd.ce).songDetection.durationThreshold, dgd.experData(dgd.ce).songDetection.ratioThreshold, dgd.experData(dgd.ce).songDetection.minFreq, dgd.experData(dgd.ce).songDetection.maxFreq, false);
    axes(handles.axes3);
    cla;
    plot(songRatio,'r'); 
    axis tight;
    ylim([0,10]);
    hold on;
    plot(songDetect*10, 'b');
    legend('powerRatio','score');
    line(xlim, [dgd.experData(dgd.ce).songDetection.ratioThreshold, dgd.experData(dgd.ce).songDetection.ratioThreshold],'Color','red');
    line(xlim, [dgd.experData(dgd.ce).songDetection.durationThreshold*10, dgd.experData(dgd.ce).songDetection.durationThreshold*10],'Color','blue');
    hold off;
end

% --- Executes on button press in checkboxAutostart.
function checkboxAutostart_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxAutostart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkboxAutostart
guifig = get(hObject, 'Parent');
if(get(hObject,'Value'))
    setMorningRestartTimer(guifig);
else
    clearMorningRestartTimer();
end

function setMorningRestartTimer(guifig)
handles = guidata(guifig);
%clear restart timer just in case.
clearMorningRestartTimer();
%build a timer that calls the restart function.
t_restart = timer;
set(t_restart, 'Name', 'acqguiRestartInMorning');
set(t_restart,'TimerFcn','acqgui_restartGUI(timerfind(''Name'', ''acqguiRestartInMorning''), [], findobj(''Name'', ''acquisitionGui''))');
set(t_restart,'Period',5);
set(t_restart,'ExecutionMode','fixedDelay');
set(t_restart,'BusyMode', 'queue');

strStopHour = get(handles.editStopTime, 'String');
stopHour = str2double(strStopHour);
if(isempty(stopHour))
    uiwarn('Stop hour is invalid, Using 11pm');
    stopHour = 23;
end
stopTime = floor(now) + stopHour/24;
if(stopTime < now)
    stopTime = stopTime + 1;
end
startat(t_restart, stopTime);   

function clearMorningRestartTimer()  
%delete restart timer if there is one.
if(~isempty(timerfind('Name','acqguiRestartInMorning')))
    stop(timerfind('Name','acqguiRestartInMorning'));
    delete(timerfind('Name','acqguiRestartInMorning'));
end

function editStartTime_Callback(hObject, eventdata, handles)
% hObject    handle to editStartTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editStartTime as text
%        str2double(get(hObject,'String')) returns contents of editStartTime as a double

% --- Executes during object creation, after setting all properties.
function editStartTime_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editStartTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function editStopTime_Callback(hObject, eventdata, handles)
% hObject    handle to editStopTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editStopTime as text
%        str2double(get(hObject,'String')) returns contents of editStopTime as a double
guifig = get(hObject, 'Parent');
handles = guidata(guifig);
if(get(handles.checkboxAutostart,'Value'))
    setMorningRestartTimer(guifig);
end

% --- Executes during object creation, after setting all properties.
function editStopTime_CreateFcn(hObject, eventdata, handles)
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


% --------------------------------------------------------------------
function MenuStartTrigOnSong_Callback(hObject, eventdata, handles)
% hObject    handle to MenuStartTrigOnSong (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function dlgRecordingParameters_Callback(hObject, eventdata, handles)
% hObject    handle to dlgRecordingParameters (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
guifig = findobj('Name','acquisitionGui');
handles = guidata(guifig);
tsd = getappdata(guifig,'threadSafeData');
dgd = aa_getAppDataReadOnly(guifig, 'acqguidata');

stp = tsd.songTrigParams(dgd.ce);
prompt = {'Pre Trigger Secs:','Post Trigger Secs:','Max File Length:'};
dlg_title = 'Input Recording Parameters:';
num_lines = 1;
def = {num2str(stp.preSecs),num2str(stp.postSecs),num2str(stp.maxFileLength)};
answer = inputdlg(prompt,dlg_title,num_lines,def);

if(length(answer) ~= 0) %#ok<ISMT>
    [stp.preSecs, bStatus1] = str2num(answer{1}); %#ok<ST2NM>
    [stp.postSecs, bStatus2] = str2num(answer{2}); %#ok<ST2NM>
    [stp.maxFileLength , bStatus3] = str2num(answer{3}); %#ok<ST2NM>
    if bStatus1 && bStatus2 && bStatus3
        tsd.songTrigParams(dgd.ce).preSecs = stp.preSecs;
        tsd.songTrigParams(dgd.ce).postSecs = stp.postSecs;
        tsd.songTrigParams(dgd.ce).maxFileLength = stp.maxFileLength;
    else
        beep;
    end
    setappdata(guifig,'threadSafeData', tsd);
    acqgui_updateDisplay(guifig);  
end

% --------------------------------------------------------------------
function MenuStartRecording_Callback(hObject, eventdata, handles)
% hObject    handle to MenuStartRecording (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function dlgForcedRecordingProperties_Callback(hObject, eventdata, handles)
% hObject    handle to dlgForcedRecordingProperties (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in listboxDatafileProperties.
function listboxDatafileProperties_Callback(hObject, eventdata, handles)
% hObject    handle to listboxDatafileProperties (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns listboxDatafileProperties contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listboxDatafileProperties


% --- Executes during object creation, after setting all properties.
function listboxDatafileProperties_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listboxDatafileProperties (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editDatafileComment_Callback(hObject, eventdata, handles)
% hObject    handle to editDatafileComment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editDatafileComment as text
%        str2double(get(hObject,'String')) returns contents of editDatafileComment as a double


% --- Executes during object creation, after setting all properties.
function editDatafileComment_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editDatafileComment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in buttonAddDatafileComment.
function buttonAddDatafileComment_Callback(hObject, eventdata, handles)
% hObject    handle to buttonAddDatafileComment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
guifig = findobj('Name','acquisitionGui');
handles = guidata(guifig); 
commentStr = get(handles.editDatafileComment, 'String');
if(~all(isspace(commentStr)))
    dgd = aa_getAppDataReadOnly(guifig, 'acqguidata');
    ddd = aa_getAppDataReadOnly(guifig, 'acqdisplaydata');
    exper = dgd.expers{dgd.ce};
    dispfilenum = ddd.currFilenum;
    filename = getExperDatafile(exper,dispfilenum,exper.audioCh);
    bStatus = daq_appendProperty([exper.dir,filename], 'Comment', commentStr);
    if(bStatus)
        set(handles.editDatafileComment, 'String', '');
        strList = get(handles.listboxDatafileProperties,'String');
        ndx = length(strList);
        strList{ndx+1} = ['Comment: ', commentStr];
        set(handles.listboxDatafileProperties,'String', strList);
    end
end

% --------------------------------------------------------------------
function MenuAudioAxis_Callback(hObject, eventdata, handles)
% hObject    handle to MenuAudioAxis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function playAudio_Callback(hObject, eventdata, handles)
% hObject    handle to playAudio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%get the audio
axes(handles.axesAudio);
ud = get(gca,'UserData');
audio = ud.data;
fs = ud.fs;

range = max(max(audio), abs(min(audio)));
audio = audio/(range*3);
 
player = audioplayer(audio, fs);
axes(handles.axesAudio);
hold on;
xl= xlim;
ylimits1 = ylim;
l1 = line([xl(1),xl(1)],ylimits1,'Color','yellow');

play(player);
while(isplaying(player))
    currTime = xl(1) + get(player,'CurrentSample')/fs;
    set([l1],'XData',[currTime, currTime]);
    drawnow;        
end
delete(l1);

axes(handles.axesAudio);
hold off;
 

% --------------------------------------------------------------------
function MenuSignalAxis_Callback(hObject, eventdata, handles)
% hObject    handle to MenuSignalAxis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function playSignal_Callback(hObject, eventdata, handles)
% hObject    handle to playSignal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%get the signal
axes(handles.axesSignal);
ud = get(gca,'UserData');
sig = ud.data;
fs = ud.fs;

range = max(max(sig), abs(min(sig)));
sig = sig/(range*3);  

player = audioplayer(sig, fs);

axes(handles.axesSignal);
hold on;
xl = xlim;
ylimits2 = ylim;
l2 = line([xl(1),xl(1)],ylimits2,'Color','red');    

play(player);
while(isplaying(player))
    currTime = xl(1) + get(player,'CurrentSample')/fs;
    set([l2],'XData',[currTime, currTime]);
    drawnow;        
end

delete(l2);
axes(handles.axesSignal);
hold off;    

% --------------------------------------------------------------------
function setAudioColorRange_Callback(hObject, eventdata, handles)
% hObject    handle to setAudioColorRange (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
guifig = findobj('Name','acquisitionGui');
handles = guidata(guifig);
tsd = getappdata(guifig,'threadSafeData');
dgd = aa_getAppDataReadOnly(guifig, 'acqguidata');

if(isempty(tsd.displayParams(dgd.ce).audioCLim))
    cRange = get(handles.axesAudio, 'CLim');
else
    cRange = tsd.displayParams(dgd.ce).audioCLim;
end

prompt = {'Enter floor:','Enter ceiling:'};
dlg_title = 'Input audio axis color range';
num_lines = 1;
def = {num2str(cRange(1)),num2str(cRange(2))};
answer = inputdlg(prompt,dlg_title,num_lines,def);
if(length(answer) ~= 0) %#ok<ISMT>
    [cRange(1), bStatus1] = str2num(answer{1}); %#ok<ST2NM>
    [cRange(2), bStatus2] = str2num(answer{2}); %#ok<ST2NM>
    if bStatus1 && bStatus2
        tsd.displayParams(dgd.ce).audioCLim = cRange;
    else
        tsd.displayParams(dgd.ce).audioCLim = [];
    end
    setappdata(guifig,'threadSafeData', tsd);
    acqgui_updateDisplay(guifig);  
end

% --- Executes on button press in buttonDisplayFilesPerHour.
function buttonDisplayFilesPerHour_Callback(hObject, eventdata, handles)
% hObject    handle to buttonDisplayFilesPerHour (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
guifig = findobj('Name','acquisitionGui');
handles = guidata(guifig);
dgd = aa_getAppDataReadOnly(guifig, 'acqguidata');
exper = dgd.expers{dgd.ce};
chan = exper.audioCh;
d = dir([exper.dir,exper.birdname,'_d*chan',num2str(chan),'.dat']);
times = [d(:).datenum];
firstDay = floor(min(times));
lastDay = ceil(max(times));
times = times - firstDay;
edges = linspace(0,lastDay-firstDay,96*(lastDay-firstDay));
count = histc(times,edges);
axes(handles.axes3);
cla;
bar(edges*24,count,'histc');
xlabel('hours');
ylabel('files');






% --- Executes on button press in buttonFindCell.
function buttonFindCell_Callback(hObject, eventdata, handles)
% hObject    handle to buttonFindCell (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




% --- Executes on button press in buttonReportCellLoss.
function buttonReportCellLoss_Callback(hObject, eventdata, handles)
% hObject    handle to buttonReportCellLoss (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function viewSignalIFR_Callback(hObject, eventdata, handles)
% hObject    handle to viewSignalIFR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function viewSignalRaw_Callback(hObject, eventdata, handles)
% hObject    handle to viewSignalRaw (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes on button press in buttonUp.
function buttonUp_Callback(hObject, eventdata, handles)
% hObject    handle to buttonUp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%[microsteps, micronsApprox, Status] = sutterGetCurrentPosition(dgd.sutterConnection);


% --- Executes on button press in buttonDown.
function buttonDown_Callback(hObject, eventdata, handles)
% hObject    handle to buttonDown (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes on button press in buttonSutterGoTo.
function buttonSutterGoTo_Callback(hObject, eventdata, handles)
% hObject    handle to buttonSutterGoTo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function menuSutterMovement_Callback(hObject, eventdata, handles)
% hObject    handle to menuSutterMovement (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function setSutterStepSize_Callback(hObject, eventdata, handles)
% hObject    handle to setSutterStepSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
stepSize = get(handles.buttonDown, 'UserData');
answer = inputdlg('Enter size of each movement (sutter units):','Set Step Size', 1, num2str(stepSize));
[stepSize, status] = str2num(answer{1}); %#ok<ST2NM>
if(status)
    set(handles.buttonDown, 'UserData', stepSize);
end

% --- Executes on button press in buttonSaveState.
function buttonSaveState_Callback(hObject, eventdata, handles)
% hObject    handle to buttonSaveState (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
    guifig = get(hObject,'Parent');
    tsd = getappdata(guifig,'threadSafeData');
    dgd = aa_getAppDataReadOnly(guifig, 'acqguidata');

    for nExper = 1:length(dgd.expers)
        songDetection(nExper).songDensity = dgd.experData(nExper).songDetection.durationThreshold; %#ok<AGROW>
        songDetection(nExper).powerThres = dgd.experData(nExper).songDetection.ratioThreshold; %#ok<AGROW>
        songDetection(nExper).songLength = dgd.experData(nExper).songDetection.songDuration; %#ok<AGROW>
        songDetection(nExper).minFreq = dgd.experData(nExper).songDetection.minFreq; %#ok<AGROW>
        songDetection(nExper).maxFreq = dgd.experData(nExper).songDetection.maxFreq; %#ok<AGROW>
        dispchanAudio(nExper) = dgd.experData(nExper).dddbackground.dispchanAudio;
        dispchan(nExper) = dgd.experData(nExper).dddbackground.dispchan;
        dispchan2(nExper) = dgd.experData(nExper).dddbackground.dispchan2;
        dispchan3(nExper) = dgd.experData(nExper).dddbackground.dispchan3;       
        if(isfield(dgd.expers{nExper},'sigName'))
            expers(nExper) = dgd.expers{nExper};
        else
            temp = dgd.expers{nExper};
            temp.sigName = {};
            temp.sigDesc = {};
            expers(nExper) = temp;
        end            
    end
    bTrigOnSong = dgd.bTrigOnSong;
    logfile = dgd.logfile;
    bRestartInMorning = get(handles.checkboxAutostart, 'Value');
    startHour = str2double(get(handles.editStartTime, 'String'));
    stopHour = str2double(get(handles.editStopTime, 'String'));
    [f,p] = uiputfile(['acqgui_state_',datestr(now,30),'.mat'],'Select file for acquistion gui state:');
    save([p,filesep,f], 'tsd','songDetection','dispchanAudio','dispchan','dispchan2',...
                        'dispchan3', 'bTrigOnSong', 'logfile', 'expers', 'bRestartInMorning', 'startHour', 'stopHour');   
end

% --- Executes on button press in buttonLoadState.
function buttonLoadState_Callback(hObject, eventdata, handles)
% hObject    handle to buttonLoadState (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
guifig = get(hObject,'Parent');

[recinfo] = aa_getAppDataReadOnly(guifig, 'acqrecordinfo');
[dgd] = aa_getAppDataReadOnly(guifig, 'acqguidata');
if ~isempty(recinfo) && any([recinfo(:).bForcedRecording] | dgd.bTrigOnSong)
    warndlg({'In order to load a previously saved state ','all triggering and recording must be stopped'});
    uiwait;
    return;
end

[f,p] = uigetfile('acqgui_state_*','Load acquisition gui state:');
load([p,filesep,f]);

button = questdlg('Would you like update experiment names to the current day?','','Yes','No','Yes'); 
bUpdate = strcmp(button,'Yes'); 

if(bUpdate)
    for(nExper = 1:length(expers))
        rootndx = strfind(expers(nExper).dir,expers(nExper).birdname);
        rootdir = expers(nExper).dir(1:rootndx-2);
        expers(nExper) = createExperAuto(rootdir, expers(nExper).birdname, datestr(now,29), expers(nExper).desiredInSampRate, expers(nExper).audioCh, expers(nExper).sigCh);
    end
end

acquisitionGui_OpeningFcn(guifig, eventdata, handles, ...
                          'bTrigOnSong', bTrigOnSong, ...
                          'logfile', logfile, ...
                          'expers', expers, ...
                          'dispchanAudio', dispchanAudio, ...
                          'dispchan', dispchan, ...
                          'dispchan2', dispchan2, ...
                          'dispchan3', dispchan3, ...
                          'songDetection', songDetection, ...
                          'bRestartInMorning', logical(bRestartInMorning), ...
                          'startHour', startHour, ...
                          'stopHour', stopHour, ...
                          'threadSafeData', tsd);

% --- Executes on button press in buttonRestart.
function buttonRestart_Callback(hObject, eventdata, handles)
% hObject    handle to buttonRestart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
guifig = get(hObject,'Parent');
button = questdlg('Would you like to run the overnight batch?','','Yes','No','No'); 
bBatch = strcmp(button,'Yes'); 
for(nAttempt = 1:100)
    status = acqgui_restartGUI([], [], guifig, now+(0.5/(60*24)), bBatch);
    if(status)
        disp('acquisitionGui will restart in 30 seconds.');
        break;
    else
        pause(2);
    end
end
if(nAttempt == 100)
    disp('Forced acquistion restart failed.  Are you currently recording a file?');
end


