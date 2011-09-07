%% 2011-08-24
annotate_exper('2468', '2011-08-23', 'triggerSyllThreshold', -8, 'edgeSyllThreshold', -11)
vectorClust
% Not good. soemtimes target syllable is joined iwth syllable before it
annotate_exper('2468', '2011-08-23', 'triggerSyllThreshold', -8, 'edgeSyllThreshold', -10, 'fMinIntervalDuration', .025)
vectorClust
%somewhat difficult to cluster. using mean and std pitch in target region
%to find the target syllable. this will definitely need adjustment as the
%mean pitch of the target region changes with CAF.
vcQuickCluster('2468', '2011-08-23', 'c:\stetner\data\2468\polygons 2011-08-23.mat', [], 'root', 'c:\stetner\data')
labeledspecgram('2468', '2011-08-23')
% target syllable is sometimes missed because due to segmentation
% difficulties (merging or splitting with adjacent syllables) see file 158
% for example of both problems.

rules

%% 2011-08-26
annotate_exper('2468', '2011-08-25', 'triggerSyllThreshold', -8, 'edgeSyllThreshold', -10, 'fMinIntervalDuration', .025, 'maxFilesPerAnnotation', 400)

%% 2011-08-27
annotate_exper('2468', '2011-08-26', 'triggerSyllThreshold', -8, 'edgeSyllThreshold', -10, 'fMinIntervalDuration', .025, 'maxFilesPerAnnotation', 400)
labeledspecgram('2468', '2011-08-26')
vectorClust

%% 2011-08-29
% abandoned because caf is too hard