function width = fwhm(x)
%FWHM Full Width at Half Maximum
%   width = fwhm(x)

DEBUG_FLAG = 0;

[xmax, imax] = max(x);
halfmax = xmax/2;
i1 = find(x(imax-1:-1:1)<= halfmax, 1, 'first');
i2 = find(x(imax+1:end) <= halfmax, 1, 'first');

if isempty(i1) || isempty(i2)
    width = nan; % if x does not reach half max, fwhm is undefined
else
    width = i1 + i2;
end

if DEBUG_FLAG
    figure
    plot(x)
    hold on
    h = line([-i1, i2]+imax, halfmax*[1,1]);
    set(h, 'LineStyle', '--')
end