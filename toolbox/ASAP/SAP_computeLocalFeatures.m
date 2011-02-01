function [specDeriv, fAmp, fAM, fFM, fEntropy, fPeakFreq, fPitch, fPitchGoodness] = SAP_computeLocalFeatures(audio, actSampRate, sampPerWin, sampAdv, noiseRatio, tapers)
%Ideally the audio signal should be near zero at the ends.
%sampPerWin and sampAdv are specified in samples at 44.1Hz. 
%default sampPerWin = 409, default sampAdv = 60

%Testing:
%Entropy has similar shape and scale.
%AM has similar shape and scale.
%FM has similar shape and scale.
%Pitch is the right shape but reduced by an offset.
%PitchGoodness generally good but slightly off in scale.
%PeakFreq - ??? not displayable
%Amplitude - somethings off

fftSize = 1024;
cepstSize = 512;
sampRate = 44100;

%Taken from options3.cpp
pitchGoodnessThresh=30;
pitchEntropyThresh=-2;
harmonicPitchThresh=1800; %1800Hz and above is not harmonic... note that pitch units are here in Hz
ampBaseline=70; 

if(sampPerWin > 1024)
    warning('aa: sampPerWin should be less than 1024');
end

if(~exist('tapers'))
    [tapers, concs] = dpss(sampPerWin, 1.5); %generates 2 tapers. 1.5*2 -1.
end

%Resample to 44100, thereby all ffts can be the same length
audio441 = resample(audio, sampRate, actSampRate);
audio441 = audio441 + eps;

%reshape audio for windowed fft
numWindows = floor((length(audio441) - sampPerWin) / sampAdv);
windowAud = zeros(sampPerWin, numWindows);
for(nWin=1:numWindows)
    currNdx = (nWin-1)*sampAdv;
    windowAud(:,nWin) = audio441(currNdx+1:currNdx+sampPerWin);
end

%taper the windows
windowTap1 = zeros(sampPerWin, numWindows);
windowTap2 = zeros(sampPerWin, numWindows);
windowTap1 = windowAud .* repmat(tapers(:,1),1,numWindows);
windowTap2 = windowAud .* repmat(tapers(:,2),1,numWindows);

%if boost amplitude them multiply by 5.

F1 = fft(windowTap1, fftSize);
F2 = fft(windowTap2, fftSize);
F1 = F1(1:512,:);
F2 = F2(1:512,:);


%compute the powerSpec and the derivatives.
powerSpec = real(F1).^2 + real(F2).^2 + imag(F1).^2 + imag(F2).^2;
timeDeriv = -(real(F1).*real(F2)) - (imag(F1).*imag(F2));
freqDeriv = imag(F1).*real(F2) - (real(F1).*imag(F2));

%keep the max derivative in each window.
maxTD = max(timeDeriv.^2);
[maxFD,maxNdx] = max(freqDeriv.^2);

%determine freq with max power in each slice
peakFreq = (maxNdx-1) * (sampRate/fftSize);

%comp power in noisy frequencies
lowFreqNoiseCutoff = 500; %Hz
highFreqNoiseCutoff = 11000; %Hz
lowFreqNoiseNdx = round((lowFreqNoiseCutoff / (sampRate/fftSize)) + 1);
highFreqNoiseNdx = round((highFreqNoiseCutoff / (sampRate/fftSize)) + 1);
noisePower = sum(powerSpec([1:lowFreqNoiseNdx,highFreqNoiseNdx:end],:));

%compute features from energy in good frequencies
minEntropyFreq = 860; %Hz
maxEntropyFreq = 8600; %Hz
minEntropyNdx = round((minEntropyFreq / (sampRate/fftSize)) + 1);
maxEntropyNdx = round((maxEntropyFreq / (sampRate/fftSize)) + 1);
entropyRange = maxEntropyNdx - minEntropyNdx +1;

powerSpecEntRange = powerSpec([minEntropyNdx:maxEntropyNdx],:);
sumpower = sum(powerSpecEntRange);  %raw amplitude

%compute entropy
logpower = log(powerSpec([minEntropyNdx:maxEntropyNdx],:));
zndx = find(powerSpec == 0);
logpower(zndx) = 0;
sumlog = sum(logpower);
logsum = log(sumpower./entropyRange);
zndx = find(sumpower == 0);
logsum(zndx) = 0;
entropy = (sumlog/entropyRange) - logsum;
entropy(zndx) = 0;
    
%peak frequency
logDpower = freqDeriv([minEntropyNdx:maxEntropyNdx],:).^2 + timeDeriv([minEntropyNdx:maxEntropyNdx],:).^2; 
gc_base = sum(logDpower); %gc: gravity center.
gc = sum(logDpower .* repmat([minEntropyNdx-1:maxEntropyNdx-1]',1,numWindows));
gc = gc ./ (gc_base + 1); %(mean frequency)
 
%amplitude modulation
temp = sumpower;
ndx = find(sumpower == 0);
temp(ndx) = 1;
AM = (sum(timeDeriv) ./ temp);

%amplitude
amplitude = sumpower;
ndx = find(sumpower == 0);
amplitude(ndx) = 1;
noisePower = noisePower ./ max(amplitude,ones(1,numWindows));
amplitude = log10(amplitude+1)*10 - ampBaseline;
nndx = find(noisePower > noiseRatio);
amplitude(nndx) = 0;

%frequency modulation
FM = zeros(1, numWindows);
nzndx = find((maxFD~=0) & (maxTD~=0));
FM(nzndx) = atan(maxTD(nzndx)./maxFD(nzndx));

%compute spectral derivatives
cFM = cos(FM);
sFM = sin(FM);
specDeriv = timeDeriv.*repmat(sFM,fftSize/2,1) + freqDeriv.*repmat(cFM,fftSize/2,1);

%compute the cepstrum of the spectral derivative
cepst = zeros(fftSize/2, numWindows);
nzndx = find(powerSpec~=0);
cepst(nzndx) = specDeriv(nzndx) ./ powerSpec(nzndx);
cepst([1:7,255:end],:) = 0;
cepst = fft(cepst, cepstSize);

%compute the pitch and the goodness of pitch
upper_pitch_bound = 4;  %7350 Hz maximum pitch estimate
lower_pitch_bound = 56; %400Hz minimum pitch estimate
pitchGoodness = real(cepst(4:56,:)).^2 + imag(cepst(4:56,:)).^2;
[pitchGoodness, pitch] = max(pitchGoodness);
pitch = pitch + 3;
pitch = repmat(cepstSize,1,numWindows) ./ (pitch-1); %divistion by ztFFT_CEPST transform from period to frequency units (those are not Hz yet!)

FM=57.2957795*FM; % change units of FM to degrees
peakFreq = gc;

%These are the raw feature values that SAP saves to the file...
fAM = AM.*100;
fFM = FM.*10;
fAmp = amplitude;
fPitch = pitch-120;
fEntropy = entropy.*100;
fPitchGoodness = pitchGoodness.*10;
fPeakFreq = peakFreq-120;

%But when the file is loaded the feature values are adjusted
fPitch = 43.0 .* (fPitch + 120);
fPeakFreq = 43.0 .* (fPeakFreq +120);
fEntropy = fEntropy ./ 100;
fFM = fFM ./ 10;
fAmp = fAmp;
fPitchGoodness = fPitchGoodness ./ 10;
fAM = fAM ./ 100;
%Decide whether to use cepstrum estimate or peakFreq as pitch estimate.
%If goodness is low & the sound is tonal or cepstum gave an estimate higher
%than 1800hz then use fPeakFreq as the estimate of pitch.
fCepstPitch = fPitch;  
if(fPitchGoodness<pitchGoodnessThresh & fEntropy<pitchEntropyThresh | fPitch>harmonicPitchThresh)
    fPitch = fPeakFreq;
end
 
 
 

	




