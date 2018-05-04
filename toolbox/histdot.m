function h = histdot(N, bin_centers)
X = [];
Y = [];
for bin = 1:length(bin_centers)
    X = [X, bin_centers(bin)*ones(1,N(bin))];
    Y = [Y, 1:N(bin)] ;
end
h = scatter(X,Y);