%% 4007
% Microdrive implant in VTA/SNc

%% 2014-03-14
% Just plugged into cable. Make filters to detect two different moments in
% his song. One will be hit with noise randomly 80% of the time and the other will
% be hit 20% of the time (not contingent on pitch).

annotate_exper('4007', '2014-03-14', 'triggerSyllThreshold', -8, 'edgeSyllThreshold', -10, 'filenum', 200, 'bDebug', true)

% Thresholds too low. Raise by 2.

annotate_exper('4007', '2014-03-14', 'triggerSyllThreshold', -6, 'edgeSyllThreshold', -8, 'filenum', 200, 'bDebug', true)

% Good. Now process all the files.

annotate_exper('4007', '2014-03-14', 'triggerSyllThreshold', -6, 'edgeSyllThreshold', -8)

vectorClust

%%
show_file_with_labeled_syllables('4007', '2014-03-14', 1)