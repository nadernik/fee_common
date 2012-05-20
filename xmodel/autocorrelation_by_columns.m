function [acorr, lags] = autocorrelation_by_columns(M, maxlag)

acorr = zeros(maxlag * 2 + 1, size(M, 2));
for col = 1:size(M, 2)
    [c, lags] = xcorr(M(:, col), maxlag, 'unbiased');
    acorr(:, col) = c / max(c);
end