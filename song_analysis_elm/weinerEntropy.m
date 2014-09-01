function W = weinerEntropy(syl, fs);
% calculates the weiner entropy of syl
T = 1/fs;                     % Sample time
L = length(syl);
t = (0:L-1)*T;                % Time vector
y = syl;

NFFT = 2^nextpow2(L); % Next power of 2 from length of y
Y = fft(y,NFFT)/L;
f = fs/2*linspace(0,1,NFFT/2+1);
df = f(2)-f(1);

S = 2*abs(Y(1:NFFT/2+1));
%S = S/sum(S);
%E = -sum(S.*log2(S));
%W = log(exp(1/length(S)*sum(log(S)))/mean(S));
W = log(exp(1/length(S)*sum(log(S)))/mean(S));