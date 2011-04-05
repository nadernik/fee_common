%% 2011-03-15

annotate_exper('2145', '2011-03-15', 'edgeSyllThreshold',-10,'triggerSyllThreshold',-8, 'filenum', 1:91)
% clustered in vectorClust. 1 = escapes.
% made rules and loaded them after file 150

%% 2011-03-16

% Made new polygons in vectorClust
%   1 = escapes
%   2 = hits
vcQuickCluster('2145', '2011-03-15', 'polygons20110316.mat', [], 'root', 'c:\stetner\data')
cafplots('2145', '2011-03-15', ...
    'EscapeCluster', 1, ...
    'HitCluster', 2, ...
    'Range', [.029 .033], ...
    'RangeUnits', 'seconds', ...
    'LastN', 200, ...
    'SaveVcdb', 'c:\stetner\data\2145\vcdb2011-03-15.mat')

% Yes learned upwards. Push up again. New rules puship upwards from 1008 Hz
% to hit 51%. Tested on files 613 - 639. Loaded before any singing.

%% 2011-03-18

vcQuickCluster('2145', '2011-03-16', 'polygons20110316.mat', 2, 'root', 'c:\stetner\data')
cafplots('2145', '2011-03-16', ...
    'EscapeCluster', 1, ...
    'HitCluster', 2, ...
    'Range', [.029 .033], ...
    'RangeUnits', 'seconds', ...
    'LastN', 100, ...
    'SaveVcdb', 'c:\stetner\data\2145\2011-03-16\vcdb.mat')
% No learning, but also not very much singing.

vcQuickCluster('2145', '2011-03-17', 'polygons20110316.mat', 1, 'root', 'c:\stetner\data')
cafplots('2145', '2011-03-17', ...
    'EscapeCluster', 1, ...
    'HitCluster', 2, ...
    'Range', [.029 .033], ...
    'RangeUnits', 'seconds', ...
    'LastN', 100, ...
    'SaveVcdb', 'c:\stetner\data\2145\2011-03-17\vcdb.mat')
% Good learning upwards. Push back down, then will be ready to implant.

%% 2011-03-19

vcQuickCluster('2145', '2011-03-18', 'polygons20110316.mat', 2, 'root', 'c:\stetner\data')
% No singing :(

%% 2011-03-21
vcQuickCluster('2145', '2011-03-19', 'polygons20110316.mat', 2, 'root', 'c:\stetner\data')
cafplots('2145', '2011-03-19', ...
    'EscapeCluster', 1, ...
    'HitCluster', 2, ...
    'Range', [.029 .033], ...
    'RangeUnits', 'seconds', ...
    'LastN', 100, ...
    'SaveVcdb', 'c:\stetner\data\2145\2011-03-19\vcdb.mat')
% Learned downwards. Ready to implant.

%% 2011-03-25
vcQuickCluster('2145', '2011-03-24', 'polygons20110322.mat', 2, 'root', 'c:\stetner\data')
cafplots('2145', '2011-03-24', ...
    'EscapeCluster', 1, ...
    'HitCluster', 2, ...
    'Range', [.029 .033], ...
    'RangeUnits', 'seconds', ...
    'LastN', 100, ...
    'SaveVcdb', 'c:\stetner\data\2145\2011-03-24\vcdb.mat')

%% 2011-03-26
vcQuickCluster('2145', '2011-03-25', 'polygons20110322.mat', 1, 'root', 'c:\stetner\data')
labeledspecgram('2145', '2011-03-25')
% some escapes are not labeled

cafplots('2145', '2011-03-25', ...
    'EscapeCluster', 1, ...
    'HitCluster', 2, ...
    'Range', [.029 .033], ...
    'RangeUnits', 'seconds', ...
    'LastN', 100, ...
    'SaveVcdb', 'c:\stetner\data\2145\2011-03-25\vcdb.mat')
% Filters not good? Or maybe pitch goodness in target region is bad.

%% 2011-03-28

figure
dotm = 25:27;
axh = nan(size(dotm));
for ii = 1:length(dotm)
    filename = ['c:\stetner\data\2145\2011-03-' int2str(dotm(ii)) '\vcdb.mat'];
    % Load vcdb
    load(filename)
    % caluclate new feature -- pitch goodness in target region (~20 to 40 ms
    % into the syllable)
    try
        vcdb = handles.vcdb;
        clear handles
    catch
    end
    vcdb = vc_feat_mean(vcdb, 'pitchGoodness', 'Range', [0.03 0.04], 'RangeUnits', 'seconds', 'Name', 'tpg');
    % histogram of new feature
    axh(ii) = subplot(length(dotm),1,ii);
    sfhist(vcdb, 'tpg','BinWidth', 0.05, 'Mask', vcdb.d.cn == 1)
    title(filename)
    clear vcdb
end
% doesn't seem like pitchGoodness is decreasing. What about std(pitch)

figure
dotm = 25:27;
axh = nan(size(dotm));
for ii = 1:length(dotm)
    filename = ['c:\stetner\data\2145\2011-03-' int2str(dotm(ii)) '\vcdb.mat'];
    % Load vcdb
    load(filename)
    % caluclate new feature -- pitch goodness in target region (~20 to 40 ms
    % into the syllable)
    try
        vcdb = handles.vcdb;
        clear handles
    catch
    end
    vcdb = vc_feat_std(vcdb, 'pitch', 'Range', [0.03 0.04], 'RangeUnits', 'seconds', 'Name', 'stdp');
    % histogram of new feature
    axh(ii) = subplot(length(dotm),1,ii);
    sfhist(vcdb, 'stdp','BinWidth', 5, 'Mask', vcdb.d.cn == 1)
    title(filename)
    clear vcdb
end
% Hard to tell. A few syllables on each day have very high SD, but most are
% very low. 

%% 2011-03-30
vcQuickCluster('2145', '2011-03-29', 'polygons20110328.mat', [], 'root', 'c:\stetner\data')
labeledspecgram('2145', '2011-03-29')
% Cannot get good filters. Sac him.