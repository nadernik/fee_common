load c:\stetner\data\sparsemodel\debugging5.mat
dw_all = diff(w_all, 1, 3); % first difference across motifs
% msns by channel
m_up = weights_on_pallidus_from_msn(1,:) ~= 0;
m_down = weights_on_pallidus_from_msn(2,:) ~= 0;

% all dw across all neurons
dw_pooled_motifs = reshape(dw_all, msn_units*hvc_units, total_motifs - 1);
bins = -0.02:.00005:.02;
dw_hist_motifs = zeros(length(bins), total_motifs-1);
for mo = 1:total_motifs-1
    dw_hist_motifs(:,mo) = hist(dw_pooled_motifs(:,mo), bins);
end
plot(bins,dw_hist_motifs(:,600:610))

%% dw of synapses only at peak of template

[junk, t] = max(template);
[junk, h] = max(hvc_output(:,t));
dw_at_peak_time = squeeze(dw_all(:,h,:));
plot(dw_at_peak_time')
disp('Enter to continue...')
pause
bins = globalmin(dw_at_peak_time):.0005:globalmax(dw_at_peak_time);
dw_hist_at_peak = zeros(length(bins), total_motifs-1);
for mo = 1:total_motifs-1
    dw_hist_at_peak(:,mo) = hist(dw_at_peak_time(m_up, mo), bins);
end
plot(bins,dw_hist_at_peak)

%% dw of synapses where template approx 0
t = 100;
[junk, h] = max(hvc_output(:,t));
dw_at_zero_time = squeeze(dw_all(:,h,:));
plot(dw_at_zero_time')
disp('Enter to continue...')
pause
% use same bins as above
dw_hist_at_zero = zeros(length(bins), total_motifs-1);
for mo = 1:total_motifs-1
    dw_hist_at_zero(:,mo) = hist(dw_at_zero_time(m_up, mo), bins);
end
plot(bins,dw_hist_at_zero)

%% dw of synapses where template around half max
[junk, t] = min(abs(template - max(template)/2)); % time at which template is closest to half max
[junk, h] = max(hvc_output(:,t)); % hvc unit most active at that time
dw_at_halfmax_time = squeeze(dw_all(:,h,:));
plot(dw_at_halfmax_time')
disp('Enter to continue...')
pause
% use same bins as above
dw_hist_at_halfmax = zeros(length(bins), total_motifs-1);
for mo = 1:total_motifs-1
    dw_hist_at_halfmax(:,mo) = hist(dw_at_halfmax_time(m_up, mo), bins);
end
plot(bins,dw_hist_at_halfmax)