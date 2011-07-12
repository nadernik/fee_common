function pitchfluctuations(varargin)
% PITCHFLUCTUATIONS
%
% Usage:
%   pitchfluctuations(birdname, expernames, targetsyllable, timewindow)
%     
%   pitchfluctuations(filename)
%     Load data from a previous run of pitchfluctuations
%   pitchfluctuations( ... , 'Param1', value1, 'Param2', value2 ... )
%     Change parameters. All parameters with their default values are
%     listed below:
%
% ---------------Parameters--------------
% RootDir = 'c:\stetner\data'; 
% MaxDeltaPitch = 100 Hz, exclude pitch trajectories that 
% MaxLag = 10; max lag in time steps for autocorrelation
% Save = ''; name of file to which data will be saved 
% PlotPitchTraces = true;
% PlotPowerSpectrum = true;
% PlotFluctuationOffset = true;
% PlotAutocorrelation = true;
% PlotPitchHistrogram = true;

if nargin < 4 || ~isnumeric(varargin{3}) || ~isnumeric(varargin{4})
    loaded = true;
    temp = load(varargin{1});
    pitches = temp.pitches;
    birdname = temp.birdname;
    expernames = temp.expernames;
    targetsyllable = temp.targetsyllable;
    timewindow = temp.timewindow;
    Fs = temp.Fs;
    t = temp.t;
    pargs = varargin(2:end);
else
    loaded = false;
    birdname = varargin{1};
    expernames = varargin{2};
    targetsyllable = varargin{3};
    timewindow = varargin{4};
    pargs = varargin(5:end);
end

P.RootDir = 'c:\stetner\data';
P.MaxDeltaPitch = 100; %Hz
P.MaxLag = 10;
P.DC = true;
P.Save = '';

P.PlotPitchTraces       = true;
P.PlotPowerSpectrum     = true;
P.PlotFluctuationOffset = true;
P.PlotAutocorrelation   = true;
P.PlotPitchHistrogram   = true;

P = parseargs(P, pargs{:});

%% Load data from files
if ~loaded
    if ~iscell(expernames)
        expernames = {expernames};
    end
    pitches = [];
    np = 0;
    for nexper = 1:length(expernames)
        for part = 1:1000
            % Load processed annotation files
            miscfile = annofilename(birdname, expernames{nexper}, ...
                'Part', part, 'RootDir', P.RootDir, 'Type', 'misc');
            pitchfile = annofilename(birdname, expernames{nexper}, ...
                'Part', part, 'RootDir', P.RootDir, 'Type', 'pitch');
            if exist(miscfile, 'file') && exist(pitchfile, 'file')
                load(miscfile)
                load(pitchfile)

                % Start by selecting the target syllable
                selected = [misc.segs.segType] == targetsyllable;

                % combine selected syllables with selected syllables from other
                % files
                nadd = sum(selected);
                selectedindex = find(selected);
                for n = 1:nadd
                    ii = selectedindex(n);
                    np = np + 1;
                    newpitch = snippet(pitch.segs(ii).pitch, timewindow, 't', pitch.segs(ii).pitchTime, 'units', 'seconds');
                    pitches = catnanpad(2, pitches, newpitch');
                    t(np) = misc.segs(ii).absStart;
                end
            end
        end
    end

    % Throw out trials where pitch fluctuates unrealistically
    keepers = all(diff(pitches) <= P.MaxDeltaPitch);
    pitches = pitches(:, keepers);
    t = t(keepers);

    % mean pitch over time across all syllables
    meanpitch = mean(pitches, 2) * ones(1, size(pitches, 2));
    % convert pitches to percent difference from mean pitch
    pitches = (pitches - meanpitch) ./ meanpitch * 100;
    
    % Optionally remove DC offset from pitches.
    if ~P.DC
        dc = ones(size(pitches, 1), 1) * mean(pitches, 1);
        pitches = pitches - dc;
    end
    
    Fs = 1/mode(diff(pitch.segs(ii).pitchTime));
end

%%
% show overlay of all selected syllables with target region highlighted
if P.PlotPitchTraces
    figure
    axes('FontSize', 16)
    plot(pitches)
    xlabel('Time (ms)')
    ylabel('% difference from mean pitch')
end

%% Power spectrum
if P.PlotPowerSpectrum

    nfft = 1024;
    
    % Window after padding
%     e = dpss(nfft, 4);
%     fftcoefs = zeros(nfft, size(pitches, 2), size(e, 2));
%     for nwin = 1:size(e, 2)
%         padded = zeros(nfft, size(pitches, 2));
%         padded(1:size(pitches, 1), :) = pitches;
%         windowed = padded .* (e(:, nwin) * ones(1, size(padded, 2)));
%         fftcoefs(:,:,nwin) = fft(windowed, nfft);
%     end
%     freqpower = abs(mean(fftcoefs(1:nfft/2,:,:), 3)).^2;
%     freq = linspace(0, 1, nfft/2)' * Fs/2;
    
    % Window before padding
    e = dpss(size(pitches, 1), 4);
        windowed = pitches .* (e(:, 1) * ones(1, size(pitches, 2)));
        fftcoefs = fft(windowed, nfft);
    freqpower = abs(fftcoefs(1:nfft/2,:)).^2;
    freq = linspace(0, 1, nfft/2)' * Fs/2;

%     freqpower = zeros(nfft / 2 + 1, size(pitches, 2));
%     for col = 1:size(pitches, 2)
%         [Pxx, freq] = pmtm(pitches(:, col),1.5,nfft,Fs,0.99);
%         freqpower(:, col) = Pxx;
%     end
    
    % plot fft over time and over trials
%     figure
%     axes('FontSize', 16)
%     trials = 1:length(t);
%     imagesc(trials, freq, freqpower)
%     xlabel('Trials')
%     ylabel('Frequency (Hz)')
%     title('Pitch Fluctuations in all trials')
    
    
    % Power on log log plot
    figure
    axes('FontSize', 16, 'XScale', 'log', 'YScale', 'log')
    hold on
    loglog(freq, freqpower)
    loglog(freq, mean(freqpower, 2), 'k', 'LineWidth', 3)
    xlabel('Frequency (Hz)')
    ylabel('Power')
    title('Average power spectrum of pitch')
end

%% plot dc component over trials
if P.PlotFluctuationOffset
    offset = mean(pitches, 1);
    figure
    axes('FontSize', 16)
    plot(offset)
    xlabel('Trials')
    ylabel('DC Offset (%)')
    
    fluctuations = max(pitches) - min(pitches);
    figure
    axes('FontSize', 16)
    scatter(fluctuations, offset)
    xlabel('Fluctuations (%)')
    ylabel('Offset (%)')
    
    figure
    hist(offset ./ fluctuations)
    xlabel('Offset:Fluctuation Ratio')
    
end

%% plot autocorrelation
if P.PlotAutocorrelation
    acorr = zeros(P.MaxLag * 2 + 1, size(pitches, 2));
    for col = 1:size(pitches, 2)
        [c, lags] = xcorr(pitches(:, col), P.MaxLag, 'unbiased');
        acorr(:, col) = c / max(c);
    end
    

    figure
    axes('FontSize', 16)
    plot(lags, acorr)
    hold on
    plot(lags, mean(acorr, 2), 'k', 'LineWidth', 3)
    xlabel('Lag (ms)')
    ylabel('Autocorrelation')
end

%% 3-D pitch histogram
if P.PlotPitchHistrogram
    centers = -10:0.5:10;
    % hdata = zeros(size(pitches, 1), length(centers));
    hdata = hist(pitches', centers);
    figure
    pitchtime = (1:size(pitches, 1)) * 1000/Fs; % milliseconds
    imagesc(pitchtime, centers, hdata)
    ylabel('% difference from mean pitch')
    xlabel('Time (ms)')
end

%% Save
if ~isempty(P.Save)
    save(P.Save)
end
        