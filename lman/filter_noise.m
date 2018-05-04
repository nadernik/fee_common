close all
clear all

noise_length = 20; % number of points in noise
filename = 'c:\stetner\data\pitchfluctuations\mes011_yesdc.mat'; % file to load for real data
% filter_trial = 100; % trial of real data to use as filter

% Load real data
d = load(filename);
real_pitch = d.pitches;
nfft = d.nfft;

for n = 1:1000
    % Generate white noise
    noise = rand(noise_length, 1) - .5;

    % Fourier transform noise
    e = dpss(noise_length, 1);
    f_noise = fft(e(:,1) .* noise, nfft);
    f_noise = f_noise ./ mean(abs(f_noise)) .* (11/3);

    % Filter noise in frequency domain using real data as the filter
    freqpower = sqrt(mean(d.freqpower, 2));
%     freqpower(d.freq < 100) = 0;
    f_filter = [freqpower; flipdim(freqpower, 1)];
    % f_noise_filtered = f_noise .* ones(size(f_filter));
    f_noise_filtered = f_noise .* f_filter;

    % Transform noise back to time domain
    temp = real(ifft(f_noise_filtered));
    noise_filtered(:, n) = temp(1:noise_length);% ./ d.e(:,1);
end


%%

% Plot noise along with the signal we used to filter it
% figure
% 
% subplot(1,2,1)
% plot(noise_filtered)
% 
% subplot(1,2,2)
% f = fft(noise_filtered, nfft);
% plot(f_filter(1:nfft/2, :))
% hold all
% plot(abs(f_noise_filtered(1:nfft/2, :)))
% plot(abs(f(1:nfft/2, :)))
% 
% disp(num2str(mean(noise_filtered)))
% 
% figure
% mn = mean(abs(noise_filtered), 2);
% plot(mn)

figure
subplot(2,3,1)
mn = mean(abs(noise_filtered), 2);
flattened = 11/3*noise_filtered ./ (mn*ones(1,1000));
plot(flattened)
axis([0 21 -15 15])
subplot(2,3,2)
hist(mean(flattened))
subplot(2,3,3)
fflat = fft(flattened .* (e(:,1) * ones(1, 1000)), nfft);
fpow = abs(fflat(1:nfft/2, :));
% plot(d.freq, fpow)
hold on
plot(d.freq, mean(fpow, 2), 'k', 'LineWidth', 3)
plot(d.freq, freqpower, 'g', 'LineWidth', 3)
axis([0 500 0 13])

subplot(2,3,4)
plot(noise_filtered)
axis([0 21 -15 15])
subplot(2,3,5)
hist(mean(noise_filtered))
subplot(2,3,6)
ffilt = fft(noise_filtered .* (e(:,1) * ones(1, 1000)), nfft);
fpow = abs(ffilt(1:nfft/2, :));
% plot(d.freq, fpow)
hold on 
plot(d.freq, mean(fpow, 2), 'k', 'LineWidth', 3)
plot(d.freq, freqpower, 'g', 'LineWidth', 3)
axis([0 500 0 13])