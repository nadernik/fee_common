%% Reward Prediction Error
close all
N = 10; % number of trials
T = 50; % number of time points in each trial
nred = 3; % red example trial number
ngreen = 4; % green example trial number
taulman = 8; % width of lman fluctuations (in time points)
taurpe = .1; % time constant of exponentially weighted average in rpe
t = 40; % target time for examples
template = sin(linspace(0, 4*pi, T)) + 4;
meansong = cos(linspace(0, 4*pi, T)) + 2;

songs      = zeros(length(template), N);
prediction = zeros(size(songs));
rpe        = zeros(size(songs));
errors     = zeros(size(songs));
rewards    = zeros(size(songs));

for n = 1:N
    % song is average underlying song (motor pathway or bias) plus random
    % noise
    songs(:, n) = meansong' + smoothnoise(length(template), taulman);
    % Error is the squared difference between song and template.
    errors(:, n) = (songs(:, n) - template').^2;
    % Reward is just negative error.
    rewards(:, n) = -errors(:, n);
    
    % Initial prediction is initial reward.
    if n == 1
        prediction(:, 1) = rewards(:, 1);
    end
    
    % Reward prediction error is the difference between actual and expected
    % rewards.
    rpe(:, n) = rewards(:, n) - prediction(:, n);
    % Update predicted rewards using reward prediction error. This makes
    % something like an exponentially weighted mean of rewards.
    prediction(:, n + 1) = prediction(:, n) + taurpe * rpe(:, n);    
end

%% (a) Template and actual song

figure
hold on
plot(template)
plot(songs, 'Color', [.8 .8 .8])
plot(mean(songs, 2), 'k')
x = t + [-0.5, 0.5];
y = interp1(1:T, songs(:, nred), x);
plot(x, y, 'r', 'LineWidth', 2)
y = interp1(1:T, songs(:, ngreen), x);
plot(x, y, 'g', 'LineWidth', 2)
ylo = min(min(min(songs)), min(template));
yhi = max(max(max(songs)), max(template));
yrange = yhi - ylo;
ylo = ylo - 0.15 * yrange;
yhi = yhi + 0.15 * yrange;
fill([-.5, .5, .5, -.5] + t, [ylo ylo yhi yhi], [1 1 .7], 'FaceAlpha', 0.5)
xlim([1 T])
ylim([ylo yhi])
xlabel('Time (ms)')
ylabel('Pitch')

%% (b) Error is squared difference between template and actual song

figure
hold on
yhi = max(max(errors));
ylo = min(min(errors));
yrange = yhi - ylo;
ylo = ylo - 0.15 * yrange;
yhi = yhi + 0.15 * yrange;
plot(errors, 'Color', [.8 .8 .8])
x = t + [-0.5, 0.5];
y = interp1(1:T, errors(:, nred), x);
plot(x, y, 'r', 'LineWidth', 2)
y = interp1(1:T, errors(:, ngreen), x);
plot(x, y, 'g', 'LineWidth', 2)
fill([-.5, .5, .5, -.5] + t, [ylo ylo yhi yhi], [1 1 .7], 'FaceAlpha', 0.5)
xlim([0 T])
ylim([ylo yhi])
xlabel('Time (ms)')
ylabel('Error')

figure
scatter(1:N, errors(t, :),'.k')
hold on
scatter(nred, errors(t, nred), 300, '.r')
scatter(ngreen, errors(t, ngreen), 300, '.g')
xlim([0 N+1])
ylim([ylo yhi])
xlabel('Trial')
ylabel('Error')

%% (c) Reward is negative error
% Because VTA seems to signal rewarding things, not punishments

pred = mean(rewards, 2);

figure
hold on
plot(rewards, 'Color', [.8 .8 .8])
plot(pred, 'k')
yhi = max(max(rewards));
ylo = min(min(rewards));
yrange = yhi - ylo;
ylo = ylo - 0.15 * yrange;
yhi = yhi + 0.15 * yrange;
x = t + [-0.5, 0.5];
y = interp1(1:T, rewards(:, nred), x);
plot(x, y, 'r', 'LineWidth', 2)
y = interp1(1:T, rewards(:, ngreen), x);
plot(x, y, 'g', 'LineWidth', 2)
fill([-.5, .5, .5, -.5] + t, [ylo ylo yhi yhi], [1 1 .7], 'FaceAlpha', 0.5)
xlim([1 T])
ylim([ylo yhi])
xlabel('Time (ms)')
ylabel('Reward')

figure
hold on
plot(1:N, pred(t)*ones(N,1), 'k')
scatter(1:N, rewards(t, :),'.k')
scatter(nred, rewards(t, nred), 300, '.r')
scatter(ngreen, rewards(t, ngreen), 300, '.g')
xlim([0 N+1])
ylim([ylo yhi])
xlabel('Trial')
ylabel('Reward')


%% (d) Reward prediction error is difference between reward and predicted reward

rpe2 = rewards - pred * ones(1, N);

figure
hold on
plot(rpe2, 'Color', [.8 .8 .8])
yhi = max(max(rpe2));
ylo = min(min(rpe2));
yrange = yhi - ylo;
ylo = ylo - 0.15 * yrange;
yhi = yhi + 0.15 * yrange;
x = t + [-0.5, 0.5];
y = interp1(1:T, rpe2(:, nred), x);
plot(x, y, 'r', 'LineWidth', 2)
y = interp1(1:T, rpe2(:, ngreen), x);
plot(x, y, 'g', 'LineWidth', 2)
fill([-.5, .5, .5, -.5] + t, [ylo ylo yhi yhi], [1 1 .7], 'FaceAlpha', 0.5)
xlim([1 T])
ylim([ylo yhi])
xlabel('Time (ms)')
ylabel('Reward prediction error')

figure
hold on
scatter(1:N, rpe2(t, :), '.k')
scatter(nred, rpe2(t, nred), 300, '.r')
scatter(ngreen, rpe2(t, ngreen), 300, '.g')
xlim([0 N+1])
ylim([ylo yhi])
xlabel('Trial')
ylabel('Reward prediction error')
%%
save c:\stetner\data\figures\xmodel\errortorpe.mat
