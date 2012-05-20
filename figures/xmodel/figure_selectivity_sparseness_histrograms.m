bins = -6:0.5:0.5;

% Nothing
d0 = load('c:\stetner\data\figures\xmodel\no_competition_nor_inhibition.mat');

% with competition only
dc = load('c:\stetner\data\figures\xmodel\inhibition_no.mat');

% with inhibition only
di = load('c:\stetner\data\figures\xmodel\nocompetition.mat');



se0 = selectivity(d0.weights_on_msn_from_hvc');
sec = selectivity(dc.weights_on_msn_from_hvc');
sei = selectivity(di.weights_on_msn_from_hvc');

se0norm = hist(se0, bins) / d0.msn_units;
secnorm = hist(sec, bins) / dc.msn_units;
seinorm = hist(sei, bins) / di.msn_units;

sp0 = sparseness(d0.weights_on_msn_from_hvc');
spc = sparseness(dc.weights_on_msn_from_hvc');
spi = sparseness(di.weights_on_msn_from_hvc');

sp0norm = hist(sp0, bins) / d0.hvc_units;
spcnorm = hist(spc, bins) / dc.hvc_units;
spinorm = hist(spi, bins) / di.hvc_units;

figure
subplot(1,2,1)
stairs(bins, se0norm, ':k', 'LineWidth', 3)
hold on
stairs(bins, secnorm, '-k', 'LineWidth', 3)
title('Selectivity, nothing vs. competition only')
subplot(1,2,2)
stairs(bins, sp0norm, ':k', 'LineWidth', 3)
hold on
stairs(bins, spcnorm, '-k', 'LineWidth', 3)
title('Sparseness, nothing vs. competition only')

figure
subplot(1,2,1)
stairs(bins, se0norm, ':k', 'LineWidth', 3)
hold on
stairs(bins, seinorm, '-k', 'LineWidth', 3)
title('Selectivity, nothing vs. inhibition only')
subplot(1,2,2)
stairs(bins, sp0norm, ':k', 'LineWidth', 3)
hold on
stairs(bins, spinorm, '-k', 'LineWidth', 3)
title('Sparseness, nothing vs. inhibition only')