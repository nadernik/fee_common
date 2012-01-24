function plotmean95pct(varargin)
% plotmean95pct Plots mean and filled area containing 95th percentile

% find Y in arguments. It should be a matrix.
matrixargs = ismatrix(varargin{:});

% if none of the arguments is a matrix, then Y must be a vector. In this
% case there will be no 95th percentile, so we can just plot as usual.
if ~any(matrixargs)
    plot(varargin{:})
    return
end

% Y is the first argument that is a matrix
nargY = matrixargs(1);
Y = varargin{nargY};

% find middle 95 percentile of each row in Y (each time point)
p = prctile(Y, [2.5 97.5], 2);
upperlim = p(:,1);
lowerlim = p(:,2);

% plot mean of Y across columns using all the same plot arguments.
meanY = mean(Y,2);
varargin{nargY} = meanY;
h = plot(varargin{:});

% Plot area using same color as for the mean
% nargcolor = find(strcmpi(varargin, 'Color')) + 1;
mycolor = get(h, 'Color'); %varargin{nargcolor};
x = get(h, 'XData');
xxrev = [x, wrev(x)];
hold on
fill(xxrev, [upperlim; wrev(lowerlim)], mycolor,'FaceAlpha', 0.5, 'LineStyle', 'none');
hold off

function tf = ismatrix(varargin)
ismatrix1 = @(x) sum(size(x)>1)==2; % returns true if x has exactly 2 nonsingleton dimensions
tf = cellfun(ismatrix1, varargin);


    
    