function [bDetect, tElapsed, score, songRatio, songDet] = songDetector5(audio, fs, songDuration, durationThreshold, ratioThreshold, minFreq, maxFreq, bDebug)
%Author: Aaron Andalman 2006

%audio: the audio signal
%fs: the sampling rate
%songDuration: the min duration of the birds singing bouts in seconds.  0.6
%   works well
%durationThreshold: a parameter between 0 to 1, representing the fraction of sound
%   during singing that will be above the ratio threshold (see below).  A
%   value of 0.5 or 0.6 works well depending on the density of song.
%ratioThreshold: the ratio of song frequency power to nonsong frequency
%   power that is considered singing.  A ratio of between 2 or 3 works for
%   my rig, but this might depend on your mic and recording set up.
%minFreq: the minimum freq that is considered in the singing range (1000Hz)
%maxFreq: the maximum freq that is considered in the singing range (7000Hz)
%bDebug: if true a figure is displayed.


%Technique:
%1. Course Spectram
%2. Generate course binary signal. Signal is 1 if time slice of spectrogram
%has a ratio of song frequency power to non-song frequency power that
%exceeds a ratioThreshold.
%3. If great enough percentage of consequtive time points are value of 1,
%then song detected.

actInSampleRate = fs;
sig = audio;

%Parameters for part 1.  Spectrogram Parameters
windowSize = actInSampleRate/20;
windowOverlap = fix(windowSize*.5);

%Parameters for Part 2.  Frequency range in which songs typically has
%power, and power threshold.
minNdx = floor((windowSize/actInSampleRate)*minFreq + 1);
maxNdx = ceil((windowSize/actInSampleRate)*maxFreq + 1);

%Parameters for part 3
windowLength = round((actInSampleRate * songDuration) / (windowSize-windowOverlap)); %songs average .6 seconds in length
windowAvg = repmat(1/windowLength,1,windowLength);

tic;
[b,f,t] = specgram(sig, windowSize, actInSampleRate, windowSize, windowOverlap);

powerSong = mean(abs(b(minNdx:maxNdx,:)), 1);
powerNonSong = mean(abs(b([1:minNdx-1,maxNdx+1:end],:)), 1) + eps;
songRatio = powerSong./powerNonSong;
thresCross = (songRatio>ratioThreshold);
songDet = conv(thresCross,windowAvg);
tElapsed = toc;

score = max(songDet);
bDetect = score > durationThreshold;

if(bDebug)
    figure(6578);
    h(1) = subplot(4,1,1); displayAudioSpecgram(sig,actInSampleRate,0,10000);
    h(2) = subplot(4,1,2);plot(songRatio); axis tight;
    line(xlim, [ratioThreshold, ratioThreshold],'Color','red');
    h(3) = subplot(4,1,3);plot(thresCross); axis tight;
    h(4) = subplot(4,1,4);plot(songDet); axis tight;
    line(xlim, [durationThreshold, durationThreshold],'Color','red');
    ylim([0,1]);
end

 
 
 