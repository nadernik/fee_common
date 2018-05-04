function [Freq,S] = myMultitaper(x,Fs,NW,K,Pad,fpass)
%%% multitaper spectral analysis
%%% [Freq,S] = myMultitaper(x,Fs,NW,K,Pad)
%%% Fs: sampling frequency
%%% fpass: frequency range in Hz e.g. [0 50]
%%% Same output as the chronux toolbox
%%% Tatsuo Okubo
%%% 2011/02/21

if size(x,2)>size(x,1)
    x = x'; % x is a column vector
end

if K > 2*NW-1
    warning('Using too many tapers');
end
Taper = dpss(length(x),NW,K); % [N,NW,K];
Taper = Taper.*sqrt(Fs); % normalization
NFFT = 2^(nextpow2(length(x))+Pad);
for k=1:K % for every taper
    y = x.*Taper(:,k);    
    X = fft(y,NFFT)./Fs;
    S(:,k) = X.*conj(X);
end
S = mean(S,2); % average over tapered spectral estimates
Freq = 0:Fs/NFFT:Fs-Fs/NFFT;
if exist('fpass')
    Idx = find(Freq>=fpass(1) & Freq<=fpass(2));
    Freq = Freq(Idx);
    S = S(Idx);
end
if size(Freq,2)>size(Freq,1)
    Freq = Freq'; % Freq is column vector
end