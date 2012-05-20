% sparsemodel_main

close all
clear all
DEBUG_FLAG = 0;
sparsemodel_parameters
sparsemodel_initialize

% set first template and run
template = zeros(1, motif_steps);
template(35:40) = 5;
sparsemodel_run

% store results from first run
old_msn_output = msn_output;
old_ra_output = ra_output;

% set new template and run (do NOT initialize again!)
template = zeros(1, motif_steps);
template(160:165) = 5;
sparsemodel_run

% combine results
msn_output = cat(3, old_msn_output, msn_output);
ra_output = cat(3, old_ra_output, ra_output);


figure
imagesc(squeeze(ra_output)')
figure
imagesc(weights_on_msn_from_hvc)
figure
for m = 1:msn_units/2
    imagesc(squeeze(msn_output(m,:,:))')
    pause(0.25)
end