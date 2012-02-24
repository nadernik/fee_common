function s = selectivity(x)
% each row is one stimulus, each column is one neuron
num_stimuli = size(x,1);

% normalize population activity to 1 for each neuron
a = sum(x, 1); %population activity for each stimulus
p = x ./ (ones(num_stimuli,1) * a);

s = -sum(plogp(p), 1); % sum across neurons to give one value of sparseness for each stimulus

function z = plogp(y)
skip = y==0;
z = zeros(size(y)); % if probability is zero, set p*log(p) to zero. even tho 0*log(0) is indeterminate, its limit is zero
z(~skip) = y(~skip) .* log(y(~skip));