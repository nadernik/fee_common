%% Reward Prediction Error
close all
N = 100; % number of trials
T = 50; % number of time points in each trial
t = 40; % target time for examples
Nshow = 10;
nred = 89 % red example trial number
ngreen = 3; % green example trial number

colors.good = [0 1 0]; %green
colors.bad = [1 0 0]; %red
colors.trace = [.4 .4 1];
colors.mean = [1 1 1]; %white
colors.template = [1 1 0]; %yellow

hist_ymax = 50;

if exist('regen', 'var') && regen == true
    template = sin(linspace(0, 4*pi, T)) + 4;
    meansong = cos(linspace(0, 4*pi, T)) + 2;

    songs = meansong'*ones(1, N) + generate_lman_noise(T, N);
    errors = (songs - template'*ones(1, N)).^2;
    rewards = -errors;
    prediction = mean(rewards, 2);
    rpe = rewards - prediction*ones(1, N);
    nrand = randperm(N);
    nrand = nrand(nrand~=nred & nrand~=ngreen);
    nshow = [nred, ngreen, nrand(1:Nshow-2)];
end



%% (a) Template and actual song
bin_centers = -9.5:1:9.5;
figure
hold on
plot(songs, 'Color', [.5 .5 1])
plot(mean(songs, 2), 'Color', mean_color, 'LineWidth', 3)
x = t + [-0.5, 0.5];
y = interp1(1:T, songs(:, nred), x);
plot(x, y, 'Color', bad_color, 'LineWidth', 3)
y = interp1(1:T, songs(:, ngreen), x);
plot(x, y, 'g', 'Color', good_color, 'LineWidth', 3)
plot(template, 'Color', template_color, 'LineWidth', 3)

ylo = min(min(min(songs)), min(template));
yhi = max(max(max(songs)), max(template));
xlim([1 T])
ylim([ylo yhi])
xlabel('Time (ms)')
ylabel('Pitch')
axis off

figure
counts = hist(songs(t, :), bin_centers);
h = histdot(counts, bin_centers);
set(h, 'Marker', '.', 'MarkerEdgeColor', trace_color, 'MarkerFaceColor', trace_color)
hold on
[junk, redbin] = min(abs(bin_centers - songs(t, nred)));
scatter(bin_centers(redbin), counts(redbin) + 1, 'MarkerEdgeColor', bad_color, 'MarkerFaceColor', bad_color)
[junk, greenbin] = min(abs(bin_centers - songs(t, ngreen)));
scatter(bin_centers(greenbin), counts(greenbin) + 1, 'MarkerEdgeColor', good_color, 'MarkerFaceColor', good_color)
% scatter(nred, errors(t, nred), 300, '.r')
% scatter(ngreen, errors(t, ngreen), 300, '.g')
xlim([-10 10])
ylim([0 30])
xlabel('Error')
ylabel('count')
axis off




%% (b) Error is squared difference between template and actual song
bin_centers = -97.5:5:97.5;

Y = errors;

figure
hold on
yhi = max(max(Y));
ylo = min(min(Y));
yrange = yhi - ylo;
ylo = ylo - 0.15 * yrange;
yhi = yhi + 0.15 * yrange;
plot(Y, 'Color', colors.trace)
plot(mean(Y, 2), 'Color', colors.mean, 'LineWidth', 3)
x = t + [-0.5, 0.5];
y = interp1(1:T, Y(:, nred), x);
plot(x, y, 'Color', colors.bad, 'LineWidth', 3)
y = interp1(1:T, Y(:, ngreen), x);
plot(x, y, 'Color', colors.good, 'LineWidth', 3)
xlim([0 T])
ylim([ylo yhi])
axis off

figure
counts = hist(Y(t, :), bin_centers);
h = histdot(counts, bin_centers);
set(h, 'Marker', '.', 'MarkerEdgeColor', colors.trace, 'MarkerFaceColor', colors.trace)
hold on
[junk, redbin] = min(abs(bin_centers - Y(t, nred)));
scatter(bin_centers(redbin), counts(redbin) + 1, 'MarkerEdgeColor', colors.bad, 'MarkerFaceColor', colors.bad)
[junk, greenbin] = min(abs(bin_centers - Y(t, ngreen)));
scatter(bin_centers(greenbin), counts(greenbin) + 1, 'MarkerEdgeColor', colors.good, 'MarkerFaceColor', colors.good)
x = mean(Y(t, :));
line([x x], [0 hist_ymax], 'Color', colors.mean, 'LineWidth', 2)
xlim([-100 100])
ylim([0 hist_ymax])
axis off

%% (c) Reward is negative error
% Because VTA seems to signal rewarding things, not punishments

Y = rewards;

figure
hold on
yhi = max(max(Y));
ylo = min(min(Y));
yrange = yhi - ylo;
ylo = ylo - 0.15 * yrange;
yhi = yhi + 0.15 * yrange;
plot(Y, 'Color', colors.trace)
plot(mean(Y, 2), 'Color', colors.mean, 'LineWidth', 3)
x = t + [-0.5, 0.5];
y = interp1(1:T, Y(:, nred), x);
plot(x, y, 'Color', colors.bad, 'LineWidth', 3)
y = interp1(1:T, Y(:, ngreen), x);
plot(x, y, 'Color', colors.good, 'LineWidth', 3)
xlim([0 T])
ylim([ylo yhi])
axis off

figure
counts = hist(Y(t, :), bin_centers);
h = histdot(counts, bin_centers);
set(h, 'Marker', '.', 'MarkerEdgeColor', colors.trace, 'MarkerFaceColor', colors.trace)
hold on
[junk, redbin] = min(abs(bin_centers - Y(t, nred)));
scatter(bin_centers(redbin), counts(redbin) + 1, 'MarkerEdgeColor', colors.bad, 'MarkerFaceColor', colors.bad)
[junk, greenbin] = min(abs(bin_centers - Y(t, ngreen)));
scatter(bin_centers(greenbin), counts(greenbin) + 1, 'MarkerEdgeColor', colors.good, 'MarkerFaceColor', colors.good)
x = mean(Y(t, :));
line([x x], [0 hist_ymax], 'Color', colors.mean, 'LineWidth', 2)
xlim([-100 100])
ylim([0 hist_ymax])
axis off


%% (d) Reward prediction error is difference between reward and predicted reward

Y = rpe;

figure
hold on
yhi = max(max(Y));
ylo = min(min(Y));
yrange = yhi - ylo;
ylo = ylo - 0.15 * yrange;
yhi = yhi + 0.15 * yrange;
plot(Y, 'Color', colors.trace)
plot(mean(Y, 2), 'Color', colors.mean, 'LineWidth', 3)
x = t + [-0.5, 0.5];
y = interp1(1:T, Y(:, nred), x);
plot(x, y, 'Color', colors.bad, 'LineWidth', 3)
y = interp1(1:T, Y(:, ngreen), x);
plot(x, y, 'Color', colors.good, 'LineWidth', 3)
xlim([0 T])
ylim([ylo yhi])
axis off

figure
counts = hist(Y(t, :), bin_centers);
h = histdot(counts, bin_centers);
set(h, 'Marker', '.', 'MarkerEdgeColor', colors.trace, 'MarkerFaceColor', colors.trace)
hold on
[junk, redbin] = min(abs(bin_centers - Y(t, nred)));
scatter(bin_centers(redbin), counts(redbin) + 1, 'MarkerEdgeColor', colors.bad, 'MarkerFaceColor', colors.bad)
[junk, greenbin] = min(abs(bin_centers - Y(t, ngreen)));
scatter(bin_centers(greenbin), counts(greenbin) + 1, 'MarkerEdgeColor', colors.good, 'MarkerFaceColor', colors.good)
x = mean(Y(t, :));
line([x x], [0 hist_ymax], 'Color', colors.mean, 'LineWidth', 2)
xlim([-100 100])
ylim([0 hist_ymax])
axis off
%%
% save c:\stetner\data\figures\xmodel\errortorpe.mat
