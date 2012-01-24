% You should have already run lman/pitchfluctuations_all_birds.m
clear all
close all

% set seed of random number generator
total_traces = 5;
fs=1e3;

b(1).name= '1772';
b(2).name= 'black401';
b(3).name= 'blue298';
b(4).name= 'mes003';
b(5).name= 'mes010';
b(6).name= 'mes011';
b(7).name= 'mes013';
b(8).name= 'mes020';
b(9).name= 'mes021';
% b(10).name= 'mes021';

b(1).exper = '2010-08-26';
b(2).exper = '2010-12-20';
b(3).exper = '2010-12-12';
b(4).exper = '2011-02-08';
b(5).exper = '2011-02-26';
b(6).exper = '2011-03-03';
b(7).exper = '2011-03-10';
b(8).exper = '2011-04-09';
b(9).exper = '2011-05-03';
% b(10).exper = '2011-05-03';

b(1).syllable = 1;
b(2).syllable = 1;
b(3).syllable = 1;
b(4).syllable = 2;
b(5).syllable = 2;
b(6).syllable = 2;
b(7).syllable = 1;
b(8).syllable = 2;
b(9).syllable = 1;
% b(10).syllable = 1;


c = colormap;
colors = c(round(linspace(1,64,length(b))),:);
%% Load all data
for ii = 1:length(b)
    try
    pitchfluctuations_data_file = sprintf('c:\\stetner\\data\\pitchfluctuations\\long_stacks_for_figure\\%s_yesdc.mat', b(ii).name)
    load(pitchfluctuations_data_file, 'P')
    
    % box around target area
    debugdisp('Getting time window')
    load(pitchfluctuations_data_file, 'timewindow')
    b(ii).time_window = timewindow;
    clear timewindow
    
    % example spectrogram
    debugdisp('Getting audio')
    [all_audio, absTime, syllType, dura] = getProcessedAudio(b(ii).name, 'experNames', b(ii).exper, 'targetSyll', b(ii).syllable);
    irnd = ceil(rand*length(all_audio)); % choose a single example at random
    b(ii).audio_full = all_audio{irnd};
    clear all_audio absTime syllType dura irnd

    % pitch traces
    debugdisp('Getting full pitch traces')
    [pitchTraj, absTime, syllType, dura] = getProcessedPitchTrajectories(b(ii).name, 'experNames', b(ii).exper, 'targetSyll', b(ii).syllable);
    % discard traces with large fluctuations in pitch in target region
    ndx = randperm(length(pitchTraj));
    samples_found = 0;
    jj = 1;
    b(ii).mx = -inf;
    b(ii).mn = inf;
    while samples_found < total_traces
        target = snippet(pitchTraj{ndx(jj)}, b(ii).time_window, 'units', 'seconds', 'fs', 1e3);
        if all(abs(diff(target)) <= P.MaxDeltaPitch)
            samples_found  = samples_found+1;
            b(ii).pitch_full{samples_found} = pitchTraj{ndx(jj)};
            b(ii).mx = max(b(ii).mx, max(target));
            b(ii).mn = min(b(ii).mn, min(target));
        else
            %disp('rejected')
        end
        jj = jj+1;
    end
    debugdisp('Getting pitch snippets')
    load(pitchfluctuations_data_file, 'pitches')
    irnd = ceil(rand(1,total_traces)*length(pitches));
    b(ii).pitch_harmonic = pitches(:,irnd); % snippet of pitch
    clear pitchTraj absTime syllType dura pitches irnd

    % autocorrelation
    debugdisp('Autocorrelation')
    load(pitchfluctuations_data_file, 'acorr', 'lags')
    if ~exist('acorr', 'var')
        acorr = zeros(P.MaxLag * 2 + 1, size(pitches, 2));
        for col = 1:size(pitches, 2)
            [c, lags] = xcorr(pitches(:, col), P.MaxLag, 'unbiased');
            acorr(:, col) = c / max(c);
        end
    end
    b(ii).acorr = mean(acorr, 2);
    b(ii).lags = lags;
    clear acorr c lags P
    
    % power spectrum
    debugdisp('Power spectrum')
    load(pitchfluctuations_data_file, 'freq', 'freqpower')
    b(ii).freq = freq;
    b(ii).freqpower = mean(freqpower,2);
    
    catch
        keyboard
    end
end

% reorder by value of autocorrleation at longest lag
temp = [b.acorr];
[junk, ndx] = sort(temp(1,:));
b = b(ndx);

%% Plot all autocorrelations
figure
set(gca, 'ColorOrder', colors)
hold all
for ii = 1:length(b)
    plot(b(ii).lags, b(ii).acorr)
end
xlabel('Lag (ms)')
ylabel('Correlation (normalized)')
% legend({b.name})

%% Plot all spectrograms
figure
set(gca, 'ColorOrder', colors)
hold all
for ii = 1:length(b)
    plot(b(ii).freq, b(ii).freqpower)
end
set(gca, 'YScale', 'log')
xlabel('Frequency (Hz)')
ylabel('Power')

for ii = 1:length(b)
    figure
    a(1) = subplot(2,1,1);
    displaySpecgramQuick(b(ii).audio_full, 40e3)
    ylabel('Frequency (kHz)')
    set(gca, 'XTickLabel', {'0', '2', '4', '6'})
    a(2) = subplot(2,1,2);
    hold on
    for jj = 1:length(b(ii).pitch_full)
        t = (1:length(b(ii).pitch_full{jj}))/fs;
        plot(t, b(ii).pitch_full{jj},'Color', colors(ii,:))
    end
    mx = b(ii).mx;
    mn = b(ii).mn;
    rg = 250; % range
    
    line(b(ii).time_window, (mn-rg)*ones(1,2), 'LineWidth', 4, 'Color', 'r') %bottom
    line(b(ii).time_window, (mx+rg)*ones(1,2), 'LineWidth', 4, 'Color', 'r') %top
    line(b(ii).time_window(1)*ones(1,2), [mx+rg, mn-rg], 'LineWidth', 4, 'Color', 'r') %left
    line(b(ii).time_window(2)*ones(1,2), [mx+rg, mn-rg], 'LineWidth', 4, 'Color', 'r') %right
    
    title(b(ii).name)
    linkaxes(a, 'x')
           
end

%% plot example pitch traces from harmonic stacks of a few birds
figure
p = 0;
for ii = [2, 4, 9]
    p = p+1;
    a(p) = subplot(1,3,p);
    plot(b(ii).pitch_harmonic, 'LineWidth', 2, 'Color', colors(ii,:))
    title(b(ii).name)
    axis off
end
linkaxes(a, 'xy')
xlim([0 50])
ylim([-10 10])
hold on
% 10 ms scale bar
fill([40 40 50 50], [-10, -9.8, -9.8, -10], 'k')
text(45, -9.6, '10 ms')
% 5% delta pitch scale bar
fill([0 0 1 1],[-5, -10, -10, -5], 'k')
text(3,-7,'5% \Delta pitch')
return
%% example randomly generated pitch traces
offset     = 5;
pitch_up   =  max(generate_lman_noise(50, total_traces) + offset,0);
pitch_down = -max(generate_lman_noise(50, total_traces) + offset,0);
song = pitch_up + pitch_down;
figure

a(1) = subplot(1,3,1);
plot(pitch_up,'k', 'LineWidth', 2)
hold on
plot(xlim, [0 0],'k')
ylim([-15, 15])
axis off

a(2) = subplot(1,3,2);
plot(pitch_down,'k', 'LineWidth', 2)
hold on
plot(xlim, [0 0], 'k')
ylim([-15, 15])
axis off

a(3) = subplot(1,3,3);
plot(song,'k', 'LineWidth', 2)
hold on
plot(xlim, [0 0],'k')
ylim([-15, 15])
axis off

% scale bar (x)
fill([50 50 40 40], -[15 14.7 14.7 15],'k')
text(55,-14,'10 ms')

% scale bar (y)
fill([0 0 2 2],[-15, -10, -10, -15], 'k') 
text(5,-12,'5% \Delta pitch')

%% compare power spectra of actual and simulated pitch fluctuations

rows = 100;
motifs = 1000;

e = dpss(rows, 1);
dpss_window = e(:, 1) * ones(1, motifs);

simulated_lman = generate_lman_noise(rows,motifs);
ddc = load('c:\stetner\data\pitchfluctuations\black401_yesdc.mat', 'nfft', 'fftcoefs');
f2 = fft(simulated_lman .* dpss_window, ddc.nfft);

figure
plotmean95pct(abs(f2(1:ddc.nfft/2, :)), 'Color', [0 0 1], 'LineWidth', 3)
hold on
plotmean95pct(abs(ddc.fftcoefs(1:ddc.nfft/2,:)), 'Color', [0 1 0], 'LineWidth', 3)
hold off

% legend('simulated', 'actual')
title('spectra')
xlabel('Frequency (Hz)')
ylabel('Magnitude')