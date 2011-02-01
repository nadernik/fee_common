function audio = getHarmonicStack(fundFreq, Harmonics, fs, secs)
%%% generates artificial harmonic stack for testing filters
time = 0:1/fs:secs; 
audio = zeros(1,length(time));
nHarm = 1;
for(harmonic = Harmonics)
    audio = audio + harmonic * sin(2*pi*time*fundFreq*nHarm);
    nHarm = nHarm + 1;
end