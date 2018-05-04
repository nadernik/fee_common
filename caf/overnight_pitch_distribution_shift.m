function overnight_pitch_distribution_shift(birdname, expername1, expername2, varargin)
% Assumes segs are in chronological order.
P.clusters = [nan nan]; %just need to make it not scalar here to avoid errors
P.N = 100;
P.minpg = 0;
P.range = [0 100];
P.rangeunits = {'percent', 'seconds', 'samples'};
P.polygonfile = '';
P.binwidth = 5;
P = parseargs(P, varargin{:});

% Load data
vcdb1 = annotation2vcdb(birdname, expername1, 'audio', false);
vcdb2 = annotation2vcdb(birdname, expername2, 'audio', false);

% Cluster
if exist(P.polygonfile, 'file')
    vcdb1 = apply_polygon_file(vcdb1, P.polygonfile);
    vcdb2 = apply_polygon_file(vcdb2, P.polygonfile);
end

% Calculate pitch feature for histogram
vcdb1 = vc_feat_mean(vcdb1, 'pitch', ...
    'range', P.range, ...
    'rangeunits', P.rangeunits, ...
    'name', 'pitchtarg');
vcdb2 = vc_feat_mean(vcdb2, 'pitch', ...
    'range', P.range, ...
    'rangeunits', P.rangeunits, ...
    'name', 'pitchtarg');

% Only take syllables from clusters given in P.clusters
mask1 = false(size(vcdb1.d.v));
mask2 = false(size(vcdb2.d.v));
for ii = 1:length(P.clusters)
    cn = P.clusters(ii);
    mask1 = mask1 | vcdb1.d.cn == cn;
    mask2 = mask2 | vcdb2.d.cn == cn;
end
% Discard syllables that do not have high pitch goodness over target
% interval
if P.min_pitch_goodness > 0
    vcdb1 = vc_feat_mean(vcdb1, 'pitchGoodness', ...
        'range', P.target_range, ...
        'rangeunits', P.target_units, ...
        'name', 'pgtarg');
    vcdb2 = vc_feat_mean(vcdb2, 'pitchGoodness', ...
        'range', P.target_range, ...
        'units', P.target_units, ...
        'name', 'pgtarg');
    mask1 = mask1 & getSFbyName(vcdb1, 'pgtarg') >= P.min_pitch_goodness;
    mask2 = mask2 & getSFbyName(vcdb2, 'pgtarg') >= P.min_pitch_goodness;
end
% Take last P.N syllables from vcdb1 and first P.N syllables from vcdb2.
mask1 = mask1 & (sum(mask1) - cumsum(mask1)) <= P.N;
mask2 = mask2 & cumsum(mask2) <= P.N;

% Make distributions of vcdb1 in purple and vcdb2 in orange
hist_sf(vcdb1, 'pitchtarg', ...
    'mask', mask1, ...
    'bin_width', P.bin_width, ...
    'patchargs', {'FaceColor', [0.6 0.2 1], 'FaceAlpha', 0.5})
hist_sf(vcdb2, 'pitchtarg', ...
    'mask', mask2, ...
    'bin_width', P.bin_width, ...
    'patchargs', {'FaceColor', [1 0.6 0], 'FaceAlpha', 0.5})