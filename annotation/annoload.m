function anno = annoload(exper, varargin)
%ANNOLOAD load annotation created from acquisitionGui exper
%
%Usage:
% ANNO = ANNOLOAD(EXPER);
% ANNO = ANNOLOAD(EXPER, PT);
%
% ANNO is the annotation
%
% EXPER is an exper struct (typically created by acquisitionGui and stored
% in exper.mat inside the exper's directory).
%
% PT is the part of the annotation to load. If omitted, the first part is
% loaded.

if nargin > 1
    part = varargin{1};
else
    part = 1;
end

filename = annofilename(exper.birdname, exper.expername, ...
    'Type', 'annotation', ...
    'Part', part, ...
    'RootDir', getExperRootdir(exper));

anno = aaLoadHashtable(filename);