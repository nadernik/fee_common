videoInfo = hdf5info('Q:\Inscopix\Testing\recording_20150603_213519_gpio.hdf5')
VIDEO = hdf5read('Q:\Inscopix\Adult\recording_20150603_211035_gpio.hdf5','/');

%%
A = importdata('Q:\Inscopix\Adult\recording_20150603_211035_gpio.hdf5')
%% Gibbs sampling
% make the posterior
% height weight
MUobserved = [6; 180]; 
SIGMAobserved = [.1 0; 0 5]; 
MUprior = [5.7; 184]; 
SIGMAprior = [1.2 .2; .2 15]; 
SIGMA = inv(inv(SIGMAobserved) + inv(SIGMAprior)); 
MU = SIGMA*inv(SIGMAobserved)*MUobserved + SIGMA*inv(SIGMAprior)*MUprior;
z = (2*pi)^(-1)*(norm(SIGMA)/norm(SIGMAprior)/norm(SIGMAobserved))^.5*...
    exp(-.5*(MUobserved'*inv(SIGMAobserved)*MUobserved + ...
    MUprior'*inv(SIGMAprior)*MUprior - ...
    MU'*inv(SIGMA)*MU)); 

MU = MUprior
SIGMA = SIGMAprior


% initialize
nIter = 1000; 
x = zeros(2,nIter); 
x(:,1) = MU; 
% for each iteration
for i = 2:nIter
    if mod(i,2) == 0
        x(2,i) = x(2,i-1); 
        mu = MU(1) + SIGMA(2,1)/SIGMA(2,2)*(x(2,i) - MU(2)); 
        sigma = sqrt(SIGMA(1,1) - SIGMA(1,2)/SIGMA(2,2)*SIGMA(2,1)); 
        x(1,i) = randn*sigma + mu; 
    else
        x(1,i) = x(1,i-1); 
        mu = MU(2) + SIGMA(1,2)/SIGMA(1,1)*(x(1,i) - MU(1)); 
        sigma = sqrt(SIGMA(2,2) - SIGMA(2,1)/SIGMA(1,1)*SIGMA(1,2)); 
        x(2,i) = randn*sigma + mu; 
    end
end
figure(1); clf; hold on
plot(x(1,:),x(2,:), 'color', .8*[1 1 1]); shg
plot(x(1,:),x(2,:), 'ks')
ylabel('weight (lbs)'); xlabel('height (ft)')
mu1 = mean(x(:,1)); 
mu2 = mean(x(:,2)); 
Cov = cov(x')
% get each x_i conditioned on the others on the previous iteration