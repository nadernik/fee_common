function rootdir = getExperRootdir(exper)
%GETEXPERROOTDIR Gets the root directory for acquisitionGui exper
% Assumes that exper.dir is like rootdir/birdname/expername with the
% system-appropriate path delimeter (/ or \)

pattern = ['(.*)' filesep exper.birdname filesep exper.expername];
pattern = stresc(pattern);
tokens = regexp(exper.dir, pattern, 'tokens');
rootdir = tokens{1}{1};
