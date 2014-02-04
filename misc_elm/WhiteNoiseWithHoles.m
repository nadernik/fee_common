%% setup 
fs = 44100;
dur = .5;
hf = design(fdesign.bandpass('N,F3dB1,F3dB2',100,6e3,20e3,fs));
lf = design(fdesign.bandpass('N,F3dB1,F3dB2',100,20,2e3,fs));
%doc fdesign.bandpass
%Once you get the filter, assuming x is what you get from wgn, which is white noise, you can simply get the filtered noise by
x = rand(1, fs*dur);
hi = filter(hf,x); 
lo = filter(lf,x); 

% sound(x, fs); 
% displaySpecgramQuick(x, fs)
% sound(hi, fs)
% displaySpecgramQuick(hi, fs)
% sound(lo, fs)
% displaySpecgramQuick(lo, fs)
% sound(hi+lo,fs)
% displaySpecgramQuick(hi+lo, fs)
%%
n = 5
hl = hi+lo;
for i = 1:n
    sound(hl(1:fs*.05), fs)
    pause(rand*5*dur)
end
