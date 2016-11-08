classdef (Sealed) DaqBuffer < handle
%ACQDAQ is a subset of the daq library with less timing bugs
    properties
        logFID = -1;
    end
    properties (Dependent = true)
        isLogging
        bufferSecs
    end
    properties (SetAccess = private)
        %% DAQ properties
        inChannels % List of input channels
        samplingRate
        
        %% Peek properties
        peekData = [];
        peekTimeStamps = [];
        peekHwChans = [];
        
        %% State properties
        isUpdating = false;
        isPeeking = false;
        isStarted = false;
        
        %% Buffer properties
        lastSample = 0; % Last sample placed in buffer (absolute, since DAQ start)
        updateFreq
    end
    properties (Access = private)
        %% DAQ properties
        Session % DAQ session object
        
        buffUpdateCnt = 0;% Running total number of buffer units recorded.
        DataListener % DAQ data listener
        ErrorListener % DAQ error listener
        nativeDataType = '';
        
        %% Buffer properties
        updateSize
        daqData
        daqTimeStamps
        
        %% Trigger properties
        chanIsTriggered % Boolean array indicating if channels are triggered (recording)
        trigStartSamples % Absolute sample number to start recording, -1 if recording already started
        trigStopSamples % Absolute sample number to stop recording at, -2 if open-ended recording
        trigFileNames
        trigFIDs
        
        %% Peek properties
        peekSample = 0; % Starting index in the buffer to peek from
        peekChans = [];
        
        %% Convenience properties
        numInCh
        numUpdatesInBuff % Length of buffer in terms of updates
        buffSize
    end
    properties (Constant = true) % constants
        fileFormatID = -4;
        headerEncoding = 'float64';
        openEnded = -2;
        trigStarted = -1;
        voltageRange = [-10.0, 10.0];
        terminalConfig = 'Differential'; % SingleEnded, NonReferencedSingleEnded, Differential, PseudoDifferential
    end
    
    methods
        % CONSTRUCTOR IS PRIVATE TO ENSURE ONLY ONE INSTANCE
        % USE DaqBuffer.get_instance(...) TO GET DAQBUFFER
        
        function log(self, str)
            if self.isLogging
                fprintf(self.logFID, '%s\n', str);
            end
        end
        
        function delete(self)
            self.log('Closing daq buffer');
            delete(self.DataListener);
            delete(self.ErrorListener);
            %% Try to close files
            %Data files (trigger files)
            for fNo = 1:self.numInCh
                try
                    fclose(self.trigFIDs(fNo));
                catch err
                    handle_file_err(err);
                end
            end
            self.stop()
            delete(self.Session);
        end
        
        function val = get.isLogging(self)
            if self.logFID > 0
                val = true;
            else
                val = false;
            end
        end
        
        function val = get.bufferSecs(self)
            val = self.buffSize ./ self.samplingRate;
        end
        
        function set.logFID(self, fID)
            fName = fopen(fID);
            if fID > 0
                assert(~isempty(fName), 'file identifier not valid');
                self.logFID = fID;
            else
                self.logFID = nan;
            end
        end
        
        function start(self)
            assert(~isempty(self.Session), 'DaqBuffer initialization failed');
            if self.isStarted
                warning('DAQ already started');
                return
            else
                startBackground(self.Session);
                self.isStarted = true;
            end
        end
        
        function stop(self)
            stop(self.Session);
            self.isStarted = false;
        end
        
        function debug(self)
            keyboard;
        end
        
        function update_buffer(self, ~, EventData)
            %This internal function moves data from the hardware buffer to the
            %software buffer maintained by DaqBuffer. It should only be
            %called by the DAQ DataAvailable event.
            if self.isUpdating
                self.log('Update called before last update finished');
                self.stop();
                error('Update called before last update finished');
            end
            self.isUpdating = true;
            
            %% Calculate position in buffer
            lastBuffIdx = mod(self.buffUpdateCnt, self.numUpdatesInBuff) * self.updateSize; %Circular buffer
            updateStartIdx = lastBuffIdx + 1;
            updateStopIdx = lastBuffIdx + self.updateSize;
            self.log(sprintf('Placing DAQ data between idxs %d:%d', updateStartIdx, updateStopIdx)); %DEBUG
            
            %% Place event data into buffer
            self.daqData(updateStartIdx:updateStopIdx, :) = EventData.Data;
            self.daqTimeStamps(updateStartIdx:updateStopIdx) = EventData.TimeStamps;
            
            %% Update DaqBuffer State
            self.buffUpdateCnt = self.buffUpdateCnt + 1;
            self.log(sprintf('\tFinished update %d', self.buffUpdateCnt)); %DEBUG
            self.lastSample = self.buffUpdateCnt * self.updateSize;
            
            %% Record data type
            if isempty(self.nativeDataType)
                self.nativeDataType = class(EventData.Data);
            end
            
            %% Process peek and triggers
            [recReady, recCompleteEvent] = self.process_triggers(EventData.TriggerTime, updateStartIdx, updateStopIdx);
            [peekReady, peekEvent] = self.process_peek(updateStopIdx);
            
            %% Delayed until end to avoid concurrency problems
            self.isUpdating = false;
            if recReady
                notify(self, 'RecordingComplete', recCompleteEvent);
            end
            if peekReady
                notify(self, 'PeekAvailable', peekEvent);
            end
            notify(self, 'UpdateComplete'); % Put this at the end if peeks are schedule on UpdateComplete events
            
        end % bufferUpdate
        
        function success = request_peek(self, hwChannels, startSample)
            if self.isPeeking
                success = false;
                self.log('Called request_peek while peek already being processed');
                return
            else
                self.isPeeking = true;
                self.peekHwChans = hwChannels;
                chanIdx = self.hwChans_2_idx(hwChannels);
                self.log(sprintf('Request peek on channels %s, matched channels %s', mat2str(hwChannels), mat2str(self.inChannels(chanIdx))));
                self.peekChans = chanIdx;
                self.peekSample = startSample;
                success = true;
            end
        end
        
        function [status, datFileNames] = record(self, startSample, stopSample, baseFileName, channels)
            self.log('Received recording request');
            nChans = numel(channels);
            chanIdxs = self.hwChans_2_idx(channels);
            status = false(nChans, 1);
            datFileNames = cell(nChans, 1);
            if ~any(self.chanIsTriggered(chanIdxs)) % only attempt to record if all are free
                for chanNo = 1:nChans
                    chanIdx = chanIdxs(chanNo);
                    if ~self.chanIsTriggered(chanIdx) % Check that channel is still free
                        self.log(sprintf('\tSetting trigger for channel %d', self.inChannels(chanIdx)));
                        self.chanIsTriggered(chanIdx) = true;
                        self.trigStartSamples(chanIdx) = startSample;
                        self.trigStopSamples(chanIdx) = stopSample;
                        self.log(sprintf('\tStart Sample: %d Stop Sample: %d', startSample, stopSample));
                        datFileNames{chanNo} = [baseFileName, 'chan', num2str(self.inChannels(chanIdx)), '.dat'];
                        self.trigFileNames{chanNo} = datFileNames{chanNo};
                        self.log(sprintf('\tDerived file name: %s', datFileNames{chanNo}));
                        status(chanNo) = true;
                    end
                end
            else
                self.log('Already recording, request denied');
            end
        end
        
        function isRecording = channel_is_recording(self, channel)
            chanIdx = self.hwChans_2_idx(channel);
            isRecording = self.chanIsTriggered(chanIdx);
        end
        
        function [status, datFileNames] = start_recording(self, startSample, baseFileName, channels)
            self.log('Received request for open ended recordings');
            [status, datFileNames] = self.record(startSample, DaqBuffer.openEnded, baseFileName, channels);
        end
        
        function status = stop_recording(self, endSample, channels)
            self.log('Received request to stop recordings');
            chanIdxs = self.hwChans_2_idx(channels);
            nChans = numel(channels);
            status = false(nChans, 1);
            for chanNo = 1:nChans
                chanIdx = chanIdxs(chanNo);
                if self.chanIsTriggered(chanIdx) && self.trigStopSamples(chanIdx) == DaqBuffer.openEnded % channel is set for open-ended recording
                    self.log(sprintf('\tSet channel %d to stop recording at sample %d', self.inChannels(chanIdx), endSample));
                    self.trigStopSamples(chanIdx) = endSample;
                    status(chanNo) = true;
                else
                    warning('Could not stop recording for channel number %d', channels(chanNo));
                end
            end
        end
        
    end % public methods
    
    methods (Access = private)
        function self = DaqBuffer(inChannels, reqSampleRate, bufferSecs, desiredUpdateFreq)
            %% Initialize DAQ session
            assert(~isempty(inChannels), 'no inputs specified');
            d = daq.getDevices();
            assert(numel(d) > 0, 'No DAQ found');
            niIdx = 0;
            for dNo = 1:numel(d)
                if strcmp(d(dNo).Vendor.ID, 'ni')
                    niIdx = dNo;
                end
            end
            assert(niIdx > 0, 'No working NI daq found');
            dID = d(niIdx).ID;
            self.Session = daq.createSession('ni');
            self.Session.Rate = reqSampleRate; % up to 200000
            self.samplingRate = self.Session.Rate;
            self.Session.IsContinuous = true; % DAQ will continuously acquire data!
            
            % Attach input channels
            self.inChannels = inChannels;
            self.numInCh = numel(inChannels);
            aiCh = addAnalogInputChannel(self.Session, dID, self.inChannels, 'Voltage');
            for chNo = 1:self.numInCh
                aiCh(chNo).TerminalConfig = DaqBuffer.terminalConfig; 
                aiCh(chNo).Range = DaqBuffer.voltageRange; % Force range
            end
            self.chanIsTriggered = false(self.numInCh, 1);
            
            %% Set up buffer
            % Set updateSize to integer value such that actUpdateFreq >= updateFreq
            self.updateSize = floor(self.samplingRate / desiredUpdateFreq);
            self.Session.NotifyWhenDataAvailableExceeds = self.updateSize; % Trigger DataAvailable event when this many samples acquired
            
            % Allocate buffer
            self.updateFreq = self.samplingRate / self.updateSize;
            self.numUpdatesInBuff = ceil(self.updateFreq * bufferSecs);    % Length of buffer in terms of number update units
            self.buffSize = self.updateSize * self.numUpdatesInBuff;
            self.daqData = zeros(self.buffSize, self.numInCh);
            self.daqTimeStamps = zeros(self.buffSize, 1); 
            
            % Add bufferUpdate as listener to DAQ session
            self.DataListener = addlistener(self.Session,...
                'DataAvailable', @self.update_buffer);
            self.ErrorListener = addlistener(self.Session,...
                'ErrorOccurred', @(~, ~) self.delete());
            
            %% Set up triggers
            self.trigStartSamples = nan(self.numInCh, 1);
            self.trigStopSamples = nan(self.numInCh, 1);
            self.trigFileNames = cell(self.numInCh, 1);
            self.trigFIDs = nan(self.numInCh, 1);
            
            %% Set up peeks
        end % constructor
        
        function [readyToNotify, recCompleteEvent] = process_triggers(self, TriggerTime, updateStartIdx, updateStopIdx)
        %PROCESSTRIGGERS checks if channels should be saved to disk
            self.log('Entering process_triggers');
            absTime = datevec(TriggerTime);
            completedRecordings = false(self.numInCh, 1);
            for chanNo = 1:self.numInCh
                if self.chanIsTriggered(chanNo) % channel is ready to record
                    self.log(sprintf('Channel %d is triggered', self.inChannels(chanNo)));
                    pastStartSample = self.trigStartSamples(chanNo) == DaqBuffer.trigStarted || ...
                    self.lastSample >= self.trigStartSamples(chanNo);
                    if pastStartSample
                        %% Check to see if file must be opened
                        if self.trigStartSamples(chanNo) == DaqBuffer.trigStarted
                            self.log(sprintf('\talready writing to file'));
                            recStartRelIdx = updateStartIdx;
                        else
                            self.log(sprintf('\tpast start sample %d, last sample %d', self.trigStartSamples(chanNo), self.lastSample));
                            %% Check that start sample is in buffer
                                % Start sample can only be outside buffer if the file
                                % is not started
                            if self.trigStartSamples(chanNo) < max(self.lastSample - self.buffSize + 1, 1)
                                warning('Trigger start outside buffer range.  Truncating start of recording.');
                                if self.lastSample < self.buffSize
                                    self.trigStartSamples(chanNo) = 1;
                                else
                                    self.trigStartSamples(chanNo) = self.lastSample - self.buffSize + 1; % entire content of buffer
                                end
                            end
                            
                            %% Calculate starting position relative to buffer
                            recStartRelIdx = updateStopIdx - (self.lastSample - self.trigStartSamples(chanNo)); % Can be negative
                            
                            %% Open trigger file if necessary 
                            %% Open file
                            if(exist(self.trigFileNames{chanNo}, 'file'))
                                warning('File already exists, data being appended to end of file.')
                            end
                            self.trigFIDs(chanNo) = fopen(self.trigFileNames{chanNo}, 'ab'); % 'a': append, 'b': binary.
                            self.log(sprintf('\t!!! opening file %s', self.trigFileNames{chanNo}));
                            
                            %% Write header
                            recStartIndex = mod(recStartRelIdx - 1, self.buffSize) + 1; % index in the circular buffer
                            self.log(sprintf('\tlastSample:%d\ttrigStartSample:%d\ttrigStopSample:%d', self.lastSample, self.trigStartSamples(chanNo), self.trigStopSamples(chanNo)));
                            self.log(sprintf('\tbuffSize:%d\tupdateStopIdx:%d', self.buffSize, updateStopIdx));
                            self.log(sprintf('\trawStartPosInBuff%d\tstartIdxInBuff:%d', recStartRelIdx, recStartIndex));
                            self.log(sprintf('\tWriting header'));
                            write_triggerfile_header(self.trigFIDs(chanNo),...
                                absTime,...
                                self.inChannels(chanNo),...
                                self.nativeDataType,...
                                self.trigStartSamples(chanNo),...
                                self.daqTimeStamps(recStartIndex));
                            
                            %% flush the requested part of the buffer prior to this update to file
                            if recStartRelIdx < updateStartIdx
                                self.log(sprintf('\tFlushing buffered data prior to this update to disk'));
                                priorIdxes = mod((recStartRelIdx - 1):(updateStartIdx - 2), self.buffSize) + 1;
                                fwrite(self.trigFIDs(chanNo), self.daqData(priorIdxes, chanNo), self.nativeDataType);
                                recStartRelIdx = updateStartIdx;
                            end

                            %% Indicate that file is open
                            self.trigStartSamples(chanNo) = DaqBuffer.trigStarted;
                        end
                        
                        %% Calculate end of the buffer to append
                        if self.trigStopSamples(chanNo) == DaqBuffer.openEnded
                            self.log(sprintf('\tOpen ended recording'));
                            recStopRelIdx = updateStopIdx;
                        elseif self.trigStopSamples(chanNo) > self.lastSample
                            self.log(sprintf('\tRecording stop is past the last sample'));
                            recStopRelIdx = updateStopIdx;
                        else
                            recStopRelIdx = updateStopIdx - (self.lastSample - self.trigStopSamples(chanNo)); % Can be negative
                        end
                        
                        %% Append data to trigger file
                        if  recStartRelIdx == updateStartIdx &&...
                                recStopRelIdx == updateStopIdx
                            %Save the entire latest update to the datafile.
                            self.log(sprintf('\tAppending entire update to trigger file'));
                            self.log(sprintf('\tAppending buffer between %d:%d', updateStartIdx, updateStopIdx));
                            fwrite(self.trigFIDs(chanNo), self.daqData(updateStartIdx:updateStopIdx, chanNo), self.nativeDataType);
                        elseif recStartRelIdx >= updateStartIdx  && recStopRelIdx <= updateStopIdx
                            self.log(sprintf('\tAppending subsection of update to file between indicies %d:%d', recStartRelIdx, recStopRelIdx));
                            fwrite(self.trigFIDs(chanNo), self.daqData(recStartRelIdx:recStopRelIdx, chanNo), self.nativeDataType);
                        else
                            self.stop();
                            keyboard
                            error('logic error');
                        end

                        %% Finish trigger file if necessary
                        if self.trigStopSamples(chanNo) ~= DaqBuffer.openEnded && self.lastSample >= self.trigStopSamples(chanNo)
                            
                            %The end of the trigger is within the buffer, therefore complete the
                            %file, and close it.
                            %% Write footer
                            stopSampleIndex = mod(recStopRelIdx - 1, self.buffSize) + 1;
                            self.log(sprintf('\tWriting footer'));
                            write_trigger_file_footer(self.trigFIDs(chanNo),...
                                self.nativeDataType, self.trigStopSamples(chanNo),...
                                self.daqTimeStamps(stopSampleIndex))
                            %% Close the file.
                            self.log(sprintf('\t!!! Closing file %s', self.trigFileNames{chanNo}));
                            fclose(self.trigFIDs(chanNo));
                            self.trigStopSamples(chanNo) = -1;
                            self.chanIsTriggered(chanNo) = false;
                            completedRecordings(chanNo) = true;
                        end
                    end
                end
            end
            
            %% Notify that recordings are complete
            if any(completedRecordings)
                readyToNotify = true;
                recCompleteEvent = RecordingCompleteEvent(self.inChannels(completedRecordings), self.trigFileNames(completedRecordings));
            else
                readyToNotify = false;
                recCompleteEvent = RecordingCompleteEvent([], {});
            end
        end % process_triggers
        
        function [readyToNotify, peekEvent] = process_peek(self, updateStopIdx)
            self.log('Entering process_peek');
            %% peek: make recent samples available for processing
            readyToNotify = false;
            if self.isPeeking
                self.log(sprintf('Peek has been requested from sample %d', self.peekSample));
                if self.lastSample < self.peekSample %Not enough data to peek
                    self.reset_peek();
                    warning('Cannot peek into future');
                elseif self.lastSample - self.peekSample > self.buffSize
                    self.reset_peek();
                    warning('Peek start is no longer in the buffer.');
                else
                    %% Find the data requested in the buffer
                    nSamples = self.lastSample - self.peekSample + 1;
                    bufferIdxs = mod((updateStopIdx - nSamples):(updateStopIdx - 1), self.buffSize) + 1;
                    
                    %% Place the peek data into visible properties
                    self.peekData = self.daqData(bufferIdxs, self.peekChans);
                    self.peekTimeStamps = self.daqTimeStamps(bufferIdxs);
                    
                    %% Reset state
                    self.peekSample = 0;
                    self.isPeeking = false;
                    
                    %% Notify listeners
                    readyToNotify = true;
                    peekEvent = PeekEvent(self.peekData, self.peekTimeStamps);
                end
            end
            if ~readyToNotify
                peekEvent = PeekEvent([], []);
            end
        end % process_peek
        
        function reset_peek(self)
            self.log('Resetting peek');
            self.isPeeking = false;
            self.peekSample = 0;
            self.peekData = [];
            self.peekTimeStamps = [];
        end
        
        function chanIdx = hwChans_2_idx(self, hwChannels)
            nChans = numel(hwChannels);
            chanIdx = nan(nChans, 1);
            for chanNo = 1:nChans
                chanIdx(chanNo) = find(self.inChannels == hwChannels(chanNo), 1, 'first');
            end
        end
        
    end % Private methods
    methods (Static)
        
        function singleObj = get_instance(inChannels, reqSampleRate, bufferSecs, desiredUpdateFreq)
            persistent localObj
            if isempty(localObj) || ~isvalid(localObj)
                localObj = DaqBuffer(inChannels, reqSampleRate, bufferSecs, desiredUpdateFreq);
            else
                warning('DAQBFUFER:SingletonWarning', 'DaqBuffer already created. Ignoring arguments and returning existing instance. Use DaqBuffer.reset() to reset.');
            end
            singleObj = localObj;
        end
        
        function reset()
            try
                warning('off', 'DAQBFUFER:SingletonWarning');
                DaqInstance = DaqBuffer.get_instance();
                warning('on', 'DAQBFUFER:SingletonWarning');
                delete(DaqInstance);
            catch ME
                warning('on', 'DAQBFUFER:SingletonWarning');
                if ~strcmp(ME.identifier, 'MATLAB:minrhs')
                    rethrow(ME);
                end
            end
            daq.reset();
        end
    end % static methods
    events (NotifyAccess = private)
        PeekAvailable
        RecordingComplete
        UpdateComplete
    end
end

%% Utility methods
function write_triggerfile_header(fID, absTime, hwChannel, nativeDataType, startSampleNo, startTimeStamp) % File format -4
    %First thing in the file is the trigger file format id.
    fwrite(fID, DaqBuffer.fileFormatID, DaqBuffer.headerEncoding);
    %Next write the time of daq start as a datevec
    fwrite(fID, absTime, DaqBuffer.headerEncoding);
    %Next write the current time as a datevec
    fwrite(fID, datevec(now), DaqBuffer.headerEncoding);
    %Next thing in the file is the number of channels.  %With
    %current version there is always one channel per file.
    fwrite(fID, 1, DaqBuffer.headerEncoding);
    %Next write the channel hardware numbers.
    fwrite(fID, hwChannel, DaqBuffer.headerEncoding);
    %Next write the native scale and offset for each hardware
    %channel.
    %No longer collecting data in native format replacing
    %"NativeScaling" with 1 and "NativeOffset" with 0
    fwrite(fID, 1.0, DaqBuffer.headerEncoding);%NativeScaling
    fwrite(fID, 0.0, DaqBuffer.headerEncoding);%NativeOffset
    %Next write the native data type followed by file format id.
    fwrite(fID, double(nativeDataType), DaqBuffer.headerEncoding); %Weird backwards compatibility?
    fwrite(fID, DaqBuffer.fileFormatID, DaqBuffer.headerEncoding);

    %Next write the number of the first sample.
    fwrite(fID, startSampleNo, DaqBuffer.headerEncoding);
    %Next write time of the first sample in the file (in seconds) since daq start
    fwrite(fID, startTimeStamp, DaqBuffer.headerEncoding);
end

function write_trigger_file_footer(fID, nativeDataType, stopSampleNo, stopSampleTime) % File format -4
    %Write the trigger file format id THREE times to
    %mark the end of the window of samples.
    %nativeDataType encoding at end of file
    fwrite(fID, DaqBuffer.fileFormatID, nativeDataType);
    fwrite(fID, DaqBuffer.fileFormatID, nativeDataType);
    fwrite(fID, DaqBuffer.fileFormatID, nativeDataType);
    %Write the number and time of the last sample in the file
    %for error checking.
    fwrite(fID, stopSampleNo, DaqBuffer.headerEncoding);
    fwrite(fID, stopSampleTime, DaqBuffer.headerEncoding);
end

function handle_file_err(err)
switch err.identifier
    case 'MATLAB:badfid_mx'
    case 'MATLAB:FileIO:InvalidFid'
    otherwise
        keyboard
        warning(err.message);
end
end