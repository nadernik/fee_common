function stretching_lman(do_simulations)

num_traces = 15;
song_length = 200;
total_motifs = 1000;
threshold = 1;
nfft = 1024;
target_time = 100;
datafile = 'c:\stetner\data\figures\xmodel\stretching_lman.mat';

%%
if exist('do_simulations', 'var') && (do_simulations == 1)
    lman_normal = generate_lman_noise_streched_spectrum(song_length, total_motifs, 1);
    lman_slow = generate_lman_noise_streched_spectrum(song_length, total_motifs, 1/5);
    

    e = dpss(song_length, 1);
    dpss_window = e(:,1) * ones(1, total_motifs);
    C = fft(lman_normal .* dpss_window, nfft);
    power_normal = mean(abs(C(1:nfft/2, :)), 2).^2;
    C = fft(lman_slow .* dpss_window, nfft);
    power_slow = mean(abs(C(1:nfft/2, :)), 2).^2;
    Fs = 1e3;%Hz
    f = Fs/2*linspace(0,1,nfft/2);
    save(datafile)
end

%% hits and escapes
c = load('xmodel_color_scheme.mat');
load(datafile)
figure
subplot(2,1,1)
plot_hits_escapes(lman_normal)
set(gca, 'XTick', [])
set(gca, 'YTick', [])
subplot(2,1,2)
plot_hits_escapes(lman_slow)
set(gca, 'YTick', [])
set(gca, 'FontSize', 16)
xlabel('Time (ms)')

%% power spectra
figure
loglog(f, power_normal, ':k', 'LineWidth', 3)
hold on
loglog(f, power_slow, '-k', 'LineWidth', 3)
set(gca, 'FontSize', 16)
xlabel('Frequency (Hz)')
ylabel('Power')
xlim([0, 400])


    
%%
function plot_hits_escapes(y)
escape_trials = find(y(target_time, :) > threshold);
hit_trials = find(y(target_time, :) < threshold);
n = randsample(length(hit_trials), num_traces);
plot(y(:,hit_trials(n)), 'Color', c.hit, 'LineWidth', 2)
hold on
n = randsample(length(escape_trials), num_traces);
plot(y(:,escape_trials(n)), 'Color', c.escape, 'LineWidth', 2)
hold off
end
end