function [pitch, pitchGoodness, harmonicPower, time, entropy] = estimatePitchHPS(audio, fs, varargin)
% Written by Aaron Andalman Copywrite 2007.

%each window around the triggers is a row of the windows matrix.
%counts returns (for each column in windows) the number of elements which
%do not contain padding, be the padding be zeroes or nan.
persistent e;

%Default Parameters
%TODO add triggering on particular syllable catagory...
P.winSize = 1024;
P.winStep = 40;
P.NFFT = 2^10; %yields 1 Hz precision with 40000 Hz sampling rate.
P.cepsNFFT = 2^13;
P.minPitchFreq = 400;
P.maxPitchFreq = 4000;
P.totalPowerRange = [300,min(10000,fs/2)];
P.minEntropyFreq = 400;
P.maxEntropyFreq = 8600;
P = parseargs(P,varargin{:});

if(size(e,1) ~= P.winSize)
    [e] = dpss(P.winSize,1);
end

try
    %demean audio  
    audio = audio - mean(audio);
    
    %take spectrogram
    [s,f,time,p] = spectrogram(audio, e(:,1), P.winSize - P.winStep, P.NFFT, fs);

    %Demean, interpolate, then fft.
    %CEPSTRUM METHOD
    ffs = 1 / (P.NFFT / fs); %sampling rate in frequency space.
    ndxmin = round((1 / ((P.minPitchFreq / ffs) / P.cepsNFFT)) + 1);
    ndxmax = round((1 / ((P.maxPitchFreq / ffs) / P.cepsNFFT)) + 1);
    cepstrum = fft(p, P.cepsNFFT);  % takes fft of spectrum at each time.  fft on matrix takes fft of each column.    
    %cepstrum = fft(log10(abs(p)), P.cepsNFFT);
    cepstrum = cepstrum(ndxmax:ndxmin, :);
    [peak, peakNdx] = max(abs(cepstrum));
    peakNdx = peakNdx + (ndxmax-1);
    pitch = ((1./(peakNdx - 1)) * P.cepsNFFT) * ffs;
    %pitchGoodness = []; %peak ./ sum(abs(cepstrum));
    
%     %HPS METHOD
%     [sBig,fBig,time,pBig] = spectrogram(audio, e(:,1), P.winSize - P.winStep, 2^15, fs);
%     pBig = log(pBig);
%     pBig2 = pBig(1:2:end,:);
%     pBig3 = pBig(1:3:end,:);
%     pBig4 = pBig(1:4:end,:);
%     p4Len = size(pBig4,1);
%     hps = pBig(1:p4Len,:) + pBig2(1:p4Len,:) + pBig3(1:p4Len,:) + pBig4(1:p4Len,:);
%     fNdx = find(fBig>100 & fBig<4000);
%     fRange = fBig(fNdx);
%     [m,pNdx] = max(hps(fNdx,:),[],1);
%     
%     % TODO: to prevent doubleing of pitch.  need to find second highest
%     % peak.  If second highest peak is half the freq of highest peak, and
%     % the ratio of amplitudes is above a threshold, then use second highest
%     % peak instead!
%     
%     % TODO2: the cepstrum method and be combined with the HPS method for
%     % best results... see Efficient Pitch Detection Techniques for
%     % Interactive Music. Cuadra, Master and Sapp.
%     
%     pitchHPS = fRange(pNdx);
    
    %get total power
    widthHz = f(2) - f(1);
    powerNdx = round(P.totalPowerRange/widthHz) + 1;
    totalPower = widthHz*sum(abs(p(powerNdx(1):powerNdx(2),:)));
    
    %get harmonic power
    power = abs(p);
    power = power(:); 
    harmonicPower = zeros(floor(P.totalPowerRange(2)/P.minPitchFreq),length(pitch));
    for(harmonic = 1:floor(P.totalPowerRange(2)/P.minPitchFreq))
        %determine the ndx of the harmonic in the specgram:
        freqNdx = round((harmonic.*pitch)/widthHz) + 1;
        %do some index magic:
        freqNdx(freqNdx > length(f)-1) = length(f) - 1; %If the harmonic frequency is above the nyquist, set it to the below the nyquist for now, because it will be set to 0 a few lines down.
        ndx = freqNdx + length(f)*[0:length(freqNdx)-1];
        ndx = repmat(ndx, 3, 1) + repmat([-1,0,1]', 1, length(ndx));
        ndx = ndx(:);
        harmonicPower(harmonic, :)  = widthHz*sum(reshape(power(ndx),3,[]));
        harmonicPower(harmonic, freqNdx>powerNdx(2)) = 0; %If the harmonic frequency is above the maximum, set it to 0.
    end   
    pitchGoodness = sum(harmonicPower) ./ totalPower;
    
    %compute entropy
    entrNdx = find(f>P.minEntropyFreq & f<P.maxEntropyFreq);
    sumlog = sum(log(abs(p(entrNdx,:)) + eps));
    logsum = sum(abs(p(entrNdx,:))); 
    logsum(logsum==0) = length(entrNdx); 
    logsum = log(logsum/length(entrNdx));
    entropy = (sumlog/length(entrNdx)) - logsum;
    entropy(logsum==0) = 0; 
    
catch
    pitch = [];
    pitchGoodness = [];
    harmonicPower = [];
    time = [];
    entropy = [];
end
