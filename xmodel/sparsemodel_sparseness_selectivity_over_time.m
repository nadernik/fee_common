sp = zeros(hvc_units, total_motifs);
se = zeros(msn_units, total_motifs);
for mo = 1:total_motifs
    sp(:,mo) = sparseness(w_all(:,:,mo)');
    se(:,mo) = selectivity(w_all(:,:,mo)');
end

figure
imagesc(sp')
title('MSN Population Sparseness')
xlabel('HVC time slice')
ylabel('Motif')

figure
imagesc(se')
title('Selectivity')
xlabel('MSN unit')
ylabel('Motif')