function Y = gettrials(vec, trials, trialsteps)
% GETTRIALS returns matrix of trials from a vector
% 
% Usage: gettrials(vec, trials, trialsteps)
%
%
% If trials are negative, they are measured from end
% If the last trial is not complete, it doesn't count
% Assumes that first element in vec is the beginning of the first trial

npad = trialsteps - mod(length(vec), trialsteps);
if npad ~= trialsteps
    vec(end+1:end+npad) = nan;
end

Y = reshape(vec, trialsteps, []);

trials(trials <= 0) = size(Y, 2) + trials(trials <= 0) + 1;
Y = Y(:, trials);