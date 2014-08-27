function daqgui_timerFcnAcqTrigOnSong(obj, evnt, guifig)

%It is crucial, that this function, which accesses daq_data, does not
%interrupt the daq_bufferUpdate.  Interruptions result in crashes and
%freezes.
if(daq_isUpdating)
    return;
end

daq_log('Not updating');
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

%grab new data with 100ms overlap
daq_log('Starting Peek.');
if(abs(params.nextPeek - daq_getCurrSampNum) > params.actInSampleRate*10)
    daq_log('Falling behind skipping data for song detect');
    warning('Falling behind skipping data for song detect');
    params.nextPeek = daq_getCurrSampNum - params.actInSampleRate;
end
[data, time, sampNum] = daq_peek(round(params.nextPeek-params.actInSampleRate/10));
params.nextPeek = sampNum+length(time);
audio = data(:,1);
daq_log('Peek Completed.');

%Take specgram and measure power in each time-slice
[b,f,t] = specgram(audio, params.windowSize, params.actInSampleRate, params.windowSize, params.windowOverlap);
powerSong = mean(abs(b(params.minNdx:params.maxNdx,:)), 1);
powerNonSong = mean(abs(b([1:params.minNdx-1,params.maxNdx+1:end],:)), 1) + eps;
songRatio = powerSong./powerNonSong;
thresCross = (songRatio>params.ratioThreshold);
songDet = conv(thresCross,params.windowAvg);
maxSongScore = max(songDet);
set(handles.textSongScore, 'String', ['Song Score: ', num2str(maxSongScore)]);
if(isequal(get(handles.textSongScore, 'BackgroundColor'),[1,1,1]))
    set(handles.textSongScore, 'BackgroundColor', [1,1,.5]);
else
    set(handles.textSongScore, 'BackgroundColor', [1,1,1]);
end
daq_log('Song score computed');
bNewFile = false;
if(~daq_isRecording(dgd.exper.audioCh))
    %Since not currently recording this bird, check for song start.
    if( (maxSongScore > params.durationThreshold) )
        daq_log('Attempt start song triggered recording.');
        %If sufficient power to signify song, then begin recording
        params.songStartSampNum = sampNum;
        [filenamePrefix, recfilenum] = getNewDatafilePrefix(dgd.exper);
        dgd.recfilenum = recfilenum;
        [bStatus, params.startSamp, params.filenames] = daq_recordStart(params.songStartSampNum - params.preSamps, [dgd.exper.dir, filenamePrefix], dgd.inChans);
        if(~bStatus)
            warning('Start recording failed' );
        else
            set(handles.textRecordingStatus, 'String', ['Started recording.', num2str(dgd.recfilenum)]);
            set(handles.textRecordingStatus, 'BackgroundColor', 'red');            
            params.isRecordingSong = true;
        end
        params.stopSamp = sampNum + length(time) - 1;
        daq_log('Started song triggered recordings.');
    end
elseif(params.isRecordingSong)
    %Since already recording this bird, check for silence and file
    %getting too long.
    if( (maxSongScore > params.durationThreshold) & (sampNum - params.songStartSampNum < 500000))
        params.stopSamp = sampNum + length(time) - 1;
    end
    if( sampNum + length(audio) - 1 - params.stopSamp > params.postSamps )
        daq_log('Attempt to stop song triggered recordings.');
        songEndSampNum = sampNum + length(audio) - 1;
        [bStatus, endSamp] = daq_recordStop(songEndSampNum, dgd.inChans);
        if(~bStatus)
            warning('Song stop recording failed.');
        else
            set(handles.textRecordingStatus, 'String', ['Finished recording.', num2str(dgd.recfilenum), '.   Ready to record.']);
            set(handles.textRecordingStatus, 'BackgroundColor', 'green');            
            params.isRecordingSong = false;
        end
        dgd.filenum = dgd.recfilenum;
        bNewFile = true;
        daq_log('Stopped song triggered recordings.');
    end
end

aa_checkinAppData(guifig, 'daqguidata', dgd);
aa_checkinAppData(guifig, 'paramsTrigOnSong', params);
if(bNewFile & (get(handles.checkboxAutoDisplay,'Value') ~= 0))
    daq_log('Wait for new file to be written.');
    daq_waitForRecording(dgd.inChans);
    daqgui_updateDisplayFile(guifig, dgd.filenum);
    daq_log('Completed waiting and display.');
end
