%learning_rule_indirect
% like learning_rule_from_model.m but for the indirect pathway!

%%
clear all
tf = 9:17;
big_fluctuation = normpdf(tf, mean(tf), length(tf)/6);
big_fluctuation = big_fluctuation/max(big_fluctuation) * 10;

xmodel_parameters_learning_rule_figure

template = -template;

xmodel_initialize

% make very large lman fluctuations 
mo = 30;
for motif = mo:mo:total_motifs
    lman_noise(1,tf,motif) = lman_noise(1,tf,motif) + big_fluctuation;
end
lman_noise(2,:,:) = 0;

xmodel_run

save c:\stetner\data\figures\xmodel\learning_rule_indirect.mat

%%
close all
clear all
load c:\stetner\data\figures\xmodel\learning_rule_indirect.mat

figure
dy = 2;
rpe = reward - expected_reward(:,1:total_motifs);
rpe(:,1:99) = 0;
for motif = 690 %mo:mo:total_motifs %240, 300, 390, 480, 570, 690, 720, 810, 840,   
    clf
    hold on
    y0 = 0;
    
    L = lman_output(1,:,motif) ./ globalmax(lman_output(1,:,:));
    
    % plot lman
    plot(L/max(L)-y0)
    y0=y0+dy;
    
    % plot reward
    z = zscore(rpe(:));
    zrpe = reshape(z, size(rpe));
    R = zrpe(:,motif) ./ 3;
    plot(R-y0)
    y0=y0+dy;

    % plot hvc overlayed with eligibility trace
    for h = 1:2:hvc_units
        H = hvc_output(h, :);
        plot(H - y0)
        e = conv(H .* L, ekernel);
        if h == 3
            W = -cumsum(e.*R(1:end-1)');
        end
        plot(e/1.5 - y0,'r--')
        y0 = y0 + dy;
    end
    
    % change in weight of selected HVC synapse
    y0 = y0+dy;
    plot(W/30 - y0)
    
    title(['motif ' int2str(motif)])
    pause
end