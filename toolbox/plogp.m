function z = plogp(y)
skip = y==0;
z = zeros(size(y));
z(~skip) = y(~skip) .* log2(y(~skip));