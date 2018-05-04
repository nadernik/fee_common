function yy = smoothma(y, span)
%SMOOTHMA Smooth with moving average without edge effects
%   Smooths a vector using a moving average window. The filter coefficients
%   are equal to the reciprocal of the span. Then, the edges of the
%   resulting smoothed vector are set to NaN to eliminate edge effects. The
%   first span/2 samples and the last span/2 samples are set to NaN.
%
%   Usage:
%       yy = smoothma(y, span);

yy = smooth(y, span);
nnan = floor(span / 2);
yy(1:nnan) = NaN;
yy(end-nnan:end) = NaN;
