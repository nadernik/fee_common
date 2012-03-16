function a = selectivity_franco(y)
% Biol Cybern. 2007 Jun;96(6):547-60. Epub 2007 Apr 5.
% Neuronal selectivity, population sparseness, and ergodicity in the inferior temporal visual cortex.
% Franco L, Rolls ET, Aggelopoulos NC, Jerez JM.

S = size(y, 1); % number of stimuli

a = sum(y/S).^2 ./ (sum(y.^2)/S);