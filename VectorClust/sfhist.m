function sfhist(vcdb, sfname, varargin)
% SFHIST Histogram of scalar feature from vectorClust vcdb.
%   SFHIST(vcdb, sfname) plots histogram of scalar feature with name sfname
%   from vcdb.
%
%   SFHIST(vcdb, sfname, 'Parameter', value, ...) takes additional
%   parameters:
%
%       Mask = logical array to select the segments that are plotted
%       BinWidth = width of bins in histogram. Bin edges are automatically
%       calculated 
%       PatchProperties = cell array of {'Parameter', value, ...} to be
%       passed as arguments to histpp().
%
%   See also HISTPP

P.BinWidth = [];
P.PatchProperties = [];
P.Mask = true(size(vcdb.d.v));
P = parseargs(P, varargin{:});
if isempty(P.PatchProperties)
    P.PatchProperties = {}; % because parseargs does not allow empty cell arrays
end
y = getsf(vcdb, sfname, P.Mask);
if ~isempty(P.BinWidth)
    x = min(y - P.BinWidth):P.BinWidth:max(y + P.BinWidth);
    histpp(y, x, P.PatchProperties{:})
else
    histpp(y, P.PatchProperties{:})
end