function displayAudioSpecgram(audio, sampleRate, startTime, maxfreq, colorRange, inchPerSec, inchPerkHz)
%DISPLAYAUDIOSPECGRAM Beautiful spectrogram for audio
%
%    DISPLAYAUDIOSPECGRAM(AUDIO, SAMPLERATE) displays a spectrogram of
%    AUDIO using overlapping windows of ten milliseconds. Window is shifted
%    by one millisecond. Frequency resolution is 1 Hz or better.
%
%    DISPLAYAUDIOSPECGRAM(AUDIO, SAMPLERATE, STARTTIME) sets the time of
%    the first sample of the spectrogram, in seconds. If STARTTIME is
%    omitted, the time starts at zero. STARTTIME only affects the numbers
%    displayed on the x-axis. The spectrogram always contains the full
%    signal from AUDIO.
%
%    DISPLAYAUDIOSPECGRAM(AUDIO, SAMPLERATE, STARTTIME, MAXFREQ) specifies
%    the maximum frequency (in Hz) to plot with MAXFREQ. It does not change
%    the frequency resolution. If MAXFREQ is omitted, the maximum frequency
%    is set to 6000 Hz.
%
%    DISPLAYAUDIOSPECGRAM(AUDIO, SAMPLERATE, STARTTIME, MAXFREQ,
%    COLORRANGE) specifies the color range of the spectrogram using
%    COLORRANGE. This is a two element long vector, where sound power of
%    COLORRANGE(1) or lower is mapped onto the first color in the colormap
%    and sound power COLORRANGE(2) or higher is mapped onto the last color
%    in the colormap. Colors in between are mapped linearly. If COLORRANGE
%    is omitted, the colormap spans the full range of the data.
%
%    DISPLAYAUDIOSPECGRAM(AUDIO, SAMPLERATE, STARTTIME, MAXFREQ,
%    COLORRANGE, INCHPERSEC, INCHPERKHZ) specifies the size of the
%    resulting image. If either INCHPERSEC or INCHPERKHZ is omitted, the
%    size of the figure is not changed.
if(length(audio) > 2000000)
    warning('displayAudioSpecgram: audio too long to take spectrogram.');
    return;
end

if(~exist('startTime', 'var'))
    startTime = 0;
end

if(~exist('maxfreq', 'var'))
    maxfreq = 6000;
end

%demean audio
audio = audio - mean(audio);

%Signal - xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
%time=0   ----------- (Segment 1): filter,take FFT, return as column of b 
%time=7          ----------- (Segment 2) ...
%                       ----------- (Segment 3) ...
%                       ---- (Size of overlap 4)  
%         ----------- (Segment size 11, best if power of 2)

window = ceil(0.01 * sampleRate); % ten milliseconds
noverlap = ceil(0.008 * sampleRate); % eight milliseconds
% Choose nfft to give one Hz frequency resolution, or better. For best
% performance of the fft algorithm, nfft is chosen to be a power of 2.
nfft = 2^nextpow2(sampleRate/2);
[b, freq, time] = spectrogram(audio, window, noverlap, nfft, sampleRate);
%b is a matrix of size length(freq) x length(time)
%If the sample rate is passed to specgram, then time is in seconds, and
%freq is in Hz.

%To plot the specgram we take the log of the power at each time and each
%frequency and display it as color
ndx = find(freq<maxfreq);
endTime = startTime + (length(audio)/sampleRate);
stepTime = (endTime - startTime)/ (length(time)-1);

t = startTime:stepTime:endTime;
pow = 20*log10(abs(b) + .02);
if(~exist('colorRange', 'var'))
    imagesc(t, freq(ndx), pow(ndx, :));
else
    imagesc(t, freq(ndx), pow(ndx, :), colorRange);
end
axis xy;
xlabel('time (s)');
ylabel('freq (Hz)');

if(exist('inchPerSec', 'var') && exist('inchPerkHz', 'var'))
    hf = gcf;
    ha = gca;       
    set(ha,'Units','inches');
    set(ha,'Position',[.75,.5,(endTime-startTime)*inchPerSec, (maxfreq/1000)*inchPerkHz]);
    set(hf,'PaperPosition',[.25,2.5,(endTime-startTime)*inchPerSec+1,(maxfreq/1000)*inchPerkHz + 1]);
    set(hf,'Units','inches');
    set(hf,'Position',[.25,2.5,(endTime-startTime)*inchPerSec+1,(maxfreq/1000)*inchPerkHz + 1]);
end


