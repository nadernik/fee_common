function figure_compare_model_lman_to_bird
% Figure comparing power spectra of pitch fluctuations from the model and from the actual bird

ddc = load('c:\stetner\data\pitchfluctuations\long_stacks_for_figure\mes010_yesdc.mat', 'nfft', 'fftcoefs', 'pitches');

rows = size(ddc.pitches, 1);
motifs = size(ddc.pitches, 2);

e = dpss(rows, 1);
dpss_window = e(:, 1) * ones(1, motifs);

simulated_lman = generate_lman_noise_mes010(rows,motifs);
f2 = fft(simulated_lman .* dpss_window, ddc.nfft);

plot(mean(abs(f2(1:ddc.nfft/2, :).^2), 2), 'Color', 'k', 'LineWidth', 3)
hold on
plot(mean(abs(ddc.fftcoefs(1:ddc.nfft/2,:).^2),2), 'LineWidth', 3)
hold off
set(gca, 'YScale', 'log', 'XLim', [0 500], 'XTick', 0:100:500, 'YLim', [1e-2 1e3])
legend('Model', 'Bird')
xlabel('Frequency (Hz)')
ylabel('Power')