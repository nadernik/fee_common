%% Learning from successes
% Charlesworth et al. 2011 showed that CAF induces learning that looks more
% like successful trials than the opposite of unsuccessful trials. Here we
% replicate that finding.

%%
close all
clear all

xmodel_parameters_learning_from_successes;
xmodel_initialize;

is_escape = rand(1,total_motifs) < 0.5;
t1 = 80;
t2 = 100;
t = 0:20;
p = sin(2*pi/40*t);
esc = zeros(lman_units, motif_steps);
hit = zeros(lman_units, motif_steps);
esc(1,t2+t) = p; % on escape, pitch up LMAN neuron is active at t2
hit(2,t1+t) = p; % on hit and pitch down neuron is active at t1
for m = 1:total_motifs
    if is_escape(m)
        lman_noise(:,:,m) = esc;
    else
        lman_noise(:,:,m) = hit;
    end
end
weights_on_lman_from_dlm = zeros(size(weights_on_lman_from_dlm));

xmodel_run_learning_from_sucesses;
save c:\stetner\data\figures\xmodel\learning_from_successes_1.mat

%%
clear all
xmodel_parameters_learning_from_successes;
xmodel_initialize;
clear lman_noise is_escape
load c:\stetner\data\figures\xmodel\learning_from_successes_1.mat lman_noise is_escape;
is_escape = ~is_escape; % reverse which variants are successful
weights_on_lman_from_dlm = zeros(size(weights_on_lman_from_dlm)); % turn off dlm to lman to prevent bias from showing
xmodel_run_learning_from_sucesses;
save c:\stetner\data\figures\xmodel\learning_from_successes_2.mat

%%
clear all
load c:\stetner\data\figures\xmodel\learning_from_successes_2.mat

%% Plots of escapes and hits
% Overlay of all hits and escapes, with LMAN activity
figure

% Activity in the first LMAN neuron (the "pitch up" channel) on all escapes
subplot(3,2,1)
plot(squeeze(lman_output(1,:,is_escape)))
title('Escapes, pitch up channel')

% Activity in the first LMAN neuron (the "pitch up" channel) on all hits
subplot(3,2,2)
plot(squeeze(lman_output(1,:,~is_escape)))
title('Hits, pitch up channel')

% Activity in the second LMAN neuron (the "pitch down" channel) on all escapes
subplot(3,2,3)
plot(squeeze(lman_output(2,:,is_escape)))
title('Escapes, pitch down channel')

% Activity in the second LMAN neuron (the "pitch down" channel) on all hits
subplot(3,2,4)
plot(squeeze(lman_output(2,:,~is_escape)))
title('Hits, pitch down channel')

% RA output on all escapes
subplot(3,2,5)
plot(squeeze(ra_output(1,:,is_escape)))
title('Escapes, actual song')

% RA output on all hits
subplot(3,2,6)
plot(squeeze(ra_output(1,:,~is_escape)))
title('Hits, actual song')

%% Bias

% DLM was disconnected from LMAN during learning so that learned bias would
% not disrupt our prearranged escapes and hits. Now we reconnect DLM to
% LMAN to calculate bias.
weights_on_lman_from_dlm = eye(lman_units);
xmodel_calculate_bias


figure
imagesc(bias')
title('Bias')
xlabel('Time in motif')
ylabel('Motif number')

figure
plot(bias(:,end))
xlabel('Time in motif')
ylabel('Bias')
title('Bias on the last motif')