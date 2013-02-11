%% Bias at a single time across trials
% t [vector]
iters = 1:sn.niter;
b = zeros(length(iters), length(t));
for i = 1:length(iters)
    temp = sn.bias(iters(i));
    b(i,:) = temp(t);
end
plot(b)
bn = b ./ (ones(sn.niter,1) * sn.template);
plot(bn)

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
% imsn [scalar]
plot_every = false;
ltp = zeros(sn.nhvc, sn.niter);
ltd = zeros(sn.nhvc, sn.niter);
for iter = 1:sn.niter
    ltp(:,iter) = sn.LTP(imsn, iter);
    ltd(:,iter) = sn.LTD(imsn, iter);
    if plot_every
        plot(ltp(:,iter), 'r')
        hold on
        plot(ltd(:,iter), 'b')
        title(sprintf('LTP for MSN %g on trial %g', imsn, iter))
        ylim([-.1, .1])
        pause
    end
end
clf
subplot(2,1,1)
imagesc(ltp')
xlabel('HVC')
ylabel('Trial')
title(sprintf('LTP for MSN %g', imsn))
subplot(2,1,2)
imagesc(ltd')
xlabel('HVC')
ylabel('Trial')
title(sprintf('LTD for MSN %g', imsn))


%% LTP and LTD for a single HVC-X synapse
% imsn [scalar]
% ihvc [scalar]
% iters [vector]
clf
ltp = zeros(1, length(iters));
ltd = zeros(1, length(iters));
vp  = zeros(1, length(iters));
rpe = zeros(1, length(iters));
for i = 1:length(iters)
    temp = sn.LTP(imsn, iters(i));
    ltp(i) = temp(ihvc);
    temp = sn.LTD(imsn, iters(i));
    ltd(i) = temp(ihvc);
    temp = sn.vpost(imsn, iters(i)) - sn.v0(imsn, iters(i));
    vp(i) = temp(ihvc);
    temp = sn.rpe(iters(i));
    rpe(i) = temp(ihvc);
end

axh(1) = subplot(6,1,1);
plot(ltp)
hold all
plot(ltd)
hold off
xlabel('Trial')
ylabel('LTP or LTD')
legend({'LTP', 'LTD'})
title(sprintf('LTP and LTD for weight onto MSN %g from HVC neuron %g', imsn, ihvc))

axh(2) = subplot(6,1,2);
plot(squeeze(sn.wH(imsn,ihvc,:)))
xlabel('Trial')
ylabel('Weight')

axh(3) = subplot(6,1,3);
plot(squeeze(sn.msnout(imsn, ihvc, :)))
hold all
plot(squeeze(sum(sn.msnout(:,ihvc,:), 1)))
ylabel('MSN output')

axh(4) = subplot(6,1,4);
plot(sn.lmanout(ihvc,:))
hold all
plot([1, sn.niter], ones(1,2) * sn.template(ihvc))
hold off
ylabel('LMAN output')

axh(5) = subplot(6,1,5);
plot(vp)
hold on
plot(xlim, [0 0])
hold off
ylabel('V_p_o_s_t - V_0')

axh(6) = subplot(6,1,6);
plot(rpe)
hold on
plot(xlim, [0 0])
hold off
ylabel('RPE')

linkaxes(axh, 'x')

%% LTP for all synapses from a single HVC neuron
iters = 1:500;
ihvc1 = 47;
ihvc2 = 62;
p1 = zeros(sn.nmsn, length(iters));
p2 = zeros(sn.nmsn, length(iters));
d1 = zeros(sn.nmsn, length(iters));
d2 =zeros(sn.nmsn, length(iters));
for ii = 1:length(iters)
    iter = iters(ii)
    for imsn = 1:sn.nmsn
        temp = sn.LTP(imsn, iter);
        p1(imsn,ii) = temp(ihvc1);
        p2(imsn,ii) = temp(ihvc2);
        
        temp = sn.LTD(imsn, iter);
        d1(imsn,ii) = temp(ihvc1);
        d2(imsn,ii) = temp(ihvc2);
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
% t [vector]
% iter [scalar]

nactivemsn = squeeze(sum(sn.msnout > 0, 1));
subplot(1,3,1)
plot(nactivemsn(t,:)')
xlabel('Trial')
ylabel('Active MSNs')
title(['Number of active MSNs at time ', int2str(t)])
if length(t) > 1
    legend(arrayfun(@int2str, t, 'UniformOutput', 0))
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
%imagesc(vpost')
plot(vpost)
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
% iters [vector]
imagesc(squeeze(sn.wH(imsn,:,iters))')
title(

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
legend({'Reward', 'Expected Reward'})

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

%% V0 for a single MSN across all times and trials
for iter = 400:sn.niter
    plot(sn.vpost(imsn,iter), 'k', 'LineWidth', 2)
    hold on
    plot(ones(sn.nhvc,1) * sn.v0(imsn,iter), 'r', 'LineWidth', 2)
    hold off
    ylabel('V')
    xlabel('Time')
    
    title(sprintf('MSN %g on trial %g\n[Enter] for next...', imsn, iter))
    legend({'Vpost', 'V_0'}, 'Location', 'NorthWest')
    ylim([0 3])
    pause
end

%% V_0 for a single MSN across trials
clf
plot(squeeze(sn.v0(imsn,:)))
xlabel('Trial')
ylabel('V_0')
title(sprintf('MSN %g', imsn))

%% (Vpost - V_0) on each iter
iters = 1:sn.niter;
for i = 1:50:length(iters)
    v = zeros(sn.nmsn, sn.nhvc);
    for imsn = 1:sn.nmsn
        v(imsn,:) = sn.vpost(imsn,iters(i)) - sn.v0(imsn,iters(i));
    end
    plot(v(1,:))
    title(sprintf('(Vpost - V_0) for trial %g', iters(i)))
    xlabel('Time')
    ylabel('V')
    ylim([-0.3, 0.3])
    pause
    
end

%% (Vpost - V_0) vs lman noise
clf
v = zeros(size(sn.lmanout));
for iter = 1:sn.niter
    v(:,iter) = sn.vpost(imsn,iter) - sn.v0(imsn,iter);
end
% scatter(sn.noise(:), v(:))
scatter(sn.noise(ihvc,:), v(ihvc,:))
xlabel('Noise')
ylabel('V_p_o_s_t - V_0')
title(sprintf('MSN %g, LMAN weight %g', imsn, sn.wL(imsn)))

%% (Vpost - V_0) vs RPE
% Only use with instantaneous reward
% Paramters
%   t     = vector
%   iters = vector
%   imsn  = scalar

v = zeros(length(t),length(iters));
d = zeros(length(t),length(iters));
legendstr = cell(1,length(t));
for i = 1:length(iters)
    temp = sn.vpost(imsn, iters(i)) - sn.v0(iters(i));
    v(:,i) = temp(t);
    temp = sn.rpe(iters(i));
    d(:,i) = temp(t);
end
for k = 1:length(t)
    scatter(v(k,:),d(k,:))
    if k == 1
        hold all
    end
    legendstr{k} = sprintf('Time %g', t(k));
    fprintf('Correlation of (Vpost-V0) with RPE at time %g = %g\n', t(k), corr(v(k,:)', d(k,:)'))
end
legend(legendstr)
xlabel('V_p_o_s_t - V_0')
ylabel('RPE')
title(sprintf('MSN %g', imsn))
hold off

%% LMAN noise vs RPE
% Use only with instantaneous reward
% Parameters: 
%   t     = [vector]
%   iters = [vector]
clf
z = sn.noise(t, iters) - sn.lmanoffset;
d = zeros(length(t),length(iters));
for i = 1:length(iters)
    temp = sn.rpe(iters(i));
    d(:,i) = temp(t);
end
legendstr = cell(1,length(t));
for k = 1:length(t)
    scatter(z(k,:),d(k,:))
    if k == 1
        hold all
    end
    legendstr{k} = sprintf('Time %g', t(k));
    fprintf('Correlation of noise with RPE at time %g = %g\n', t(k), corr(z(k,:)', d(k,:)'))
end
legend(legendstr)
xlabel('LMAN noise')
ylabel('RPE')
hold off

%% LMAN noise vs change in bias
% t
% iters
z = sn.noise(t, iters(1:end-1));
b = zeros(sn.nhvc, length(iters));
for i = 1:length(iters)
    b(:,i) = sn.bias(iters(i));
end
db = diff(b(t,:),1,2); % difference along iterations
for k = 1:length(t)
    scatter(z(k,:),db(k,:))
    if k == 1
        hold all
    end
    legendstr{k} = sprintf('Time %g', t(k));
    fprintf('Correlation of noise with change in bias at time %g = %g\n', t(k), corr(z(k,:)', db(k,:)'))
end
xlabel('LMAN noise')
ylabel('Change in bias')
legend(legendstr)

%% LMAN noise vs change in weights
z = sn.noise(t, iters(1:end-1));
dw = diff(sn.wH(:,t,iters), 1, 3);

for k = 1:length(t)
    clf
    msnlist = find(sn.wH(:,t(k),end)>eps);
    for imsn = msnlist'
        scatter(z(k,:), squeeze(dw(imsn,k,:)))
        xlabel('LMAN noise')
        ylabel('Change in weight')
        title(sprintf('Time %g, MSN %g, weight %g', t(k), imsn, sn.wH(imsn,t(k),end)))
        pause
    end
end

%% LMAN noise vs LTP
% imsn
% t
z = sn.noise(t, iters(1:end-1)) - sn.lmanoffset;
dw = diff(sn.wH(:,t,iters), 1, 3);

for k = 1:length(t)
    clf
    msnlist = find(sn.wH(:,t(k),end)>eps);
    for imsn = msnlist'
        scatter(z(k,:), squeeze(dw(imsn,k,:)))
        xlabel('LMAN noise')
        ylabel('Change in weight')
        title(sprintf('Time %g, MSN %g, weight %g', t(k), imsn, sn.wH(imsn,t(k),end)))
        pause
    end
end

%% (Vpost - V_0) and change in weight
clf
for i = 1:length(iters)
    v = sn.vpost(imsn,iters(i)) - sn.v0(imsn,iters(i));
    p = sn.LTP(imsn, iters(i));
    d = sn.LTD(imsn, iters(i));
    plot(v/max(abs(v)), 'k', 'LineWidth', 2)
    hold on
    plot(p/max(abs(p)), 'g', 'LineWidth', 2)
    plot(d/max(abs(p)), 'r', 'LineWidth', 2)
    hold off
    title(sprintf('MSN %g on trial %g', imsn, iters(i)))
    legend({'V_p_o_s_t - V_0', 'LTP', 'LTD'})
    ylim([-1.5, 1.5])
    pause
end

%% 
t = 25;
iters = 800:1000;
msnlist = find(sn.msnout(:,t,end) > eps);
for imsn = msnlist'
    plot(iters,squeeze(sn.msnout(imsn,t,iters)))
    title(sprintf('MSN %g', imsn))
    ylim([0, .1])
    pause
end

%% MICHALE IS WATCHING
for iter = 1:1:sn.niter
    subplot(2,3,[1 4])
    sn.imagemsnout(iter)
    subplot(2,3,[2 5])
    sn.plotbiasvstemplate(iter)
    title(int2str(iter))
    subplot(2,3,3)
    %sn.plotmse();
    subplot(2,3,6)
    sn.plotvdw(1,iter)
    drawnow
    %pause
end

%% Histogram of vpost for a single neuron
% iters [vector]
% t [vector]
% imsn [scalar]
ratio = zeros(1,sn.nmsn);
for imsn = 1:sn.nmsn
vp = zeros(length(iters), length(t));
r = zeros(length(iters), length(t));
for i = 1:length(iters)
    vtemp = sn.vpost(imsn, iters(i)) - sn.v0(imsn,iters(i));
    rtemp = sn.rpe(iters(i));
    vp(i,:) = vtemp(t);
    r(i,:) = rtemp(t);    
end
% % bins = linspace(-.01, 0.04, 40);
% bins = linspace(-0.05, 0.2, 40);
% c = {'b', 'r'};
% for n = 1:length(t)
% %     stairs(bins, cumsum(hist(vp(:,n).*r(:,n), bins)), 'LineWidth', 3)
% scatter(vp(:,n), r(:,n), [], c{n})
%     if n == 1
%         hold all
%     end
% end
% hold off
pr = mean(vp.*r);
ratio(imsn) = pr(2) / pr(1);
end
plot(ratio)
    
    
%%
mi = zeros(sn.nhvc, length(iters));
for i = 1:length(iters)
    mi(:,i) = sn.wH(imsn,:,iters(i)) * sn.hvcout;
end
plot(mi)

%% Sum of weights
% iters [vector]
wmax = globalmax(sum(sn.wH(:,:,iters),1));
for i = 1:length(iters)
    plot(sum(sn.wH(:,:,iters(i))))
    ylim([0 wmax])
    title(sprintf('Trial %g', iters(i)))
    xlabel('Time')
    ylabel('\Sigma Weight')
    pause
end

%% Weight image unsorted
% iters [vector]
wmax = 1.1 * globalmax(sn.wH(:,:,iters(1)));
for i = 1:length(iters)
    image(sn.wH(:,:,iters(i)) ./ wmax .* 64)
    title(sprintf('Trial %g', iters(i)))
    pause
end

%% All weight profiles, aligned at peak
% iter [scalar]
clf
tt = 1:sn.nhvc;
for m = 90:100
    w = sn.wH(m,:,iter);
    [wmax, tpk] = max(w);
    plot(tt-tpk, w/wmax)
    if true %m == 1
        hold all
    end
end
hold off
xlim([-10, 10])

%% LTD components
% imsn [scalar]
% ihvc [vector]
% iter [scalar]
a(1) = subplot(4,1,1);
M = sn.msnout(imsn,:,iter);
plot(M)
ylabel('MSN output')
a(2) = subplot(4,1,2);
H = sn.hvcout(ihvc,:);
ph = plot(H);
ylabel('HVC output')
xlabel('Time')
a(3) = subplot(4,1,3);
plot((ones(length(ihvc),1)*M) .* (H == 0))
a(4) = subplot(4,1,4);
ltd = sn.LTD(imsn, iter);
plot(ltd)
hold on
for n = 1
    c = get(ph, 'Color');
    scatter(ihvc(n), ltd(ihvc(n)), 50, c, 'filled')    
end
hold off
xlabel('HVC neuron')
ylabel('LTD')
linkaxes(a, 'x')

%% Noise * RPE
% iters [vector]
% t [vector]
rpe = zeros(length(t), length(iters));
for i = 1:length(iters)
    temp = sn.rpe(iters(i));
    rpe(:,i) = temp(t);
end
noise = sn.noise(t,iters);
plot(iters, cumsum(rpe .* noise))
xlabel('Trial')
    

%% Bias - Template
% iters [vector]
db = zeros(length(sn.template), length(iters));
for i = 1:length(iters)
    db(:,i) = sn.bias(iters(i));
end
imagesc(1:sn.nhvc,iters,db')
xlabel('Time')
ylabel('Trial')
    
%%
% iter [scalar]
b = sn.bias(iter) - sn.template;
omax = zeros(sn.nmsn,1);
tmax = zeros(sn.nmsn,1);
for m = 1:sn.nmsn
    out = sn.msnout(m,:,iter);
    [omax(m), tmax(m)] = max(out);
%     plot(out)
%     title(int2str(m))
%     ylim([0, 0.4])
%     pause
end
bins = 1:sn.nhvc;
N = hist(tmax,bins);
N(1)=nan;
plot(b/max(b))
hold all
plot(N)
hold off

%% Bias and LTP
% iters [vector]
% imsn [scalar]
clear a
for i = 1:length(iters)
    bias = sn.bias(iters(i));
    ltp = sn.LTP(imsn,iters(i));
    a(1) = subplot(2,1,1);
    plot(bias)
    hold on
    title(int2str(iters(i)))
    grid on
    a(2) = subplot(2,1,2);
    plot(ltp)
    grid on
    linkaxes(a, 'x')
    hold on
    pause
end

%% 
vp = zeros(sn.nhvc, length(iters));
for i = 1:length(iters)
    vp(:,i) = sn.vpost(imsn,iters(i)) - sn.v0(imsn,iters(i));
end

%% Calibrate LTD for fixed values
%load lastscalinginhib sn
iter = 50;
isactive = sn.msnout(:,:,iter) > 0;
tactive = sum(isactive, 2);% number of timesteps where each MSN is active
nactive = sum(isactive, 1); % number of MSNs active at each timestep
ltd   = zeros(sn.nmsn,1);
inhib = zeros(sn.nmsn,1);
for imsn = 1:sn.nmsn
    ltd(imsn) = min(sn.LTD(imsn, iter));
    inhib(imsn) = max(sn.allinhib(imsn, iter));
end
fprintf('On average, each MSN is active on %g timesteps and LTD is %g\n', mean(tactive), mean(ltd))
fprintf('New value for LTD/timestep is %g\n', mean(ltd)/mean(tactive))
fprintf('On average, there are %g MSNs active on each timestep and inhibition is %g\n', mean(nactive), mean(inhib))
fprintf('New value for inhibtion/timestep is %g\n', mean(inhib)/mean(nactive))



