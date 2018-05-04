%% What is the relationship between added dc and lman autocorrleation?
% To see how LMAN fluctuations affect the temporal resolution of learning,
% I change the spectrum of LMAN fluctuations by adding a DC component to
% them. Here I find the relationship between how much DC I add and the
% measured width of the autocorrelation function

dc_levels = [0 1 2 4 8 16 32 64];
maxlag = 100;
figure
hold all
for n = 1:length(dc_levels)
    % make lman noise (two channels)
    noise_down = generate_lman_noise_set_dc(500, 1000, dc_levels(n));
    noise_up = generate_lman_noise_set_dc(500, 1000, dc_levels(n));
    % combine it like we would if we were simulating
    dlm = 5;
    lman = max(noise_up + dlm, 0) - max(noise_down + dlm, 0);
    % do autocorrelation
    for col = 1:1000
        [c, lags] = xcorr(lman(:,col), maxlag, 'unbiased');
        lman_autocorrelation(:,col) = c / max(c);
    end
    plot(mean(lman_autocorrelation,2))
end