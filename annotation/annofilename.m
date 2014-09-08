function filename = annofilename(birdname, expername, varargin)
%ANNOFILENAME Name of annotation files
%
% Names of annotation files created by ANNOTATE_EXPER based on
% acquisitionGui exper.mat files.
%
% In general, the filename is:
% datadir/birdname/birdname_prefix_type_expername-pt###.mat
%
% Except:
% For type 'annotation', the prefix and type are omitted
% For part 1, the '-pt###' is omitted.
%
% Usage:
% filename = annofilename(birdname, expername)
% filename = annofilename( ... 'Part', p)
%   optionally specify part (default = 1)
% filename = annofilename( ... 'RootDir', pathtodata)
%   optionally specify path to data (default = c:\stetner\data)
% filename = annofilename( ... 'Type', typ)
%   optionally specify type (default = 'annotation'). By default,
%   ANNOTATE_EXPER makes files with types annotation, audio, misc, and
%   pitch.
% filename = annofilename( ... 'Prefix', pfx)
%   optionally specify prefix (default = 'all'). By default, ANNOTATE_EXPER
%   only uses prefix = 'all'.
%
% See also: ANNOTATE_EXPER

%% Parameters
P.Part = 1;
P.RootDir = 'c:\stetner\data\';
P.Type = 'annotation';
P.Prefix = 'all';
P = parseargs(P, varargin{:});

%% omit suffix if first part
if P.Part > 1
    suffix = num2str(P.Part, '-pt%03.f');
else
    suffix = '';
end

%% omit prefix if annotation
if strcmp(P.Type, 'annotation')
    prefix_and_type = P.Type;
else
    prefix_and_type = [P.Prefix '_' P.Type];
end

%%
filename = [P.RootDir filesep birdname filesep ...
    birdname '_' prefix_and_type '_' expername suffix '.mat'];