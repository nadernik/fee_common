nlist = [16, 49, 85];
total_files = length(nlist);
escape_color = [1 0 0]; % red
hit_color = [0 0 0]; % black

for n = 1:total_files
    d = load(['c:\stetner\data\figures\xmodel\temporal_resolution_lman' int2str(nlist(n)) '.mat']);
    
    song = squeeze(d.ra_output(1, :, 1:d.baseline_motifs));
    is_escape = d.is_escape(1:d.baseline_motifs); % 1=>escape, 0=>hit

    subplot(total_files,2,2*n-1)
    plot(song(:, ~is_escape), 'Color', hit_color)
    hold on
    plot(song(:, is_escape), 'Color', escape_color)
    ylabel('\Delta Pitch (Hz)')
    xlabel('Time (ms)')
    title('Baseling song, color coded by escape/hit')
    
    subplot(total_files,2,2*n)
    C = fft(song .* dpss_window, nfft);
    mag = abs(C(1:nfft/2, :));
    Fs = 1e3;%Hz
    f = Fs/2*linspace(0,1,nfft/2);
    loglog(f, mean(mag, 2))
    xlabel('Frequency (Hz)')
    ylabel('Magnitude')
    xlim([0, 400])
    
end

    
% figure
% 
% frac = 0.1;
% stretches = [1/5, 1, 5];
% song_length = 200;
% motifs = 200;
% total_stretches = length(stretches);
% nfft = 1024;
% e = dpss(song_length, 1);
% dpss_window = e(:, 1) * ones(1, motifs);
% for n = 1:total_stretches
%     subplot(total_stretches,2,2*n-1)
%     lman = generate_lman_noise_streched_spectrum(song_length, motifs, stretches(n));
%     p = rand(1,motifs) < frac;
%     plot(lman(:,p))
%     subplot(total_stretches,2,2*n)
%     C = fft(lman .* dpss_window, nfft);
%     mag = abs(C(1:nfft/2, :));
%     Fs = 1e3;%Hz
%     f = Fs/2*linspace(0,1,nfft/2);
%     loglog(f, mean(mag, 2))
%     xlabel('Frequency (Hz)')
%     ylabel('Magnitude')
%     xlim([0, 400])
% end
