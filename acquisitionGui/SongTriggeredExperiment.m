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
    end
    properties (Access = private)
        fileNameFormat
        RecordingListener
        
        
        %% DAQ parameters
        DaqObj
        daqFs = -1; % -1 indicates daq is not set up
        daqBufferSecs = -1;
        daqUpdateFreq = -1;% in Hz
        
        %% Derived song detection parameters
        songConvKernel
        minNdx
        maxNdx
        windowSampleSize
        windowSampleOverlap
        specNfft
        nFreq
        nyqFreq
        
        DeletionListener
        ChangeDetectionListener
        detectionChange
    end
    
    methods
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
            if exist(self.experDirectory, 'dir')
                self.lastFileNo = SongTriggeredExperiment.last_fileno(self.experDirectory, self.birdName);
            else
                self.lastFileNo = 0;
            end
        end
        
        function delete(self)
            % Clean up
            try
                if ~isempty(self.DeletionListener) && isvalid(self.DeletionListener)
                    delete(self.DeletionListener);
                end
                if self.isRecording
                    self.DeletionListener = addlistener(self, 'RecordingComplete', @(~, ~) self.delete());
                    status = self.stop_recording();
                    while ~status
                        status = self.stop_recording();
                    end
                end
                delete(self.RecordingListener);
            catch
                % do nothing
            end
        end
        
        function status = change_detectingSong(self, detectingSong)
            if self.isRecording
                if ~isempty(self.ChangeDetectionListener) && ...
                        isvalid(self.ChangeDetectionListener)
                    status = true;
                    self.detectionChange = detectingSong;
                    self.ChangeDetectionListener = ...
                        addlistener(self, 'RecordingComplete',...
                        @self.change_detectingSong_callback);
                else  
                    status = false;
                end
            else
                status = true;
                self.detectingSong = detectingSong;
            end
        end
        
        function set_freq_range(self, minFreq, maxFreq)
            assert(minFreq < maxFreq, ...
                'minimum frequency must be strictly less than maximum frequency');
            assert(minFreq >= 0 && maxFreq >= 0, 'frequencies must be postiive');
            if self.daqFs >= 0 % Daq is set up
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
        
        function prefix = get_next_file_prefix(self)
            nextNo = self.lastFileNo + 1;
            prefix = sprintf(self.fileNameFormat, self.birdName, nextNo, datestr(datetime(), 30));
        end
        
        function [status, isSong, firstSongTime] = check_for_song(self, audioData)
            % Should only be called once daq is set up
            if  self.daqFs < 0 
                status = false;
                isSong = false;
                firstSongTime = nan;
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
                maxSongScore = max(threshCrossMovingAv);
                isSong = maxSongScore > self.songDensity;
                if isSong
                    firstSongTime = t(find(threshCross, 1, 'first'));
                else
                    firstSongTime = nan;
                end
            end
        end
        
        function status = start_recording(self)
            if self.daqFs < 0 || self.DaqObj.isUpdating || self.isRecording
                status = false;
            else
                self.isRecording = true;
                recSampNum = self.DaqObj.lastSample + 1;
                self.RecordingListener = addlistener(self.DaqObj, 'RecordingComplete', @self.recording_completion_callback);
                recFilePrefix = fullfile(self.experDirectory, self.get_next_file_prefix());
                [startedChannels, ~] = self.DaqObj.start_recording(recSampNum, recFilePrefix, self.inChannels);
                status = all(startedChannels);
                if ~status
                    self.isRecording = false;
                    delete(self.RecordingListener);
                end
            end
        end
        
        function status = stop_recording(self)
            if ~self.isRecording || self.DaqObj.isUpdating
                status = false;
            else
                stoppedChannels = self.DaqObj.stop_recording(self.DaqObj.lastSample, self.inChannels);
                status = all(stoppedChannels);
            end
        end
        
        function recording_completion_callback(self, ~, EventData)
            %% See if these are the channels we are looking for
            channelsMatch = compare_channels(self.inChannels, EventData.hwChannels);
            %% Respond to event if all channels match
            if channelsMatch
                delete(self.RecordingListener); % Un-subcribe to future events
                self.isRecording = false;
                self.lastFileNo = self.lastFileNo + 1;
                notify(self, 'RecordingComplete');
            end
        end
        
        function change_detectingSong_callback(self, ~, ~)
            delete(self.DisableDetectionListener);
            self.detectingSong = self.detectionChange;
        end
    end
    
    methods (Access = private)
        function calculate_derived_song_params(self)
            if self.daqFs >= 0 % DAQ is set up
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
            exper.sigDesc = self.signalDesc;
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
        
        function fix_freq_range(self)
            if self.daqFs >= 0 % Daq is set up
                self.minFreq = self.freqndx_to_hz(self.minNdx);
                self.maxFreq = self.freqndx_to_hz(self.maxNdx);
            else
                warning('Cannot fix frequency range before DAQ is set up');
            end
        end
        
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
        
        function Exper = create_experiment_prompt(varargin)
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
        end
        
        function Exper = load_experiment(fileName)
            S = load(fileName, 'exper');
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
            name = dirstat(end).name;
            fileNo = extract_datafile_number(name);
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
        RecordingComplete
    end
end