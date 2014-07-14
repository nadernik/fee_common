[data, fs] = wavread('Z:\emackev\AcqGui\BabiesBabbling\BabblingTwins.wav');
data = mean(data, 2); 
data = data((min(find(data~=0))):max(find(data~=0)));
%%
close all
smoothwin = .1; 

P = log(1+conv((data.^2), gausswin(smoothwin*fs), 'same'));
%P = P - min(P);

figure;
h = subplot(2,3,1:2)
%Thres = -Inf; % threshold for being in black background
params.Fs = fs;
params.fpass = [0 10];
winsize = 3;
winstep = winsize/20;
T = winsize; 
W = .4; % frequency bandwidth
K = 2; %number of tapers
params.tapers = [T*W K];
movingwin = [winsize winstep]; 
[S,t,f]=mtspecgramc(P,movingwin,params);
plot_matrix(S,t,f)
Pow = 10*log10(abs(S))';
% Pow(Pow<Thres) = Thres;
% cmap = jet; 
% cmap(1,:) = zeros(1,3); % background = black
% colormap(cmap);
% surf(t, f, Pow,'edgecolor','none'); axis tight; 
% view(0,90);
ylabel('Frequency (Hz)')
xlabel('')
colorbar off
%imagesc(t, f, 10*log10(S)');shg
%set(gca, 'Ydir', 'normal')
set(gca, 'xtick', [], 'box', 'off')

subplot(2,3,3)
plot(sum(Pow,2), f, 'k')
set(gca,  'xticklabel', [])
axis tight
ylabel('Frequency (Hz)')
xlabel('Power (au)')
set(gca, 'box', 'off')

g = subplot(2,3,4:5)
plot((1:size(data,1))/fs, P, 'k')
xlabel('Time (s)')
ylabel('Loudness (au)')
linkaxes([h g], 'x')
set(gca, 'box', 'off')

set(gcf, 'Color', [1 1 1], 'papersize', [6 3], 'paperposition', [0 0 6 3])

% finding peak frequency
M = max(sum(Pow(f>1,:),2));
ind = find(sum(Pow,2)==M)
PeakFreq = f(ind); 

% subplot(g); hold on
% plot((1:size(data,1))/fs, 5*(round(mod((1:size(data,1)), fs/PeakFreq))==round(1)),  'r')
%%
winsize = 2;
winstep = winsize/10;
nPhases = 25; 
totalTime = numel(P)/fs; 
winstarti = 1:winstep*fs:totalTime*fs;
winendi = winstarti+winsize*fs; 
winstarti = winstarti(winendi<=totalTime*fs);
winendi = winendi(winendi<=totalTime*fs);
nChunks = numel(winendi);
Coh = zeros(nChunks, nPhases);

Pnorm = P; %zscore(P); 
for phasei = 1:nPhases
    Sine = sin(2*pi*PeakFreq/fs*(1:totalTime*fs)+ phasei*2*pi/nPhases);
    for chunki = 1:nChunks
        tempP = Pnorm(winstarti(chunki):winendi(chunki))';
        tempSine = Sine(winstarti(chunki):winendi(chunki));
        Coh(chunki, phasei) = sum(tempP.*tempSine); 
    end
end
k = subplot(2,1,2)
plot((1:size(data,1))/fs, P, 'k')
xlabel('Time (s)')
ylabel('Loudness (au)')
box off
axis tight

m = subplot(2,1,1)
set(gca, 'box', 'off')
surf((winstarti+winendi)/fs/2, (1:nPhases)*2*pi/nPhases, Coh','edgecolor','none'); axis tight; 
colormap jet
view(0,90);
set(gca, 'xtick', [])
set(gca, 'ytick', [0 pi 2*pi], 'yticklabel', {'0', 'pi', '2pi'})
ylabel('Phase (radians)')
box off
axis tight

linkaxes([k m], 'x')

set(gcf, 'Color', [1 1 1], 'papersize', [9 3], 'paperposition', [0 0 9 3])
