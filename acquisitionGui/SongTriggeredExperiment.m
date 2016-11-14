classdef SongTriggeredExperiment < handle
    properties
        %% Song detection parameters
        ratioThreshold
        songDensity
        songDuration
        windowSize % in seconds
        windowOverlap % Fracitonal
        
        preSongSeconds % to record
        postSongSeconds % to record
        maxFileDuration % to record, in seconds
    end
    properties (Access = private, Dependent = true)
        changeDetectionValid
        deletionListenerValid
        isRunning
    end
    properties (SetAccess = private)
        birdName
        birdDesc
        experName
        experDesc
        signalName
        signalDesc
        timeCreated
        
        desiredFs
        songScore = nan;
        minFreq
        maxFreq
        
        %% Information about which channels are part of this experiment
        songHWChannel
        nonSongHWChannels
        inChannels
        
        %% Information about saved files
        rootDirectory
        birdDirectory
        experDirectory
        lastFileNo = 0;
        
        %% Recording/monitoring status
        detectingSong = false;
        isRecording = false;
        forcedRecording = false;
        lastSingingSample = -1;
    end
    properties (Access = private)
        fileNameFormat
        DeletionListener
        
        %% DAQ parameters
        DaqObj
        daqFs = -1; % -1 indicates daq is not set up
        daqBufferSecs = -1;
        daqUpdateFreq = -1;% in Hz
        DaqRecordingListener
        
        %% Derived song detection parameters
        songConvKernel
        minNdx
        maxNdx
        windowSampleSize
        windowSampleOverlap
        specNfft
        nFreq
        nyqFreq
        
        %% Song detection
        ChangeDetectionListener
        queuedDetectionChange
        lastDetectingSong
        songStartSamp
    end
    
    methods
        %% Constructor and destructor
        function self = SongTriggeredExperiment(birdName, ...
                rootDirectory, songHWChannel, ...
                nonSongHWChannels, desiredFs, varargin)
            persistent p;
            if isempty(p)
                p = inputParser();
                addParameter(p, 'birdDirectory', '');
                addParameter(p, 'experDirectory', '');
                addParameter(p, 'experName', '');
                addParameter(p, 'lastFileNo', 0);
                addParameter(p, 'minFreq', 2000);
                addParameter(p, 'maxFreq', 6000);
                addParameter(p, 'ratioThreshold', 2); % aka powerThreshold
                addParameter(p, 'songDensity', 0.5); % aka durationThreshold
                addParameter(p, 'songDuration', 1); % aka songLength
                addParameter(p, 'windowSize', 0.05); % in seconds
                addParameter(p, 'windowOverlap', 0.5); % Fractional
                addParameter(p, 'preSongSeconds', 1);
                addParameter(p, 'postSongSeconds', 0);
                addParameter(p, 'maxFileDuration', 30); % in seconds
                addParameter(p, 'fileNameFormat', '%s_d%06g_%s');% format with bird name, file number, and datestring
                addParameter(p, 'birdDesc', '');
                addParameter(p, 'experDesc', '');
                addParameter(p, 'signalName', {});
                addParameter(p, 'signalDesc', {});
                addParameter(p, 'timeCreated', nan);
            end
            parse(p, varargin{:});
            Params = p.Results;
            
            %% Set properties
            self.birdName = birdName;
            self.songScore = nan;
            self.rootDirectory = rootDirectory;
            self.detectingSong = false;
            self.isRecording = false;
            self.songHWChannel = songHWChannel;
            self.nonSongHWChannels = nonSongHWChannels;
            self.inChannels = [songHWChannel, nonSongHWChannels];
            self.desiredFs = desiredFs;
            self.set_freq_range(Params.minFreq, Params.maxFreq);
            self.ratioThreshold = Params.ratioThreshold;
            self.songDensity = Params.songDensity;
            self.songDuration = Params.songDuration;
            self.windowSize = Params.windowSize;
            self.windowOverlap = Params.windowOverlap;
            self.preSongSeconds = Params.preSongSeconds;
            self.postSongSeconds = Params.postSongSeconds;
            self.maxFileDuration = Params.maxFileDuration;
            self.birdDesc = Params.birdDesc;
            self.experDesc = Params.experDesc;
            self.signalName = Params.signalName;
            self.signalDesc = Params.signalDesc;
            if isnan(Params.timeCreated)
                self.timeCreated = datetime();
            else
                self.timeCreated = Params.timeCreated;
            end
            if isempty(Params.experName)
                self.experName = datestr(self.timeCreated, 29);
            else
                self.experName = Params.experName;
            end
            if isempty(Params.birdDirectory)
                self.birdDirectory = fullfile(self.rootDirectory, self.birdName);
            else
            end
            if isempty(Params.experDirectory)
                self.experDirectory = fullfile(self.birdDirectory, self.experName);
            else
                self.experDirectory = Params.experDirectory;
            end
            if any(strcmp(p.UsingDefault, 'lastFileNo')) && exist(self.experDirectory, 'dir')
                self.lastFileNo = SongTriggeredExperiment.last_fileno(self.experDirectory, self.birdName);
            end
        end
        
        function delete(self)
            % Clean up
            try
                if self.deletionListenerValid
                    delete(self.DeletionListener);
                end
                if self.isRecording && self.forcedRecording
                    self.DeletionListener = addlistener(self, 'RecordingComplete', @(~, ~) self.delete());
                    status = self.stop_recording(self.DaqObj.lastSample);
                    while ~status
                        status = self.stop_recording(self.DaqObj.lastSample);
                    end
                end
                delete(self.DaqRecordingListener);
            catch
                % do nothing
            end
        end
        
        %% Parameter setting methods
        function set.detectingSong(self, val)
            self.detectingSong = val;
            notify(self, 'DetectionChanged');
        end
        
        function set_freq_range(self, minFreq, maxFreq)
            assert(minFreq < maxFreq, ...
                'minimum frequency must be strictly less than maximum frequency');
            assert(minFreq >= 0 && maxFreq >= 0, 'frequencies must be postiive');
            if self.isRunning % Daq is set up
                assert(minFreq <= self.nyqFreq && maxFreq <= self.nyqFreq, ...
                    'frequencies must be less than nyquist freqeuncy');
            else
                desiredNyqF = self.desifredFs / 2;
                assert(minFreq <= desiredNyqF && maxFreq <= desiredNyqF, ...
                    'frequencies must be less than desired nyquist frequency');
            end
            self.minFreq = minFreq;
            self.maxFreq = maxFreq;
        end
        
        function set_daq_params(self, DaqObj)
            self.DaqObj = DaqObj;
            self.daqFs = self.DaqObj.samplingRate;
            self.nyqFreq = self.daqFs ./ 2;
            self.daqBufferSecs = DaqObj.bufferSecs;
            self.daqUpdateFreq = DaqObj.updateFreq;
            self.calculate_derived_song_params();
            self.write_daqsetup();
        end
        
        function clear_daq_params(self)
            self.DaqObj = [];
            self.daqFs = -1;
            self.nyqFreq = -1;
            self.daqBufferSecs = -1;
            self.daqUpdateFreq = -1;
            delete(self.DaqRecordingListener);
        end
        
        function status = change_detectingSong(self, detectingSong)
            % Public method to ask for a change in detection state
            if self.isRecording
                %% Make the change after this recording
                if ~self.changeDetectionValid
                    status = true;
                    self.queuedDetectionChange = detectingSong;
                    self.ChangeDetectionListener = ...
                        addlistener(self, 'RecordingComplete',...
                        @self.change_detectingSong_callback);
                else  
                    status = false;
                end
            else
                %% Make the change now
                status = true;
                self.detectingSong = detectingSong;
            end
        end
        
        %% Song detection methods
        function status = detect_song_and_record(self, audioData, peekStartSamp)
            if self.forcedRecording
                status = false;
            else
                [status, isSong, songScore, firstSongSamp] = detect_song(self, audioData, peekStartSamp);   %#ok<PROPLC>
                self.songScore = songScore;   %#ok<PROPLC>
                if status
                    lastPeekSamp = peekStartSamp + numel(audioData) - 1;
                    self.update_triggered_recording(isSong, firstSongSamp, lastPeekSamp);
                end
            end
        end
        
        function [status, isSong, songScore, firstSongSamp] = detect_song(self, audioData, peekStartSamp)
            % Should only be called once daq is set up
            if  ~self.isRunning
                status = false;
                isSong = false;
                firstSongSamp = nan;
            else
                status = true;
                %% Take specgram and measure in-band vs. out-band power in each time-slice
                [s, ~, t] = spectrogram(audioData, self.windowSampleSize,...
                    self.windowSampleOverlap, self.specNfft, self.daqFs);
                powerSong = mean(abs(s(self.minNdx:self.maxNdx, :)), 1);
                powerNonSong = mean(abs(s([1:(self.minNdx - 1), (self.maxNdx + 1):end], :)), 1) + eps;
                songPowerRatio = powerSong ./ powerNonSong;
                
                %% Smooth song power ratio
                threshCross = songPowerRatio > self.ratioThreshold;
                threshCrossMovingAv = conv(double(threshCross), self.songConvKernel); % Cast into double for convolution
                songScore = max(threshCrossMovingAv);
                isSong = songScore > self.songDensity;
                if isSong
                    relSongStartSamp = floor(t(find(threshCross, 1, 'first')) .* self.daqFs) + 1;
                    firstSongSamp = peekStartSamp + relSongStartSamp;
                else
                    firstSongSamp = nan;
                end
            end
        end
        
        %% public recording methods (use these to ask for recordings)
        function status = force_recording(self)
            if ~self.isRunning || self.DaqObj.isUpdating || self.isRecording
                %% Cannot safely start recording
                status = false;
            else
                self.forcedRecording = true;
                
                %% Stop song triggering during the forced recording
                self.lastDetectingSong = self.detectingSong;
                self.detectingSong = false;
                
                %% Start the recording
                startSamp = self.DaqObj.lastSample + 1;
                status = self.record(startSamp);
                if ~status
                    self.forcedRecording = false;
                end
            end
        end
        
        function status = force_stop_recording(self)
            if self.isRecording
                if ~self.forcedRecording % recording was song triggered
                    %% Stop song detection or the recording will resume after
                    self.detectingSong = false;
                end
                status = self.stop_recording(self.DaqObj.lastSample);
            else
                status = false;
            end
        end
        
        function fileNames = get_filenames(self, recNo, hwChannels)
            nChan = numel(hwChannels);
            prefix = sprintf(self.fileNameFormat, self.birdName, recNo, datestr(datetime(), 30));
            fileNames = cell(nChan, 1);
            for chanNo = 1:nChan
                file = sprintf('%schan%d.dat', prefix, hwChannels(chanNo));
                fileNames{chanNo} = fullfile(self.experDirectory, file);
            end
        end
        
        function [fileNames, hwChannels] = find_files(self, recordingNo)
            REGSTR = sprintf('^%s_d%06g_\\d{8}T\\d{6}chan(\\d+)\\.dat$', self.birdName, recordingNo); %slashes escaped
            experDir = self.experDirectory;
            listing = dir(experDir);
            candidateNames = {listing.name};
            candidateFiles = candidateNames(~[listing.isdir]);
            [rawMatch, rawTokens] = regexp(candidateFiles, REGSTR, 'match', 'tokens', 'once');
            nonEmptyMask = ~cellfun(@isempty, rawMatch);
            fileNames = rawMatch(nonEmptyMask);
            hwChannels = str2double([rawTokens{nonEmptyMask}]);
        end
        
        %% Callbacks
        function daq_recording_finished(self, ~, EventData)
            %% See if these are the channels we are looking for
            channelsMatch = compare_channels(self.inChannels, EventData.hwChannels);
            %% Respond to event if all channels match
            if channelsMatch
                delete(self.DaqRecordingListener); % Un-subcribe to future events
                self.recording_complete();
            end
        end
        
        function change_detectingSong_callback(self, ~, ~)
            delete(self.DisableDetectionListener);
            self.detectingSong = self.queuedDetectionChange;
        end
        
        %% Derived getters
        function val = get.changeDetectionValid(self)
            val = ~isempty(self.ChangeDetectionListener) && ...
                isvalid(self.ChangeDetectionListener);
        end
        function val = get.deletionListenerValid(self)
            val = ~isempty(self.DeletionListener) && ...
                isvalid(self.DeletionListener);
        end
        function val = get.isRunning(self)
            val = self.daqFs > 0;
        end
    end
    
    methods (Access = private)
        %% Methods for updating parameters
        function calculate_derived_song_params(self)
            if self.isRunning % DAQ is set up
                self.windowSampleSize = floor(self.daqFs * self.windowSize);
                self.windowSampleOverlap = floor(self.windowSampleSize * self.windowOverlap);
                self.specNfft = 2 ^ nextpow2(self.windowSampleSize);
                self.nFreq = self.specNfft / 2 + 1;
                self.minNdx = self.hz_to_freqndx(@floor, self.minFreq);
                self.maxNdx = self.hz_to_freqndx(@ceil, self.maxFreq);
                self.fix_freq_range();
                kernelLength = (self.songDuration * self.daqFs) / ...
                    (self.windowSampleSize - self.windowSampleOverlap); % This is from the original function, I don't understand why it's normalized this way
                if kernelLength <= 0 || kernelLength == Inf
                    kernelLength = 1;
                end
                self.songConvKernel = ones(1, kernelLength) ./ kernelLength;
            else
                warning('Cannot calculate derived song triggering parameters before DAQ is set up');
            end
        end
        
        function fix_freq_range(self)
            if self.isRunning % Daq is set up
                self.minFreq = self.freqndx_to_hz(self.minNdx);
                self.maxFreq = self.freqndx_to_hz(self.maxNdx);
            else
                warning('Cannot fix frequency range before DAQ is set up');
            end
        end
        
        %% Recording methods
        function status = record(self, startSamp)
            if self.DaqObj.isUpdating || self.isRecording || ~self.isRunning
                status = false;
            else
                self.isRecording = true;
                
                self.DaqRecordingListener = addlistener(self.DaqObj, 'RecordingComplete', @self.daq_recording_finished);
                recFileNames = self.get_filenames(self.lastFileNo + 1, self.inChannels);
                [startedChannels, ~] = self.DaqObj.start_recording(startSamp, recFileNames, self.inChannels);
                status = all(startedChannels);
                if status
                    notify(self, 'RecordingStarted');
                else
                    self.isRecording = false;
                    delete(self.DaqRecordingListener);
                end
            end
        end
        
        function status = stop_recording(self, stopSamp)
            if ~self.isRunning
                error('Daq was stopped during a recording!');
            elseif ~self.isRecording || self.DaqObj.isUpdating
                status = false;
            else
                stoppedChannels = self.DaqObj.stop_recording(stopSamp, self.inChannels);
                status = all(stoppedChannels);
                if status
                    self.isRecording = false;
                end
            end
        end
        
        function recording_complete(self)
            self.isRecording = false;
            self.lastFileNo = self.lastFileNo + 1;
            if self.forcedRecording
                self.forcedRecording = false;
                self.detectingSong = self.lastDetectingSong;
            end
            notify(self, 'RecordingComplete');
        end
        
        function update_triggered_recording(self, isSinging, firstSongSamp, lastPeekSamp)
            if self.forcedRecording || ~self.isRunning
                return
            end
            if isSinging
                if ~self.isRecording % Start to write file
                    startSamp = firstSongSamp - round(self.daqFs * self.preSongSeconds);
                    self.record(startSamp)
                end
                self.lastSingingSample = lastPeekSamp;
            else
                sampsSinceLastSong = lastPeekSamp - self.lastSingingSample;
                postSongSamples = ceil(self.daqFs * self.postSongSeconds);
                if sampsSinceLastSong > postSongSamples
                    %% End recording
                    stopSamp = self.lastSingingSample + postSongSamples;
                    self.stop_recording(stopSamp);
                else
                    self.lastSingingSample = lastPeekSamp;
                end
            end
        end
        
        %% Methods for experiment persistence
        function make_exper_dir(self)
            if ~exist(self.birdDirectory, 'dir')
                mkdir(self.birdDirectory);
            end
            if ~exist(self.experDirectory, 'dir')
                mkdir(self.experDirectory);
            end
        end
        
        function write_exper_file(self)
            exper.rootdir = self.rootDirectory;
            exper.birddir = self.birdDirectory;
            exper.dir = self.experDirectory;
            exper.birdname = self.birdName;
            exper.birddesc = self.birdDesc;
            exper.expername = self.experName;
            exper.experdesc = self.experDesc;
            exper.datecreated = datestr(self.timeCreated, 30);
            exper.desiredInSampRate = self.desiredFs;
            exper.audioCh = self.songHWChannel;
            exper.sigCh = self.nonSongHWChannels;
            exper.sigName = self.signalName;
            exper.sigDesc = self.signalDesc;  %#ok<STRNU>
            save(fullfile(self.experDirectory, 'exper.mat'), 'exper');
        end
        
        function write_daqsetup(self)
            daqSetup.actInSampleRate = self.daqFs;
            daqSetup.actOutSampleRate = nan;
            daqSetup.buffer = self.daqBufferSecs;
            daqSetup.actUpdateFreq = self.daqUpdateFreq;
            fileName = fullfile(self.experDirectory, sprintf('daqSetup%s.mat', datestr(datetime(), 30)));
            save(fileName, 'daqSetup');
        end
        
        %% Utility methods
        function hz = freqndx_to_hz(self, freqNdx)
            hz = self.nyqFreq * (freqNdx - 1) ./ (self.nFreq - 1);
        end
        function freqNdx = hz_to_freqndx(self, roundFun, hz)
            freqNdx = roundFun((self.nFreq - 1) * hz / self.nyqFreq) + 1;
        end
    end
    methods (Static)
        function ClonedExper = clone_experiment(ExperIn, varargin)
            ClonedExper = SongTriggeredExperiment(ExperIn.birdName, ...
                ExperIn.rootDirectory, ExperIn.songHWChannel, ...
                ExperIn.nonSongHWChannels, ExperIn.desiredFs, ...
                'birdDirectory', ExperIn.birdDirectory, ...
                'minFreq', ExperIn.minFreq, ...
                'maxFreq', ExperIn.maxFreq, ...
                'ratioThreshold', ExperIn.ratioThreshold, ...
                'songDensity', ExperIn.songDensity, ...
                'songDuration', ExperIn.songDuration, ...
                'windowSize', ExperIn.windowSize, ...
                'windowOverlap', ExperIn.windowOverlap, ...
                'preSongSeconds', ExperIn.preSongSeconds, ...
                'postSongSeconds', ExperIn.postSongSeconds, ...
                'maxFileDuration', ExperIn.maxFileDuration, ...
                'fileNameFormat', ExperIn.fileNameFormat,...
                'birdDesc', ExperIn.birdDesc, ...
                'experDesc', ExperIn.experDesc, ...
                'signalName', ExperIn.signalName, ...
                'signalDesc', ExperIn.signalDesc);
            ClonedExper.make_exper_dir();
            ClonedExper.write_exper_file();
        end
        
        function [status, Exper] = create_experiment_prompt(varargin)
            %Creates a folder for all files related to this experiment.  Also saves a
            %.mat file to this folder containing the experiment description.
            persistent p;
            if isempty(p)
                p = inputParser();
                addOptional(p, 'rootDirectory', '');
            end
            parse(p, varargin{:});
            Params = p.Results;
            if isempty(Params.rootDirectory)
                rootDir = pwd();
            else
                rootDir = Params.rootDirectory;
            end
            
            try
                birdName = input('Enter a bird name: (no spaces or strange characters)', 's');
                birdDesc = input('Enter a description of the bird:', 's');
                experName = input('Enter a experiment name (nothing for default):', 's');
                experDesc = input('Enter a description of the exper:', 's');
                desiredInSampRate = input('Enter the desired input sampling rate:');
                audioCh = input('What hw channel will audio be on: (-1 if no audio)');
                sigCh = input('Enter vector of other hw channels to be recorded: ([] if none)');
                
                nCh = numel(sigCh);
                sigName = cell(nCh, 1);
                sigDesc = cell(nCh, 1);
                for chanNo = 1:nCh
                    sigName{chanNo} = input(sprintf('Enter name of signal on channel %d:', sigCh(chanNo)), 's');
                    sigDesc{chanNo} = input(sprintf('Enter description of signal on channel %d:', sigCh(chanNo)), 's');
                end
                
                Exper = SongTriggeredExperiment(birdName, rootDir, audioCh, sigCh, ...
                    desiredInSampRate, ...
                    'experName', experName, ...
                    'birdDesc', birdDesc, ...
                    'experDesc', experDesc, ...
                    'signalName', sigName, ...
                    'signalDesc', sigDesc);
                Exper.make_exper_dir();
                Exper.write_exper_file();
                status = true;
            catch
                status = false;
                Exper = [];
            end
        end
        
        function Exper = load_experiment(fileName, varargin)
            persistent p;
            if isempty(p)
                p = inputParser();
                addParameter(p, 'currentDir', '');
            end
            parse(p, varargin{:});
            currentDir = p.Results.currentDir;
            
            S = load(fileName, 'exper');
            if ~isempty(p.Results.currentDir) && strcmp(which(currentDir), S.exper.dir) % This is a pretty lame way to check that the directories are the same...
                assert(exist(currentDir, 'dir'), 'New directory not valid');
                S.exper.rootdir = currentDir;
                S.exper.birddir = currentDir;
                S.exper.dir = currentDir;
            end
            
            Exper = SongTriggeredExperiment(S.exper.birdname, ...
                S.exper.rootdir, ...
                S.exper.audioCh, ...
                S.exper.sigCh, ...
                S.exper.desiredInSampRate, ...
                'birdDirectory', S.exper.birddir, ...
                'experDirectory', S.exper.dir, ...
                'experName', S.exper.expername, ...
                'experDesc', S.exper.experdesc, ...
                'timeCreated', datetime(S.exper.datecreated), ...
                'signalName', S.exper.sigName, ...
                'signalDesc', S.exper.sigDesc);
        end
        
        function fileNo = last_fileno(directory, birdName)
            dirstat = dir(fullfile(directory, [birdName, '_d*']));
            if isempty(dirstat)
                fileNo = 0;
            else
                name = dirstat(end).name;
                fileNo = extract_datafile_number(name);
            end
        end
        
        function fileNos = extract_datafile_number(names)
            REGSTR = '^.+_d(\d{6})_\d{8}T\d{6}chan\d+\.dat$';
            if ~iscell(names)
                names = {names};
            end
            tokens = regexp(names, REGSTR, 'tokens', 'once');
            fileNos = str2double([tokens{:}]);
        end
    end
    
    events (NotifyAccess = private)
        RecordingStarted
        RecordingComplete
        DetectionChanged
    end
end