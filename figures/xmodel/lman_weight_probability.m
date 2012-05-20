lman_rand = 10;
x = logspace(-1.5,1.5);
P = 1/x;
P(x>10|x<0.1) = 0;
semilogx(x, P)
xlabel('Weight')
ylabel('Probability')

%%
y = lman_rand.^(2*rand(10000,1) - 1);
t = logspace(-1.5, 1.5);
for n = 1:length(t)
    mycdf(n) = sum(y <= t(n)) / length(y);
end
semilogx(t, mycdf)

%%
x = 
P = 