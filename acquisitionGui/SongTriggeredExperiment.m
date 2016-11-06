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
        
        desiredFs
        
        songScore
        
        minFreq
        maxFreq
        %% Information about which channels are part of this experiment
        songHWChannel
        nonSongHWChannels
        
        %% Information about saved files
        directory
        lastFileNo
        fileTimes
        
        %% Recording/monitoring status
        detectingSong
        isRecording
    end
    properties (Access = private)
        fileNameFormat
        
        RecordingListener
        
        inChannels
        
        %% DAQ parameters
        DaqObj
        daqFs
        daqBufferSecs
        daqUpdateFreq % in Hz
        
        %% Derived song detection parameters
        songConvKernel
        minNdx
        maxNdx
        windowSampleSize
        windowSampleOverlap
        specNfft
        nFreq
        nyqFreq
    end
    
    methods
        function self = SongTriggeredExperiment(birdName, directory, songHWChannel, nonSongHWChannels, desiredFs, varargin)
            persistent p;
            if isempty(p)
                p = inputParser();
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
            end
            parse(p, varargin{:});
            Params = p.Results;
            
            %% Set properties
            self.birdName = birdName;
            self.songScore = nan;
            self.directory = directory;
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
            self.lastFileNo = SongTriggeredExperiment.last_fileno(self.directory, self.birdName);
            self.fileTimes = [];
            
            %% Set daq properties to -1 to indicate that daq has not been set up
            self.daqFs = -1;
            self.daqBufferSecs = -1;
            self.daqUpdateFreq = -1;
        end
        
        function set_freq_range(self, minFreq, maxFreq)
            assert(minFreq < maxFreq, 'minimum frequency must be strictly less than maximum frequency');
            assert(minFreq >= 0 && maxFreq >= 0, 'frequencies must be postiive');
            if self.daqFs >= 0 % Daq is set up
                assert(minFreq <= self.nyqFreq && maxFreq <= self.nyqFreq, 'frequencies must be less than nyquist freqeuncy');
            else
                desiredNyqF = self.desifredFs / 2;
                assert(minFreq <= desiredNyqF && maxFreq <= desiredNyqF, 'frequencies must be less than desired nyquist frequency');
            end
            self.minFreq = minFreq;
            self.maxFreq = maxFreq;
        end
        
        function set_daq_params(self, DaqObj, daqBufferSecs, daqUpdateFreq)
            self.DaqObj = DaqObj;
            self.daqFs = self.DaqObj.samplingRate;
            self.nyqFreq = self.daqFs ./ 2;
            self.daqBufferSecs = daqBufferSecs;
            self.daqUpdateFreq = daqUpdateFreq;
            self.calculate_derived_song_params();
            self.write_daqsetup();
        end
        
        function prefix = get_next_file_prefix(self)
            nextNo = self.lastFileNo + 1;
            prefix = sprintf(self.fileNameFormat, self.birdName, nextNo, datestr(now,30));
        end
        
        function [isSong, firstSongTime] = check_for_song(self, audioData)
            %% Take specgram and measure in-band vs. out-band power in each time-slice
            [s, ~, t] = spectrogram(audioData, self.windowSampleSize, self.windowSampleOverlap, self.specNfft, self.daqFs);
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
        
        function status = start_recording(self)
            if self.DaqObj.isUpdating || self.isRecording
                status = false;
            else
                self.isRecording = true;
                recSampNum = self.DaqObj.lastSample + 1;
                self.RecordingListener = addlistener(self.DaqObj, 'RecordingComplete', @self.recording_completion_callback);
                recFilePrefix = fullfile(self.directory, self.get_next_file_prefix());
                [startedChannels, ~] = self.DaqObj.start_recording(recSampNum, recFilePrefix, self.inChannels);
                status = all(startedChannels);
                if ~status
                    self.isRecording = false;
                    delete(self.RecordingListener);
                end
            end
        end
        
        function status = stop_recording(self)
            if self.DaqObj.isUpdating
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
                self.fileTimes = [self.fileTimes, now()];
                notify(self, 'RecordingComplete');
            end
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
                kernelLength = (self.songDuration * self.daqFs) / (self.windowSampleSize - self.windowSampleOverlap); % This is from the original function, I don't understand why it's normalized this way
                if kernelLength <= 0 || kernelLength == Inf
                    kernelLength = 1;
                end
                self.songConvKernel = ones(1, kernelLength) ./ kernelLength;
            else
                warning('Cannot calculate derived song triggering parameters before DAQ is set up');
            end
        end
        
        function write_daqsetup(self)
            daqSetup.actInSampleRate = self.daqFs;
            daqSetup.actOutSampleRate = nan;
            daqSetup.buffer = self.daqBufferSecs;
            daqSetup.actUpdateFreq = self.daqUpdateFreq;
            fileName = fullfile(self.directory, sprintf('daqSetup%s.mat', datestr(now, 30)));
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
        function Exper = create_experiment(varargin)
            %Creates a folder for all files related to this experiment.  Also saves a
            %.mat file to this folder containing the experiment description.
            persistent p;
            if isempty(p)
                p = inputParser();
                addOptional(p, 'directory', '');
            end
            parse(p, varargin{:});
            Params = p.Results; 
            if isempty(Params.directory)
                rootdir = pwd();
            else
                rootdir = Params.directory;
            end
            
            birdname = input('Enter a bird name: (no spaces or strange characters)', 's');
            birddesc = input('Enter a description of the bird:', 's');
            expername = input('Enter a experiment name:', 's');
            experdesc = input('Enter a description of the exper:', 's');
            
            mkdir(rootdir, birdname);
            mkdir(fullfile(rootdir, birdname), expername);
            
            exper.dir = fullfile(rootdir,birdname,expername);
            exper.birdname = birdname;
            exper.birddesc = birddesc;
            exper.expername = expername;
            exper.experdesc = experdesc;
            exper.datecreated = datestr(now,30);
            
            exper.desiredInSampRate = input('Enter the desired input sampling rate:');
            exper.audioCh = input('What hw channel will audio be on: (-1 if no audio)');
            exper.sigCh = input('Enter vector of other hw channels to be recorded: ([] if none)');
            
            for nName = 1:numel(exper.sigCh)
                exper.sigName{nName} = input(sprintf('Enter name of signal on channel %d:', exper.sigCh(nName)),'s');
                exper.sigDesc{nName} = input(sprintf('Enter description of signal on channel %d:', exper.sigCh(nName)),'s');
            end
            save(fullfile(exper.dir, 'exper.mat'), 'exper');
            Exper = SongTriggeredExperiment(exper.birdName, exper.dir, exper.audioCh, exper.sigCh, exper.desiredInSampRate);
        end
        
        function Exper = load_experiment(fileName)
            S = load(fileName, 'exper');
            Exper = SongTriggeredExperiment(S.exper.birdName, S.exper.dir, S.exper.audioCh, S.exper.sigCh, S.exper.desiredInSampRate);
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