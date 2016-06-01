function [P,f] = PowerSpectrumELM(signal,fs,nZPad)
if nargin<3
    nZPad = 0; 
end

% subtract the mean
signal = signal-mean(signal); 

% zeropad
signal = [signal(:); zeros(nZPad*length(signal),1)]; 

% take the fft; 
Y = fft(signal); 

% determine location of frequency bins
L = length(signal); 
df = fs/L; % frequency resolution; 
f = df*(0:(L/2)); % frequencies calculated

% determine power at relevant frequency bins
tmp = abs(Y/L).^2; % power is |Y|^2
P = tmp(1:floor(L/2)+1); % only consider positive frequencies
