function decimated = decimateMinMax(sig,n,dim)
% decimateMinMax decimates vectors, keeping the minimum and maximum points

if isvector(sig)
    % decimate vectors along their non singleton dimension
    dim = find(size(sig)>1);
end
if ~exist('dim','var')
    dim = 1; % default value, decimate along rows
end

% initialize decimated matrix
L = 2*floor(size(sig,dim)/(2*n)); % makes sure L is even
siz = size(sig);
siz(dim) = L;
decimated = zeros(siz);

% reorder dimensions so we are always decimating along rows (will shift
% back later if necessary)
sig = shiftdim(sig,dim-1);
decimated = shiftdim(decimated,dim-1);
for c = 1:size(sig,2)% for each vector
    decimated(:,c) = decimate_helper(sig(:,c),n,L);
end

% shift dimensions back to original order
decimated = shiftdim(decimated,-dim+1);

function d = decimate_helper(vec,n,L)

% reshape to windows of double decimation factor because we will get 2
% points from each window
windowed = reshape(vec(1:n*L),2*n,[]);

% get max and min
maxs = max(windowed);
mins = min(windowed);

d(2:2:L) = maxs;% assign max to even points
d(1:2:L) = mins;% min to odd points