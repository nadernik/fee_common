function covert_learning_dlm_efference_copy(do_simulations)
%% Covert learning: Incomplete block
% Charlesworth et al. 2012 demonstrated that even though a bird's pitch
% does not change during CAF if he has AP-5 in RA, covert learning is
% revealed after the AP-5 is removed. One explanation for this result is
% that AP-5 causes an incomplete block of LMAN inputs to RA so that
% variability in RA activity in song is still correlated with LMAN
% activity. Then, the AFP can use the variability in LMAN to learn.
%
% Here we simulate learning in a
% network with reduced drive from LMAN to RA and show that this network is
% still able to learn 

%%
data_dir = 'c:\stetner\data\xmodel\covert';
files = dir(fullfile(data_dir, 'dlm_efference_copy_*'));
normal_file = 'caf_normal.mat';
strengths = linspace(0,1,10);

%%
if nargin > 0 && do_simulations == 1
    for ra_noise_amplitude = strengths
        xmodel_parameters_caf
        caf_pitch_threshold2 = 0; % MAKE SURE YOU DO THIS FOR THE NORMAL RUN TOO!!!!!!
        xmodel_initialize_ra_to_dlm
        xmodel_run_ra_to_dlm_slow

        file_name = sprintf('dlm_efference_copy_%03.f', ra_noise_amplitude*100);
        save(fullfile(data_dir, file_name))
        save temp data_dir ra_noise_amplitude strengths
        clear all
        load temp
    end
    
    % normal
    xmodel_parameters_caf
    caf_pitch_threshold2 = 0;
    xmodel_initialize
    xmodel_run
    xmodel_calculate_bias
    save(fullfile(data_dir, normal_file))
    
end

%% 
nvlman = zeros(length(files), 1); % noise variance intrinsic to lman (measured)
nvra   = zeros(length(files), 1); % noise variance intrinsic to ra (measured)
nara   = zeros(length(files), 1); % noise amplitude in ra (parameter)
%btt    = zeros(1, length(files)); % bias at target time (measured)

for ii = 1:length(files)
    d = load(fullfile(data_dir, files(ii).name));
    nvlman(ii) = var(d.lman_noise(:));
    nvra(ii)   = var(d.ra_noise(:));
    nara(ii)   = d.ra_noise_amplitude;
    if ~isfield(d, 'bias')
        for m = 1:d.total_motifs
            d.bias(:,:,m) = [1, -1] * d.weights_on_lman_from_dlm * d.weights_on_dlm_from_pallidus * d.pallidal_output(:,:,m);
        end
    end
    btt(:,ii) = squeeze(d.bias(1,d.caf_target_time2,:));
end
d = load(fullfile(data_dir, normal_file));
for m = 1:d.total_motifs
    d.bias(:,:,m) = d.weights_on_ra_from_lman * d.weights_on_lman_from_dlm * d.dlm_output(:,:,m);
end
btt_normal = squeeze(d.bias(1,d.caf_target_time2,:));
%% Sanity check: total variance of LMAN activity should be constant
figure(2937)
clf
% area(nara, [nvra, nvlman])
plot(nara, nvra)
hold all
plot(nara, nvra + nvlman)
hold off
legend({'RA-driven noise', 'Total noise'}, 'Location', 'SouthEast')
xlabel('RA-driven fraction of LMAN noise variance')
ylabel('Noise variance')
title('Total noise variance is the same under all conditions')

%%
figure(2938)
clf
axh = axes;
c = colormap('Autumn');
cc = interp1(linspace(1,length(files),length(c)), c, 1:length(files));
set(axh, 'ColorOrder', cc)
hold on
plot(axh, btt)
plot(btt_normal, 'k')
hold off
xlabel('Trials')
ylabel('Bias at target time')
for ii = 1:length(nara)
    legendstr{ii} = sprintf('%3.0f%% LMAN noise driven by RA', nara(ii)*100);
end
legend(legendstr, 'Location', 'NorthWest')


%% Plot bias restored depending on strength of RA-DLM connection
figure(2939)
clf
scatter(nara, btt(end,:))
hold on
plot(xlim, repmat(btt_normal(end),1,2),':k')
text(0.6, btt_normal(end), 'Learning with LMAN-RA intact', 'VerticalAlignment', 'top')
hold off
xlabel('RA-driven fraction of LMAN variance')
ylabel('Learned pitch change')
title('Learning from RA-driven noise')