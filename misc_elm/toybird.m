clear all; close all; clc
dt = .001; 
dur = 5; 
T = dt:dt:dur; 
smu = .100; 
gmu = .05; 
sdurs = round(exprnd(smu/dt, 1, length(T)*smu)); 
gdurs = round(exprnd(gmu/dt, 1, length(T)*smu)); 
LMAN = zeros(1,length(T));
c = 1; 
for ti = 1:length(T)*smu
    LMAN(c:(c+sdurs(ti))) = 1; 
    LMAN((c+sdurs(ti)+1):(c+sdurs(ti)+1+gdurs(ti))) = 0; 
    c = (c+sdurs(ti)+1+gdurs(ti))+1;
end
LMAN = [zeros(1,2*smu/dt) LMAN(1:(length(T)-4*smu/dt)), zeros(1,2*smu/dt)];
%plot(T, LMAN); ylim([-1 2]); shg
RA = zeros(1,length(LMAN)); 
nHVC = 15; 
intHVC = .005/dt; 
HVC = zeros(nHVC, length(T)); 
NIf = zeros(1,length(LMAN)); 
HVC(1,:) = NIf;
wHVC = .5; 
wNoise = .5; 
smwin = .01;
Lnoise = smooth(randn(1,length(LMAN)),ceil(smwin/dt)); 
LMAN = (1-wNoise)*LMAN+wNoise*Lnoise'; 
NIfthres = .2; 
for ti = 2:length(T); 
    RA(ti) = (1-wHVC)*LMAN(ti-1) + ...
        wHVC*(sum(HVC(:,ti))>0);
    NIf(ti) = mean(RA(max([1,ti-gmu/2/dt]):(ti-1)))<NIfthres & ...
        RA(ti)>NIfthres; 
    HVC(1,:) = NIf; 
    for hvci = 2:nHVC
        if HVC(hvci-1, ti-1)== 1 & HVC(hvci-1, ti-1)>HVC(hvci-1, ti)
            HVC(hvci,ti:min([(ti+intHVC),length(T)])) = 1; 
        end
    end
end


RA = smooth(RA, smwin/dt); 
figure(1); clf; 
hold all
plot(T,RA, 'k', 'linewidth', 2);
plot(T,NIf-2, 'r')
plot(T,LMAN-4); 
plot(T,HVC'-6); 
plot([0 T(end)], [NIfthres NIfthres], 'r')
%legend('RA', 'NIf', 'LMAN', 'HVC', 'location', 'southeast')
set(gca, 'ytick', .5+[-6 -4 -2 0], 'yticklabel', {'HVC', 'LMAN', 'NIf', 'RA'})
set(gcf, 'Color', [1 1 1], 'papersize', [6 3], 'paperposition', [0 0 6 3])
xlabel('Time (s)')
shg
% %% 
% % syll onset dist
% th = median(RA)/2; 
% ons = find(RA(2:end)>=th & (RA(1:end-1)<th))*dt;
% offs = find(RA(2:end)<th & RA(1:end-1)>=th)*dt;
% figure(1); plot(ons/dt, th*ones(size(ons,1),1), 'g.');plot(offs/dt, th*ones(size(ons,1),1), 'r.');
% figure(3); hold on; hist(RA,20); plot([th th], [0 length(RA)/20], 'r')
% figure(2); clf; hist(offs-ons, .01:.01:2);

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
song = base.*resample(RA(1:durplay/dt), 1/dtplay, 1/dt); 
displaySpecgramQuick(song,1/dtplay); 
h = subplot(2,1,2); 
plot(tplay,song); linkaxes([h g], 'x')
sound(song, 1/dtplay); 
