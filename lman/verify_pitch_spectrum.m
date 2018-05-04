% Tests to make sure that generated LMAN fluctuations match the measured
% pitch fluctuations.

steps = 200;
motifs = 1000;
dc = 5;

% LMAN noise is composed of two signals -- pitch-up neuron and pitch-down
% neuron summed together.
pitch_up_input   = generate_lman_noise(steps, motifs);
pitch_down_input = generate_lman_noise(steps, motifs);
pitch_up_output   = max(pitch_up_input + dc,   0); % output must be nonnegative
pitch_down_output = max(pitch_down_input + dc, 0);
simulated_pitch = pitch_up_output - pitch_down_output;

% Plot spectra
ddc = load('c:\stetner\data\pitchfluctuations\black401_yesdc.mat');
figure
a(1) = subplot(2,1,1);
e = dpss(steps, 1);
dpss_window = e(:, 1) * ones(1, motifs);
f2 = fft(simulated_pitch .* dpss_window, ddc.nfft);
plot(mean(abs(f2(1:ddc.nfft/2, :)), 2))
hold all
plot(mean(abs(ddc.fftcoefs(1:ddc.nfft/2,:)), 2))
legend('simulated', 'actual')
title('spectra')
xlabel('Frequency (Hz)')
ylabel('Magnitude')

keyboard

for n = 1:motifs
    plot(simulated_pitch(:, n))
    ylim([-10 10])
    pause
end

% same, but without rectification
a(2) = subplot(2,1,2);
pitch_up_output = pitch_up_input;
pitch_down_output = pitch_down_input;
simulated_pitch = pitch_up_output - pitch_down_output;
f2 = fft(simulated_pitch .* dpss_window, ddc.nfft);
plot(mean(abs(f2(1:ddc.nfft/2, :)), 2))
hold all
plot(mean(abs(ddc.fftcoefs(1:ddc.nfft/2,:)), 2))
legend('simulated', 'actual')
title('spectra')
xlabel('Frequency (Hz)')
ylabel('Magnitude')

linkaxes(a, 'x')