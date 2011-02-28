function caf_plots(birdname, expername, varargin)
P.cluster_escape = 1;
P.cluster_hit = [];
P.target_region = [0 100];
P.target_units = {'percent', 'seconds', 'samples'};
P.last_n = 100;
P.min_pitch_goodness = 0.3;
P.polygon_file = '';
P.vcdb_file = '';
P = parseargs(P, varargin{:});

if exist(P.vcdb_file, 'file')
    load(P.vcdb_file)
    vcdb = handles.vcdb;
    clear handles
else
    vcdb = processedAnnotation2vcdb(birdname, expername);
end

if exist(P.polygon_file, 'file')
    vcdb = apply_polygon_file(vcdb, P.polygon_file);
else
    vcdb.d.cn = vcdb.d.icn;
end

% add features:
% mean pitch in target region
vcdb = vc_feat_mean(vcdb, 'pitch', ...
    'sfname', 'pitchtarg', ...
    'target_region', P.target_region, ...
    'target_units', P.target_units);
% mean pitch goodness in target region
vcdb = vc_feat_mean(vcdb, 'pitchGoodness', ...
    'sfname', 'pgtarg', ...
    'target_region', P.target_region, ...
    'target_units', P.target_units);

% Select only syllables that have good (well-defined) pitch in target
% region and are either hits or escapes.
good_pitch = get_feature_by_name(vcdb, 'pgtarg') >= P.min_pitch_goodness;
is_hit    = vcdb.d.cn == P.cluster_hit;
is_escape = vcdb.d.cn == P.cluster_escape;
mask = good_pitch & (is_hit | is_escape);
mask_lastn = mask & (sum(mask) - cumsum(mask)) <= P.last_n;
mask_firstn = mask & cumsum(mask) <= P.last_n;

% Plot pitch traces of last_n syllables. Hits in red and escapes in black.
subplot(2,2,1)
h = plot_vf(vcdb, 'pitch', 'mask', mask_lastn & is_hit);
hold on
for ii = 1:length(h)
    set(h(ii), 'LineColor', 'r');
end
h = plot_vf(vcdb, 'pitch', 'mask', mask_lastn & is_escape);
for ii = 1:length(h)
    set(h(ii), 'LineColor', 'k');
end
hold off

% Plot mean pitch in target region over time. Again, hits are in red and
% escapes are in black.
subplot(2,2,2)
h = scatter_sf_over_time(vcdb, 'pitchtarg', 'mask', mask & is_hit);
set(h, 'MarkerFaceColor', 'r')
hold on
h = scatter_sf_over_time(vcdb, 'pitchtarg', 'mask', mask & is_escape);
set(h, 'MarkerFaceColor', 'k')
% Overlay a running average of pitch
plot_sf_over_time(vcdb, 'pitchtarg', 'mask', mask, 'smoothing', P.last_n)
hold off

% Show pitch distribitions for first and last n
subplot(2,2,3)
cmap = colormap;
colormap([0 0 1]) % make histogram we are about to plot blue
hist_sf(vcdb, 'pitchtarg', 'mask', mask_firstn, 'bin_width', 5)
hold on
colormap([0 1 0]) % make histogram we are about to plot green
hist_sf(vcdb, 'pitchtarg', 'mask', mask_lastn, 'bin_width', 5)
% make histograms 50% transparent
h = findobj(gca,'Type','patch');
set(h,'FaceAlpha',0.5)
hold off
colormap(cmap) % reset colormap to old value

% Plot percent hits over time. Running average over window of size last_n.
subplot(2,2,4)
t = [vcdb.d.t(is_hit); vcdb.d.t(is_escape)];
y = [ones(sum(is_hit),1); zeros(sum(is_escape), 1)];
[t, ndx] = sort(t);
y = y(ndx);
plot(t, runmean(y, P.last_n));