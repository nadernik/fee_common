function recording_completion_callback(EventData, ListenerHandle, hwChannels, guiFig, experIdxs, recFileNums)
%% See if these are the channels we are looking for
channelsMatch = compare_channels(hwChannels, EventData.hwChannels);

%% Respond to event if all channels match
if channelsMatch
    %% These are the channels we are looking for!
    delete(ListenerHandle); % Un-subcribe to future events
    dgd = aa_getAppDataReadOnly(guiFig, 'acqguidata');
%     nExper = numel(experIdxs);
%     %% Append sutter data
%     if(dgd.sutterStatus)
%         for experNo = 1:nExper
%             [~, micronsApprox, sutterStatus] = sutterGetCurrentPosition(dgd.sutterConnection);
%             if sutterStatus
%                 experFilename = getExperDatafile(dgd.expers{experIdxs(experNo)}, recFileNums(experNo), dgd.expers{experIdxs(experNo)}.audioCh);
%                 path = dgd.expers{experIdxs(experNo)}.dir;
%                 fullName = [path, experFilename];
%                 daq_appendProperty(fullName, 'SutterMicronsX',  sprintf('%4.2f', micronsApprox(1)));
%                 daq_appendProperty(fullName, 'SutterMicronsY',  sprintf('%4.2f', micronsApprox(2)));
%                 daq_appendProperty(fullName, 'SutterMicronsZ',  sprintf('%4.2f', micronsApprox(3)));
%             end
%         end
%     end
    
    %% Update displayed file
    if any(experIdxs == dgd.ce) && dgd.experData(dgd.ce).autoUpdate
        acqgui_updateDisplayFile(guiFig, recFileNums(dgd.ce));
    end
end % snooze if no match