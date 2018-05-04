m = 100
h = 13

%%
figure
subplot(1,2,1)
hold on
plot(squeeze(ltp_all(m,h,:)), 'Color', [0 0.6 0], 'LineWidth', 2)
plot(squeeze(ltd_all(m,h,:)), 'Color', [0.6 0 0], 'LineWidth', 2)
plot(squeeze(comp_all(m,h,:)), 'Color', [0.6 0.6 0], 'LineWidth', 2)
legend({'Learning', 'Inhibition', 'Competition'})

subplot(1,2,2)
plot(squeeze(w_all(m,h,:)))
titlestr = sprintf('Synapse onto MSN %g from HVC unit %g', m, h);
title(titlestr)