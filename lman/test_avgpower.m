cols = 1000;
nfft = 1024;
rows = round(linspace(10,1000));
avgpower = zeros(size(rows));

for nr = 1:length(rows)
    white_noise = randn(rows(nr), cols); % zero mean gaussian white noise
    white_noise_fft = fft(white_noise, nfft);
    avgpower(nr) = mean(mean(abs(white_noise_fft)));
end

plot(rows, avgpower)

% looks sorta like sqrt(rows) but grows slightly slower