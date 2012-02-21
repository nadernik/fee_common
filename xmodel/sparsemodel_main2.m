close all
clear all
sparsemodel_parameters
sparsemodel_initialize
sparsemodel_run
xmodel_calculate_bias
%%
figure
imagesc(bias')

figure
plot(bias(:,end))
hold on
plot(template)

figure
imagesc(msn_output(:,:,end))