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
function acquisitionGui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to acquisitionGui (see VARARGIN
guiFig = hObject; %in this function only.

%clear any preexisting timers
if(length(timerfind('Name','trigOnSong'))~=0)
    delete(timerfind('Name','trigOnSong'));
end
% if(length(timerfind('Name','sutterPositionTimer'))~=0)
%     delete(timerfind('Name','sutterPositionTimer'));
% end

%clear any semaphores...
aa_resetCheckouts;

guiFig.CloseRequestFcn = @(Src, EventData) acqgui_closereq(Src, EventData, guiFig);

%Initialize app data, not necessary, but useful coding practice:
aa_checkoutAppData(guiFig, 'acqguidata');
acqguidata.logfile = []; %filename
% acqguidata.sutterConnection = [];
% acqguidata.sutterStatus = [];
% acqguidata.sutterUpdateTimer = [];
acqguidata.trigOnSongTimer = []; %the timer used for song trigger.
acqguidata.bTrigOnSong = []; %array specifying which experiments are triggering on song.
acqguidata.daqSetup = {}; %one for each open exper
acqguidata.actInSampRate = 0;
acqguidata.ce = 0;
acqguidata.expers = {}; 
acqguidata.experData = []; %one struct for each exper
    %ndxOfAudioChan;  %all the channels of all the experiments have to be merged.  This is the ndx of this experiments audio in this merged list of channels.
    %inChans
    %autoUpdate
    %dddbackground - copied into ddd when exper selected.
        %dispfilenum
        %dispchanAudio
        %dispchan
        %dispchan2
        %dispchan3
        %startNdx
        %endNdx
        %lengthFile
    %songDetection
        %windowSize
        %windowOverlap
        %minFreq
        %maxFreq
        %minNdx
        %maxNdx
        %ratioThreshold
        %songDuration
        %windowLength
        %windowAvg
        %durationThreshold

aa_checkinAppData(guiFig, 'acqguidata', acqguidata);    
    
aa_checkoutAppData(guiFig, 'acqdisplaydata');
acqdisplaydata.currFilenum = 0;
acqdisplaydata.currChanAudio = 0;
acqdisplaydata.currChan = 0;
acqdisplaydata.currChan2 = 0;
acqdisplaydata.currChan3 = 0;
acqdisplaydata.startNdx = 0;
acqdisplaydata.endNdx = 0;
acqdisplaydata.lengthFile = 0;
aa_checkinAppData(guiFig, 'acqdisplaydata', acqdisplaydata);

aa_checkoutAppData(guiFig, 'acqrecordinfo');
recinfo = []; %one struct for each exper.   
    %filenum
    %recfilenum
    %bForcedRecording
    %bSongTrigRecording
    %recordingListener
    %recFileTimes %list of the times at which files were recorded since last start.
aa_checkinAppData(guiFig, 'acqrecordinfo', recinfo);

aa_checkoutAppData(guiFig, 'songtrigdata');
songtrigdata = []; %one struct for each exper.
    %nextPeek
    %songStartSampNum
    %startSamp
    %stopSamp
    %filenames
    %PeekListener
aa_checkinAppData(guiFig, 'songtrigdata', songtrigdata);

%app data that does not need be made thread safe:
threadSafeData.songTrigParams = []; % one for each exper..
        %preSecs
        %postSecs
        %maxFileLength
threadSafeData.displayParams = []; % one for each exper..
        %audioCLim
setappdata(guiFig, 'threadSafeData', threadSafeData);

% Choose default command line output for acquisitionGui
handles.output = guiFig;
guidata(guiFig, handles);

%Make handle of figure visible so that command line timer function can find
%it.
set(guiFig,'HandleVisibility','on');

%parse varargin
P.logfile = '';
P.threadSafeData = [];
P.bTrigOnSong = [];
P.expers = []; %auto load exper on start.
P.dispchanAudio = []; %array of chans for audio plot for each exper.
P.dispchan = []; %array of chans for top signal plot for each exper.
P.dispchan2 = []; %array of chans for 2nd signal plot for each exper.
P.dispchan3 = []; %array of chans for 3rd signal plot for each exper.
P.songDetection = []; %array of structs.  One for each exper.
    %songDensity = .5; aka durationThreshold
    %powerThres = 5; aka ratioThreshold
    %songLength = .6; aka songDuration
P.bRestartInMorning = false;
P.startHour = 9;
P.stopHour = 25;
P = parseargs(P, varargin{:});

%initialize properties of ui elements
set(handles.buttonTrigOnSong,'Enable','off');
set(handles.buttonRecord,'Enable','off');
set(handles.buttonTrigOnChan,'Enable','off');
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

%set the autorestart timer fields and initialize timer
set(handles.editStartTime, 'String', num2str(P.startHour));
set(handles.editStopTime, 'String',num2str(P.stopHour));
if(P.bRestartInMorning)
    set(handles.checkboxAutostart, 'Value', true);
    setMorningRestartTimer(guiFig);
end

%Done with standard start up, now loading any experiments.
%Load experiment if one was passed in
aa_checkoutAppData(guiFig, 'acqguidata');

%set up sutter connection
% [acqguidata.sutterConnection, acqguidata.sutterStatus] = sutterOpenConnection;
% acqguidata.sutterUpdateTimer = timer;
% set(acqguidata.sutterUpdateTimer,'Name', 'sutterPositionTimer');
% set(acqguidata.sutterUpdateTimer,'TimerFcn','acqgui_updateSutterPosition(timerfind(''Name'', ''sutterUpdateTimer''), [], findobj(''Name'', ''acquisitionGui''))');
% set(acqguidata.sutterUpdateTimer,'Period',10);
% set(acqguidata.sutterUpdateTimer,'ExecutionMode','fixedSpacing');
% set(acqguidata.sutterUpdateTimer,'BusyMode', 'drop');

%set up expers and log
acqguidata.expers = {}; %will be updated below.
acqguidata.logfile = P.logfile;
aa_checkinAppData(guiFig, 'acqguidata',acqguidata);  

if(~isempty(P.expers))
    for nExper = 1:length(P.expers) 
        addExperiment(guiFig, P.expers(nExper), ...
                      'songDensity', P.songDetection(nExper).songDensity, ...
                      'ratioThreshold', P.songDetection(nExper).powerThres, ...
                      'songLength', P.songDetection(nExper).songLength,...
                      'minFreq', P.songDetection(nExper).minFreq,...
                      'maxFreq', P.songDetection(nExper).maxFreq);               
    end    
    for nExper = 1:length(P.expers)
        if(P.bTrigOnSong(nExper))
           toggleTriggeringOnSong(guiFig, nExper); 
        end
    end    
end

%pass along thread safe data.
if(~isempty(P.threadSafeData))
    threadSafeData = P.threadSafeData;
    setappdata(guiFig, 'threadSafeData', P.threadSafeData);
end

function acqgui_closereq(~, ~, guiFig)
poisonPill = onCleanup(@() closereq());
semaphoreKill = onCleanup(@() aa_resetCheckouts());
daqKill = onCleanup(@() DaqBuffer.reset());
dgd = aa_getAppDataReadOnly(guiFig, 'acqguidata');
nExper = numel(dgd.expers);
for experNo = 1:nExper
    try
        closeExperiment(guiFig, experNo);
    catch ME
        %Do nothing
    end
end
try
    fclose(fopen(dgd.logfile)); % Attempt to close the log file, if it's open
catch ME
    % Do nothing
end


% --- Outputs from this function are returned to the command line.
function varargout = acquisitionGui_OutputFcn(hObject, eventdata, handles) 
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


guiFig = get(hObject,'Parent');
handles = guidata(guiFig);

dgd = aa_getAppDataReadOnly(guiFig, 'acqguidata');
if(dgd.DaqBuffer.isUpdating)
    return;
end
[recInfo, bRecStatus] = aa_checkoutAppData(guiFig, 'acqrecordinfo');
if ~bRecStatus 
    return; 
end

if ~recInfo(dgd.ce).bSongTrigRecording % no triggered recording
    if recInfo(dgd.ce).bForcedRecording % Recording already started
        ListenerHandle = addlistener(dgd.DaqBuffer, 'RecordingComplete', @(~, ~) error('lost the callback race!'));
        
        completionClosure = @(~, EventData) stop_forced_recording_callback(...
            EventData, ListenerHandle, dgd.experData(dgd.ce).inChans, recInfo, guiFig); % recInfo checked back in by callback!
        
        ListenerHandle.Callback = completionClosure;
        bStatus = dgd.DaqBuffer.stop_recording(dgd.DaqBuffer.lastSample, dgd.experData(dgd.ce).inChans);
        if ~all(bStatus)
            aa_checkinAppData(guiFig, 'acqrecordinfo', recInfo);
            error('Song stop recording failed.');
        end
    else % Recording not started
        recSampNum = dgd.DaqBuffer.lastSample + 1;
        [filenamePrefix, recfilenum] = getNewDatafilePrefix(dgd.expers{dgd.ce});
        recInfo(dgd.ce).recfilenum = recfilenum;
        
        %% Make Listener for recording
        ListenerHandle = addlistener(dgd.DaqBuffer, 'RecordingComplete', @(~, ~) error('lost the callback race!'));
        completionClosure = @(~, EventData) recording_completion_callback(...
            EventData, ListenerHandle, dgd.experData(dgd.ce).inChans, guiFig,...
            dgd.ce, recInfo(dgd.ce).recfilenum);
        ListenerHandle.Callback = completionClosure;
        [bStatus, ~] = dgd.DaqBuffer.start_recording(recSampNum, [dgd.expers{dgd.ce}.dir, filenamePrefix], dgd.experData(dgd.ce).inChans);
        if ~all(bStatus)
            delete(ListenerHandle);
            aa_checkinAppData(guiFig, 'acqrecordinfo', recInfo);
            error('Failed to start forced recording' );
        else
            set(handles.textRecordingStatus, 'String', ['Started forced recording.', num2str(recInfo(dgd.ce).recfilenum)]);
            set(handles.textRecordingStatus, 'BackgroundColor', 'cyan');
            set(handles.buttonRecord, 'String', 'Stop Recording');
            recInfo(dgd.ce).recordingListener = ListenerHandle;
            recInfo(dgd.ce).bForcedRecording = true;
        end
        aa_checkinAppData(guiFig, 'acqrecordinfo', recInfo);
    end
else
    aa_checkinAppData(guiFig, 'acqrecordinfo', recInfo);
end

function stop_forced_recording_callback(EventData, ListenerHandle, hwChannels, recInfo, guiFig)
channelsMatch = compare_channels(hwChannels, EventData.hwChannels);
if channelsMatch
    delete(ListenerHandle); %Unsubscribe
    dgd = aa_getAppDataReadOnly(guiFig, 'acqguidata');
    handles = guidata(guiFig);
    
    %% Update recInfo
    recInfo(dgd.ce).filenum = recInfo(dgd.ce).recfilenum;
    recInfo(dgd.ce).recFileTimes = [recInfo(dgd.ce).recFileTimes, now];
    recInfo(dgd.ce).bForcedRecording = false;
    
    %% Update GUI
    set(handles.textRecordingStatus, 'String', ['Finished forced recording.', num2str(recInfo(dgd.ce).recfilenum), '.   Ready to record.']);
    aa_checkinAppData(guiFig, 'acqrecordinfo', recInfo); % Check in acqrecordinfo
    set(handles.textRecordingStatus, 'BackgroundColor', 'green'); 
    set(handles.buttonRecord, 'String', 'Start Recording');
end

% --- Executes on button press in pushbutton1.
function buttonTrigOnSong_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
guifig = get(hObject,'Parent');
toggleTriggeringOnSong(guifig);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function toggleTriggeringOnSong(guiFig)
%% Try to checkout acqguidata
handles = guidata(guiFig);
[dgd, bDgdStatus] = aa_checkoutAppData(guiFig, 'acqguidata');
if ~bDgdStatus
    return;
end
experNo = dgd.ce;
%% Toggle triggering state
if dgd.bTrigOnSong(experNo) % If already triggering on song
    recInfo = aa_getAppDataReadOnly(guiFig, 'acqrecordinfo');
    if recInfo(experNo).bSongTrigRecording % In the middle of a recording
        if dgd.DaqBuffer.isUpdating
            %% Give up
            aa_checkinAppData(guiFig, 'acqguidata', dgd);            
            return
        else
            %% Create callback for when recording completes
            ListenerHandle = addlistener(dgd.DaqBuffer, 'RecordingComplete', @(~, ~) error('lost the callback race!'));
            completionClosure = @(~, EventData) disable_song_triggering_callback(...
                EventData, ListenerHandle, dgd.experData(experNo).inChans, guiFig, experNo, dgd); % Call back checks in acqguidata
            ListenerHandle.Callback = completionClosure;
        end
    else
        %% Stop triggering
        disable_song_triggering(guiFig, experNo, dgd); % Checks in acqguidata
    end
else  % If not already triggering on song
    [params, bParamStatus] = aa_checkoutAppData(guiFig, 'songtrigdata');
    if ~bParamStatus
        aa_checkinAppData(guiFig, 'acqguidata', dgd);
        return; 
    end    
    dgd.bTrigOnSong(experNo) = true;
    params(experNo).nextPeek = ceil(dgd.DaqBuffer.lastSample - dgd.actInSampRate); % Last second of the buffer
    aa_checkinAppData(guiFig, 'songtrigdata', params);

    %% start the recurring song check timer...
    if isempty(dgd.trigOnSongTimer) % Timer not created
        dgd.trigOnSongTimer = timer();
        set(dgd.trigOnSongTimer,'Name', 'trigOnSong');
        timerFcn = @(Src, EventData) acqgui_timerFcnAcqTrigOnSong(Src, EventData, guiFig);
        songTrigErrFcn = @(~, ~) song_trigger_error(guiFig, experNo);
        set(dgd.trigOnSongTimer,'TimerFcn', timerFcn, 'ErrorFcn', songTrigErrFcn);
        set(dgd.trigOnSongTimer,'Period',1);
        set(dgd.trigOnSongTimer,'ExecutionMode','fixedRate');
        set(dgd.trigOnSongTimer,'BusyMode', 'drop');
        aa_checkinAppData(guiFig, 'acqguidata', dgd);
        start(dgd.trigOnSongTimer);
    else
        aa_checkinAppData(guiFig, 'acqguidata', dgd);
    end
    set(handles.buttonTrigOnSong, 'String', 'Stop Triggering On Song');
end

function song_trigger_error(guiFig, experNo)
TRYINTERVAL = 0.1;
MAXTRIES = 200;
warning('Error during song triggering for experiment %d', experNo);
warning('Attempting to disable song triggering');
[dgd, succeeded] = aa_checkoutAppData(guiFig, 'acqguidata');
tryNo = 1;
while ~succeeded && tryNo <= MAXTRIES
    pause(TRYINTERVAL);
    [dgd, succeeded] = aa_checkoutAppData(guiFig, 'acqguidata');
end
if tryNo > MAXTRIES
    error('Could not recover from song triggering error!');
end
disable_song_triggering(guiFig, experNo, dgd);
error('Error during song triggering! Succesfully disabled triggering.');

function disable_song_triggering_callback(EventData, ListenerHandle, hwChannels, guiFig, experNo, dgd)
channelsMatch = compare_channels(hwChannels, EventData.hwChannels);
if channelsMatch
    delete(ListenerHandle); %Unsubscribe to future events
    disable_song_triggering(guiFig, experNo, dgd);
end

function disable_song_triggering(guiFig, experNo, dgd)
%% Disable song triggering
dgd.bTrigOnSong(experNo) = false;
if ~dgd.bTrigOnSong
    stop(dgd.trigOnSongTimer);
    delete(dgd.trigOnSongTimer);
    dgd.trigOnSongTimer = [];
end

%% Update gui
if experNo == dgd.ce
    handles = guidata(guiFig);
    set(handles.buttonTrigOnSong, 'String', 'Start Triggering On Song');
    set(handles.textSongScore, 'String', 'Not triggering on song.');
end

%% Check in AppData
aa_checkinAppData(guiFig, 'acqguidata', dgd);

function editSongDensity_Callback(hObject, eventdata, handles)
% hObject    handle to editSongThreshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editSongThreshold as text
%        str2double(get(hObject,'String')) returns contents of editSongThreshold as a double

%If currently triggering on song, then we have to update parameters
%directly.  If not currently triggering then no worries.

%If currently triggering on song, then we have to update parameters
%directly.  If not currently triggering then no worries.
guifig = get(hObject,'Parent');
[dgd, bDGDStatus] = aa_checkoutAppData(guifig, 'acqguidata');
if(bDGDStatus) 
    try
        dgd.experData(dgd.ce).songDetection.durationThreshold = str2num(get(handles.editSongDensity, 'String'));
        aa_checkinAppData(guifig, 'acqguidata', dgd);
    catch
        aa_checkinAppData(guifig, 'acqguidata', dgd);
    end
else
    dgd = aa_getAppDataReadOnly(guifig, 'acqguidata');
    set(handles.editSongDensity, 'String', num2str(dgd.experData(dgd.ce).songDetection.durationThreshold))
end

% --- Executes during object creation, after setting all properties.
function editSongDensity_CreateFcn(hObject, eventdata, handles)
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
guifig = get(hObject,'Parent');
[dgd, bDGDStatus] = aa_checkoutAppData(guifig, 'acqguidata');
if(bDGDStatus) 
    try
        dgd.experData(dgd.ce).songDetection.ratioThreshold = str2num(get(handles.editPowerThres, 'String'));
        aa_checkinAppData(guifig, 'acqguidata', dgd);
    catch
        aa_checkinAppData(guifig, 'acqguidata', dgd);
    end
else
    dgd = aa_getAppDataReadOnly(guifig, 'acqguidata');
    set(handles.editPowerThres, 'String', num2str(dgd.experData(dgd.ce).songDetection.ratioThreshold))
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

function editSongLength_Callback(hObject, eventdata, handles)
% hObject    handle to editSongLength (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editSongLength as text
%        str2double(get(hObject,'String')) returns contents of
%        editSongLength as a double
guifig = get(hObject,'Parent');
[dgd, bDGDStatus] = aa_checkoutAppData(guifig, 'acqguidata');
if(bDGDStatus) 
    try
        dgd.experData(dgd.ce).songDetection.songDuration = str2num(get(handles.editSongLength, 'String'));
        aa_checkinAppData(guifig, 'acqguidata', dgd);
    catch
        aa_checkinAppData(guifig, 'acqguidata', dgd);
    end
else
    dgd = aa_getAppDataReadOnly(guifig, 'acqguidata');
    set(handles.editSongLength, 'String', num2str(dgd.experData(dgd.ce).songDetection.songDuration))
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

% --- Executes on button press in buttonAntidromic.
function buttonAntidromic_Callback(hObject, eventdata, handles)
% hObject    handle to buttonAntidromic (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
guifig = get(hObject,'Parent');
dgd = aa_getAppDataReadOnly(guifig, 'acqguidata');
ddd = aa_getAppDataReadOnly(guifig, 'acqdisplaydata');
dispfilenum = ddd.currFilenum;
currchan = ddd.currChan;
exper = dgd.expers{dgd.ce};
fs = exper.desiredInSampRate;
if(dispfilenum > 0)
    [sig] = loadData(exper, dispfilenum, currchan);
    preStimMs = 10;
    postStimMs = 50;
    maxStimPeakWidthMs = 1;
    minStimSpacingSecs = .7;
    set(hObject,'String','Click on signal at threshold');
    set(hObject,'BackgroundColor','red');
    [junk, stimThreshold] = ginput(1);
    set(hObject,'String','Show aligned antidromic');
    set(hObject,'BackgroundColor',[236/255,233/255,216/255]);
    stimClips = clipStimFromSignal(sig, fs, stimThreshold, preStimMs, postStimMs, maxStimPeakWidthMs, minStimSpacingSecs);
    axes(handles.axes3);
    cla;
    title([int2str(size(stimClips,1)) ' stims on chan ' int2str(currchan)])
    if(~isempty(stimClips))
        time = linspace(-preStimMs, postStimMs, size(stimClips,2));
        plot(time, stimClips');
        xlim([-preStimMs,postStimMs]);
        ylim([-0.5,0.5]);
        set(gca, 'ButtonDownFcn', @zoomboxCallback)
    end
end

% --- Executes on button press in buttonPlayAudioSig.
function buttonPlayAudioSig_Callback(hObject, eventdata, handles)
% hObject    handle to buttonPlayAudioSig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%get the audio
axes(handles.axesAudio);
ud = get(gca,'UserData');
audio = ud.data;
fs = ud.fs;

%get the signal
axes(handles.axesSignal);
ud = get(gca,'UserData');
sig = ud.data;

range = max(max(audio), abs(min(audio)));
audio = audio/(range*3);
range = max(max(sig), abs(min(sig)));
sig = sig/(range*3);  

player = audioplayer(audio+sig, fs);
axes(handles.axesAudio);
hold on;
xl = xlim;
ylimits1 = ylim;
l1 = line([xl(1),xl(1)],ylimits1,'Color','yellow');
axes(handles.axesSignal);
hold on;
ylimits2 = ylim;
l2 = line([xl(1),xl(1)],ylimits2,'Color','red');    
play(player);
while(isplaying(player))
    currTime = xl(1) + get(player,'CurrentSample')/fs;
    set([l1,l2],'XData',[currTime, currTime]);
    drawnow;        
end
delete(l1);
delete(l2);
axes(handles.axesAudio);
hold off;
axes(handles.axesSignal);
hold off;    


% --- Executes on selection change in popupChannel.
function popupChannel_Callback(hObject, eventdata, handles)
% hObject    handle to popupChannel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = get(hObject,'String') returns popupChannel contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupChannel
guifig = get(hObject,'Parent');
[ddd, status] = aa_checkoutAppData(guifig, 'acqdisplaydata');
if(~status)
    warning('Unable to checkout ddd.');
    return;
end

value = get(handles.popupChannel,'Value');
names = get(handles.popupChannel,'String');
currName = names{value};
dash = strfind(currName, '-');
currChan = str2num(currName(1:dash(1)-1));
ddd.currChan = currChan;

aa_checkinAppData(guifig, 'acqdisplaydata', ddd);
acqgui_updateDisplay(guifig);

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

% --- Executes on selection change in popupAudio.
function popupAudio_Callback(hObject, eventdata, handles)
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
guifig = get(hObject,'Parent');
[ddd, status] = aa_checkoutAppData(guifig, 'acqdisplaydata');
if(~status)
    warning('Unable to checkout ddd.');
    return;
end

value = get(handles.popupAudio,'Value');
names = get(handles.popupAudio,'String');
currName = names{value};
dash = strfind(currName, '-');
currChan = str2num(currName(1:dash(1)-1));
ddd.currChanAudio = currChan;

aa_checkinAppData(guifig, 'acqdisplaydata', ddd);
acqgui_updateDisplay(guifig);

% --- Executes during object creation, after setting all properties.
function popupAudio_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupAudio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupChannel2.
function popupChannel2_Callback(hObject, eventdata, handles)
% hObject    handle to popupChannel2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupChannel2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupChannel2
guifig = get(hObject,'Parent');
[ddd, status] = aa_checkoutAppData(guifig, 'acqdisplaydata');
if(~status)
    warning('Unable to checkout ddd.');
    return;
end

value = get(handles.popupChannel2,'Value');
names = get(handles.popupChannel2,'String');
currName = names{value};
dash = strfind(currName, '-');
currChan = str2num(currName(1:dash(1)-1));
ddd.currChan2 = currChan;

aa_checkinAppData(guifig, 'acqdisplaydata', ddd);
acqgui_updateDisplay(guifig);

% --- Executes during object creation, after setting all properties.
function popupChannel2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupChannel2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupChannel3.
function popupChannel3_Callback(hObject, eventdata, handles)
% hObject    handle to popupChannel3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupChannel3 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupChannel3
guifig = get(hObject,'Parent');
[ddd, status] = aa_checkoutAppData(guifig, 'acqdisplaydata');
if(~status)
    warning('Unable to checkout ddd.');
    return;
end

value = get(handles.popupChannel3,'Value');
names = get(handles.popupChannel3,'String');
currName = names{value};
dash = strfind(currName, '-');
currChan = str2num(currName(1:dash(1)-1));
ddd.currChan3 = currChan;

aa_checkinAppData(guifig, 'acqdisplaydata', ddd);
acqgui_updateDisplay(guifig);

% --- Executes during object creation, after setting all properties.
function popupChannel3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupChannel3 (see GCBO)
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
[recinfo] = aa_getAppDataReadOnly(guifig, 'acqrecordinfo');
[dgd] = aa_getAppDataReadOnly(guifig, 'acqguidata');
if(~isempty(recinfo) & ~(~[recinfo(:).bForcedRecording] & ~dgd.bTrigOnSong))
    warndlg({'In order to alter the loaded experiments','all triggering and recording must be stopped'});
    uiwait;
    return;
end

dirname = uigetdir('', 'Select the root directory?');
if(dirname == 0)
    error('');
else
    exper = createExper(dirname);
    addExperiment(guifig, exper);
end

% --- Executes on button press in buttonLoadExperiment.
function buttonLoadExperiment_Callback(hObject, eventdata, handles)
% hObject    handle to buttonLoadExperiment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
guifig = get(hObject,'Parent');
[recinfo] = aa_getAppDataReadOnly(guifig, 'acqrecordinfo');
[dgd] = aa_getAppDataReadOnly(guifig, 'acqguidata');
if(~isempty(recinfo) & ~(~[recinfo(:).bForcedRecording] & ~dgd.bTrigOnSong))
    warndlg({'In order to alter the loaded experiments','all triggering and recording must be stopped'});
    uiwait;
    return;
end

[experfilename, experfilepath] = uigetfile('exper.mat', 'Choose an experiment file:');
if(~isequal(experfilename, 0))
    load([experfilepath,filesep,experfilename]);%Loads exper struct into namespace
    %Code for checking if exper has been moved
    if ~strcmp(exper.dir, experfilepath) %directory has been moved
        exper.dir = experfilepath;
    end
    addExperiment(guifig, exper);
end

% --- Executes on button press in buttonCloseExper.
function buttonCloseExper_Callback(hObject, eventdata, handles)
% hObject    handle to buttonCloseExper (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
guifig = get(hObject,'Parent');
[recinfo] = aa_getAppDataReadOnly(guifig, 'acqrecordinfo');
[dgd] = aa_getAppDataReadOnly(guifig, 'acqguidata');
if(~isempty(recinfo) & ~(~[recinfo(:).bForcedRecording] & ~dgd.bTrigOnSong))
    warndlg({'In order to alter the loaded experiments','all triggering and recording must be stopped'});
    uiwait;
    return;
end
if(length(dgd.expers) > 0)
    closeExperiment(guifig, dgd.ce);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function addExperiment(guifig, exper, varargin)

%Default parameters...
P.minFreq = 2000;
P.maxFreq = 6000;
P.songDensity = .5; %aka durationThreshold
P.ratioThreshold = 2; %aka powerThreshold
P.songLength = 1; %aka songDuration
P = parseargs(P, varargin{:});

%check out everything we need.
handles = guidata(guifig);
tsd = getappdata(guifig, 'threadSafeData');
[dgd,status] = aa_checkoutAppData(guifig, 'acqguidata');
if(~status) 
    disp('Failed to checkout data necessary to add experiment');
    return; 
end
[ddd, status] = aa_checkoutAppData(guifig, 'acqdisplaydata');
if(~status)
    disp('Failed to checkout data necessary to add experiment');
    aa_checkinAppData(guifig, 'acqguidata', dgd); return; 
end
[recinfo, status] = aa_checkoutAppData(guifig, 'acqrecordinfo');
if(~status)
    disp('Failed to checkout data necessary to add experiment');
    aa_checkinAppData(guifig, 'acqguidata', dgd); aa_checkinAppData(guifig, 'acqdisplaydata', ddd); return; 
end
[params, status] = aa_checkoutAppData(guifig, 'songtrigdata');
if(~status)
    disp('Failed to checkout data necessary to add experiment');
    aa_checkinAppData(guifig, 'acqguidata', dgd); aa_checkinAppData(guifig, 'acqdisplaydata', ddd); aa_checkinAppData(guifig, 'acqrecordinfo', recinfo); return; 
end    

%Verify that the experiments do not overlap channels:
desiredInSampRate = exper.desiredInSampRate;
inChans = [exper.audioCh, exper.sigCh];
allChannels = [];
for nExper = 1:length(dgd.expers)
    if(desiredInSampRate ~= dgd.expers{nExper}.desiredInSampRate)
        warndlg({'The experiment does not have the same sampling rate as those already open.  Experiment was not opened'});
        uiwait;
        aa_checkinAppData(guifig, 'acqguidata', dgd);
        aa_checkinAppData(guifig, 'acqdisplaydata', ddd);
        aa_checkinAppData(guifig, 'acqrecordinfo', recinfo);
        aa_checkinAppData(guifig, 'songtrigdata', params);
        return;
    end
    if(~isempty(intersect(inChans, dgd.experData(nExper).inChans)))
        warndlg({'The channels specified in the experiment are already in use.  Experiment was not opened.'});
        uiwait;
        aa_checkinAppData(guifig, 'acqguidata', dgd);
        aa_checkinAppData(guifig, 'acqdisplaydata', ddd);
        aa_checkinAppData(guifig, 'acqrecordinfo', recinfo);
        aa_checkinAppData(guifig, 'songtrigdata', params);        
        return;
    end
    allChannels = [allChannels, dgd.experData(nExper).inChans]; %#ok<AGROW>
end
ndxOfAudioChan = length(allChannels) + 1;
allChannels = [allChannels, inChans];

%Add exper to data structures...
experNdx = length(dgd.expers) + 1;
dgd.expers{experNdx} = exper;
dgd.bTrigOnSong(experNdx) = false;
dgd.experData(experNdx).ndxOfAudioChan = ndxOfAudioChan;
dgd.experData(experNdx).inChans = inChans;
dgd.experData(experNdx).autoUpdate = true;
%Display Data
dgd.experData(experNdx).dddbackground.dispfilenum = getLatestDatafileNumber(dgd.expers{experNdx});
dgd.experData(experNdx).dddbackground.dispchanAudio = inChans(1);
dgd.experData(experNdx).dddbackground.dispchan = inChans(min(length(inChans),2));
dgd.experData(experNdx).dddbackground.dispchan2 = inChans(min(length(inChans),3));
dgd.experData(experNdx).dddbackground.dispchan3 = inChans(min(length(inChans),4));
dgd.experData(experNdx).dddbackground.startNdx = 0;
dgd.experData(experNdx).dddbackground.endNdx = 0;
dgd.experData(experNdx).dddbackground.lengthFile = 0;
%record info
recinfo(experNdx).filenum = getLatestDatafileNumber(dgd.expers{experNdx});
recinfo(experNdx).recfilenum = -1;
recinfo(experNdx).bForcedRecording = false;
recinfo(experNdx).bSongTrigRecording = false;
recinfo(experNdx).recordingListener = [];
recinfo(experNdx).recFileTimes = [];
%song trig info
params(experNdx).nextPeek = 0;
%Song Trigger Default Parameters
minFreq = 2000; %parameterize
maxFreq = 6000; %parameterize
ratioThreshold = 2; %unitless. set based on sig to noise of mic.
songDuration = .6; %in seconds
durationThreshold = .3; %fraction of duration that must exceed ratio threshold (0-1).
%Parameters for part 1.  Song Trigger Spectrogram Parameters
songDetection.windowSize = fix(desiredInSampRate/20);
songDetection.windowOverlap = fix(songDetection.windowSize*.5);
%Parameters for Part 2.  Frequency range in which songs typically has power, and power threshold.
songDetection.minFreq = P.minFreq; 
songDetection.maxFreq = P.maxFreq;
songDetection.minNdx = floor((songDetection.windowSize/desiredInSampRate)*songDetection.minFreq + 1);
songDetection.maxNdx = ceil((songDetection.windowSize/desiredInSampRate)*songDetection.maxFreq + 1);
songDetection.ratioThreshold = P.ratioThreshold;
%Parameters for part 3
songDetection.songDuration = P.songLength;
songDetection.windowLength = round((desiredInSampRate * songDetection.songDuration) / (songDetection.windowSize-songDetection.windowOverlap)); 
if(songDetection.windowLength <= 0 || songDetection.windowLength == Inf)
    songDetection.windowLength = 1;
end
songDetection.windowAvg = repmat(1/songDetection.windowLength,1,songDetection.windowLength);
songDetection.durationThreshold = P.songDensity;
dgd.experData(experNdx).songDetection = songDetection;

%Thread safe data
tsd.songTrigParams(experNdx).preSecs = 1;
tsd.songTrigParams(experNdx).postSecs = 0; 
tsd.songTrigParams(experNdx).maxFileLength = 30;
tsd.displayParams(experNdx).audioCLim = [];

%UPDATE THE EXPER POPUP
if(length(dgd.expers) == 1)
    experStrings{experNdx} = [exper.birdname, ':' exper.expername];
    set(handles.popupExperiments, 'String', experStrings);
    set(handles.popupExperiments, 'Value', 1);
else
    experStrings = get(handles.popupExperiments, 'String');
    experStrings{experNdx} = [exper.birdname, ':' exper.expername];
    set(handles.popupExperiments, 'String', experStrings);
end

%START THE DAQ
%reset
DaqBuffer.reset();
if(isempty(timerfind('Name','trigOnSong')))
    delete(timerfind('Name','trigOnSong'));
end
%parameters
buffer = 15; %Seconds %parameterize
updateFreq = 4; %Hz %parameterize
dgd.DaqBuffer = DaqBuffer.get_instance(allChannels, desiredInSampRate, buffer, updateFreq);
LOGFILE = 'daq_log.txt';
dgd.DaqBuffer.logFID = fopen(LOGFILE, 'w');
dgd.logfile = LOGFILE;
daqSetup.actInSampleRate = dgd.DaqBuffer.samplingRate;
daqSetup.actOutSampleRate = nan;
daqSetup.buffer = buffer;
daqSetup.actUpdateFreq = dgd.DaqBuffer.updateFreq;
save([exper.dir,'daqSetup', datestr(now,30), '.mat'], 'daqSetup');
dgd.actInSampRate = dgd.DaqBuffer.samplingRate;
dgd.daqSetup{experNdx} = daqSetup;
%Start data acquisition
dgd.DaqBuffer.start();
set(handles.textRecordingStatus, 'String', 'Ready to record');
set(handles.textRecordingStatus, 'BackgroundColor', 'green');

set(handles.buttonTrigOnSong,'Enable','on');
set(handles.buttonRecord,'Enable','on');
set(handles.buttonTrigOnChan,'Enable','on');

setappdata(guifig,'threadSafeData',tsd);
aa_checkinAppData(guifig, 'acqguidata', dgd);
aa_checkinAppData(guifig, 'acqdisplaydata', ddd);
aa_checkinAppData(guifig, 'acqrecordinfo', recinfo);
aa_checkinAppData(guifig, 'songtrigdata', params);

%call updateExper
updateCurrentExperiment(guifig, experNdx)

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


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function closeExperiment(guifig, experNdx)
%check out everything we need.
handles = guidata(guifig);
[dgd,status] = aa_checkoutAppData(guifig, 'acqguidata');
if(~status) 
    disp('Failed to checkout data necessary to add experiment');
    return; 
end
[ddd, status] = aa_checkoutAppData(guifig, 'acqdisplaydata');
if(~status)
    disp('Failed to checkout data necessary to add experiment');
    aa_checkinAppData(guifig, 'acqguidata', dgd); return; 
end
[recinfo, status] = aa_checkoutAppData(guifig, 'acqrecordinfo');
if(~status)
    disp('Failed to checkout data necessary to add experiment');
    aa_checkinAppData(guifig, 'acqguidata', dgd); aa_checkinAppData(guifig, 'acqdisplaydata', ddd); return; 
end
[params, status] = aa_checkoutAppData(guifig, 'songtrigdata');
if(~status)
    disp('Failed to checkout data necessary to add experiment');
    aa_checkinAppData(guifig, 'acqguidata', dgd); aa_checkinAppData(guifig, 'acqdisplaydata', ddd); aa_checkinAppData(guifig, 'acqrecordinfo', recinfo); return; 
end  

%determine remaining channels
desiredInSampRate = dgd.expers{experNdx}.desiredInSampRate;
allChannels = [];
for nExper = 1:length(dgd.expers)
    if(nExper ~= experNdx)
        dgd.experData(nExper).ndxOfAudioChan = length(allChannels) + 1;
        allChannels = [allChannels, dgd.experData(nExper).inChans]; %#ok<AGROW>
    end
end

%Remove exper from data structures...
dgd.expers = dgd.expers([1:experNdx-1,experNdx+1:length(dgd.expers)]);
dgd.bTrigOnSong(experNdx) = [];
dgd.daqSetup = dgd.daqSetup([1:(experNdx - 1), (experNdx + 1):length(dgd.daqSetup)]);
dgd.experData(experNdx) = [];
recinfo(experNdx) = [];
params(experNdx) = [];

%UPDATE THE EXPER POPUP
if isempty(dgd.expers)
    experStrings{experNdx} = '';
    set(handles.popupExperiments, 'String', experStrings);
    set(handles.popupExperiments, 'Value', 1);
    DaqBuffer.reset();
    dgd.ce = 0;
    cla(handles.axesAudio);
    cla(handles.axesSignal);
    
    set(handles.buttonTrigOnSong,'Enable','off');
    set(handles.buttonRecord,'Enable','off');
    set(handles.buttonTrigOnChan,'Enable','off');
    
    aa_checkinAppData(guifig, 'acqguidata', dgd);
    aa_checkinAppData(guifig, 'acqdisplaydata', ddd);
    aa_checkinAppData(guifig, 'acqrecordinfo', recinfo);
    aa_checkinAppData(guifig, 'songtrigdata', params);    
else
    experStrings = get(handles.popupExperiments, 'String');
    experStrings = experStrings([1:experNdx-1,experNdx+1:length(experStrings)]);
    set(handles.popupExperiments, 'String', experStrings);
    set(handles.popupExperiments, 'Value', 1);
    dgd.ce = 1;
    %reset 
    delete(dgd.DaqBuffer);
    if(isempty(timerfind('Name','trigOnSong')))
        delete(timerfind('Name','trigOnSong'));
    end
    %parameters
    buffer= 90; %Seconds %parameterize
    updateFreq = 4; %Hz %parameterize
    dgd.DaqBuffer = DaqBuffer.get_instance(allChannels, desiredInSampRate, buffer, updateFreq);
    daqSetup.actInSampleRate = dgd.DaqBuffer.samplingRate;
    daqSetup.actOutSampleRate = nan;
    daqSetup.buffer = buffer;
    daqSetup.actUpdateFreq = dgd.DaqBuffer.updateFreq;
    dgd.actInSampRate = dgd.DaqBuffer.samplingRate;

    %Start data acquisition
    dgd.DaqBuffer.start();
    set(handles.textRecordingStatus, 'String', 'Buffering');
    set(handles.textRecordingStatus, 'BackgroundColor', 'yellow');
    pause(7); %uiwait(guifig,7);
    set(handles.textRecordingStatus, 'String', 'Ready to record');
    set(handles.textRecordingStatus, 'BackgroundColor', 'green');

    set(handles.buttonTrigOnSong,'Enable','on');
    set(handles.buttonRecord,'Enable','on');
    set(handles.buttonTrigOnChan,'Enable','on');

    aa_checkinAppData(guifig, 'acqguidata', dgd);
    aa_checkinAppData(guifig, 'acqdisplaydata', ddd);
    aa_checkinAppData(guifig, 'acqrecordinfo', recinfo);
    aa_checkinAppData(guifig, 'songtrigdata', params);
    
    %call updateExper
    updateCurrentExperiment(guifig, 1, true)
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
updateCurrentExperiment(guifig, newExper);
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function updateCurrentExperiment(guifig, experNdx, bDeleted)
%check out everything we need.
handles = guidata(guifig);
[dgd,status] = aa_checkoutAppData(guifig, 'acqguidata');
if(~status) 
    disp('Failed to checkout data necessary to add experiment');
    return; 
end
[ddd, status] = aa_checkoutAppData(guifig, 'acqdisplaydata');
if(~status)
    disp('Failed to checkout data necessary to add experiment');
    aa_checkinAppData(guifig, 'acqguidata'); return; 
end
recinfo = aa_getAppDataReadOnly(guifig, 'acqrecordinfo'); 

if(~exist('bDeleted'))
    bDeleted = false;
end

%save current display in backround structure
if(dgd.ce > 0 & ~bDeleted) %In case the experiment is the first one opened...
    dgd.experData(dgd.ce).dddbackground.dispfilenum = ddd.currFilenum;
    dgd.experData(dgd.ce).dddbackground.dispchanAudio = ddd.currChanAudio;
    dgd.experData(dgd.ce).dddbackground.dispchan = ddd.currChan;
    dgd.experData(dgd.ce).dddbackground.dispchan2 = ddd.currChan2;
    dgd.experData(dgd.ce).dddbackground.dispchan3 = ddd.currChan3;
    dgd.experData(dgd.ce).dddbackground.startNdx = ddd.startNdx;
    dgd.experData(dgd.ce).dddbackground.endNdx = ddd.endNdx;
    dgd.experData(dgd.ce).dddbackground.lengthFile = ddd.lengthFile;
end

%update the experiment
dgd.ce = experNdx;
set(handles.popupExperiments, 'Value', dgd.ce); 

%load new display data

ddd.currFilenum = dgd.experData(dgd.ce).dddbackground.dispfilenum;
ddd.currChanAudio = dgd.experData(dgd.ce).dddbackground.dispchanAudio;
ddd.currChan = dgd.experData(dgd.ce).dddbackground.dispchan;
ddd.currChan2 = dgd.experData(dgd.ce).dddbackground.dispchan2;
ddd.currChan3 = dgd.experData(dgd.ce).dddbackground.dispchan3;
ddd.startNdx = dgd.experData(dgd.ce).dddbackground.startNdx;
ddd.endNdx = dgd.experData(dgd.ce).dddbackground.endNdx;
ddd.lengthFile = dgd.experData(dgd.ce).dddbackground.lengthFile;

%set exper text display:
set(handles.experInfo,'String',[dgd.expers{dgd.ce}.birdname,' ',dgd.expers{dgd.ce}.expername]);

%Set up channel popups
chanstrings{1} = [num2str(dgd.expers{dgd.ce}.audioCh), '- audio'];
for(nChan = 0:length(dgd.expers{dgd.ce}.sigCh))
    if(nChan == 0)
        chanstrings{1} = [num2str(dgd.expers{dgd.ce}.audioCh), '- audio'];
    else
        chanstrings{nChan+1} = [num2str(dgd.expers{dgd.ce}.sigCh(nChan)),'-hardwareChan']; %#ok<AGROW>
    end
    dash = strfind(chanstrings{nChan+1}, '-');
    chan = str2double(chanstrings{nChan+1}(1:dash(1)-1));
    if(chan == ddd.currChan)
        channdx = nChan+1;
    end
    if(chan == ddd.currChanAudio)
        channdxAudio = nChan+1;
    end
    if(chan == ddd.currChan2)
        channdx2 = nChan+1;
    end   
    if(chan == ddd.currChan3)
        channdx3 = nChan+1;
    end       
end
set(handles.popupAudio,'String', chanstrings);
set(handles.popupAudio,'Value',channdxAudio);
set(handles.popupChannel,'String', chanstrings);
set(handles.popupChannel,'Value',channdx);
set(handles.popupChannel2,'String', chanstrings);
set(handles.popupChannel2,'Value',channdx2);
set(handles.popupChannel3,'String', chanstrings);
set(handles.popupChannel3,'Value',channdx3);


%Set various stuff
set(handles.editSongDensity, 'String', num2str(dgd.experData(dgd.ce).songDetection.durationThreshold));
set(handles.editPowerThres, 'String', num2str(dgd.experData(dgd.ce).songDetection.ratioThreshold));
set(handles.editSongLength, 'String', num2str(dgd.experData(dgd.ce).songDetection.songDuration));
set(handles.checkboxAutoDisplay, 'Value', dgd.experData(dgd.ce).autoUpdate);
set(handles.editFilenum, 'String', num2str(ddd.currFilenum));

%set recording colors and values...
if(dgd.bTrigOnSong(dgd.ce))
    set(handles.buttonTrigOnSong, 'String', 'Stop Triggering On Song');
else
    set(handles.buttonTrigOnSong, 'String', 'Start Triggering On Song');
end
if(recinfo(dgd.ce).bForcedRecording)
    set(handles.textRecordingStatus, 'String', ['Started forced recording.', num2str(recinfo(dgd.ce).recfilenum)]);
    set(handles.textRecordingStatus, 'BackgroundColor', 'cyan');
    set(handles.buttonRecord, 'String', 'Stop Recording');
elseif(recinfo(dgd.ce).bSongTrigRecording)
    set(handles.textRecordingStatus, 'String', ['Started song recording.', num2str(recinfo(dgd.ce).recfilenum)]);
    set(handles.textRecordingStatus, 'BackgroundColor', 'red');
    set(handles.buttonRecord, 'String', 'Stop Recording');    
else
    set(handles.textRecordingStatus, 'String', ['Finished recording.', num2str(recinfo(dgd.ce).filenum), '.   Ready to record.']);
    set(handles.textRecordingStatus, 'BackgroundColor', 'green');     
    set(handles.buttonRecord, 'String', 'Start Recording')  
end

% update specgram
aa_checkinAppData(guifig, 'acqguidata',dgd);
aa_checkinAppData(guifig, 'acqdisplaydata',ddd);
acqgui_updateDisplay(guifig);


% --- Executes on button press in buttonTrigOnChan.
function buttonTrigOnChan_Callback(hObject, eventdata, handles)
% hObject    handle to buttonTrigOnChan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

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
    acqgui_updateDisplayFile(guifig, dispfilenum);
end

% --- Executes on button press in buttonPrevFile.
function buttonPrevFile_Callback(hObject, eventdata, handles)
% hObject    handle to buttonPrevFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
guifig = get(hObject,'Parent');
[dispfilenum, ok] = str2num(get(handles.editFilenum,'String'));
dispfilenum = dispfilenum - 1;
acqgui_updateDisplayFile(guifig, dispfilenum);

% --- Executes on button press in buttonNextFile.
function buttonNextFile_Callback(hObject, eventdata, handles)
% hObject    handle to buttonNextFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
guifig = get(hObject,'Parent');
[dispfilenum, ok] = str2num(get(handles.editFilenum,'String'));
dispfilenum = dispfilenum + 1;
acqgui_updateDisplayFile(guifig, dispfilenum);


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
stopHour = str2num(strStopHour);
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
    if(bStatus1 & bStatus2 & bStatus3)
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
    if(bStatus1 & bStatus2)
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
[stepSize status] = str2num(answer{1});
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
if(~isempty(recinfo) & ~(~[recinfo(:).bForcedRecording] & ~dgd.bTrigOnSong))
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


