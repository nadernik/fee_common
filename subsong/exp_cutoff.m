function tau = exp_cutoff(x,c)
% x: [ms]
% Maximum likelihood estimation for an exponential distribution
% on a finite domain [c1 c2]

maxposs = 0.2;
numinit = 40;

c1 = c(1);
c2 = c(2);
x(x<c1) = [];
x = x-c1;
c = c2-c1;

x=sort(x(x<c));
if size(x,1)>size(x,2)
    x = x';
end
sumx = sum(x);
N = length(x);

lil = inf;
for j = linspace(0,maxposs,numinit)
    ntau = fzero(@(etau)logP(sumx,N,etau,c),j);
    expfitcdf = (expcdf(x,ntau)-expcdf(c1,ntau))/(expcdf(c2,ntau)-expcdf(c1,ntau));
    nlil = max(abs((1:length(x))/length(x)-expfitcdf))*sqrt(length(x));
    if nlil < lil
        tau = ntau;
    end
end

% restau = zeros(1,1000);
% for t = 1:length(restau)
%     sumx = sum(x(ceil(rand(1,length(x))*length(x))));
%     restau(t) = fzero(@(etau)logP(sumx,N,etau,c),0.1);
% end
% intr = [prctile(restau,2.5) prctile(restau,97.5)];


function logP = logP(sumx,N,etau,c)

if etau > 0
    logP = sumx + N*(-etau+c*exp(-c/etau)/(1-exp(-c/etau)));
else
    logP = 1;
end