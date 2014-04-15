%% 2014-04-15

% Find a good threshold for segmentation
annotate_exper('vtadrive02', '2014-04-14', 'edgeSyllThreshold', -8, ...
    'triggerSyllThreshold', -5, 'bDebug', true, 'filenum', 100)

% Annotate the whole day of singing
annotate_exper('vtadrive02', '2014-04-14', 'edgeSyllThreshold', -8, ...
    'triggerSyllThreshold', -5)

% Cluster syllables
vectorClust