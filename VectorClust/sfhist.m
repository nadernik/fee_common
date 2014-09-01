function varargout = sfhist(vcdb, sfname, varargin)
% SFHIST Histogram of scalar feature from vectorClust vcdb.
%   SFHIST(vcdb, sfname) plots histogram of scalar feature with name sfname
%   from vcdb.
%
%   H = SFHIST(...) returns a handle to the object plotted. 
%
%   SFHIST(vcdb, sfname, 'Parameter', value, ...) takes additional
%   parameters:
%
%     Mask (default = trues)
%       logical array to select the segments that are plotted. Its length
%       must be equal to length(vcdb.d.v)
%     BinWidth (default = [])
%       Width of bins in histogram. If blank, the bin edges are 
%       automatically calculated by the HIST function.
%     PatchProperties (default = {})
%       Cell array of {'Parameter', value, ...} to be passed as arguments 
%       to histpp().
%     Stairs (default = false)
%       If true, plot histogram using STAIRS instead of HISTPP. Stairs is
%       better if you want to make two overlapping histograms on the same
%       plot because one stairs plot will not obscure another. If Stairs is
%       true, the PatchProperties argument has no effect.
%
%   See also HISTPP, STAIRS

P.BinWidth = [];
P.PatchProperties = [];
P.Mask = true(size(vcdb.d.v));
P.Stairs = false;
P = parseargs(P, varargin{:});
if isempty(P.PatchProperties)
    P.PatchProperties = {}; % because parseargs does not allow empty cell arrays
end
y = getsf(vcdb, sfname, P.Mask);

if ~isempty(P.BinWidth)
    x = min(y - P.BinWidth):P.BinWidth:max(y + P.BinWidth);
    if P.Stairs
        n = hist(y, x);
        h = stairs(x, n);
    else
        h = histpp(y, x, P.PatchProperties{:});
    end
else
    if P.Stairs
        [n, x] = hist(y);
        h = stairs(x, n);
    else
        h = histpp(y, P.PatchProperties{:});
    end
end

if nargout > 0
    varargout{1} = h;
end