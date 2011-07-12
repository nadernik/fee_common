close all
clear all

% Load real data
savefile1 = 'c:\stetner\data\pitchfluctuations\mes021_stack1.mat';
d1 = load(savefile1);

% Fourier transform of all pitch
X = d1.fouriercoefs;

% Take mean in frequency space
meanX = mean(X, 2);

% Transform mean back to time domain
x2 = ifft(meanX);
T = size(d1.pitches,1);
x2 = x2(1:T,:);

% Compare new signal vs. examples of the original
nplot = 20;
plot(d1.pitches(:,1:nplot))
hold on
plot(x2, 'k', 'LineWidth', 3)

% The resulting signal x2 is nearly zero everywhere. This is not a good
% approach.