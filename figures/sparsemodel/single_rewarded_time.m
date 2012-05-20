% Medium Spiny neurons fire at most rewarded times

clc
close all
clear all

DEBUG_FLAG = 0;
sparsemodel_parameters
sparsemodel_initialize
sparsemodel_run


for motif = 1:total_motifs
    bias(:, motif) = weights_on_ra_from_lman*weights_on_lman_from_dlm*weights_on_dlm_from_pallidus*pallidal_output(:,:,motif);
end

figure
imagesc(bias)
title('bias')

% find time when 

if (DEBUG_FLAG)
    for m = 1:msn_units/2
        figure
        y = squeeze(wtemp(m,:,end,:));
        imagesc(y)
        title(['msn ' int2str(m)])
    end
end