close all
clear all

% Build a FIR filter to recreate frequency spectrum of observed pitch
% fluctuations.
datafile = 'c:\stetner\data\pitchfluctuations\mes021_stack1.mat';
filter_order = 50;

% Load data from file
d = load(datafile);

% Calculate average magnitude of frequency response
nfreq = length(d.freq); % number of frequency points
normalized_freq = linspace(0, 1, nfreq);
fft_coefs = d.fouriercoefs(1:nfreq, :); % only take positive frequencies
freq_response_magnitude = abs(fft_coefs);
avg_freq_response_magnitude = mean(freq_response_magnitude, 2)';

% Make FIR filter
fir_coefs = fir2(filter_order, normalized_freq, avg_freq_response_magnitude);

%
figure
plot(fir_coefs)

figure
noise = rand(5000,1);
noise_normalized = (noise - min(noise)) ./ (max(noise) - min(noise));
filtered_noise =  filter(fir_coefs, 1, noise);
filtered_noise(1:filter_order) = nan; % remove edge effects
filtered_noise_normalized = (filtered_noise - min(filtered_noise)) ./ (max(filtered_noise) - min(filtered_noise));
plot(noise_normalized)
hold all
plot(filtered_noise_normalized)

% sanity check: freq response magnitude
figure
[H, W] = freqz(fir_coefs, 1, nfreq);
new_fft_coefs = fft(filtered_noise_normalized(filter_order+1:end), nfreq*2);
new_freq_response_magnitude = abs(new_fft_coefs(1:nfreq));
loglog(avg_freq_response_magnitude)
hold all
loglog(abs(H))
% loglog(new_freq_response_magnitude)