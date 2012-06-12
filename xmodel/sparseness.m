function s = sparseness(x)
%SPARSENESS Entropy measure of sparseness of neural population to stimuli
%   SPARSENESS(X) is a vector with each element is a measure of how a
%   population of neurons respond to each stimulus. The matrix
%   X contains the average responses of each neuron to each stimulus. Each
%   row in X represents one stimulus and each column represents one neuron.
%   Activites must be non-negative. If all neurons have zero activity for
%   a stimulus, the sparsness for that stimulus is undefined and will have
%   the value NaN.
num_neurons = size(x,2);

% normalize population activity to 1 for each stimulus
a = sum(x, 2); %population activity for each stimulus
p = x ./ (a * ones(1,num_neurons));

s = sum(plogp(p), 2); % sum across neurons to give one value of sparseness for each stimulus

pmn = ones(1, num_neurons) / num_neurons;
pmx = [zeros(1, num_neurons - 1), 1];
mx = sum(plogp(pmx), 2);
mn = sum(plogp(pmn), 2);

s = (s - mn) / (mx - mn);

function z = plogp(y)
skip = y==0;
z = zeros(size(y));
z(~skip) = y(~skip) .* log(y(~skip));