function varargout = experAcquistionGui(varargin)
% EXPERACQUISTIONGUI M-file for experAcquistionGui.fig
%      EXPERACQUISTIONGUI, by itself, creates a new EXPERACQUISTIONGUI or raises the existing
%      singleton*
%
%      H = EXPERACQUISTIONGUI returns the handle to a new EXPERACQUISTIONGUI or the handle to
%      the existing singleton*.
%
%      EXPERACQUISTIONGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EXPERACQUISTIONGUI.M with the given input arguments.
%
%      EXPERACQUISTIONGUI('Prdaeoperty','Value',...) creates a new EXPERACQUISTIONGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before experAcquistionGui_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to experAcquistionGui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help experAcquistionGui

% Last Modified by GUIDE v2.5 03-Aug-2007 17:41:02

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @experAcquistionGui_OpeningFcn, ...
                   'gui_OutputFcn',  @experAcquistionGui_OutputFcn, ...
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


% --- Executes just before experAcquistionGui is made visible.
function experAcquistionGui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to experAcquistionGui (see VARARGIN


% Choose default command line output for experAcquistionGui
handles.output = hObject;

%Make handle of figure visible so that command line timer function can find
%it.
set(hObject,'HandleVisibility','on');

%parse varargin
P.logfile = '';
P.exper = []; %auto load exper on start.
P.songDensity = .5;
P.powerThres = 5;
P.songLength = .6;
P.startTrigOnSong = false;
P.bRestartInMorning = false;
P.startHour = 9;
P.stopHour = 25;
P = parseargs(P, varargin{:});

%clear any semaphores...
aa_resetCheckouts;

daqguidata.exper = []; %will be updated below.
daqguidata.logfile = P.logfile;

set(handles.buttonTrigOnSong,'Enable','off');
set(handles.buttonRecord,'Enable','off');
set(handles.buttonTrigOnChan,'Enable','off');

%clear any preexisting timers
if(length(timerfind('Name','trigOnSong'))~=0)
    delete(timerfind('Name','trigOnSong'));
end

%set up display data
daqdisplaydata.currFilenum = 0;
daqdisplaydata.startNdx = 0;
daqdisplaydata.endNdx = 0;
daqdisplaydata.lengthFile = 0;

%Set up the gui
guidata(hObject, handles);
aa_checkoutAppData(hObject, 'daqguidata');
aa_checkinAppData(hObject, 'daqguidata', daqguidata);
aa_checkoutAppData(hObject, 'daqdisplaydata');
aa_checkinAppData(hObject, 'daqdisplaydata', daqdisplaydata);

fields = fieldnames(handles);
for(nField = 1:length(fields))
    hand = getfield(handles, fields{nField});
    if(isprop(hand,'BusyAction'))
        set(hand,'BusyAction','cancel');
    end
    if(isprop(hand,'Interruptible'))
        set(hand,'Interruptible','off');
    end
end

set(handles.editSongDensity, 'String', num2str(P.songDensity));
set(handles.editPowerThres, 'String', num2str(P.powerThres));
set(handles.editSongLength, 'String',num2str(P.songLength));
set(handles.editStartTime, 'String', num2str(P.startHour));
set(handles.editStopTime, 'String',num2str(P.stopHour));

%Done with standard start up, now loading any experiments.
%Load experiment if one was passed in
if(~isempty(P.exper))
    [dgd, status] = aa_checkoutAppData(hObject, 'daqguidata');
    if(~status)
        return;
    end
    try
        dgd.exper = P.exper;
        aa_checkinAppData(hObject, 'daqguidata', dgd);      
        updateExperiment(hObject);
        if(P.startTrigOnSong)
            buttonTrigOnSong_Callback(handles.buttonTrigOnSong);  
        end
    catch
        aa_checkinAppData(hObject, 'daqguidata', dgd);
        return;
    end
end

if(P.bRestartInMorning)
    set(handles.checkboxAutostart, 'Value', true);
    setMorningRestartTimer(hObject);
end
% UIWAIT makes experAcquistionGui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = experAcquistionGui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in buttonRecord.
function buttonRecord_Callback(hObject, eventdata, handles)
% hObject    handle to buttonRecord (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%It is crucial, that this function, which accesses daq_data, does not
%interrupt the daq_bufferUpdate.  Interruptions result in crashes and
%freezes.
if(daq_isUpdating)
    return;
end

guifig = get(hObject,'Parent');
handles = guidata(guifig);
[dgd, bDgdStatus] = aa_checkoutAppData(guifig, 'daqguidata');
if(~bDgdStatus) 
    return; 
end

bNewFile = false;
if(~dgd.bForcedRecording)
    recSampNum = daq_getCurrSampNum;
    [filenamePrefix, recfilenum] = getNewDatafilePrefix(dgd.exper);
    dgd.recfilenum = recfilenum;
    [bStatus, startSamp, filenames] = daq_recordStart(recSampNum, [dgd.exper.dir, filenamePrefix], dgd.inChans);
    if(~bStatus)
        error('Forced Start recording failed' );
    else
        set(handles.textRecordingStatus, 'String', ['Started recording.', num2str(dgd.recfilenum)]);
        set(handles.textRecordingStatus, 'BackgroundColor', 'red');
        set(handles.buttonRecord, 'String', 'Stop Recording');
        dgd.bForcedRecording = true;
    end
else
    recSampNum = daq_getCurrSampNum;
    [bStatus, endSamp] = daq_recordStop(recSampNum, dgd.inChans);
    if(~bStatus)
        error('Song stop recording failed.');
    else
        bNewFile = true;
        dgd.filenum = dgd.recfilenum;
        set(handles.textRecordingStatus, 'String', ['Finished recording.', num2str(dgd.recfilenum), '.   Ready to record.']);
        set(handles.textRecordingStatus, 'BackgroundColor', 'green'); 
        set(handles.buttonRecord, 'String', 'Start Recording');
        dgd.bForcedRecording = false;       
    end
end
st = dbstack;
des = dgd.bForcedRecording;
aa_checkinAppData(guifig, 'daqguidata', dgd);
dgd2 = aa_getAppDataReadOnly(guifig, 'daqguidata');
if(dgd2.bForcedRecording ~= des)
    error('wtf');
end
if(bNewFile & (get(handles.checkboxAutoDisplay,'Value') ~= 0)) 
    daq_waitForRecording(dgd.inChans);
    daqgui_updateDisplayFile(guifig, dgd.filenum);
end

% --- Executes on button press in pushbutton1.
function buttonTrigOnSong_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

guifig = get(hObject,'Parent');
handles = guidata(guifig);

[dgd, bDgdStatus] = aa_checkoutAppData(guifig, 'daqguidata');
if(~bDgdStatus)
    return;
end
[params, bParamStatus] = aa_checkoutAppData(guifig, 'paramsTrigOnSong');
if(~bParamStatus)
    aa_checkinAppData(guifig, 'daqguidata', dgd);
    return; 
end

if(isempty(timerfind('Name','trigOnSong')))
    %set up the trigger parameters
    %Parameters for part 0.
    params.actInSampleRate = dgd.daqSetup.actInSampleRate;
    params.preSamps = ceil(1*params.actInSampleRate); %Save data 1 seconds prior song start.
    params.postSamps = ceil(1*params.actInSampleRate); %Save date 1 seconds after song end.

    %Parameters for part 1.  Song Trigger Spectrogram Parameters
    params.windowSize = fix(params.actInSampleRate/20);
    params.windowOverlap = fix(params.windowSize*.5);

    %Parameters for Part 2.  Frequency range in which songs typically has
    %power, and power threshold.
    params.minFreq = 2000; 
    params.maxFreq = 6000;
    params.minNdx = floor((params.windowSize/params.actInSampleRate)*params.minFreq + 1);
    params.maxNdx = ceil((params.windowSize/params.actInSampleRate)*params.maxFreq + 1);
    params.ratioThreshold = str2num(get(handles.editPowerThres, 'String'));

    %Parameters for part 3
    params.songDuration = str2num(get(handles.editSongLength, 'String'));
    params.windowLength = round((params.actInSampleRate * params.songDuration) / (params.windowSize-params.windowOverlap)); %song average .9 seconds in length
    params.windowAvg = repmat(1/params.windowLength,1,params.windowLength);
    params.durationThreshold = str2num(get(handles.editSongDensity, 'String'));

    params.isRecordingSong = false;
    params.nextPeek = ceil(daq_getCurrSampNum - params.actInSampleRate);
    aa_checkinAppData(guifig, 'paramsTrigOnSong', params);

    %start the recurring song check timer...
    dgd.trigOnSongTimer = timer;
    set(dgd.trigOnSongTimer, 'Name', 'trigOnSong');
    set(dgd.trigOnSongTimer,'TimerFcn','daqgui_timerFcnAcqTrigOnSong(timerfind(''Name'', ''trigOnSong''), [], findobj(''Name'', ''experAcquistionGui''))');
    set(dgd.trigOnSongTimer,'Period',1);
    set(dgd.trigOnSongTimer,'ExecutionMode','fixedRate');
    set(dgd.trigOnSongTimer,'BusyMode', 'drop');
    
    set(handles.buttonTrigOnSong, 'String', 'Stop Triggering On Song');
    aa_checkinAppData(guifig, 'daqguidata', dgd);
    start(dgd.trigOnSongTimer);
else
    if(params.isRecordingSong)
        aa_checkinAppData(guifig, 'paramsTrigOnSong', params);
        daq_waitForRecording(dgd.inChans);
    else
        aa_checkinAppData(guifig, 'paramsTrigOnSong', params);
    end
    stop(dgd.trigOnSongTimer);
    delete(dgd.trigOnSongTimer);
    set(handles.buttonTrigOnSong, 'String', 'Start Triggering On Song');
    set(handles.textSongScore, 'String', 'Not triggering on song.');
    aa_checkinAppData(guifig, 'daqguidata', dgd);
end

function editSongThreshold_Callback(hObject, eventdata, handles)
% hObject    handle to editSongThreshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editSongThreshold as text
%        str2double(get(hObject,'String')) returns contents of editSongThreshold as a double

%If currently triggering on song, then we have to update parameters
%directly.  If not currently triggering then no worries.

%If currently triggering on song, then we have to update parameters
%directly.  If not currently triggering then no worries.
if(length(timerfind('Name','trigOnSong'))==1)
    guifig = get(hObject,'Parent');
    [params, bParamStatus] = aa_checkoutAppData(guifig, 'paramsTrigOnSong');
    if(bParamStatus) 
        params.durationThreshold = str2num(get(handles.editSongThreshold, 'String'));
        aa_checkinAppData(guifig, 'paramsTrigOnSong', params);
    else
        params = aa_getAppDataReadOnly(guifig, 'paramsTrigOnSong');
        set(handles.editSongThreshold, 'String', num2str(params.durationThreshold))
    end
end

% --- Executes during object creation, after setting all properties.
function editSongThreshold_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editSongThreshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function editPowerThres_Callback(hObject, eventdata, handles)
% hObject    handle to editPowerThres (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editPowerThres as text
%        str2double(get(hObject,'String')) returns contents of editPowerThres as a double

%If currently triggering on song, then we have to update parameters
%directly.  If not currently triggering then no worries.
if(length(timerfind('Name','trigOnSong'))==1)
    guifig = get(hObject,'Parent');
    [params, bParamStatus] = aa_checkoutAppData(guifig, 'paramsTrigOnSong');
    if(bParamStatus) 
        params.ratioThreshold = str2num(get(handles.editPowerThres, 'String'));
        aa_checkinAppData(guifig, 'paramsTrigOnSong', params);
    else
        params = aa_getAppDataReadOnly(guifig, 'paramsTrigOnSong');
        set(handles.editPowerThres, 'String', num2str(params.ratioThreshold))
    end
end


% --- Executes during object creation, after setting all properties.
function editPowerThres_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editPowerThres (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in buttonAntidromic.
function buttonAntidromic_Callback(hObject, eventdata, handles)
% hObject    handle to buttonAntidromic (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
guifig = get(hObject,'Parent');
dgd = aa_getAppDataReadOnly(guifig, 'daqguidata');
[dispfilenum, ok] = str2num(get(handles.editFilenum,'String'));
currchan = dgd.currChan;
exper = dgd.exper;
fs = exper.desiredInSampRate;
if(logical(ok) && dispfilenum > 0)
    [sig, sigTimes, HWChannels, startSamp, timeCreated] = loadData(exper, dispfilenum, currchan);
    preStimMs = 10;
    postStimMs = 50;
    maxStimPeakWidthMs = 1;
    minStimSpacingSecs = .7;
    stimThreshold = 4.2;
    stimClips = clipStimFromSignal(sig, fs, stimThreshold, preStimMs, postStimMs, maxStimPeakWidthMs, minStimSpacingSecs);
    if(length(stimClips) > 0)
        axes(handles.axes3);
        cla;
        time = linspace(-preStimMs, postStimMs, size(stimClips,2));
        plot(time, stimClips);
        zoom on;
        %set rt and lf click to flip through individual stims.
    end
end


% --- Executes on button press in buttonPlayAudio.
function buttonPlayAudio_Callback(hObject, eventdata, handles)
% hObject    handle to buttonPlayAudio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
guifig = get(hObject, 'Parent');
dgd = aa_getAppDataReadOnly(guifig, 'daqguidata');
ddd = aa_getAppDataReadOnly(guifig, 'daqdisplaydata');

[dispfilenum, ok] = str2num(get(handles.editFilenum,'String'));
currchan = dgd.currChan;
exper = dgd.exper;

if(logical(ok) && dispfilenum > 0)
    %Load the data...
    audio = loadAudio(exper,dispfilenum);   
    
    %Clip according to current zoom if current.
    if(ddd.currFilenum == dispfilenum)
        sn = min(ddd.startNdx, length(audio));
        en = max(1, ddd.endNdx);
        if(sn < en)
            audio = audio(sn:en);
        end
    else
        sn = 1;
        en = length(audio);
    end
    soundsc(audio, exper.desiredInSampRate);
end 

% --- Executes on selection change in popupChannel.
function popupChannel_Callback(hObject, eventdata, handles)
% hObject    handle to popupChannel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = get(hObject,'String') returns popupChannel contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupChannel
guifig = get(hObject,'Parent');
[dgd, status] = aa_checkoutAppData(guifig, 'daqguidata');
if(~status)
    error('Unable to checkout dgd.');
end

value = get(handles.popupChannel,'Value');
names = get(handles.popupChannel,'String');
currName = names{value};
dash = strfind(currName, '-');
currChan = str2num(currName(1:dash(1)-1));
dgd.currChan = currChan;

aa_checkinAppData(guifig, 'daqguidata', dgd);
daqgui_updateDisplay(guifig);

% --- Executes during object creation, after setting all properties.
function popupChannel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupChannel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in buttonCreateExper.
function buttonCreateExper_Callback(hObject, eventdata, handles)
% hObject    handle to buttonCreateExper (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
guifig = get(hObject,'Parent');
[dgd, status] = aa_checkoutAppData(guifig, 'daqguidata');
if(~status)
    return;
end
try
    dirname = uigetdir('', 'Select the root directory?');
    if(dirname == 0)
        error('');
    end
    dgd.exper = createExper(dirname);
    aa_checkinAppData(guifig, 'daqguidata', dgd);
    updateExperiment(guifig);
catch
    aa_checkinAppData(guifig, 'daqguidata', dgd);
end

% --- Executes on button press in buttonLoadExperiment.
function buttonLoadExperiment_Callback(hObject, eventdata, handles)
% hObject    handle to buttonLoadExperiment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
guifig = get(hObject,'Parent');
[dgd, status] = aa_checkoutAppData(guifig, 'daqguidata');
if(~status)
    return;
end
try
    [experfilename, experfilepath] = uigetfile('exper.mat', 'Choose an experiment file:');
    load([experfilepath,filesep,experfilename]);
    dgd.exper = exper;
    aa_checkinAppData(guifig, 'daqguidata', dgd);
    updateExperiment(guifig);
catch
    aa_checkinAppData(guifig, 'daqguidata', dgd);
end


% --- Executes on button press in checkboxDisplaySpectrogram.
function checkboxDisplaySpectrogram_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxDisplaySpectrogram (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkboxDisplaySpectrogram
guifig = get(hObject,'Parent');
daqgui_updateDisplay(guifig);

% --- Executes on button press in buttonTrigOnChan.
function buttonTrigOnChan_Callback(hObject, eventdata, handles)
% hObject    handle to buttonTrigOnChan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in buttonReset.
function buttonReset_Callback(hObject, eventdata, handles)
% hObject    handle to buttonReset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
guifig = get(hObject,'Parent');
updateExperiment(guifig);

function editFilenum_Callback(hObject, eventdata, handles)
% hObject    handle to editFilenum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editFilenum as text
%        str2double(get(hObject,'String')) returns contents of editFilenum as a double
guifig = get(hObject,'Parent');
dispfile = get(handles.editFilenum, 'String');
[dispfilenum, bOk] = str2num(dispfile);
if(bOk)
    daqgui_updateDisplayFile(guifig, dispfilenum);
end

% --- Executes on button press in buttonPrevFile.
function buttonPrevFile_Callback(hObject, eventdata, handles)
% hObject    handle to buttonPrevFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
guifig = get(hObject,'Parent');
[dispfilenum, ok] = str2num(get(handles.editFilenum,'String'));
dispfilenum = dispfilenum - 1;
daqgui_updateDisplayFile(guifig, dispfilenum);

% --- Executes on button press in buttonNextFile.
function buttonNextFile_Callback(hObject, eventdata, handles)
% hObject    handle to buttonNextFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
guifig = get(hObject,'Parent');
[dispfilenum, ok] = str2num(get(handles.editFilenum,'String'));
dispfilenum = dispfilenum + 1;
daqgui_updateDisplayFile(guifig, dispfilenum);



% --- Executes during object creation, after setting all properties.
function editFilenum_CreateFcn(hObject, eventdata, handles)
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
if(get(hObject,'Value') ~= 0)
    guifig = get(hObject,'Parent');
    dgd = aa_getAppDataReadOnly(guifig, 'daqguidata');
    daqgui_updateDisplayFile(guifig, dgd.filenum);
end

function editSongLength_Callback(hObject, eventdata, handles)
% hObject    handle to editSongLength (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editSongLength as text
%        str2double(get(hObject,'String')) returns contents of
%        editSongLength as a double
if(length(timerfind('Name','trigOnSong'))==1)
    guifig = get(hObject,'Parent');
    [params, bParamStatus] = aa_checkoutAppData(guifig, 'paramsTrigOnSong');
    if(bParamStatus) 
        params.songDuration = str2num(get(handles.editSongLength, 'String'));
        aa_checkinAppData(guifig, 'paramsTrigOnSong', params);
    else
        params = aa_getAppDataReadOnly(guifig, 'paramsTrigOnSong');
        set(handles.editSongLength, 'String', num2str(params.songDuration))
    end
end

% --- Executes during object creation, after setting all properties.
function editSongLength_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editSongLength (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in buttonShowSongScore.
function buttonShowSongScore_Callback(hObject, eventdata, handles)
% hObject    handle to buttonShowSongScore (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
guifig = get(hObject,'Parent');
dgd = aa_getAppDataReadOnly(guifig, 'daqguidata');
handles = guidata(guifig);
[dispfilenum, ok] = str2num(get(handles.editFilenum,'String'));
exper = dgd.exper;
if(logical(ok) && dispfilenum > 0)
    audio = loadAudio(exper,dispfilenum);
    minFreq = 2000;
    maxFreq = 6000;
    ratioThreshold = str2num(get(handles.editPowerThres, 'String'));
    songDuration = str2num(get(handles.editSongLength, 'String'));
    durationThreshold = str2num(get(handles.editSongDensity, 'String'));    
    [bDetect, tElapsed, score, songRatio, songDetect] = songDetector5(audio, exper.desiredInSampRate, songDuration, durationThreshold, ratioThreshold, minFreq, maxFreq, false);
    axes(handles.axes3);
    cla;
    plot(songRatio,'r'); 
    axis tight;
    ylim([0,10]);
    hold on;
    plot(songDetect*10, 'b');
    legend('powerRatio','score');
    line(xlim, [ratioThreshold, ratioThreshold],'Color','red');
    line(xlim, [durationThreshold*10, durationThreshold*10],'Color','blue');
    hold off;
end

% --- Executes on button press in buttonStop.
function buttonStop_Callback(hObject, eventdata, handles)
% hObject    handle to buttonStop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
daqreset;

%%%%%%%%%%%%%%%%%%%%%%%%% HELPER FUNCTIONS *********************

function updateExperiment(guifig);
handles = guidata(guifig);
[dgd,status] = aa_checkoutAppData(guifig, 'daqguidata');
if(~status)
    error('Failed to checkout dgd during updateExperiment.');
end

%clear any preexisting timers
if(length(timerfind('Name','trigOnSong'))~=0)
    delete(timerfind('Name','trigOnSong'));
end

%Set exper text display:
set(handles.experInfo,'String',[dgd.exper.birdname,' ',dgd.exper.expername, ' sampRate: ', num2str(dgd.exper.desiredInSampRate)]);

%Set up channel popup
chanstrings{1} = [num2str(dgd.exper.audioCh), '- audio'];
for(nChan = 1:length(dgd.exper.sigCh))
    chanstrings{nChan+1} = [num2str(dgd.exper.sigCh(nChan)),'-hardwareChan'];
end    
set(handles.popupChannel,'Value',1);
set(handles.popupChannel,'String', chanstrings);
dgd.currChan = dgd.exper.audioCh;

%Initialize the daq toolbox
daqreset;

%input channels
dgd.inChans = [];
if(dgd.exper.audioCh>-1)
    dgd.inChans = [dgd.exper.audioCh];
else
    error('No audio channel.  Cannot monitor for singing.');
end
dgd.inChans = [dgd.inChans, dgd.exper.sigCh];

%parameters
buffer= 90; %Seconds
updateFreq = 4; %Hz
[ai, ao, actInSampleRate, actOutSampleRate, actUpdateFreq] = daq_Init(dgd.inChans, dgd.exper.desiredInSampRate, [], 1, buffer, updateFreq, dgd.logfile);

dgd.daqSetup.actInSampleRate = actInSampleRate;
dgd.daqSetup.actOutSampleRate = actOutSampleRate;
dgd.daqSetup.buffer = buffer;
dgd.daqSetup.actUpdateFreq = actUpdateFreq;
daqSetup = dgd.daqSetup;
save([dgd.exper.dir,'daqSetup',datestr(now,30),'.mat'], 'daqSetup');
    
%Start data acquisition
daq_Start;
set(handles.textRecordingStatus, 'String', 'Buffering');
set(handles.textRecordingStatus, 'BackgroundColor', 'yellow');
pause(7); %uiwait(guifig,7);
set(handles.textRecordingStatus, 'String', 'Ready to record');
set(handles.textRecordingStatus, 'BackgroundColor', 'green');

set(handles.buttonTrigOnSong,'Enable','on');
set(handles.buttonRecord,'Enable','on');
set(handles.buttonTrigOnChan,'Enable','on');

%Prepare file variables
dgd.filenum = getLatestDatafileNumber(dgd.exper);
dgd.bForcedRecording = false;
aa_checkinAppData(guifig, 'daqguidata', dgd);

%Load serial object
% s= serial('COM1');
%s.BaudRate = 9600;
%s.Parity = 'none';
%s.Terminator = 'CR'; %equivalent to 13. Line Feed is 10.
%s.StopBits = 1;
%s.DataBits = 8;
%s.OutputBufferSize = 1024;
%s.InputBufferSize = 1024;
%fopen(s);
%fprintf('c\n'); %the command c returns the current position. \n invokes the terminator
%a = fscanf('%ld%ld%ld
%set s timerFcn to get the location every second and update the display.
%modify the data file to include this information
%modify the data file to include a comment.

%update the display
daqgui_updateDisplayFile(guifig, dgd.filenum);

% --- Executes on button press in buttonPlaySig.
function buttonPlaySig_Callback(hObject, eventdata, handles)
% hObject    handle to buttonPlaySig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
guifig = get(hObject, 'Parent');
dgd = aa_getAppDataReadOnly(guifig, 'daqguidata');
ddd = aa_getAppDataReadOnly(guifig, 'daqdisplaydata');

[dispfilenum, ok] = str2num(get(handles.editFilenum,'String'));
currchan = dgd.currChan;
exper = dgd.exper;

if(logical(ok) && dispfilenum > 0)
    %Load the data... 
    [sig, sigTimes, HWChannels, startSamp, timeCreated] = loadData(exper, dispfilenum, currchan);
    
    %Clip according to current zoom if current.
    if(ddd.currFilenum == dispfilenum)
        sn = min(ddd.startNdx, length(sig));
        en = max(1, ddd.endNdx);
        if(sn < en)
            sig = sig(sn:en);
        end
    else
        sn = 1;
        en = length(sig);
    end
    soundsc(sig, exper.desiredInSampRate);
end 

% --- Executes on button press in buttonPlayAudioSig.
function buttonPlayAudioSig_Callback(hObject, eventdata, handles)
% hObject    handle to buttonPlayAudioSig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
guifig = get(hObject, 'Parent');
dgd = aa_getAppDataReadOnly(guifig, 'daqguidata');
ddd = aa_getAppDataReadOnly(guifig, 'daqdisplaydata');

[dispfilenum, ok] = str2num(get(handles.editFilenum,'String'));
currchan = dgd.currChan;
exper = dgd.exper;

if(logical(ok) && dispfilenum > 0)
    %Load the data...
    audio = loadData(exper,dispfilenum,currchan);   
    [sig, sigTimes, HWChannels, startSamp, timeCreated] = loadData(exper, dispfilenum, currchan);
    
    %Clip according to current zoom if current.
    if(ddd.currFilenum == dispfilenum)
        sn = min(ddd.startNdx, length(audio));
        en = max(1, ddd.endNdx);
        if(sn < en)
            audio = audio(sn:en);
            sig = sig(sn:en);
        end
    else
        sn = 1;
        en = length(audio);
    end
    soundsc(audio + sig, exper.desiredInSampRate);
end 

function editSpecgramMaxPower_Callback(hObject, eventdata, handles)
% hObject    handle to editSpecgramMaxPower (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editSpecgramMaxPower as text
%        str2double(get(hObject,'String')) returns contents of editSpecgramMaxPower as a double
guifig = get(hObject, 'Parent');
daqgui_updateDisplay(guifig);

% --- Executes during object creation, after setting all properties.
function editSpecgramMaxPower_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editSpecgramMaxPower (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editSpecgramMinPower_Callback(hObject, eventdata, handles)
% hObject    handle to editSpecgramMinPower (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editSpecgramMinPower as text
%        str2double(get(hObject,'String')) returns contents of editSpecgramMinPower as a double
guifig = get(hObject, 'Parent');
daqgui_updateDisplay(guifig);

% --- Executes during object creation, after setting all properties.
function editSpecgramMinPower_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editSpecgramMinPower (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
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
set(t_restart, 'Name', 'daqguiRestartInMorning');
set(t_restart,'TimerFcn','daqgui_restartGUI(timerfind(''Name'', ''daqguiRestartInMorning''), [], findobj(''Name'', ''experAcquistionGui''))');
set(t_restart,'Period',5);
set(t_restart,'ExecutionMode','fixedDelay');
set(t_restart,'BusyMode', 'queue');

strStopHour = get(handles.editStopTime, 'String');
stopHour = str2num(strStopHour);
if(isempty(stopHour))
    uiwarn('Stop hour is invalid, Using 25 (1am)');
    stopHour = 23;
end
stopTime = floor(now) + stopHour/24;
if(stopTime < now)
    stopTime = stopTime + 1;
end
startat(t_restart, stopTime);   

function clearMorningRestartTimer()  
%delete restart timer if there is one.
if(~isempty(timerfind('Name','daqguiRestartInMorning')))
    stop(timerfind('Name','daqguiRestartInMorning'));
    delete(timerfind('Name','daqguiRestartInMorning'));
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



