function aSAP_batchWavFeatureCompute(directories)

%Author Aaron Andalman 2006.01
%
%Batch computation of SAP features for wav files 
%using SAM ver 1.0

param = Parameters;

%build filter:
filt.order = 200; %suffiencity for 44100Hz of lower
filt.win = hann(filt.order+1);
filt.cutoff = 600; %Hz
filt.fs = 44100;
filt.hpf441 = fir1(filt.order, filt.cutoff/(filt.fs/2), 'high', filt.win);

for(dirCell = directories)
    dirT = dirCell{1};
    wavFiles = dir([dirT,filesep,'*.wav']);
    runTime = 0;
    for(nFile = 1:length(wavFiles))  
        tic
        aSAP_generateASAPFeatureFileFromWav([dirT,filesep,wavFiles(nFile).name], param, filt);
        runTime = runTime + toc;
        estRemainingTime = (runTime / nFile) * (length(wavFiles) - nFile); 
        
        %Display update
        disp(sprintf('%s: %d/%d Est. Remaining Time For Directory: %g', dirT, nFile, length(wavFiles), estRemainingTime));
    end
end
