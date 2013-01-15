%% Choose MSN and HVC synapse of interest
imsn = 42;
ihvc = 25;

%% MSN input relative to threshold on first iteration
bins = linspace(0,1.5,25);
hin = sn.wH(:,:,1) * sn.hvcout;
thresh = sn.tinhib2;

hist(hin(:), bins)
hold on
plot(ones(2,1)*sn.tinhib2, ylim, 'r')
xlim([bins(1), bins(end)])
xlabel('Input from HVC to MSN')
ylabel('Count')
xt = get(gca,'XTick');
xtL = get(gca, 'XTickLabel');
if size(xtL,2) < 6
    xtL(:,end+1:6) = ' ';
end
if any(xt == sn.tinhib2)
    xtL(xt == sn.tinhib2, :) = 'Thresh';
else
    xtL(end+1,:) = 'Thresh';
    xt(end+1) = sn.tinhib2;
    [xt, ndx] = sort(xt);
    xtL = xtL(ndx,:);
end
set(gca, 'XTick', xt, 'XTickLabel', xtL)
title('MSN input on first iteration (all neurons and times)')
hold off

%% LTP in a single MSN over all synapses and motifs
ltp = zeros(sn.nhvc, sn.niter);
for iter = 1:sn.niter
    ltp(:,iter) = sn.LTP(imsn, iter);
end
imagesc(ltp')
xlabel('HVC')
ylabel('Trial')
title(sprintf('LTP for MSN %g', imsn))

%% LTP and LTD for a single HVC-X synapse
clf
axh(1) = subplot(4,1,1);
ltp = zeros(1, sn.niter);
ltd = zeros(1, sn.niter);
for iter = 1:sn.niter
    temp = sn.LTP(imsn, iter);
    ltp(iter) = temp(ihvc);
    temp = sn.LTD(imsn, iter);
    ltd(iter) = temp(ihvc);
end
plot(ltp)
hold all
plot(ltd)
hold off
xlabel('Trial')
ylabel('LTP or LTD')
% legend({'LTP', 'LTD'})
title(sprintf('LTP and LTD for weight onto MSN %g from HVC neuron %g', imsn, ihvc))

axh(2) = subplot(4,1,2);
plot(squeeze(sn.wH(imsn,ihvc,:)))
xlabel('Trial')
ylabel('Weight')

axh(3) = subplot(4,1,3);
plot(squeeze(sn.msnout(imsn, ihvc, :)))
hold all
plot(squeeze(sum(sn.msnout(:,ihvc,:), 1)))
ylabel('MSN output')

axh(4) = subplot(4,1,4);
plot(sn.lmanout(ihvc,:))
hold all
plot([1, sn.niter], ones(1,2) * sn.template(ihvc))
hold off
ylabel('LMAN output')

linkaxes(axh, 'x')

%% Number of MSNs on at a particular time
plot(squeeze(sum(sn.msnout(:,ihvc,:) > 0, 1)))

%% Number of MSNs on at each time on the last trial
iter = sn.niter;
plot(squeeze(sum(sn.msnout(:,:,iter) > 0, 1)))

%% LTP for all synapses from a single HVC neuron
iters = 1:sn.niter;
p = zeros(sn.nmsn, length(iters));
for ii = 1:length(iters)
    iter = iters(ii);
    for imsn = 1:sn.nmsn
        temp = sn.LTP(imsn, iter);
        p(imsn,ii) = temp(ihvc);
    end
end
imagesc(p')
xlabel('MSN')
ylabel('Trial')

%% Vpost for a single MSN
vpost = zeros(sn.nhvc, sn.niter);
for iter = 1:sn.niter
    vpost(:,iter) = sn.vpost(imsn,iter);
end
imagesc(vpost')
ylabel('Trial')
xlabel('time')
title(sprintf('V_p_o_s_t for MSN %g', imsn))

%% Vpost for a single MSN on the first iteration
clf
plot(sn.vpost(imsn, 1))
xlabel('Time')
ylabel('V_p_o_s_t')
title(sprintf('MSN %g on first iteration', imsn))

%% Histogram of Vpost for all MSNs on the first iteration

vmax =  1;
vmin = -1;
nbins = 25;

clf
bins = linspace(vmin,vmax,nbins);
v = zeros(sn.nmsn, sn.nhvc);
for i = 1:sn.nmsn
    v(i,:) = sn.vpost(i,1);
end
hist(v(:), bins)
xlim([vmin, vmax])
xlabel('V_p_o_s_t')
ylabel('Count')
title(sprintf('V_p_o_s_t on first iteration\nMean = %g SD = %g', mean(v(:)), std(v(:))))

%% Histogram of MSN output for all MSNs on the first iteration

ymax = 0.5;
ymin = 0;
nbins = 25;

clf
bins = linspace(ymin, ymax, nbins);
y = sn.msnout(:,:,1);
hist(y(:), bins)
xlim([ymin, ymax])
xlabel('MSN output')
ylabel('Count')
title(sprintf('MSN output on first iteration\nMean = %g SD = %g', mean(y(:)), std(y(:))))

%% HVC-X weights for a single MSN for all synapses over time
iters = 1:100;
imagesc(squeeze(sn.wH(imsn,:,iters))')

%% Maximum MSN weight from each HVC neuron on each trial
imagesc(squeeze(max(sn.wH, [], 1))')
xlabel('HVC')
ylabel('Trial')

%% Histogram of LTP values
bins = linspace(-0.05, 0.05, 20);
for iter = 1:sn.niter
    p = zeros(sn.nmsn, sn.nhvc);
    for imsn = 1:sn.nmsn
        p(imsn,:) = sn.LTP(imsn, iter);
    end
    hist(p(:), bins)
    title(sprintf('LTP for all HVC-X neurons on trial %g\nSD = %g\n[Enter] to continue...', iter, std(p(:))))
    xlim([-.06, .06])
    pause
end

%% Standard deviation of LTP values
iters = 1:30;
p = zeros(sn.nhvc*sn.nmsn*length(iters), 1);
nw = sn.nhvc * sn.nmsn;
n = @(imsn, iter) (1:sn.nhvc) + (iter-1)*nw + (imsn-1)*sn.nhvc;
for ii = 1:length(iters)
    iter = iters(ii);
    for imsn = 1:sn.nmsn
        p(n(imsn, ii)) = sn.LTP(imsn, iter);
    end
end
fprintf('Standard deviation is %g.\n', std(p))

%% LMAN output at a particular time, over motifs
iters = 1:sn.niter;
plot(iters, sn.lmanout(ihvc,iters))
hold all
plot([iters(1), iters(end)], sn.template(ihvc)*ones(1,2))
hold off
xlabel('Trials')
ylabel('Output')
legend({'LMAN output', 'Template'})

%% sparsenet_test.m plots for each motif
for iter = 1:sn.niter
    subplot(1,3,1)
    sn.wimage(iter)
    subplot(1,3,2)
    sn.outvstemplate(iter)
    hold on
    plot(sn.template)
    hold off
    ylim([0, 5])
    xlabel('Time (ms)')
    ylabel('Pitch')
    legend('Learned Song', 'Template')
    title(sprintf('Motif %g', iter))
    subplot(1,3,3)
    plot(-sum(sn.rexp, 1))
    xlabel('Trial')
    ylabel('Mean squared error')
    pause
end
