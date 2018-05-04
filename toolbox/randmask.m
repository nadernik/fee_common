function mask = randmask(L, N)
% random logical mask selecting N elements from a L-element vector

mask = false(1, L);
temp = randperm(L);
true_ndx = temp(1:N);
mask(true_ndx) = true;