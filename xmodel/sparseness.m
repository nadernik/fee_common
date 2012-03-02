function s = sparseness(x)
% each row is one stimulus, each column is one neuron
num_neurons = size(x,2);

% normalize population activity to 1 for each stimulus
a = sum(x, 2); %population activity for each stimulus
p = x ./ (a * ones(1,num_neurons));

s = sum(plogp(p), 2); % sum across neurons to give one value of sparseness for each stimulus

function z = plogp(y)
skip = y==0;
z = zeros(size(y));
z(~skip) = y(~skip) .* log(y(~skip));