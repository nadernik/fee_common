function yy = smoothma(y, span)
%SMOOTH2 Smooth with moving average without edge effects

yy = smooth(y, span);
nnan = floor(span / 2);
yy(1:nnan) = NaN;
yy(end-nnan:end) = NaN;
