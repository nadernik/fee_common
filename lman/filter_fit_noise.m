close all
clear all

noise_length = 20; % number of points in noise
filename = 'c:\stetner\data\pitchfluctuations\mes011_yesdc.mat'; % file to load for real data
% filter_trial = 100; % trial of real data to use as filter

% Load real data
d = load(filename);
nfft    = d.nfft;
freqmag = sqrt(mean(d.freqpower, 2));
freq    = d.freq;

% throw out low frequencies for fitting
keep = freq >= 50;
fitfreq = freq(keep);
fitfreqmag = freqmag(keep);

% do the fitting
coefguesses = [24 0.02 1 ];
fiteq = fittype('a*exp(-b*x)+c',...
     'dependent',{'y'},'independent',{'x'},...
     'coefficients',{'a', 'b', 'c'});
myfit = fit(fitfreq,fitfreqmag,fiteq,'Startpoint',coefguesses);

% create noise
noise = rand(noise_length, 1);

% filter noise in frequency domain
e = dpss(noise_length, 1);
f_noise = fft(e(:, 1) .* noise, nfft);
f_filter = [myfit(freq); myfit(flipdim(freq, 1))];
f_filtered_noise = f_noise .* f_filter;
filtered_noise = real(ifft(f_filtered_noise));
filtered_noise = filtered_noise(1:noise_length);

% plot 
figure
subplot(2,2,1)
plot(freq, freqmag)
hold all
plot(freq, myfit(freq))
xlabel('Frequency (Hz)')
ylabel('Magnitude')
title('Fit of filter')

subplot(2,2,2)
plot(filtered_noise)
xlabel('Time (ms)')
title('Filtered Noise')

subplot(2,2,3)
f = fft(filtered_noise, nfft);
plot(f_filter(1:nfft/2))
hold all
plot(abs(f_filtered_noise(1:nfft/2)))
plot(abs(f(1:nfft/2)))

disp(num2str(mean(filtered_noise)))
