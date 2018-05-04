function y = extract_time_range(x, time_or_fs, t_range, t0)

if nargin < 4 % t0 not provided
    t0 = 0;
end

if isscalar(time_or_fs);
    fs = time_or_fs;
    t = (0:length(x)) * 1/fs;
else
    t = time_or_fs;
end

t_range = t_range + t0;
ndx = t >= t_range(1) & t < t_range(end);
y = x(ndx);