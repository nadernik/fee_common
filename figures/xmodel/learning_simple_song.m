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
hold all
ymax = globalmax(msn_output(:,:,end));
plot(4*(bias(:,end)-10)/ymax, 'k')
plot(4*(template-10)/ymax, 'r:')
offset=1.5;
for h = 5:10:hvc_units
    p = msn_output(h,:,end) / ymax;
    n = -msn_output(h+hvc_units,:,end)/ymax;
    plot(p - offset, 'k')
    %plot(n - offset, 'r')
    %plot(p+n - offset, 'k')
    offset = offset +1.5;
end
