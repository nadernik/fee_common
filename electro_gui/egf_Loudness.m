function [y label] = egf_Loudness(a,fs, params)
label = 'Loudness'; 
if isstr(a) & strcmp(a,'params')
    y.Names = {'Rectification exponent (e.g. 2 for squared signal)','Gaussian half-width sigma (ms)','Kernel half-length in stdev'};
    y.Values = {'2','5','3'};
    return
end
wind = round(.0025*fs); %2.5ms smoothing window
amp = smooth(10*log10(a.^2+eps),wind);
amp = amp-min(amp(wind:length(amp)-wind));
amp(find(amp<0))=0;
y = amp; 