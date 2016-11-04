classdef SongTriggeredExperiment < handle
    properties
        %% Song detection parameters
        minFreq
        maxFreq
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
        desiredFs
        
        songScore
        %% Information about which channels are part of this experiment
        songHWChannel
        nonSongHWChannels
        
        %% Information about saved files
        directory
        lastFileNo
        fileTimes
        
        %% Recording/monitoring status
        detectingSong
        forcedRecording
    end
    properties (Access = private)
        mutexTaken % mutex for critical sections (if they exist?)
        
        recordingListener
        
        %% DAQ parameters
        daqFs
        daqBufferSecs
        daqUpdateFreq % in Hz
        
        %% Derived song detection parameters
        songConvKernel
        minNdx
        maxNdx
        windowSampleSize
        windowSampleOverlap
    end
    
    methods
        function self = SongTriggeredExperiment(directory, songHWChannel, nonSongHWChannels, desiredFs, varargin)
            persistent p;
            if isempty(p)
                p = inputParser();
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
            end
            parse(p, varargin{:});
            Params = p.Results;
            
            %% Set properties
            self.songScore = nan;
            self.mutexTaken = false;
            self.directory = directory;
            self.songHWChannel = songHWChannel;
            self.nonSongHWChannels = nonSongHWChannels;
            self.desiredFs = desiredFs;
            self.minFreq = Params.minFreq;
            self.maxFreq = Params.maxFreq;
            self.ratioThreshold = Params.ratioThreshold;
            self.songDensity = Params.songDensity;
            self.songDuration = Params.songDuration;
            self.windowSize = Params.windowSize;
            self.windowOverlap = Params.windowOverlap;
            self.preSongSeconds = Params.preSongSeconds;
            self.postSongSeconds = Params.postSongSeconds;
            self.maxFileDuration = Params.maxFileDuration;
            
            %% Set daq properties to -1 to indicate that daq has not been set up
            self.daqFs = -1;
            self.daqBufferSecs = -1;
            self.daqUpdateFreq = -1;
        end
        
        function set_daq_params(self, daqFs, daqBufferSecs, daqUpdateFreq)
            self.daqFs = daqFs;
            self.daqBufferSecs = daqBufferSecs;
            self.daqUpdateFreq = daqUpdateFreq;
            self.calculate_derived_song_params();
            self.write_daqsetup();
        end
        
        function [isSong, firstSongTime] = check_for_song(self, audioData)
            %% Take specgram and measure in-band vs. out-band power in each time-slice
            [s, ~, t] = spectrogram(audioData, self.windowSampleSize, self.windowSampleOverlap, self.windowSampleSize, self.daqFs);
            powerSong = mean(abs(s(self.minNdx:self.maxNdx, :)), 1);
            powerNonSong = mean(abs(s([1:(self.minNdx - 1), (self.maxNdx + 1):end], :)), 1) + eps;
            songPowerRatio = powerSong ./ powerNonSong;
            
            %% Smooth song power ratio
            threshCross = songPowerRatio > self.ratioThreshold; % Cast into double for convolution
            threshCrossMovingAv = conv(double(threshCross), self.songConvKernel);
            maxSongScore = max(threshCrossMovingAv);
            isSong = maxSongScore > self.songDensity;
            if isSong
                firstSongTime = t(find(threshCross, 1, 'first'));
            else
                firstSongTime = nan;
            end
        end
    end
    methods (Access = private)
        function calculate_derived_song_params(self)
            if self.daqFs >= 0 % DAQ is set up
                self.windowSampleSize = floor(self.daqFs * self.windowSize);
                self.windowSampleOverlap = floor(self.windowSampleSize * self.windowOverlap);
                self.minNdx = floor((self.windowSampleSize / self.daqFs) * self.minFreq + 1);
                self.maxNdx = ceil((self.windowSampleSize / self.daqFs) * self.maxFreq + 1);
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
            Exper = SongTriggeredExperiment(exper.dir, exper.audioCh, exper.sigCh, exper.desiredInSampRate);
        end
        
        function Exper = load_experiment(fileName)
            S = load(fileName, 'exper');
            Exper = SongTriggeredExperiment(S.exper.dir, S.exper.audioCh, S.exper.sigCh, S.exper.desiredInSampRate);
        end
    end
end