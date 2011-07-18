function final_noise = generate_lman_noise(rows, cols, debugging)
% GENERATE_LMAN_NOISE generates random noise with power spectrum matching 
% measured pitch fluctuations
%
% Noise has the same power spectrum as the pitch fluctuations measured in a
% 20 ms harmoic stack from bird 'mes011', including dc offset Noise will
% have same sampling rate as pitch data measured from the bird (1 kHz). 
% 
% Usage:
%   nz = generate_lman_noise(timesteps, trials)
%       returns matrix nz where each column is one trial of noise
%   nz = generate_lman_noise(timesteps, trials, debugging)
%       debugging can be set to true to show many plots to compare
%       simulated and actual noise



if ~exist('debugging', 'var')
    debugging = false;
end


d = load('c:\stetner\data\pitchfluctuations\mes011_yesdc.mat');
nfft = d.nfft;
cols = size(d.fftcoefs, 2);
frequency_domain_filter = abs(d.fftcoefs);

e = dpss(rows, 1);
dpss_window = e(:, 1) * ones(1, cols);

white_noise = rand(rows, cols) - 0.5; % zero mean white noise on average
white_noise_fft = fft(white_noise, nfft);

filtered_noise_fft = white_noise_fft .* frequency_domain_filter;
filtered_noise_ifft = ifft(filtered_noise_fft);
filtered_noise = real(filtered_noise_ifft(1:rows, :));

% Rescale to compensate for dpss window that was used to calculate
% the frequency domain filter (this is hidden pitchfluctuations.m) and for
% the length of the noise
scale_factor = (1 ./ mean(dpss_window(:,1))) ./ sqrt(rows/20);
final_noise = filtered_noise .* scale_factor;


if debugging
    close all
    
    % All pitch traces
    figure
    subplot(1,2,1)
    plot(final_noise)
    title('simulated')
    subplot(1,2,2)
    plot(d.pitches)
    title('actual')
    
    % Spectra
    figure
    f2 = fft(final_noise .* dpss_window, nfft);
    plot(mean(abs(f2(1:nfft/2, :)), 2))
    hold all
    plot(frequency_domain_filter(1:nfft/2))
    legend('simulated', 'actual')
    title('spectra')
    xlabel('Frequency (Hz)')
    ylabel('Magnitude')
    
    % Pitch density (spectrogram)
    figure
    centers = -10:1:10;
    for t = 1:rows
        nsimulated(t, :) = hist(final_noise(t,:), centers);
        if t < size(d.pitches, 1)
            nactual(t, :) = hist(d.pitches(t, :), centers);
        end
    end
    subplot(1,2,1)
    imagesc(1:rows, centers, nsimulated')
    title('simulated')
    xlabel('time (ms)')
    ylabel('% from mean')
    subplot(1,2,2)
    imagesc(1:size(d.pitches, 1), centers, nactual')
    title('actual')
    xlabel('time (ms)')
    ylabel('% from mean')
    
    % Histogram of dc offsets
    figure
    centers = -9:9;
    dc = mean(final_noise, 1);
    N = hist(dc, centers);
    N = N ./ sum(N);
    stairs(centers, N)
    hold all
    N = hist(d.offset(1,:), centers);
    N = N ./ sum(N);
    stairs(centers, N)
    legend('simulated', 'actual')
    xlabel('dc offset')
    ylabel('probablility')
    
    % ratio of spectra
    figure
    ratio = mean(abs(f2(1:nfft/2, :)), 2) ./ frequency_domain_filter(1:nfft/2)';
    plot(ratio)
    title('ratio of spectra')
    
    keyboard
    
    % Example pitch traces
    figure
    for n = 1:cols
        subplot(1,2,1)
        plot(final_noise(:, n))
        axis([0 rows -10 10])
        title('simulated')
        subplot(1,2,2)
        plot(d.pitches(:, n))
        axis([0 size(d.pitches, 1) -10 10])
        title('actual')
        pause
    end
end

end

