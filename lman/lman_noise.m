function final_noise = lman_noise(rows, cols)
debugging = true;
% noise will have same sampling rate as real pitch data (1 kHz)

d = load('c:\stetner\data\pitchfluctuations\mes011_yesdc.mat');
nfft = d.nfft;

frequency_domain_filter = mean(abs(d.fftcoefs), 2) * ones(1, cols);

e = dpss(rows, 1);
dpss_window = e(:, 1) * ones(1, cols);
white_noise = rand(rows, cols);
white_noise_fft = fft(white_noise .* dpss_window, nfft);
filtered_noise_fft = white_noise_fft .* frequency_domain_filter;
filtered_noise_ifft = ifft(filtered_noise_fft);
filtered_noise = real(filtered_noise_ifft(1:rows, :));

% normalize to get rid of artifact from dpss window
normalized_filtered_noise = filtered_noise ./ (mean(filtered_noise, 2) * ones(1, cols)) - 1;

% Rescale back to proper amplitude
normalized_filtered_noise_fft = fft(normalized_filtered_noise.* dpss_window, nfft);
ratio = frequency_domain_filter(:,1) ./ mean(abs(normalized_filtered_noise_fft), 2);
scale_factor = mean(ratio);
final_noise = normalized_filtered_noise .* scale_factor;

if debugging
    close all
    
    figure
    subplot(1,2,1)
    plot(final_noise)
    title('simulated')
    subplot(1,2,2)
    plot(d.pitches)
    title('actual')
    
    figure
    f1 = fft(normalized_filtered_noise .* dpss_window, nfft);
    plot(mean(abs(f1(1:nfft/2, :)), 2))
    hold all
    f2 = fft(final_noise .* dpss_window, nfft);
    plot(mean(abs(f2(1:nfft/2, :)), 2))
    plot(frequency_domain_filter(1:nfft/2))
    
    figure
    centers = -10:1:10;
    for t = 1:rows
        nsimulated(t, :) = hist(final_noise(t,:), centers);
        nactual(t, :) = hist(d.pitches(t, :), centers);
    end
    subplot(1,2,1)
    imagesc(1:rows, centers, nsimulated')
    title('simulated')
    subplot(1,2,2)
    imagesc(1:rows, centers, nactual')
    title('actual')
    
    figure
    centers = -9:9;
    N = hist(d.offset(1,:), centers);
    N = N ./ sum(N);
    stairs(centers, N)
    hold all
    dc = mean(final_noise, 1);
    N = hist(dc, centers);
    N = N ./ sum(N);
    stairs(centers, N)
    
    keyboard
end

end

