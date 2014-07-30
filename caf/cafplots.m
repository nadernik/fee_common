function cafplots(birdname, expername, varargin)
%CAFPLOTS Plots to show the effectiveness of conditional auditory feedback
%
% Usage:
%    CAFPLOTS(BIRDNAME, EXPERNAME)
%    CAFPLOTS(BIRDNAME, EXPERNAME, 'ParameterName', value, ...)
% 
% Before you run this, you must run ANNOTATE_EXPER(BIRDNAME, EXPERNAME) or
% have a vcdb from vectorClust!
%
% Makes four plots showing the results of CAF:
%     1. Pitch traces of last N (default=100) target syllables. Hits are in
%        red and escapes are in black. For successful CAF, the pitch in the
%        target region should be different for hits vs. escapes with
%        minimal overlap. Use the Range and RangeUnits parameters (see
%        below) to set the target region.
%     2. Mean pitch in target region over time. Each point represents the
%        mean pitch in the target region for one rendition (black for
%        escape and red for hit). A line represents the average pitch of N 
%        syllables (default=100) computed in a sliding boxcar window. For 
%        successful CAF, the pitch should trend up if hitting low pitches 
%        over the course of the day. 
%     3. Histograms of pitch in target interval at beginning and end of the
%        data file. For successful CAF, the pitch distribution should have
%        shifted away from the noise.
%     4. Percentage of target syllables hit over time. This is a moving
%        average (sliding boxcar window of N=100 syllables) of
%        hits/(hits+escapes). For sucessful CAF, this should start around
%        50-70% and end around 10-20%.
%
% Parameters:
%    EscapeCluser (default = -1)
%        Cluster number for escapes
%    HitCluster (default = nan)
%        Cluster number for hits
%    Range (default = [0 100])
%        Range over which to measure pitch. Must be a two-element vector
%        marking the onset and offset of the pitch measurement window.
%    RangeUnits (default = 'percent')
%        Units for Range parameter. Valid units are 'percent', 'seconds',
%        and 'samples'
%    LastN (default = 100)
%        Number of syllables to use for histograms of pitch. The plot of
%        pitch at the target time is smoothed by a rectangluar window of
%        this length.
%    MinPitchGoodness (default = 0.3)
%        Any syllables with mean pitch goodness over the target range that
%        is below this threshold are excluded from analysis. This is
%        designed to eliminate some outliers where the pitch could not be
%        accurately measured.
%    Polygons (default = '')
%        Polygons file created by vectorClust that is used to label the
%        syllables. If blank, the existing syllable labels are used. You
%        can also label your syllables in vectorClust.
%    LoadVcdb (default = '')
%        vcdb structure or filename of .mat file containing vcdb structure.
%        By default (when this is left blank), CAFPLOTS converts processed
%        annotation files to vcdb using ANNO2VCDB. This process is time
%        consuming, so if you already have a vcdb, you can use the option
%        to speed things up.
%    SaveVcdb (default = '')
%        Filename to which the vcdb struct created by CAFPLOTS is saved. If
%        blank, the vcdb is not saved. This can be useful in conjuction
%        with the LoadVcdb parameter to speed up future calls to CAFPLOTS
%        on the same data, since creating the vcdb is the most time
%        consuming part of this function.
%
% See also: ANNOTATE_EXPER, VECTORCLUST, ANNO2VCDB

%% Parameters
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