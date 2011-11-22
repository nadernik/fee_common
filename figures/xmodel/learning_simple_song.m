close all
clear all
xmodel_parameters_simplesong
xmodel_initialize
xmodel_run

for motif = 1:total_motifs
    bias(:, motif) = weights_on_ra_from_lman*weights_on_lman_from_dlm*weights_on_dlm_from_pallidus*pallidal_output(:,:,motif);
end


figure
plot(bias(:,end))
hold all
plot(template)

figure
% e = squeeze(ra_output(1,:,:)) - template' * ones(1,total_motifs);
e = bias - template' * ones(1,total_motifs);
mse = mean(e.^2);
plot(mse(baseline_motifs+1:end))

figure
imagesc(bias)

figure
subplot(2,1,1)
hold all
ymax = globalmax(msn_output(:,:,end));
plot((bias(:,end)), '--', 'Color', [0 0 .6], 'LineWidth', 4)
plot((template), 'Color', [.6 0 .6], 'LineWidth', 4)

subplot(2,1,2)
hold all
offset=1.5;
for h = 5:10:hvc_units
    p = msn_output(h,:,end) / ymax;
    n = -msn_output(h+hvc_units,:,end)/ymax;
    plot(p - offset, 'Color', [.6 .6 0], 'LineWidth', 3)
    %plot(n - offset, 'r')
    %plot(p+n - offset, 'k')
    offset = offset +1.5;
end
