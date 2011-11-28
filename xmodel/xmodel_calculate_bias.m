bias = zeros(motif_steps, total_motifs);
for m = 1:total_motifs
    bias(:,m) = weights_on_ra_from_lman * weights_on_lman_from_dlm * dlm_output(:,:,m);
end