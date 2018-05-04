function exper = loadExper(birdname, expername, rootdir, fixdir)
% LOADEXPER loads acquisitionGui exper file
%
% Usage:
%   exper = loadExper('birdname', 'expername')
%       returns exper struct saved in .\birdname\expername\exper.mat
%   exper = loadExper('birdname', 'expername', 'c:\path\to\data\')
%       returns exper struct saved in c:\path\to\data\birdname\expername\exper.mat
%   exper = loadExper('birdname', 'expername', 'c:\path\to\data\', 1)
%       same as above, but also changes exper.dir to the directory containing
%       exper.mat (c:\path\to\data\birdname\expername\). This is useful if the
%       exper is not the same folder it was in at the time of recording.

if(nargin < 3)
    rootdir = pwd;
end

load(fullfile(rootdir, birdname, expername, 'exper.mat'));

if nargin >= 4 && fixdir
    exper.dir = fullfile(rootdir, birdname, expername);
    if isfield(exper, 'rootdir')
        exper.rootdir = rootdir;
    end
    if isfield(exper, 'birddir')
        exper.birddir = fullfile(rootdir, birdname);
    end
end
