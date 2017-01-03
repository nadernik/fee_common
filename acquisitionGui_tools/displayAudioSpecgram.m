function displayAudioSpecgram(audio, sampleRate, startTime, maxfreq, colorRange, inchPerSec, inchPerkHz)

if(length(audio) > 2000000)
    warning('displayAudioSpecgram: audio too long to take spectrogram.');
    return;
end

if(~exist('startTime'))
    startTime = 0;
end

if(~exist('maxfreq'))
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

FFTSegmentSize = 2048; %In number of samples;
hanningWindowSize = FFTSegmentSize; %In number of samples.
segmentOverlap = round(FFTSegmentSize * .9); %In number of samples
[b, freq, time] = specgram(audio, FFTSegmentSize, sampleRate, hanningWindowSize, segmentOverlap);
%b is a matrix of size length(freq) x length(time)
%If the sample rate is passed to specgram, then time is in seconds, and
%freq is in Hz.

%To plot the specgram we take the log of the power at each time and each
%frequency and display it as color
ndx = find(freq<maxfreq);
endTime = startTime + (length(audio)/sampleRate);
stepTime = (endTime - startTime)/ (length(time)-1);

min(min(20*log10(abs(b(ndx,:)) + .02)))
max(max(20*log10(abs(b(ndx,:)) + .02)))

if(~exist('colorRange'))
    imagesc(startTime:stepTime:endTime,freq(ndx),20*log10(abs(b(ndx,:)) + .02)); axis xy;
else
    imagesc(startTime:stepTime:endTime,freq(ndx),20*log10(abs(b(ndx,:)) + .02), colorRange); axis xy;
end

xlabel('time (s)');
ylabel('freq (Hz)');

if(exist('inchPerSec'))
    hf = gcf;
    ha = gca;       
    set(ha,'Units','inches');
    set(ha,'Position',[.75,.5,(endTime-startTime)*inchPerSec, (maxfreq/1000)*inchPerkHz]);
    set(hf,'PaperPosition',[.25,2.5,(endTime-startTime)*inchPerSec+1,(maxfreq/1000)*inchPerkHz + 1]);
    set(hf,'Units','inches');
    set(hf,'Position',[.25,2.5,(endTime-startTime)*inchPerSec+1,(maxfreq/1000)*inchPerkHz + 1]);
end


