function exper = loadExper(birdname, expername, rootdir)
% LOADEXPER loads acquisitionGui exper file
%
% Usage:
%   exper = loadExper('birdname', 'expername')
%   exper = loadExper('birdname', 'expername', 'c:\path\to\data\')
% 
% If the path to data is omitted, the current directory is used.
% Loads the file path\to\data\birdname\expername\exper.mat

if(~exist('rootdir'))
    rootdir = pwd;
end

load([rootdir,'\',birdname,'\',expername,'\','exper.mat']);    