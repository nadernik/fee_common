function varargout = histppstruct(varargin)
% Better version of hist that lets you set Patch Properties

[n, xout] = hist(varargin{1:end - 1});

ppstruct = varargin{end};
patchargs = serialize(ppstruct);

xedge = mean([xout(1:end-1); xout(2:end)]);
firstedge = xedge(1) - (xedge(2) - xedge(1));
lastedge = xedge(end) + (xedge(end) - xedge(end-1));
xedge = [firstedge xedge lastedge];
xL = xedge(1:end-1);
xR = xedge(2:end); % one row
X = [xL; xL; xR; xR];
ymin = zeros(size(n));
Y = [ymin; n; n; ymin];
C = zeros(size(n));
patch(X, Y, C, patchargs{:})

switch nargout
    case 1
        varargout = {h};
    case 2
        varargout = {n, xout};
    case 3
        varargout = {n, xout, h};
end



function c = serialize(s)
fields = fieldnames(s);
c = cell(2, length(fields));
for ii = 1:length(fields)
    c{1, ii} = fields{ii};
    c{2, ii} = s.(fields{ii});
end