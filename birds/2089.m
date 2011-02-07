%% 2011-02-04
annotate_exper('2089','2011-02-03','maxFilesPerAnnotation',500)

% clustered in vectorClust, using polygons.mat. No other modifications.

% tested rules_matlab.mat from 2011-02-01 on files 340-364 from 2011-02-03.
% found that 43% of cluster 1 would be hit (N=60). Looks like pitch
% actually matters. Lower pitches are hit and higher pitches escape. Yay.

% Since filters seem good, turned on CAF at 12:52pm before any files were
% sung

%% 2011-02-07
annotate_exper('2089','2011-02-06','maxFilesPerAnnotation',500)

% Seems like no noise on 2011-02-06. Is CAF running? No. Speaker is not
% plugged into TDT. Will verify that filters are still good and then start
% it.

deglitch_all_pitch('2089', '2011-02-06')
vcQuickCluster('2089', '2011-02-06', 'polygons.mat', [], 'root', 'c:\stetner\data')

% Still good. Tested on files 908-923 of 2011-02-06 and hits 43% of target
% syllable (N=44) with good pitch discrimination. Sometimes also hits the
% very end of another syllable, but I think it will be okay.

% Rules loaded after file 431