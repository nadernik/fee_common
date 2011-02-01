function aSAP_generateASAPFeatureFileFromExper(exper, filenum, param, filt)

if(~exist('param'))
    param = Parameters;
end

filename = getExperAudioFilename(exper,num);
[path,fname,ext] = fileparts(filename);

audio = loadAudio(exper, filenum);
fs = exper.desiredInSampRate;

if(~exist(filt) || (filt.fs~=fs))
    filt.order = 200; %suffiencity for 44100Hz of lower
    filt.win = hann(filt.order+1);
    filt.cutoff = 600; %Hz
    filt.fs = fs;
    filt.hpf = fir1(filt.order, filt.cutoff/(filt.fs/2), 'high', filt.win);
end
audio = filtfilt(filt.hpf, 1, audio);

SAPFeats = aSAP_generateASAPFeatures(audio, fs, param);

%Compress and store the spectral derivative
SAPFeats.specDerivFileName = [exper.dir,filesep,fname,'.sd'];
aSAP_compressSpectralDeriv(m_spec_deriv, SAPFeats.specDerivFileName); 

%Put file information into feature structure
SAPFeats.experDir = exper.dir;
SAPFeats.experBirdName = exper.birdname;
SAPFeats.experExperName = exper.expername;
SAPFeats.experFilenum = filenum;
SAPFeats.time = extractExperFilenumTime(exper,filenum);
SAPFeats.filt = filt;
SAPFeats.filt.fcn = 'filtfilt';

%Store in a .mat file.
matname = [exper.dir,filesep,fname,'.feat','.mat'];
save(matname, 'SAPFeats');