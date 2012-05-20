function [Msorted,ord] = sortbybursttime(M, threshold)

mode = 'max';

if strcmp(mode, 'crossing')
    % Find threshold crossings
    above = M > threshold;
    crossings = diff(above, 2);

    % Find first upwards threshold crossing for each row
    for row = 1:size(M, 1)
        temp = find(crossings(row,:) == 1, 1, 'first');
        if isempty(temp)
            burst_times(row) = Inf;
        else
            burst_times(row) = temp;
        end
    end
elseif strcmpi(mode, 'max')
    for row = 1:size(M,1)
        [v, ndx] = max(M(row,:));
        if v > threshold
            burst_times(row) = ndx;
        else
            burst_times(row) = Inf;
        end
    end     
else
    error('unknown mode')
end

% Use first crossing times to sort the rows of matrix M
[junk, ord] = sort(burst_times);
Msorted = M(ord,:);
end

function tf = isdimof(d, M)
% checks to see if d is a valid dimension of M
tf = mod(d,1) == 0 && d > 0 && d <= ndims(M);
end