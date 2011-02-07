%% 2011-02-04
annotate_exper('2055','2011-02-03','filenum',1300:1653,'maxFilesPerAnnotation',500)

%% 2011-02-05
annotate_exper('2055','2011-02-04','filenum',800:1105,'maxFilesPerAnnotation',500)

%% 2011-02-07
annotate_exper('2055','2011-02-06','maxFilesPerAnnotation',400)

% clustered with polygons20110207.mat, with some manual modifications to
% remove syllables with glitchy pitch estimates. This actually was a lot of
% syllables. Maybe will be a problem

% cluster 1 - long syllable that is easy to find
%       2 - target, long version
%       3 - target, short version
% sometimes target is attached to next sylable, sometimes no.

% Made CAF filters
% syllable 3, 25-30%, mean = 651, median = 654 Hz, sd = 20 Hz