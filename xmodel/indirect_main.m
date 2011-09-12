clc
close all
clear all
xmodel_parameters_indirect
xmodel_initialize_indirect
xmodel_run_indirect
imagesc(squeeze(ra_output)')
disp('done')

figure
plot(squeeze(ra_output(1,100,:)))

% figure
% subplot(2,1,1)
% plot(squeeze(ra_output(1, :, 1:20)))
% subplot(2,1,2)
% plot(squeeze(ra_output(1, :, end-20:end)))

% plot(template, 'k', 'LineWidth', 3)