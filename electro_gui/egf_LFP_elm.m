function [snd lab] = egf_LFP_elm(a,fs,params)
% ElectroGui filter
% prolly mostly pulls out motion artifacts... but at least it removes 60Hz
% noise
lab = 'LFP-ELM';
if isstr(a) & strcmp(a,'params')
    snd.Names = {'Lower frequency','Higher frequency','Order'};
    snd.Values = {'20','40','80'};
    return
end

p.Fs = fs; 
a = a-mean(a); 
a = rmlinesc(a, p, .05/length(a), 0, 60); % chronux function that removes 60hz line noise
a = rmlinesc(a, p, .05/length(a), 0, 180);
a = rmlinesc(a, p, .05/length(a), 0, 300);

freq1 = str2num(params.Values{1});
freq2 = str2num(params.Values{2});
ord = str2num(params.Values{3});
% 
% figure(2); shg; hold on
% [P,f] = PowerSpectrumELM(snd,fs,4);
% plot(f,P); shg
% xlim([0 5000]); ylabel('power (au)'); xlabel('frequency (Hz)')

L = length(a); 
if mod(L,2) == 1; % need even
    a = [a; 0]; 
    wasodd = 1;
else
    wasodd = 0; 
end
y = fft(a); 
% determine location of frequency bins
df = fs/L; % frequency resolution; 
f = df*([0:(L/2) ((L/2-1):-1:0)]);% frequencies calculated
y(f<freq1|f>freq2) = 0; 
snd = real(ifft(y)); 
if wasodd
    snd = snd(1:end-1); 
end

% b = fir1(ord,[freq1 freq2]/(fs/2));
% snd = filtfilt(b, 1, a);
% snd = [0; diff(snd(:)).^2]; % remove later.  this is just to look at power.
% snd = snd-mean(snd); 

