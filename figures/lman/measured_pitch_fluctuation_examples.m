function measured_pitch_fluctuation_examples
%% Birds
birddatafile = 'c:\stetner\data\pitchfluctuations\long_stacks_for_figure\birds.mat';
load(birddatafile, 'b')

example_birds = [2, 4, 9];

% fast fluctuations
assert(strcmp(b(example_birds(1)).name, 'mes003'))
b(example_birds(1)).example_ndx = 1;
b(example_birds(1)).traces_ndx = [1 2 3];
b(example_birds(1)).clim = [-90, -45];

% typical fluctuations
assert(strcmp(b(example_birds(2)).name, 'mes010'))
b(example_birds(2)).example_ndx = 1;
b(example_birds(2)).traces_ndx = [1 2 3];
b(example_birds(2)).clim = [-90, -25];

% slow fluctuations
assert(strcmp(b(example_birds(3)).name, 'black401'))
b(example_birds(3)).example_ndx = 12;
b(example_birds(3)).traces_ndx = [1 4 12];
b(example_birds(3)).clim = [-100, -55];

%% Parameters
datafile = @(x) sprintf('C:\\stetner\\data\\pitchfluctuations\\long_stacks_for_figure\\%s_yesdc.mat', x);
pitches_ylim = [-10, 10];

%% Spectrogram parameters
winSize = 180; % previously 1024
winStep = 40; % 1 ms step with 40 kHz sapling rate
NFFT = 2^10; % yields 1 Hz precision with 40 kHz sampling rate.
fs = 40000;
fmin = 100;
fmax = 8000;

%% Plot spectrograms and pitch traces

% For each bird...
max_syllable_duration = -Inf;
max_harmonic_stack_duration = -Inf;
e = dpss(winSize,1);
for n = 1:length(example_birds)
    d = load(datafile(b(example_birds(n)).name));
    
    % Display spectrogram of example syllable
    audiofile = annofilename(b(example_birds(n)).name, d.expernames{1}, 'Type', 'audio', 'RootDir', d.P.RootDir);
    a = load(audiofile);
    miscfile = annofilename(b(example_birds(n)).name, d.expernames{1}, 'Type', 'misc', 'RootDir', d.P.RootDir);
    m = load(miscfile);
    selected = [m.misc.segs.segType] == d.targetsyllable;
    selected_ndx = find(selected);
    subplot(2, length(example_birds), n)
    showspecgram = @(jj) specgram_helper(a.rawaudio.segs(selected_ndx(jj)).audio);
    if isempty(b(example_birds(n)).example_ndx)
        for ii = 1:length(selected_ndx)
            showspecgram(ii)
            title(int2str(ii))
            pause
        end
    else
        showspecgram(b(example_birds(n)).example_ndx)
    end

    % Put a box around the harmonic stack
    X = d.timewindow([1 1 2 2 1]);
    yy = ylim + [+0.05, -0.05] * diff(ylim);
    Y = yy([1 2 2 1 1]);
    line(X, Y, 'Color', 'w', 'LineWidth', 3)
    
    % Display example traces
    subplot(2, length(example_birds), length(example_birds) + n)
    plot(d.pitchtime, d.pitches(:, b(example_birds(n)).traces_ndx), 'Color', b(example_birds(n)).color)
    
    % Update max durations
    syllable_duration = length(a.rawaudio.segs(selected_ndx(b(example_birds(n)).example_ndx)).audio) / fs;
    max_syllable_duration = max(max_syllable_duration, syllable_duration);
    max_harmonic_stack_duration = max(max_harmonic_stack_duration, diff(d.timewindow) * 1000);
end

% Draw scale bars
patch([70, 70, 71, 71], [-9, -4, -4, -9], 'k') % 5 percent pitch change for y axis
patch([40, 40, 30, 30], [-9, -8.8, -8.8, -9], 'k') % 10 milliseconds for x axis

% Set all axes to have the same limits
for n = 1:length(example_birds)
    subplot(2, length(example_birds), n)
    setticklimx([0, max_syllable_duration])
    axis off
    subplot(2, length(example_birds), length(example_birds) + n)
    xlim([0, max_harmonic_stack_duration])
    ylim(pitches_ylim)
    axis off
end

function specgram_helper(audio)
audio = audio - mean(audio);
[s,f,t,p] = spectrogram(audio, e(:,1), winSize - winStep, NFFT, fs);
infreq = (f >= fmin) & (f <= fmax);
imagesc(t,f(infreq),10*log10(abs(p(infreq,:))))
set(gca, 'YDir', 'normal', 'CLim', b(example_birds(n)).clim)
% axis off
end
end

