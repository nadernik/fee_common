%% 2237
% Received this bird from Liora on _____
% She had been using him as a control for something. She isolated him at a
% young age and just monitored his development. Now I will try to do CAF on
% him and maybe Liora will lesion RAcup to see if it affects CAF-driven
% learning.

%% 2011-05-03
annotate_exper('2237', '2011-05-03', 'edgeSyllThreshold', -9.5, 'triggerSyllThreshold', -7, 'filenum', 250:386)

vectorClust
% polygons20110503.mat
% 1 = escapes
% 2 = short stack that always comes before target syllable

labeledspecgram('2237', '2011-05-03', 250)
% Some misses, but didn't see any false positives. This is what I want.

rules
% Loaded after file 587. Pushing 1474+