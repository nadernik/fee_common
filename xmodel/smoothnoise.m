function N = smoothnoise(len, span)
% SMOOTHNOISE Generate vector smoothed (filtered) Gaussian noise.
%   N = SMOOTHNOISE(LEN, SPAN) smooths along first nonsingleton dimension

N = smooth(randn(1,len), span, 'loess') ;