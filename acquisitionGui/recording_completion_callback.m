function recording_completion_callback(EventData, ListenerHandle, hwChannels, guiFig, experIdxs, recFileNums)
%% See if these are the channels we are looking for
channelsMatch = compare_channels(hwChannels, EventData.hwChannels);

%% Respond to event if all channels match
if channelsMatch
    %% These are the channels we are looking for!
    delete(ListenerHandle); % Un-subcribe to future events
    dgd = aa_getAppDataReadOnly(guiFig, 'acqguidata');
    
    %% Update displayed file
    if any(experIdxs == dgd.ce) && dgd.experData(dgd.ce).autoUpdate
        acqgui_updateDisplayFile(guiFig, recFileNums(dgd.ce));
    end
end % snooze if no match
