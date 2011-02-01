function aSAP_generateASAPFeatureFileFromWav(wavfilename, param, filt);

if(~exist('param'))
    param = Parameters;
end    

fdata = dir(wavfilename);
[path, fname, ext]= fileparts(wavfilename);

%Load the file...
[audio, fs] = wavread(wavfilename);

if(exist('filt')~=1)
    filt.fs = 0;
end
if(filt.fs~=fs)
    filt.order = 200; %suffiencity for 44100Hz of lower
    filt.win = hann(filt.order+1);
    filt.cutoff = 600; %Hz
    filt.fs = fs;
    filt.hpf = fir1(filt.order, filt.cutoff/(filt.fs/2), 'high', filt.win);
end
audio = filtfilt(filt.hpf, 1, audio);

[SAPFeats, m_spec_deriv] = aSAP_generateASAPFeatures(audio, fs, param);

if(~isequal(m_spec_deriv,[]))
    %Compress and store the spectral derivative
    SAPFeats.specDerivFileName = [path,filesep,fname,'.sd'];
    aSAP_compressSpectralDeriv(m_spec_deriv, SAPFeats.specDerivFileName); 

    %Put file information into feature structure
    SAPFeats.rawWaveFileName = wavfilename;
    SAPFeats.filemoddate = datenum(fdata(1).date, 0);
    SAPFeats.time = aSAP_extractTimeFromSAPFileName(fname);      
    SAPFeats.filt = filt;
    SAPFeats.filt.fcn = 'filtfilt';

    %Store in a .mat file.
    matname = [path,filesep,fname,'.feat','.mat'];
    save(matname, 'SAPFeats');
end