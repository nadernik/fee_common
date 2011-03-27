function cafplots(birdname, expername, varargin)
P.EscapeCluster = -1;
P.HitCluster = nan;
P.Range = [0 100];
P.RangeUnits = {'percent', 'seconds', 'samples'};
P.LastN = 100;
P.MinPitchGoodness = 0.3;
P.Polygons = '';
P.LoadVcdb = '';
P.SaveVcdb = '';
P = parseargs(P, varargin{:});

titlestr = sprintf(...
    '%s %s EscapeCluster=%g HitCluster=%g LastN=%g MinPitchGoodness=%g', ...
    birdname, expername, P.EscapeCluster, P.HitCluster, P.LastN, P.MinPitchGoodness);

%%
if exist(P.LoadVcdb, 'file')
    if ischar(P.LoadVcdb) % load vcdb from given filename
        try
            load(P.LoadVcdb)
            vcdb = handles.vcdb;
            clear handles
        catch
            warning('MATLAB:cafplots:LoadVcdb', 'Unable to load vcdb from file %s. Will try to create vcdb from proccessed annotation files instead.', P.Vcdb)
        end
    elseif isvcdb(P.LoadVcdb) % use given vcdb
        vcdb = P.LoadVcdb;
    end
end
            
if ~exist('vcdb', 'var')
    vcdb = anno2vcdb(birdname, expername, 'Audio', false);
end

%%

if ~isempty(P.Polygons) && exist(P.Polygons, 'file')
    try
        vcdb = vcdbloadpolys(vcdb, P.Polygons);
    catch
        warning('MATLAB:cafplots:LoadPolygons', 'Unable to load polygons from %s.', P.Polygons)
    end
else
    try
        vcdb.d.cn = vcdb.d.icn;
    catch
        warning('MATLAB:cafplots:Cluster', 'No icn.')
    end
    
end



%%

% add features:
% mean pitch in target region
vcdb = vc_feat_mean(vcdb, 'pitch', ...
    'Name', 'pitchtarg', ...
    'Range', P.Range, ...
    'RangeUnits', P.RangeUnits);
% mean pitch goodness in target region
vcdb = vc_feat_mean(vcdb, 'pitchGoodness', ...
    'Name', 'pgtarg', ...
    'Range', P.Range, ...
    'RangeUnits', P.RangeUnits);

% Select only syllables that have good (well-defined) pitch in target
% region and are either hits or escapes.
good_pitch = getsf(vcdb, 'pgtarg') >= P.MinPitchGoodness;
is_hit    = vcdb.d.cn == P.HitCluster;
is_escape = vcdb.d.cn == P.EscapeCluster;
mask = good_pitch & (is_hit | is_escape);
mask_lastn = mask & (sum(mask) - cumsum(mask)) <= P.LastN;
mask_firstn = mask & cumsum(mask) <= P.LastN;

% Plot pitch traces of last_n syllables. Hits in red and escapes in black.
figure(4441)
clf
% h = vfplot(vcdb, 'pitch', 'mask', mask_lastn & is_hit);
h = vfplot(vcdb, 'pitch', 'mask', is_hit);
hold on
for ii = 1:length(h)
    set(h(ii), 'Color', 'r');
end
% h = vfplot(vcdb, 'pitch', 'mask', mask_lastn & is_escape);
h = vfplot(vcdb, 'pitch', 'mask', is_escape);
for ii = 1:length(h)
    set(h(ii), 'Color', 'b');
end
% rectangle around target region, if region is in seconds
if strcmp(P.RangeUnits, 'seconds')
    X = [P.Range([1 2]), P.Range([2 1])];
    Y = [0 0 4000 4000];
    fill(X, Y, 'y', 'FaceAlpha', 0.3)
end
xlabel('Seconds from syllable onset')
ylabel('Pitch (Hz)')
title(titlestr)

% Plot mean pitch in target region over time. Again, hits are in red and
% escapes are in black.
figure(4442)
hold on
h = sfscatter(vcdb, 'pitchtarg', 'mask', mask & is_hit);
set(h, 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'r', 'Marker', '.', 'SizeData', 30)
% hold(axh, 'on')
h = sfscatter(vcdb, 'pitchtarg', 'mask', mask & is_escape);
set(h, 'MarkerFaceColor', 'b', 'MarkerEdgeColor', 'b', 'Marker', '.', 'SizeData', 30)
% Overlay a running average of pitch
h = sfplot(vcdb, 'pitchtarg', 'mask', mask, 'smoothing', P.LastN);
set(h, 'LineWidth', 3, 'Color', 'k')
% hold(axh, 'off')
datetick('x', 'HH:MM', 'keeplimits')
xlabel('Time of day')
ylabel('Mean pitch over target interval (Hz)')
title(titlestr)

% Show pitch distribitions for first and last n
figure(4443)
clf
hold on
patchargs = {'FaceColor', 'b', 'FaceAlpha', 0.5};
sfhist(vcdb, 'pitchtarg', 'Mask', mask_firstn, 'BinWidth', 5, 'PatchProperties', patchargs)
% hold(axh, 'on')
patchargs = {'FaceColor', 'r', 'FaceAlpha', 0.5};
sfhist(vcdb, 'pitchtarg', 'Mask', mask_lastn, 'BinWidth', 5, 'PatchProperties', patchargs)
% hold(axh, 'off')
ylabel('Number')
xlabel('Mean pitch over target interval (Hz)')
title(titlestr)

% Plot percent hits over time. Running average over window of size last_n.
figure(4444)
clf
t = [vcdb.d.t(is_hit); vcdb.d.t(is_escape)];
y = [ones(sum(is_hit),1); zeros(sum(is_escape), 1)];
[t, ndx] = sort(t);
y = y(ndx);
plot(t, smooth(y, P.LastN))
datetick('x', 'HH:MM', 'keeplimits')
xlabel('Time of day')
ylabel('Fraction hit')
title(titlestr)


if ~isempty(P.SaveVcdb)
    handles.vcdb = vcdb;
    save(P.SaveVcdb, 'handles')
end