clear all; close all; clc
tic; 

dt = .001; % simulation time step, in seconds
dur = 10; % simulation duration, in seconds
T = dt:dt:dur; % time vector
nHVC = 15; % number of HVC units
wNoise = .5; % proportion of LMAN signal governed by white noise instead of by 'on/off' part
smu = .100; % mean syllable duration in 'on/off' part of LMAN signal
gmu = .05; % mean gap duration in 'on/off' part of LMAN signal
smwin = .005; % amount to smooth LMAN and RA signals, in seconds

wHVC = .5; % proportion RA signal given by HVC input (rest is given by LMAN)
%HVCwMatrix = rand(nHVC,nHVC);
HVCwMatrix = reshape(mod(1:nHVC^2, nHVC+1)==2, nHVC,nHVC); % feedforward. Wij is weight onto i from j

% The following parameters govern how NIf and HVC respond to inputs. NIf
% gets input from RA. HVC is a feedforward chain initiated by NIf. These
% are in units of seconds
burstThres = .2; % fire if input exceeds this threshold. Inputs range approximately between 0 and 1.
burstDelay = smwin; % fire at this delay from threshold crossing. RA also fires at this delay.
burstRefPeriod = burstDelay*5; % for NIf, the refractory period is also on
% input from RA.  That is, NIf only responds to RA threshold crossings 
% preceded by quiet RA periods.  HVC units have a refractory period
% (insensitive to inputs for burstRefPeriod seconds after activated), but
% this doesn't make much difference.

%initializing neural variables
RA = zeros(1,length(T)); 
LMAN = zeros(1,length(T));
NIf = zeros(1,length(T)); 
HVC = zeros(nHVC, length(T)); 

% making 'on/off' part of LMAN signal (with exp syl and gap durations)
sdurs = round(exprnd(smu/dt, 1, length(T)*smu)); 
gdurs = round(exprnd(gmu/dt, 1, length(T)*smu)); 
c = 1; 
for ti = 1:length(T)*smu
    LMAN(c:(c+sdurs(ti))) = 1; 
    LMAN((c+sdurs(ti)+1):(c+sdurs(ti)+1+gdurs(ti))) = 0; 
    c = (c+sdurs(ti)+1+gdurs(ti))+1;
end
size(LMAN)
LMAN = [zeros(1,2*smu/dt) LMAN(1:(length(T)-4*smu/dt)) zeros(1,2*smu/dt)];

% adding white noise part of LMAN signal, smoothing
Lnoise = randn(1,length(T));
LMAN = smooth((1-wNoise)*LMAN+wNoise*Lnoise,ceil(smwin/dt)); 


% iterate through time
for ti = 2:length(T); 
    indStartSilence = ceil(max([1,ti-burstRefPeriod/dt-burstDelay/dt])); % start of refractory window
    indEndSilence = ceil(max([1,(ti-burstDelay/dt)])); % end of refractory window (burst delay)
    RA(ti) = (1-wHVC)*LMAN(indEndSilence) + ...
        wHVC*(sum(HVC(:,indEndSilence))>0); % RA is a weighted sum of LMAN and HVC
    % smoothing RA
    indStartSmooth = max([1,ti-smwin/dt]); 
    smoothvec = ((indStartSmooth:ti)-indStartSmooth); 
    smoothvec = smoothvec/sum(smoothvec); 
    RA(ti) = sum(smoothvec.*RA(indStartSmooth:ti)); 
    NIf(ti) = mean(RA(indStartSilence:indEndSilence))<burstThres & ... % refractory for inputs from RA
        max(NIf(indStartSilence:indEndSilence))==0 & ... % refractory period for NIf
        RA(indEndSilence)>burstThres; % NIf fires when RA was quiet, then exceeds threshold
    HVC(1,ti) = NIf(ti); % NIf excites the first link in the HVC chain
    for hvci = 1:nHVC
        HVC(hvci,ti) = (HVC(hvci,ti) + sum(HVCwMatrix(hvci,:).*HVC(:,indEndSilence)')>burstThres);...
            %(max(HVC(hvci,indStartSilence:indEndSilence))==0); % ref period doesn't make much difference
    end
end
toc
figure(1); clf; 
hold all
plot(T,RA, 'k', 'linewidth', 2);
plot(T,NIf-2, 'r')
plot(T,LMAN-4); 
plot(T,HVC'/nHVC + repmat((1:nHVC)/nHVC, length(T), 1) + -6); 
plot([0 T(end)], [burstThres burstThres], 'r')
%legend('RA', 'NIf', 'LMAN', 'HVC', 'location', 'southeast')
set(gca, 'ytick', .5+[-6 -4 -2 0], 'yticklabel', {'HVC', 'LMAN', 'NIf', 'RA'})
set(gcf, 'Color', [1 1 1], 'papersize', [6 3], 'paperposition', [0 0 6 3])
xlabel('Time (s)')
shg
%%
figure(2); 
[ac, lags] = xcorr(RA-mean(RA)); 
plot(lags*dt, ac,'k'); xlim([-1 1])
shg

%% play the 'song'
durplay = min(10,T(end)); 
dtplay = 1/40000; 
tplay = (dtplay:dtplay:durplay); tplay = tplay(:); 
ff = 500+2*sin(2*pi*tplay); %smooth(1000+200*randn(length(tplay),1), 10*smu/dtplay); %
ff = ff(:);  
% pitch = sin(ff.*(2*pi).*mod(tplay, 1/dtplay))'+...
%     .5*sin(ff.*(4*pi).*mod(tplay,1/dtplay))'+...
%     .25*sin(ff.*(6*pi).*mod(tplay,1/dtplay))';
% pitch = pitch(:)/max(abs(pitch));  
noise = randn(length(tplay),1); 
[b,a] = butter(5, [500 4000]/(1/dtplay/2), 'bandpass');
noise = filter(b,a,noise);
noise = noise(:)/max(abs(noise)); 
alphan = smooth(rand(2*length(tplay),1), smu/dtplay); 
alphan = alphan((length(tplay)/2):(3*length(tplay)/2)-1); 
alphan = alphan-min(alphan); alphan = alphan(:)/max(abs(alphan));
base = noise;
figure; g = subplot(2,1,1); 
song = base.*resample(RA(1:durplay/dt), 1/dtplay, 1/dt)'; 
displaySpecgramQuick(song,1/dtplay); 
h = subplot(2,1,2); 
plot(tplay,song); linkaxes([h g], 'x')
sound(song, 1/dtplay); 
