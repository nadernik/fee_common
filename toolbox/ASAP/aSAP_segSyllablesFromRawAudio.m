function [syllStartTimes, syllEndTimes, noiseEst, noiseStd, soundEst, thresSyll,thresTrig, soundStd, audioLogPow] = aSAP_segSyllablesFromRawAudio(audio, fs, varargin)
%audio is the rawaudio file
%fs is the sampling rate.

%Default Parameters
%TODO add triggering on particular syllable catagory...
P.method = {'mixture', 'fixed'}; %Mixture using EM to fit levels for noise and sound.
P.thresholdRelative = 0.8; %if using Mixture Model
P.triggerRelative = 0.6; %if using Mixture Model
P.thresholdAbs = -10; %if using fixed thresholds.
P.triggerAbs = -7; %if using fixed thresholds.
P.fMinSyllDuration = .016; %secs
P.fMinIntervalDuration = .007; %secs
P.fMaxSyllDuration = 1; %sec
P.bDebug = false;
P.audioFilt = [];
P.notchFilt = [];
P.noiseFilt = [];
P.noiseThres = [];
P.noiseFrac = 0; %if noise is greater than threshold for more than this fraction of time then the syllable is excluded.
P.bUseNoiseRatio = false;
P.entropyThres = [];
P.entropyFrac = 0; %if entropy is greater than threshold for more than this fraction of time then the syllable is excluded.
P.entropyWinSize = 256;
P.entropyWinStep = 40;
P = parseargs(P,varargin{:});

%syllStartTimes: the start time of each syllable.  This is not the onset of
%sound, but the time at which the audio level crosses above threshold.
%syllEndTimes: the end time of each syllable.  This is not the offset of
%sound, but the time at which the audio level crosses below threshold.
%noiseEst, noiseStd: the estimated noise level and variance.
%soundEst, soundStd: the estimated signal level and variance.

persistent windowCoeffs;
if(size(windowCoeffs,1) ~= P.entropyWinSize)
    [windowCoeffs] = dpss(P.entropyWinSize,1);
end   

syllStartTimes = [];
syllEndTimes = [];
noiseEst = 0;
soundEst = 0;
noiseStd = 0;
soundStd = 0;
thresSyll = 0;
thresTrig = 0;
audioLogPower = [];

%utilizes several thresholds and criteria
%1. syllable trig threshold power - the syllable has to reach this
%   threshold at least once.
%2. syllable cont threshold power - all time between this power is
%   considered the syllable.
%3. min interval duration.
%4. min syllable duration.

%5. max syllable duration

%get the log power in the audio signal
if(~isempty(P.audioFilt))
    %audio = filtfilt(P.audioFilt, 1, audio);
    audio = fftfilt(P.audioFilt, audio);
    audio = [audio(floor(length(P.audioFilt)/2):end); zeros(floor(length(P.audioFilt)/2)-1,1)];
end
audioLogPow = aSAP_getLogPower(audio, fs);

%power in notched audio.
if(~isempty(P.notchFilt))
    %audioNotch = filtfilt(P.notchFilt, 1, audio);
    audioNotch = fftfilt(P.notchFilt, audio);
    audioNotch = [audioNotch(floor(length(P.notchFilt)/2):end); zeros(floor(length(P.notchFilt)/2)-1,1)];    
    notchLogPow = aSAP_getLogPower(audioNotch, fs);
else
    audioNotch = audio;
    notchLogPow = audioLogPow;
end

%power in noise band
if(~isempty(P.noiseFilt))
    %audioNoise = filtfilt(P.noiseFilt, 1, audio);
    audioNoise = fftfilt(P.noiseFilt, audio);
    audioNoise = [audioNoise(floor(length(P.noiseFilt)/2):end); zeros(floor(length(P.noiseFilt)/2)-1,1)];        
    noiseLogPow = aSAP_getLogPower(audioNoise, fs);
    noiseScore = noiseLogPow;
    if(P.bUseNoiseRatio)
        noiseScore = noiseLogPow - audioLogPow;
    end
end

if(strcmp(P.method, 'mixture'))
    %Estimate threshold to discrimate between sound and noise using a mixture
    %of two gaussians model.
    [noiseEst, soundEst, noiseStd, soundStd] = aSAP_estimateTwoMeans(audioLogPow);    
    if(noiseEst>soundEst)
        return;
    end
    %Compute the optimal classifier between the two gaussians...
    p(1) = 1/(2*soundStd^2) - 1/(2*noiseStd^2);
    p(2) = (noiseEst)/(noiseStd^2) - (soundEst)/(soundStd^2);
    p(3) = (soundEst^2)/(2*soundStd^2) - (noiseEst^2)/(2*noiseStd^2) + log(soundStd/noiseStd);
    disc = roots(p);
    disc = disc(find(disc>noiseEst & disc<soundEst));
    if(length(disc)==0)
        return;
    end
    disc = disc(1);

    %Set the thresholds based on these estimates
    thresSyll = noiseEst + P.thresholdRelative * (disc - noiseEst); %threshold for the edge of a syllable
    thresTrig = soundEst - P.triggerRelative * (soundEst - disc); % it is only a syllable if the power is above this value (get rid of noise)
elseif(strcmp(P.method, 'fixed'))
    thresSyll = P.thresholdAbs; %if using fixed thresholds.
    thresTrig = P.triggerAbs; %if using fixed thresholds.
end

if(P.bDebug)
    figure(1115);
    clf;
    s1 = subplot(5,1,1);
    plot([0:length(audio)-1]/fs,audioLogPow, 'b');
    hold on;
    if(~isempty(P.notchFilt))
        plot([0:length(audio)-1]/fs,notchLogPow, 'r');
    end
    xl = xlim;
    if(strcmp(P.method,'mixture'))
        line(xl,[noiseEst,noiseEst], 'Color', 'red');
        line(xl,[soundEst,soundEst], 'Color', 'green');
    elseif(strcmp(P.method,'fixed'))
        line(xl,[thresTrig,thresTrig], 'Color', 'red');
        line(xl,[thresSyll,thresSyll], 'Color', 'blue');
    end
    
    s2 = subplot(5,1,2);
    if(~isempty(P.noiseFilt) & ~isempty(P.noiseThres))
        plot([0:length(audio)-1]/fs,noiseScore, 'r');
        line(xl,[P.noiseThres,P.noiseThres], 'Color', 'black');
        hold on;
    end

    s3 = subplot(5,1,3);
    if(~isempty(P.entropyThres))        
        line(xl,[P.entropyThres,P.entropyThres], 'Color', 'black');
        hold on;
    end
end

%Find threshold crossings:
[trigCross, junk] = detectThresholdCrossings(notchLogPow, thresTrig, true);
[syllUpCross, syllDownCross] = detectThresholdCrossings(audioLogPow, thresSyll, true);

if(length(syllUpCross) > 0 | length(syllDownCross) > 0)
    %Eliminated extraneous end crossing...
    if(syllUpCross(1) == 1)
        syllUpCross = syllUpCross(2:end);
    end
    if(syllDownCross(end) == length(audioLogPow))
        syllDownCross = syllDownCross(1:end-1);
    end

    %Determine syllables present
    nSyll = 0;
    beginSyll = [];
    endSyll = [];
    noiseTextX = []; 
    noiseTextY = [];
    noiseTextStr = [];
    entropyTextX = [];
    entropyTextY = [];
    entropyTextStr = [];
    for(nTrig = 1:length(trigCross))
        up = find(syllUpCross<trigCross(nTrig));
        down = find(syllDownCross>trigCross(nTrig));      
        if((length(up)>0) & (length(down)>0))
            bClean = true;
            if(~isempty(P.noiseFilt) & ~isempty(P.noiseThres))                
                bClean = sum(noiseScore(syllUpCross(up(end)):syllDownCross(down(1)))>P.noiseThres);
                bClean = bClean / (syllDownCross(down(1))-syllUpCross(up(end)));
                if(P.bDebug)
                    noiseTextX(end+1) = syllUpCross(up(end))/fs;
                    noiseTextY(end+1) = P.noiseFrac;
                    noiseTextStr{end+1} =  sprintf('%1.2f',bClean);                   
                end
                bClean = bClean <= P.noiseFrac;
            end 
            if(bClean)
                bEntropy = true;                
                if(~isempty(P.entropyThres))                    
                    syllNdx = syllUpCross(up(end)):syllDownCross(down(1));
                    if(length(syllNdx)>=P.entropyWinSize)
                        [s,f,time,p] =spectrogram(audio(syllNdx), windowCoeffs(:,1), P.entropyWinSize-P.entropyWinStep, P.entropyWinSize, fs); 
                        entrNdx = find(f>800 & f<8000);
                        sumlog = sum(log(abs(p(entrNdx,:)) + eps));
                        logsum = sum(abs(p(entrNdx,:))); 
                        logsum(logsum==0) = length(entrNdx); 
                        logsum = log(logsum/length(entrNdx));
                        entropy = (sumlog/length(entrNdx)) - logsum;
                        entropy(logsum==0) = 0; 
                        bEntropy = sum(entropy>P.entropyThres)./length(time);
                        if(P.bDebug)
                            entropyTextX(end+1) = syllUpCross(up(end))/fs;
                            entropyTextY(end+1) = P.entropyFrac;
                            entropyTextStr{end+1} =  sprintf('%1.2f',bEntropy);
                        end
                        bEntropy = bEntropy <= P.entropyFrac;
                        if(P.bDebug)
                            plot(time + syllNdx(1)/fs, entropy);
                        end
                    end
                end

                if(bEntropy)
                    nSyll = nSyll + 1;
                    beginSyll(nSyll) = syllUpCross(up(end));
                    endSyll(nSyll) = syllDownCross(down(1));
                end
            end
        end
    end

    if(length(beginSyll) > 2)
        %Remove small intervals
        intervals = (beginSyll(2:end) - endSyll(1:end-1)) ./ fs;
        realGapNdx = find(intervals > P.fMinIntervalDuration);
        beginSyll = beginSyll([1,realGapNdx+1]);
        endSyll = endSyll([realGapNdx,length(endSyll)]);
    end
        
    %Remove syllables that are too short or long
    durations = (endSyll - beginSyll) / fs;
    realSyll = find((durations > P.fMinSyllDuration) & (durations < P.fMaxSyllDuration));
    beginSyll = beginSyll(realSyll);
    endSyll = endSyll(realSyll);

    syllStartTimes = (beginSyll -1)/ fs;
    syllEndTimes = (endSyll-1) / fs;
end

if(P.bDebug)
    axes(s2);
    text(noiseTextX, noiseTextY, noiseTextStr, 'VerticalAlignment','middle');
    axes(s3);
    text(entropyTextX, entropyTextY, entropyTextStr, 'VerticalAlignment','middle');
    
    s4 = subplot(5,1,4);
    displaySpecgramQuick(audio, fs);
    s5 = subplot(5,1,5);
    displaySpecgramQuick(audioNotch, fs);

    x = [syllStartTimes; syllEndTimes; syllEndTimes; syllStartTimes]';    
    
    axes(s1);
    ylim([-20,2]); % TO
    y = repmat(ylim,length(syllStartTimes),1);
    y = [y(:,1),y(:,1),y(:,2),y(:,2)];
    patch(x',y','red','FaceAlpha',.5)
    
    axes(s4);
    y = repmat(ylim,length(syllStartTimes),1);
    y = [y(:,1),y(:,1),y(:,2),y(:,2)];
    patch(x',y','red','FaceAlpha',.5)
    
    axes(s5);
    y = repmat(ylim,length(syllStartTimes),1);
    y = [y(:,1),y(:,1),y(:,2),y(:,2)];
    patch(x',y','red','FaceAlpha',.5)    

    linkaxes([s1,s2,s3,s4,s5], 'x')
    figure(gcf);
    %pause %%%%%%%%%%
end





