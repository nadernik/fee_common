%% Learning from successes
% Charlesworth et al. 2011 showed that CAF induces learning that looks more
% like successful trials than the opposite of unsuccessful trials. Here we
% replicate that finding.

%%
close all
clear all
xmodel_parameters_learning_from_successes;
xmodel_initialize;

%%
clear lman_noise
unbiased_lman_noise = zeros(lman_units, motif_steps, total_motifs*2);
for u = 1:lman_units
    unbiased_lman_noise(u,:,:) = generate_lman_noise(motif_steps, total_motifs*2);
end
song = zeros(motif_steps, total_motifs*2);
for m = 1:total_motifs*2
    song(:,m) = weights_on_ra_from_lman * unbiased_lman_noise(:,:,m);
end

% Normally, CAF makes 
over1  = song(caf_target_time1, :) >= caf_pitch_threshold1;
under1 = song(caf_target_time1, :) <  caf_pitch_threshold1;
over2  = song(caf_target_time2, :) >= caf_pitch_threshold2;
under2 = song(caf_target_time2, :) <  caf_pitch_threshold2;

is_escape    =          over2;
is_hit       = over1  & under2;
is_discarded = under1 & under2;

selected_songs = [song(:, is_escape), song(:,is_hit), song(:,is_hit)];
selected_noise = [unbiased_lman_noise(:,:,is_escape), unbiased_lman_noise(:,:,is_hit),unbiased_lman_noise(:,:,is_hit)];
% randomize motif order so all escapes don't happen at the beginning
rndx = randperm(size(selected_songs,2));
selected_motifs = rndx(1:total_motifs);
selected_songs = selected_songs(:, selected_motifs);
lman_noise = unbiased_lman_noise(:,:,selected_motifs);



clear is_escape is_hit is_discarded unbiased_lman_noise
is_escape = ones(1,total_motifs);
keyboard
%%
xmodel_run;
save c:\stetner\data\figures\xmodel\learning_from_successes.mat

%%
clear all
load c:\stetner\data\figures\xmodel\learning_from_successes.mat

% Vocal output (pitch) before learning. Successful trials in red.
figure(4011)
clf
is_baseline = 1:total_motifs <= baseline_motifs;
baseline_escapes = squeeze(ra_output(1,:, is_escape & is_baseline));
baseline_hits  = squeeze(ra_output(1,:,~is_escape & is_baseline));
plot(baseline_hits, 'b')
hold on
plot(baseline_escapes, 'r')
xlabel('Time (ms)')
ylabel('"Pitch"')

% Vocal output after learning
figure(4012)
clf
is_after_learning = 1:total_motifs >= total_motifs - baseline_motifs;
after_learning = squeeze(ra_output(1, :, is_after_learning));
plot(after_learning,'k')
xlabel('Time (ms)')
ylabel('"Pitch"')

% histogram before
bins = -10:2:25;
figure(4013)
clf
y_escape = histc(baseline_escapes(caf_target_time2,:), bins);
y_hit = histc(baseline_hits(caf_target_time2,:), bins);
stairs(bins, y_escape+y_hit, 'k')

% histogram after
hold on
y_after = histc(after_learning(caf_target_time2, :),bins);
stairs(bins, y_after, 'g')

h = line(caf_pitch_threshold2*ones(2,1), ylim);
set(h, 'LineWidth', 3)
set(h, 'Color', [0 0 1])
%% (c) Random CAF
clear all
load c:\stetner\data\figures\xmodel\random_caf25.mat
N = 50; % number of trials to average at the end of learning

% escapes
figure(4031)
clf
escapes = squeeze(ra_output(1, :, is_escape));
plot(escapes, 'Color', [1 .8 .8])
hold on
plot(mean(escapes, 2), 'LineWidth', 3, 'Color', [1 0 0])

% random hits
figure(4032)
clf
random_hits = squeeze(ra_output(1, :, is_random_hit));
plot(random_hits, 'Color', [.8 .8 1])
hold on
plot(mean(random_hits, 2), 'LineWidth', 3, 'Color', [0 0 1])

% show average of escapes, random hits, and actual learning
figure(4033)
clf
after_learning = squeeze(ra_output(1, :, end-N:end));
before_learning = squeeze(ra_output(1, :, 1:N));
learning = mean(after_learning, 2) - mean(before_learning, 2);
plot(learning, 'LineWidth', 3, 'Color', [0 0 0])
hold on
plot(mean(escapes, 2), 'LineWidth', 3, 'Color', [1 0 0])
plot(mean(random_hits, 2), 'LineWidth', 3, 'Color', [0 0 1])
plot(squeeze(mean(ra_output, 3)))


%% (d) Comparison of successes vs. failures
figure(404)
hold all
all_b = zeros(50, 3);
all_bint = zeros(50, 3, 2);
for n = 1:50
    load(['c:\stetner\data\figures\xmodel\random_caf' int2str(n)]);
    random_hits = mean(squeeze(ra_output(1, :, is_random_hit)), 2);
    escapes = mean(squeeze(ra_output(1, :, is_escape)), 2);
    after_learning = squeeze(ra_output(1, :, end-N:end));
    before_learning = squeeze(ra_output(1, :, 1:N));
    learning = mean(after_learning, 2) - mean(before_learning, 2);
    X = [escapes, random_hits, escapes.*random_hits];
    [b, bint] = regress(learning, X);
    all_b(n,:) = b;
    all_bint(n,:,:) = bint;
    errorbar(1:3, b, bint(:, 1), bint(:, 2))
end

ylabel('coef from linear regression')
set(gca, 'XTick', 1:3, 'XTickLabels', 'escapes|hits|interaction')