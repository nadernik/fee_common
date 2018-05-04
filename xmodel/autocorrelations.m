%% Does autocorrelation match kernel?

maxlag = 200;
filename = 'C:\stetner\data\figures\xmodel\random_caf1.mat';

% Reward
d = load(filename);
for motif = 1:d.total_motifs
    [c, lags] = xcorr(d.reward(:,motif), maxlag, 'unbiased');
    reward_autocorrelation(:,motif) = c / max(c);
end
plot(mean(reward_autocorrelation, 2))
hold all
plot(d.rkernel)