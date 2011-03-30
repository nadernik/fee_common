function varargout = plottrials(vec, trials, trialsteps)
% If trials are negative, they are measured from end
% If the last trial is not complete, it doesn't count

npad = trialsteps - mod(length(vec), trialsteps);
if npad ~= trialsteps
    vec(end+1:end+npad) = nan;
end

Y = reshape(vec, trialsteps, []);

trials(trials <= 0) = size(Y, 2) + trials(trials <= 0) + 1;
h = plot(Y(:, trials));

if nargout > 0
    varargout{1} = h;
end
