function learning_sparseness

averaged_trials = 1;
first_motif_with_new_template = 550;
offset_from_end = 9;
total_examples = 15;
% file1 = 'c:\stetner\data\figures\xmodel\sparseness20111108175646.mat';
file1 = 'c:\stetner\data\figures\xmodel\sparseness20111108174922.mat';
% file1 = 'c:\stetner\data\figures\xmodel\sparseness20111109130456.mat';
rand('twister',54666)

d = load(file1);

% average activity of medium spiny neurons across motifs
motifs_to_average = 1:averaged_trials;
average_msn_activity_at_start = mean(d.X1(:,:,motifs_to_average), 3);
average_msn_activity_at_start = average_msn_activity_at_start ./ (globalmax(average_msn_activity_at_start) + eps) + eps;

motifs_to_average = (-averaged_trials:-1) + first_motif_with_new_template;
average_msn_activity_before_switch = mean(d.X1(:,:,motifs_to_average), 3);
average_msn_activity_before_switch = average_msn_activity_before_switch ./ globalmax(average_msn_activity_before_switch) + eps;
% normalize to 1

motifs_to_average = (-averaged_trials:-1) + 1 + d.P.motifs-offset_from_end;
average_msn_activity_at_end = mean(d.X1(:,:,motifs_to_average), 3);
average_msn_activity_at_end = average_msn_activity_at_end ./ globalmax(average_msn_activity_at_end) + eps;

%% stats on neurons
plothelper(average_msn_activity_at_start, zeros(size(d.P.template)))
plothelper(average_msn_activity_before_switch, d.P.template_old)
plothelper(average_msn_activity_at_end, d.P.template)
% plothelper(average_msn_activity_at_start)
%% entropy of each neurons burst pattern
edges = 0:.5:6;
entropy_start = entrpy(average_msn_activity_at_start');
entropy_before = entrpy(average_msn_activity_before_switch');
entropy_after = entrpy(average_msn_activity_at_end');
figure
subplot(3,1,1)
hist(entropy_start, edges)
subplot(3,1,2)
hist(entropy_before, edges)
subplot(3,1,3)
hist(entropy_after, edges)

%% weights
figure
sf = .017*.065/5;
subplot(1,3,1)
image(d.initial_weights(d.W_X1L(:,1)==1,:)/sf)
subplot(1,3,2)
image(d.weights_at_switch(d.W_X1L(:,1)==1,:)/sf)
subplot(1,3,3)
image(d.W_X1H(d.W_X1L(:,1)==1,:)/sf)

%%
function y = entrpy(x)
    x = x ./ (ones(size(x,1),1)*sum(x));
    y = -sum(x .* log(x));
end
%%
function plothelper(x, tpt)
figure
% random examples
subplot(total_examples+3,1,1:total_examples)
hold all
random_order = randperm(d.P.xunits);
offset = 0;
for n = 1:total_examples
    neuron = random_order(n);
    plot(x(neuron,:)+ offset, 'Color', [.6, .6, 0], 'LineWidth', 2)
    offset = offset +1.5;
end

% plot template
plot(tpt/(max(tpt)+eps)*3+offset, 'Color', [0 0 0], 'LineWidth', 4)

% distribution of neurons
subplot(total_examples+3,1,total_examples+(1:3))
y = mean(x, 1); % average across neurons
plot(y)
end
end