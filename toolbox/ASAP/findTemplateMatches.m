function findTemplateMatches(template, sampRate, exper, fileNums)

%Compute features for the template song:
[tDeriv, tAmp, tAM, tFM, tEnt, tPeakFreq, tPitch, tPitchGood] = SAP_computeLocalFeatures(template, sampRate, 409, 60, .5);
%Demean the features
tAmp = tAmp - mean(tAmp);
tAM = tAM - mean(tAM);
tFM = tFM - mean(tFM);
tEnt = tEnt - mean(tEnt);
tPeakFreq = tPeakFreq - mean(tPeakFreq);
tPitch = tPitch - mean(tPitch);

matchThres = 3e25;

for(fileNum = fileNums)
    audio = loadAudio(exper, fileNum);
    
    %Compute features for this audio file.
    [Deriv, Amp, AM, FM, Ent, PeakFreq, Pitch, PitchGood] = SAP_computeLocalFeatures(audio, exper.desiredInSampRate, 409, 60, .5);
    Amp = Amp - mean(Amp);
    AM = AM - mean(AM);
    FM = FM - mean(FM);
    Ent = Ent - mean(Ent);
    PeakFreq = PeakFreq - mean(PeakFreq);
    Pitch = Pitch - mean(Pitch);
    
    %Compute correlations of features with template
    [rFM, lags] = xcorr(FM, tFM);
    rEnt = xcorr(Ent, tEnt);
    rPeakFreq = xcorr(PeakFreq, tPeakFreq);
    rPitch = xcorr(Pitch, tPitch);
  
    %Compute match metric based on features.
    matchMetric = rFM .* rEnt .* rPeakFreq .* rPitch;
    
    %Find cross correlation lags at which matchMetric crosses threshold
    [leadingEdgeNdx] = findPeakWithinThresCross(matchMetric, matchThres, true);
    featureNdx = lags(leadingEdgeNdx);
    
    
    %Convert featureNdx to audio time (local features resamples to 44100.
    times = (featureNdx*60) / 44100;
   
    %debug
    displaySpectralDerivativeWithStims(Deriv, 60, 0, 8000, [-0.001,0.001], times', [], 6, .3);    
    keyboard;
end
    
    
    
    

    