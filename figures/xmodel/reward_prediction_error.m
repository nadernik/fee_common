clear all
close all

pitchtarget = 800; % Hz
caferrorvalue = 400;
cafthreshold = 800; % Hz
caftime = 50; % ms
cafnoiseduration = 10; % ms
songlength = 200; % ms
totalmotifs = 100;
errorstd = 7;
errorkernel = normpdf(0:8*errorstd, 4*errorstd, errorstd);
tmax = songlength + length(errorkernel) - 1;
hitcolor = [1, 0  , 0];
esccolor = [0, 0.7, 0];


%% (A) error as a function of pitch in normal singing
rpefig.fig = figure;
pitch = linspace(-150,150) + pitchtarget;
pitcherror = ((pitch - pitchtarget) ./ pitchtarget .* 100).^2; % percent error squared

rpefig.pitcherroraxes = subplot(5,2,1);
plot(pitch, pitcherror);
ylim([-50 500])
xlabel('Pitch (Hz)')
ylabel('Error')
%% (B) error as a function of pitch in conditional auditory feedback
caferror = pitcherror;
caferror(pitch < cafthreshold) = caferrorvalue;
rpefig.caferroraxes = subplot(5,2,2);
plot(pitch, pitcherror, ':')
hold on
plot(pitch, caferror)
hold off
ylim([-50 500])
xlabel('Pitch (Hz)')
ylabel('Error')
title('CAF')
%% (C) pitch over time

% generate many pitches
fluctuations = generate_lman_noise(songlength, totalmotifs);
songs = fluctuations./100 .* pitchtarget + pitchtarget; % convert percent pitch into Hz

% choose one motif that escapes...
escmotif = find(songs(caftime, :) > cafthreshold, 1);

% ... and one motif that is hit by conditional auditory feedback
hitmotif = find(songs(caftime, :) < cafthreshold, 1);

rpefig.pitchtimeaxes = subplot(5,2,3:4);
plot(songs(:,escmotif), 'Color', esccolor)
hold on
plot(songs(:,hitmotif), 'Color', hitcolor)
% bar marking noise
x = [0, cafnoiseduration, cafnoiseduration, 0] + caftime;
lims = ylim;
y = [0, 0, -.05, -.05] * (lims(2)-lims(1)) + lims(2);
fill(x, y, 'r')
xlim([0 tmax])
hold off
% arrow marking caf time
temp = ylim;
ymin = temp(1);
[nx, ny] = dsxy2figxy([caftime,caftime], [ymin,cafthreshold]);
annotation('arrow', nx, ny+eps)
set(gca, 'XTickLabel', [])
ylabel('Pitch (Hz)')
%% error over time

% error is the squared percent difference between the song and target
errorraw = ((songs - pitchtarget)/pitchtarget * 100).^2;

% if the pitch is over the caf threshold at the target time, the error is
% equal to the caf error value for the duration of the noise burst
for motif = 1:totalmotifs
%     if motif == hitmotif
%         keyboard
%     end
    if songs(caftime, motif) < cafthreshold
        errorraw(caftime+(1:cafnoiseduration), motif) = caferrorvalue;
    end
end

% convolve with kernel to make error signal delayed and blurred
errorsmooth = zeros(tmax, size(songs, 2));
for motif = 1:totalmotifs
    errorsmooth(:,motif) = conv(errorraw(:,motif), errorkernel);
end

rpefig.errortimeaxes = subplot(5,2,5:6);
plot(errorsmooth(:,escmotif), 'Color', esccolor)
hold on
plot(errorsmooth(:,hitmotif), 'Color', hitcolor)
xlim([0 tmax])
hold off
ylabel('Error')
set(gca, 'XTickLabel', [])
%% reward over time
reward = -errorsmooth;
rpefig.rewardtimeaxes = subplot(5,2,7:8);
plot(reward(:,escmotif), 'Color', esccolor)
hold on
plot(reward(:,hitmotif), 'Color', hitcolor)
xlim([0 tmax])
prediction = mean(reward, 2);
plot(prediction, 'k:')
hold off
ylabel('Reward')
set(gca, 'XTickLabel', [])
%% reward prediction error over time
prediction = mean(reward, 2);
rpe = reward - prediction*ones(1, totalmotifs);
rpefig.rpetimeaxes = subplot(5,2,9:10);
plot(rpe(:, escmotif), 'Color', esccolor)
hold on
plot(rpe(:, hitmotif), 'Color', hitcolor)
xlim([0 tmax])
hold off
ylabel('RPE')
xlabel('Time (ms)')