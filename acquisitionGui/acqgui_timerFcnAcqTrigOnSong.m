function acqgui_timerFcnAcqTrigOnSong(~, ~, guiFig)
%It is crucial, that this function, which accesses daq_data, does not
%interrupt the daq_bufferUpdate.  Interruptions result in crashes and
%freezes.

dgd = aa_getAppDataReadOnly(guiFig, 'acqguidata');
dgd.DaqBuffer.log('Entered song triggering timer');
%% Check if DaqBuffer is busy, requeue or quit if it is
if dgd.DaqBuffer.isPeeking || dgd.DaqBuffer.isUpdating
    if dgd.DaqBuffer.isPeeking
        dgd.DaqBuffer.log('Peek already occurring, exiting song trigger timer');
    else
        dgd.DaqBuffer.log('DaqBuffer is updating, registering listener for UpdateComplete...');
        NewListenerHandle = addlistener(dgd.DaqBuffer, 'UpdateComplete', @(~, ~) error('lost the callback race!'));
        peekClosure = @(~, ~) queue_peek(guiFig);
        NewListenerHandle.Callback = peekClosure;
    end
else
    queue_peek(guiFig);
end
end

function queue_peek(guiFig)
%% Get relevant information structures from guiFig
handles = guidata(guiFig);
dgd = aa_getAppDataReadOnly(guiFig, 'acqguidata');
dgd.DaqBuffer.log('Entered song triggering timer');
%% Checkout recording info
[recInfo, success] = aa_checkoutAppData(guiFig, 'acqrecordinfo');
if ~success
    dgd.DaqBuffer.log('Could not check out acqrecordinfo');
    return;
end

%% Checkout triggering data
[params, success] = aa_checkoutAppData(guiFig, 'songtrigdata');
if ~success
    dgd.DaqBuffer.log('Could not check out songtrigdata');
    aa_checkinAppData(guiFig, 'acqrecordinfo', recInfo);
    return;
end

dgd.DaqBuffer.log('Checked out all app data');

%% Toggle songscore background color for "heartbeat" effect
if isequal(get(handles.textSongScore, 'BackgroundColor'), [1, 1, 1])
    set(handles.textSongScore, 'BackgroundColor', [1, 1, .5]);
else
    set(handles.textSongScore, 'BackgroundColor', [1, 1, 1]);
end

%% Choose nextPeek to satisfy the peek asking for the most data
nextPeek = min([params(logical(dgd.bTrigOnSong)).nextPeek]); 
dgd.DaqBuffer.log(sprintf('Next peek set to %d', nextPeek));

%% Check that we're not falling behind in the buffer
if dgd.DaqBuffer.lastSample - nextPeek > dgd.actInSampRate * 10 % If the peek is more than 10 seconds ago
    beep;
    dgd.DaqBuffer.log('Falling behind on song monitoring. Skipping data for song detect.');
    warning('Falling behind on song monitoring. Skipping data for song detect.');
    nextPeek = dgd.DaqBuffer.lastSample - dgd.actInSampRate; % Last second of the buffer
end

%% Find the triggered experiments
triggeredExperIdxs = find(dgd.bTrigOnSong);
nTriggedExpers = numel(triggeredExperIdxs);
micHwChans = nan(nTriggedExpers, 1);
%% Determine which channels we should peek at
for trigExperNo = 1:nTriggedExpers
    experIdx = triggeredExperIdxs(trigExperNo);
    micIdx = dgd.experData(experIdx).ndxOfAudioChan;
    micHwChans(trigExperNo) = dgd.experData(experIdx).inChans(micIdx);
end
dgd.DaqBuffer.log(sprintf('Requesting peek for microphone channels %s', mat2str(micHwChans)));

%% grab new data with 100ms overlap
peekStartSample = round(nextPeek - dgd.actInSampRate / 10); % 1/10 of a second behind 'nextPeek'

%% Register peek listener
ListenerHandle = addlistener(dgd.DaqBuffer, 'PeekAvailable', @(~, ~) error('lost the callback race!'));
peekClosure = @(~, EventData) analyze_peek(...
    EventData, guiFig, ListenerHandle, recInfo, params, peekStartSample); % Call back checks in recInfo and params
ListenerHandle.Callback = peekClosure;
%% Request peek
dgd.DaqBuffer.request_peek(micHwChans, peekStartSample);
end

function analyze_peek(EventData, guiFig, ListenerHandle, recInfo, params, peekStartSample)
delete(ListenerHandle); % Unsubscribe from peek notifications
dgd = aa_getAppDataReadOnly(guiFig, 'acqguidata');

%% Check if daq_bufferUpdate is running
if dgd.DaqBuffer.isUpdating
    warning('Peek callback occurred while DaqBuffer is updating! Attempting to requeue!');
    %% Attempt to requeue with UpdatingComplete event
    NewListenerHandle = addlistener(dgd.DaqBuffer, 'UpdateComplete', @(~, ~) error('lost the callback race!'));
    peekClosure = @(~, ~) analyze_peek(...
        EventData, guiFig, NewListenerHandle, recInfo, params, peekStartSample); % Call back checks in recInfo and params
    NewListenerHandle.Callback = peekClosure;
    return;
end
dgd.DaqBuffer.log('Successfully entered peek callback');
tsd = getappdata(guiFig, 'threadSafeData');
handles = guidata(guiFig);

%% Find the triggered experiments
triggeredExperIdxs = find(dgd.bTrigOnSong);
nTriggedExpers = numel(triggeredExperIdxs);

%% Set next peek to be the same number of points in the future
nSampsThisPeek = numel(EventData.timeStamps);
peekStopSample = peekStartSample + nSampsThisPeek - 1;
for experIdx = triggeredExperIdxs
    params(experIdx).nextPeek = peekStartSample + nSampsThisPeek;
end

%% Update GUI song score
if ~dgd.bTrigOnSong(dgd.ce) % If current experiment is not triggering on song
    set(handles.textSongScore, 'String', 'Song Score: --');
end
peekData = EventData.data;

nExper = numel(length(dgd.expers));
recordingsStarted = false(nExper, 1);
recordingsComplete = false(nExper, 1);
recordingStartSamples = nan(nExper, 1);

%% Loop through all triggering experiments
dgd.DaqBuffer.log(sprintf('\tAnalyzing peek data'));
for trigExperNo = 1:nTriggedExpers
    experIdx = triggeredExperIdxs(trigExperNo);
    
    %% Convenience variables
    fs = dgd.actInSampRate;
    sDctParams = dgd.experData(experIdx).songDetection;
    sTrigParams = tsd.songTrigParams(experIdx);
    
    %% Take specgram and measure in-band vs. out-band power in each time-slice
    [s, ~, t] = spectrogram(peekData(:, trigExperNo), sDctParams.windowSize, sDctParams.windowOverlap, sDctParams.windowSize, fs);
    powerSong = mean(abs(s(sDctParams.minNdx:sDctParams.maxNdx, :)), 1);
    powerNonSong = mean(abs(s([1:(sDctParams.minNdx - 1), (sDctParams.maxNdx + 1):end], :)), 1) + eps;
    songPowerRatio = powerSong ./ powerNonSong;
    
    %% Smooth song power ratio
    threshCross = songPowerRatio > sDctParams.ratioThreshold; % Cast into double for convolution
    smoothThreshCross = conv(double(threshCross), sDctParams.windowAvg);
    maxSongScore = max(smoothThreshCross);
    
    %% Update GUI with song score
    if experIdx == dgd.ce
        set(handles.textSongScore, 'String', ['Song Score: ', num2str(maxSongScore)]);
    end
    
    %% Check if already recording
    if ~recInfo(experIdx).bSongTrigRecording && ~recInfo(experIdx).bForcedRecording % if not already recording
        %Since not currently recording this bird, check for song start.
        
        %% See if recording contains section usually over power-ratio threshold
        if maxSongScore > sDctParams.durationThreshold % Usually above threshold
            dgd.DaqBuffer.log(sprintf('\tExperiment %d will be triggered based on song', experIdx));
            %If sufficient power to signify song, then begin recording
            
            %% Calculate sample number when power-ratio is first above threshold
            firstCrossTime = t(find(threshCross, 1, 'first')); % First time song power ratio crosses threshold
            firstCrossSampFromPeek = floor(firstCrossTime * dgd.actInSampRate) + 1;
            params(experIdx).songStartSampNum = peekStartSample + firstCrossSampFromPeek;
            recStartSample = params(experIdx).songStartSampNum - round(sTrigParams.preSecs * fs); % Include time before this sample
            dgd.DaqBuffer.log(sprintf('\tRequesting recording from sample %d', recStartSample));
            %% Recording variables
            [filenamePrefix, recfilenum] = getNewDatafilePrefix(dgd.expers{experIdx});
            recInfo(experIdx).recfilenum = recfilenum;
            recBaseFileName = [dgd.expers{experIdx}.dir, filenamePrefix];
            
            [bStatus, params(experIdx).filenames] = ...
                dgd.DaqBuffer.start_recording(recStartSample, recBaseFileName, dgd.experData(experIdx).inChans);
            params(experIdx).startSamp = recStartSample;
            
            %% Check that we succesffuly started recording
            if ~all(bStatus)
                beep;
                warning('Failed to start triggered recording'); %#ok<WNTAG>
            else
                dgd.DaqBuffer.log(sprintf('\tSuccessfully requested recording'));
                if experIdx == dgd.ce
                    set(handles.textRecordingStatus, 'String', ['Started recording.', num2str(recInfo(experIdx).recfilenum)]);
                    set(handles.textRecordingStatus, 'BackgroundColor', 'red');
                end
                recInfo(experIdx).bSongTrigRecording = true;
                recordingsStarted(experIdx) = true;
            end
            params(experIdx).stopSamp = peekStopSample; % Set the stop sample to be at the end of this peek
        end
    elseif recInfo(experIdx).bSongTrigRecording % triggered recording already started
        dgd.DaqBuffer.log(sprintf('\tExperiment %d is already triggered based on song', experIdx));
        %Since already recording this bird, check for silence and file
        %getting too long.
        if maxSongScore > sDctParams.durationThreshold && ... % Still have song
                peekStartSample - params(experIdx).songStartSampNum < round(sTrigParams.maxFileLength * fs) % And the file is within limits
            %% Extend recording
            params(experIdx).stopSamp = peekStopSample; % Extend time of last song detection
            dgd.DaqBuffer.log(sprintf('\tExtending recording based on song...'));
        end
        
        if peekStopSample - params(experIdx).stopSamp > round(sTrigParams.postSecs * fs) % Enough peeks have elapsed since song was last detected
            dgd.DaqBuffer.log(sprintf('\tAttempting to stop recording'));
            %% Stop recording
            bStatus = dgd.DaqBuffer.stop_recording(peekStopSample, dgd.experData(experIdx).inChans);
            if(~bStatus)
                beep;
                warning('Song stop recording failed.'); %#ok<WNTAG>
            else                        
                recordingsComplete(experIdx) = true;
            end    
        end
    end
end
if any(recordingsStarted)
    dgd.DaqBuffer.log('Registering listeners for new recordings');
    recChans = [dgd.experData(recordingsStarted).inChans];
    recExperIdxs = find(recordingsStarted);
    recFileNums = [recInfo(recordingsStarted).recfilenum];
    ListenerHandle = addlistener(dgd.DaqBuffer, 'RecordingComplete', @(~, ~) error('lost the callback race!'));
    completionClosure = @(~, EventData) recording_completion_callback(...
        EventData, ListenerHandle, recChans, guiFig,...
        recExperIdxs, recFileNums);
    ListenerHandle.Callback = completionClosure;
end
if any(recordingsComplete)
    dgd.DaqBuffer.log('Registering listeners to stop recordings');
    finishedChans = [dgd.experData(recordingsComplete).inChans];
    finishedExperIdxs = find(recordingsComplete);
    ListenerHandle = addlistener(dgd.DaqBuffer, 'RecordingComplete', @(~, ~) error('lost the callback race!'));
    completionClosure = @(~, EventData) stop_triggered_rec_callback(...
        EventData, ListenerHandle, finishedChans, recInfo, guiFig,...
        finishedExperIdxs); % Callback will check in acqrecordinfo
    ListenerHandle.Callback = completionClosure;
else
    aa_checkinAppData(guiFig, 'acqrecordinfo', recInfo);
end
%moved to before checkin to make sure that new recording can't begin
%while we wait for recording to complete.

setappdata(guiFig, 'threadSafeData', tsd);

aa_checkinAppData(guiFig, 'songtrigdata', params);
dgd.DaqBuffer.log('Exiting peek callback');
end

function stop_triggered_rec_callback(EventData, ListenerHandle, hwChannels, recInfo, guiFig, experIdxs)
%% See if these are the channels we are looking for
channelsMatch = compare_channels(hwChannels, EventData.hwChannels);
if channelsMatch
    delete(ListenerHandle);
    handles = guidata(guiFig);
    %% Update recInfo
    nExper = numel(experIdxs);
    for experNo = 1:nExper
        experIdx = experIdxs(experNo);
        recInfo(experIdx).bSongTrigRecording = false; 
        recInfo(experIdx).filenum = recInfo(experIdx).recfilenum;
        recInfo(experIdx).recFileTimes = [recInfo(experIdx).recFileTimes, now()];
    end
        %% Update GUI
    dgd = aa_getAppDataReadOnly(guiFig, 'acqguidata');
    if any(experIdxs == dgd.ce)
        set(handles.textRecordingStatus, 'String', ...
            ['Finished recording.', num2str(recInfo(dgd.ce).recfilenum), '.   Ready to record.']);
        set(handles.textRecordingStatus, 'BackgroundColor', 'green');            
    end
    aa_checkinAppData(guiFig, 'acqrecordinfo', recInfo);
end
end
