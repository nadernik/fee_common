function y = snippet(x, range, varargin)
% SNIPPET Extracts a segment of data from a vector
%
% Usage:
%   y = snippet(x, [pct1 pct2])
%
%   y = snippet(x, [t1   t2  ], 'units', 'seconds', 't', timevec)
%
%   y = snippet(x, [t1   t2  ], 'units', 'seconds', 'fs', fs)
%
%   y = snippet(x, [n1   n2  ], 'units', 'samples')
%     Same as y = x(n1:n2)

P.t = []; % time vector in seconds. Takes precedence over P.fs
P.fs = []; % sampling rate in Hz
P.units = {'percent', 'seconds', 'samples'};
P = parseargs(P, varargin{:});

switch P.units
    case 'percent'
        pct = linspace(0, 100, length(x));
        ndx = pct >= range(1) & pct <= range(2);
    case 'seconds'
        if ~isempty(P.t)
            if length(P.t) ~= length(x)
                error('Time vector must be same length as data.')
            end
            ndx = P.t >= range(1) & P.t <= range(2);
        elseif ~isempty(P.fs)
            t = (0:length(x)-1) .* 1/P.fs;
            ndx = t >= range(1) & t <= range(2);
        else
            error('Parameter ''t'' or ''fs'' is required to extract snippet by time range.')
        end
    case 'samples'
        samp = 1:length(x);
        ndx = samp >= range(1) & samp <= range(2);
end

y = x(ndx);