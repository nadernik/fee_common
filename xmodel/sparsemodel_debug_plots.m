%% LMAN output and RPE at a single time across trials
iters = 1:530;
lman = sn.lmanout(ihvc,iters);
w = squeeze(sn.wH(imsn, ihvc, iters));
rpe = zeros(1,length(iters));
vpost = zeros(1,length(iters));
ltp = zeros(1,length(iters));
ltd = zeros(1,length(iters));
for ii = 1:length(iters)
    temp = sn.rpe(iters(ii));
    rpe(ii) = temp(ihvc);
    temp = sn.vpost(imsn, iters(ii));
    vpost(ii) = temp(ihvc);
    temp = sn.LTP(imsn, iters(ii));
    ltp(ii) = temp(ihvc);
    temp = sn.LTD(imsn, iters(ii));
    ltd(ii) = temp(ihvc);
end
plot(iters, vpost, 'LineWidth', 3, 'Color', 'b')
hold all
plot(iters, rpe, 'LineWidth', 3, 'Color', 'r')
plot(iters, lman, 'LineWidth', 3, 'Color', 'k')
plot(iters, w, 'LineWidth', 3, 'Color', [0.5, 0.5, 0])

hold off
legend({'Vpost', 'RPE', 'LMAN', 'Weight'})
line(xlim, ones(2,1)*sn.template(ihvc), 'Color', 'k')
xlabel('Trial')

%% LTP in a single MSN over all synapses and motifs
plot_every = false;
ltp = zeros(sn.nhvc, sn.niter);
for iter = 1:sn.niter
    ltp(:,iter) = sn.LTD(imsn, iter);
    if plot_every
        plot(ltp(:,iter))
        title(sprintf('LTP for MSN %g on trial %g', imsn, iter))
        ylim([-.1, .1])
        pause
    end
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
% hold all
% plot(ltd)
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

%% LTP for all synapses from a single HVC neuron
iters = 1:sn.niter;
ihvc1 = 20;
ihvc2 = 21;
p1 = zeros(sn.nmsn, length(iters));
p2 = zeros(sn.nmsn, length(iters));
for ii = 1:length(iters)
    iter = iters(ii)
    for imsn = 1:sn.nmsn
        temp = sn.LTP(imsn, iter);
        p1(imsn,ii) = temp(ihvc1);
        p2(imsn,ii) = temp(ihvc2);
    end
end
subplot(1,2,1)
imagesc(p1')
xlabel('MSN')
ylabel('Trial')
title(sprintf('LTP for synapses from HVC unit %g', ihvc1))

subplot(1,2,2)
imagesc(p2')
xlabel('MSN')
ylabel('Trial')
title(sprintf('LTP for synapses from HVC unit %g', ihvc2))

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

%% MSN output at a single time
ihvc = [28, 29];
clf
co = get(gca, 'ColorOrder');
h = zeros(1,length(ihvc));
for ii = 1:length(ihvc)
    temp = plot(squeeze(sn.msnout(:,ihvc(ii),:))', 'Color', co(ii,:));
    h(ii) = temp(1);
    hold on
end
legend(h, arrayfun(@int2str, ihvc, 'UniformOutput', 0))

%% MSN output for a single MSN
cm = colormap(jet);
cm(1,:) = 0;
for imsn = 1:sn.nmsn
    imagesc(squeeze(sn.msnout(imsn,:,:))')
    xlabel('Time')
    ylabel('Trial')
    title(sprintf('Output for MSN %g', imsn))
    colormap(cm)
    pause
end

%% MSN output on a single motif
dosort = true;
iter = sn.niter;
assert(isscalar(iter))
if dosort
    tmax = nan(sn.nmsn, 1);
    for i = 1:sn.nmsn
        [~, tmax(i)] = max(sn.wH(i,:, iter));
    end
    [~, ord] = sort(tmax);
    w = sn.wH(ord,:,iter);
else
    w = sn.wH(:,:,iter);
end
imagesc(w)
cm = colormap('jet');
cm(1,:) = 0;
colormap(cm);
xlabel('Time')
ylabel('MSN')
title(sprintf('MSN output on motif %g', iter))
%% MSNs active at a particular time (list)
iter = sn.niter;
imsn = find(sn.msnout(:,ihvc,iter) > 0);
fprintf('MSNs active on time step %g on trial %g: ', ihvc, iter)
disp(imsn')

%% Number of MSNs active
nactivemsn = squeeze(sum(sn.msnout > 0, 1));
iter = sn.niter;

subplot(1,3,1)
plot(nactivemsn(ihvc,:)')
xlabel('Trial')
ylabel('Active MSNs')
title(['Number of active MSNs at time ', int2str(ihvc)])
if length(ihvc) > 1
    legend(arrayfun(@int2str, ihvc, 'UniformOutput', 0))
end

subplot(1,3,2)
plot(nactivemsn(:,iter))
xlabel('Time')
ylabel('Active MSNs')
title(sprintf('Number of active MSNs on trial %g', iter))

subplot(1,3,3)
hist(nactivemsn(:,iter), 0:max(nactivemsn(:,iter)))
xlabel('Number of active MSNs')
ylabel('Number of time steps')
axis tight

% Check for multiple MSNs turning on simultaneously
dn = diff(nactivemsn, 1, 2);

%% Number of MSNs active vs. error
iter = sn.niter;
nactivemsn = sum(sn.msnout(:,:,iter) > 0, 1);
err = sn.bias(iter) - sn.template;
scatter(nactivemsn, err)
xlabel('Number of active MSNs')
ylabel('Difference between bias and template')
title(sprintf('Trial %g', iter))

%% Timescales of the simulation
clf
% HVC burst
y = sn.hvcout(10,:);
[ymax,t0] = max(y);
t = (1:length(y)) - t0;
plot(t, y/ymax, 'LineWidth', 3)
hold all
% Reward kernel
y = sn.kernel;
[ymax,t0] = max(y);
t = (1:length(y)) - t0;
plot(t, y/ymax, 'LineWidth', 3)
% LMAN autocorrelation
maxlag = 50;
acorr = zeros(maxlag*2+1, sn.niter);
for iter = 1:sn.niter
    [c, lags] = xcorr(sn.noise(:, iter), maxlag, 'unbiased');
    acorr(:, iter) = c / max(c);
end
t = -maxlag:maxlag;
plot(t,mean(acorr,2), 'LineWidth', 3)
legend('HVC', 'Reward', 'LMAN')
xlim([-20, 20])
ylim([0, 1])

%% Vpost for a single MSN at all times and trials
vpost = zeros(sn.nhvc, sn.niter);
for iter = 1:sn.niter
    vpost(:,iter) = sn.vpost(imsn,iter);
end
imagesc(vpost')
ylabel('Trial')
xlabel('time')
title(sprintf('V_p_o_s_t for MSN %g', imsn))

%% Vpost for a single MSN at a single time across trials
vpost = zeros(1, sn.niter);
for mm = 1:length(imsn)
    for iter = 1:sn.niter
        temp = sn.vpost(imsn(mm),iter);
        vpost(iter) = temp(ihvc);
    end
end
plot(vpost')
ylabel('Trial')
xlabel('time')
title(sprintf('V_p_o_s_t for MSN %g', imsn))

%% Vpost for a single MSN on the last iteration
clf
plot(sn.vpost(imsn, sn.niter))
xlabel('Time')
ylabel('V_p_o_s_t')
title(sprintf('MSN %g on first iteration', imsn))

%% Weights for a single MSN for all synapses over time
iters = 1:100;
imagesc(squeeze(sn.wH(imsn,:,iters))')

%% Weights from a single HVC neuron over trials
iters = 1:sn.niter;
imagesc(1:sn.nmsn, iters, squeeze(sn.wH(:,ihvc,:))')
xlabel('MSN')
ylabel('Trial')
title(sprintf('Weights from HVC unit %g', ihvc))

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

%% Histogram of RPE
rpe = zeros(sn.niter,1);
for iter = 1:sn.niter
    temp = sn.rpe(iter);
    rpe(iter) = temp(ihvc);
end
hist(rpe)

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

%% Weights of active MSNs
ihvc = 32:33;
iters = 1:sn.niter;
clf
hold on
co = get(gca,'ColorOrder');
h = nan(1,length(ihvc));
legendstr = cell(1,length(ihvc));
for ii = 1:length(ihvc)
    % all active msns at this time on the last trial
    mask = sn.msnout(:,ihvc(ii),iters) > 0;
    
    % plot weights
    w = sn.wH(:, ihvc(ii), iters); % MSN x Trial
    w(~mask) = nan;
    temp = plot(iters, squeeze(w)', 'Color', co(ii,:));
    h(ii) = temp(1);
    legendstr{ii} = sprintf('HVC %g', ihvc(ii));
end
hold off
legend(h, legendstr, 'Location', 'NorthWest')
ylabel('Weight')
xlabel('Trial')

%% RPE*LMAN one trial at a time
for iter = 1:sn.niter
    plot(sn.rpe(iter))
    xlabel('Time (ms)')
    ylabel('Reward Prediction Error')
    title(sprintf('Trial %g', iter))
    pause
end

%% RPE for one time across trials
e = zeros(1, sn.niter);
for iter = 1:sn.niter
    temp = sn.rpe(iter);
    e(iter) = temp(ihvc);
end
plot(e)
xlabel('Trial')
ylabel('Reward Prediction Error')
title(sprintf('Time %g', ihvc))

%% Reward and expected reward at a single time across trials
for iter = 1:sn.niter
    temp = sn.reward(iter);
    r(iter) = temp(ihvc);
end
plot(r, 'Color', [.7 .7 .7])
hold all
plot(sn.rexp(ihvc,:), 'Color', [0 0 0])

%% Compare LTP
iters = [496, 400:495];
ltp = zeros(length(iters), 1);
rpe = zeros(length(iters), 1);
vpost = zeros(length(iters), 1);
noise = zeros(length(iters), 1);
lman = zeros(length(iters), 1);

for ii = 1:length(iters)
    iter = iters(ii);
    
    temp = sn.LTP(imsn, iter);
    ltp(ii) = temp(ihvc);
    
    temp = sn.rpe(iter);
    rpe(ii) = temp(ihvc);
    
    temp = sn.vpost(imsn, iter);
    vpost(ii) = temp(ihvc);
    
    noise(ii) = sn.noise(ihvc,iter);
    
    lman(ii) = sn.lmanout(ihvc,iter);
end
    
Y = [ltp(1) / mean(abs(ltp(2:end)))
     rpe(1) / mean(abs(rpe(2:end)))
     vpost(1) / mean(vpost(2:end))
     noise(1) / mean(abs(noise(2:end)))];

bar(Y)
set(gca, 'XTickLabel', {'LTP', 'RPE', 'Vpost', 'Noise'})
ylabel('Factor higher than mean')

subplot(3,2,1)
hist(ltp(2:end))
line(ltp(1)*ones(2,1), ylim)
title('LTP')

subplot(3,2,2)
hist(rpe(2:end))
line(rpe(1)*ones(2,1), ylim)
title('RPE')

subplot(3,2,3)
hist(vpost(2:end))
line(vpost(1)*ones(2,1), ylim)
title('Vpost')

subplot(3,2,4)
hist(noise(2:end))
line(noise(1)*ones(2,1), ylim)
title('Noise')

subplot(3,2,5)
hist(lman(2:end))
line(lman(1)*ones(2,1), ylim)
line(sn.template(ihvc)*ones(2,1), ylim, 'Color', 'r')
title('LMAN output')

%% Three sigma events
iters = find(abs(sn.noise(ihvc,:)) >= 3*sn.lmanstd);
fprintf('There are %g three-sigma events at time %g across %g trials.\n', length(iters), ihvc, sn.niter)
ltp = zeros(length(iters), 1);
rpe = zeros(length(iters), 1);
vpost = zeros(length(iters), 1);
noise = zeros(length(iters), 1);
lman = zeros(length(iters), 1);
reward = zeros(length(iters), 1);
for ii = 1:length(iters)
    iter = iters(ii);
    
    temp = sn.LTP(imsn, iter);
    ltp(ii) = temp(ihvc);
    
    temp = sn.rpe(iter);
    rpe(ii) = temp(ihvc);
    
    temp = sn.reward(iter);
    reward(ii) = temp(ihvc);
    
    temp = max(0, sn.vpost(imsn, iter));
    vpost(ii) = temp(ihvc);
    
    noise(ii) = sn.noise(ihvc,iter);
    
    lman(ii) = sn.lmanout(ihvc,iter);
end    

% scatter(lman, ltp)
% scatter(lman, vpost)
% line(sn.template(ihvc)*ones(2,1), ylim, 'Color', 'r')
ndx = rpe < 0;
scatter(iters(ndx), vpost(ndx), 50, [.5 0 0])
ndx = rpe > 0;
hold on
scatter(iters(ndx), vpost(ndx), 50, [0 .5 0])
hold off


%% Error at each time in motif over trials, colored by # of msns active on final motif
clf
bias = zeros(sn.nhvc, sn.niter);
err = zeros(sn.nhvc, sn.niter);
nactivemsn = sum(sn.msnout(:,:,end) > 0, 1);
for iter = 1:sn.niter
    bias(:,iter) = sn.bias(iter);
    err(:,iter) = bias(:,iter) - template';
end
cm = colormap;
ic = floor(interp1([0, max(nactivemsn)], [1, size(cm,1)], 0:max(nactivemsn)));
hold on
legendh=[];
legendstr={};
for n = 1:max(nactivemsn)
    t = nactivemsn == n;
    if sum(t)>0
        h = plot(err(t,:)', 'Color', cm(ic(n+1),:));
        legendh(end+1) = h(1);
        legendstr{end+1} = int2str(n);
    end
end
legend(legendh, legendstr)
xlabel('Trial')
ylabel('Error')
hold off

%% Compare learning rates
filenames = {'hvcreward_unmatched', 'ltdhigher2'};
N = length(filenames);
for n = 1:N
    load(filenames{n}, 'sn')
    subplot(N+1, 1, n)
    sn.plotbiasvstemplate(sn.niter)
    title(filenames(n))
    subplot(N+1, 1, N+1)
    sn.plotmse()
    set(gca, 'YScale', 'log')
    hold all
    clear sn
end
legend(filenames)
hold off