function figure_rpe(do_simulation)

%% Parameters
pitchtarget = 800; % Hz
caferrorvalue = 400;
cafthreshold = 800; % Hz
caftime = 50; % ms
cafnoiseduration = 10; % ms
songlength = 200; % ms
totalmotifs = 100;
errorstd = 12.5;
errorkernel = normpdf(0:8*errorstd, 4*errorstd, errorstd);
tmax = songlength + length(errorkernel) - 1;
datafile = 'c:\stetner\data\figures\xmodel\rpe.mat';

% Shared color scheme for all figures in this paper
c = load('c:\stetner\code\figures\xmodel\xmodel_color_scheme.mat');

set(gcf, 'Renderer', 'painters')

%% (A) error as a function of pitch in conditional auditory feedback
pitch = linspace(-150,150) + pitchtarget;
pitcherror = ((pitch - pitchtarget) ./ pitchtarget .* 100).^2; % percent error squared
caferror = pitcherror;
caferror(pitch < cafthreshold) = caferrorvalue;
rpefig.caferroraxes = subplot(5,2,2);
plot(pitch, pitcherror, ':', 'Color', c.vta)
hold on
plot(pitch, caferror, 'Color', c.vta, 'LineWidth', 3)
hold off
ylim([-50 500])
xlabel('Pitch (Hz)')
ylabel('Error')
title('CAF')

%% (B) pitch over time

% Do simulations if requested. If simulations were not requested, load data
% from file.
if exist('do_simulation', 'var') && do_simulation == 1
    % generate many pitches
    fluctuations = generate_lman_noise_mes010(songlength, totalmotifs);
    songs = fluctuations./100 .* pitchtarget + pitchtarget; % convert percent pitch into Hz

    % choose one motif that escapes...
    escmotif = find(songs(caftime, :) > cafthreshold, 1);

    % ... and one motif that is hit by conditional auditory feedback
    hitmotif = find(songs(caftime, :) < cafthreshold, 1);
else
    load(datafile, 'fluctuations', 'songs', 'escmotif', 'hitmotif')
end

rpefig.pitchtimeaxes = subplot(5,2,3:4);
plot(songs(:,escmotif), 'Color', c.escape, 'LineWidth', 3)
hold on
plot(songs(:,hitmotif), 'Color', c.hit, 'LineWidth', 3)
ylim([-50, 50] + cafthreshold)

% Translucent rectangle marking CAF time. Left edge of the rectangle is at
% the target time; width of the rectangle is the noise duration; top edge
% of the rectangle is at the pitch threshold.
ylims = ylim;
X = [0, 0, cafnoiseduration, cafnoiseduration] + caftime;
Y = [ylims(1), cafthreshold, cafthreshold, ylims(1)];
rh = patch(X,Y,[1 0 0]);
set(rh, 'FaceAlpha', 0.2)

ylim(ylims) % drawing the rectangle can change the y axis, so change it back to what it was
xlim([0 tmax])
set(gca, 'XTick', 0:100:300, 'XTickLabel', [])
ylabel('Pitch (Hz)')
legend({'Escape', 'Hit'}, 'Location', 'SouthEast')
hold off
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
plot(errorraw(:,escmotif), 'Color', c.escape, 'LineWidth', 3)
hold on
plot(errorraw(:,hitmotif), 'Color', c.hit, 'LineWidth', 3)
xlim([0 tmax])
yrange = diff(ylim);          % Expand y limits 
ylim(ylim + [-.1, .1]*yrange) % by 10%
hold off
ylabel('Error')
set(gca, 'XTick', 0:100:300, 'XTickLabel', [])
legend({'Escape', 'Hit'}, 'Location', 'SouthEast')
hold off
%% reward over time
reward = -errorsmooth;
rpefig.rewardtimeaxes = subplot(5,2,7:8);
plot(reward(:,escmotif), 'Color', c.escape, 'LineWidth', 3)
hold on
plot(reward(:,hitmotif), 'Color', c.hit, 'LineWidth', 3)
xlim([0 tmax])
yrange = diff(ylim);          % Expand y limits 
ylim(ylim + [-.1, .1]*yrange) % by 10%
prediction = mean(reward, 2);
plot(prediction, 'k:', 'LineWidth', 2)
hold off
ylabel('Reward')
set(gca, 'XTick', 0:100:300, 'XTickLabel', [])
legend({'Escape', 'Hit', 'Average Reward'}, 'Location', 'SouthEast')
hold off

%% reward prediction error over time
prediction = mean(reward, 2);
rpe = reward - prediction*ones(1, totalmotifs);
rpefig.rpetimeaxes = subplot(5,2,9:10);
plot(rpe(:, escmotif), 'Color', c.escape, 'LineWidth', 3)
hold on
plot(rpe(:, hitmotif), 'Color', c.hit, 'LineWidth', 3)
xlim([0 tmax])
set(gca, 'XTick', 0:100:300, 'XTickLabel', arrayfun(@int2str,0:100:300, 'UniformOutput', false))
hold off
ylabel('RPE')
xlabel('Time (ms)')
legend({'Escape', 'Hit'}, 'Location', 'SouthEast')
hold off

%%
save(datafile)