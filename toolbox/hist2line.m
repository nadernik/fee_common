function hist2line(ph, varargin)
% Make a histogram into a line

for ii = 1:length(ph.Vertices)/2 - 2
    ndx = [0 1] + 2 * ii;
    x(ii) = mean(ph.Vertices(ndx,1));
    y(ii) = ph.Vertices(ndx(1), 2);
end

plot(ph.Parent, x, y, varargin{:})
delete(ph)