%% 2011-10-14
annotate_exper('1555', '2011-10-13', 'edgeSyllThreshold', -11, 'triggerSyllThreshold', -8)
vectorClust
% 1 = escapes
rules

%% 2011-10-17
annotate_exper('1555', '2011-10-14', 'edgeSyllThreshold', -11, 'triggerSyllThreshold', -8)
vectorClust
annotate_exper('1555', '2011-10-15', 'edgeSyllThreshold', -11, 'triggerSyllThreshold', -8)
vcQuickCluster('1555', '2011-10-15', 'polygons 2011-10-14.mat', []);
labeledspecgram('1555', '2011-10-15')
annotate_exper('1555', '2011-10-16', 'edgeSyllThreshold', -11, 'triggerSyllThreshold', -8)
labeledspecgram('1555', '2011-10-16')
% I am getting a lot of calls clustered as escapes. Need to make new
% polygons including sequence information to filter these out. I don't
% really care if they get hit with noise.
vcQuickCluster('1555', '2011-10-14', 'polygons 2011-10-14.mat', []);
vcQuickCluster('1555', '2011-10-15', 'polygons 2011-10-14.mat', []);
vcQuickCluster('1555', '2011-10-16', 'polygons 2011-10-14.mat', []);
labeledspecgram('1555', '2011-10-16')
% good!
cafplots('1555', '2011-10-16', ...
    'HitCluster', 2, ...
    'EscapeCluster', 1, ...
    'Range', [.035 .038], ...
    'RangeUnits', 'seconds', ...
    'LastN', 50, ...
    'SaveVcdb', 'c:\stetner\data\1555\2011-10-16\cafplots_vcdb.mat')
% Hitting about 90% of the time, which is too much. But this bird is not
% singing very much. Continue for 2 more days to see if he starts to sing
% more in response to the noise. If not, abandon.
