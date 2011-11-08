nlist = [49, 85]; %16
total_files = length(nlist);
escape_color = [.6 0 0]; % red
hit_color = [0 0 0]; % black
frequency_axis_limits = [0, 400];
magnitude_axis_limits = [1e-1, 5e1];
pitch_axis_limits = [-15, 15];
fraction_to_plot = 0.2;
nfft = 1024;

rand('twister', 312098) 
% set random number generator seed so we get the same random selection of 
% traces each time

figure
for n = 1:total_files
    d = load(['c:\stetner\data\figures\xmodel\temporal_resolution_lman' int2str(nlist(n)) '.mat']);
    
    included_motifs = 1:d.total_motifs < d.baseline_motifs & ...
        rand(1, d.total_motifs) < fraction_to_plot;
    song = squeeze(d.ra_output(1, :, included_motifs));
    is_escape = d.is_escape(included_motifs); % 1=>escape, 0=>hit

    subplot(total_files,2,2*n-1)
    plot(song(:, ~is_escape), 'Color', hit_color, 'LineWidth', 2)
    hold on
    plot(song(:, is_escape), 'Color', escape_color, 'LineWidth', 2)
    ylabel('\Delta Pitch (Hz)')
    xlabel('Time (ms)')
    ylim(pitch_axis_limits)
    title('Baseling song, color coded by escape/hit')
    
    subplot(total_files,2,2*n)
    e = dpss(d.motif_steps, 1);
    dpss_window = e(:, 1) * ones(1, sum(included_motifs));
    C = fft(song .* dpss_window, nfft);
    mag = abs(C(1:nfft/2, :));
    Fs = 1e3;%Hz
    f = Fs/2*linspace(0,1,nfft/2);
    loglog(f, mean(mag, 2),'Color', 'k', 'LineWidth', 2)
    xlabel('Frequency (Hz)')
    ylabel('Magnitude')
    xlim(frequency_axis_limits)
    ylim(magnitude_axis_limits)
    
end