function y = resample2(x, p, q)
%RESAMPLE2 Quick resampling of time domain data by interpolation
%
% Similar to RESAMPLE function but does not use upfirdn.

% parameters
beta = 5; % shape of kaiser filter
n = 10; % length of fir filter = 2*n-1

fs2 = p;
fs1 = q;
t1 = (0:length(x)-1) ./ fs1;
t2 = 0:(1 / fs2):t1(end);

w = kaiser(2*n, beta);
fnyquist1 = fs1/2;
fnyquist2 = fs2/2;
f = [0 fnyquist2 fnyquist2 fnyquist1] ./ fnyquist1;
a = [1     1         0         0];
b = firls(2 * n - 1, f, a) .* w';
lowpassed = filtfilt(b, 1, x);
y = interp1(t1, lowpassed, t2)';
