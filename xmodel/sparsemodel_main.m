% sparsemodel_main

close all
clear all
DEBUG_FLAG = 0;
sparsemodel_parameters
sparsemodel_initialize
sparsemodel_run

figure
imagesc(squeeze(ra_output)')
figure
imagesc(weights_on_msn_from_hvc)

figure
for m = 1:msn_units/2
    imagesc(squeeze(msn_output(m,:,:))')
    pause
end