function [dFiles, folder] = getProcessedDataFiles(birdName, varargin)

%Default Parameters
P.experNames = []; %pass single or cell of experNames
P.prefix = 'all';
P.dataType = 'misc'; %or pitch or audio or cafProgram
P.rootdir = 'c:\aadata\AuditoryFeedback\';
P = parseargs(P, varargin{:});

if(isempty(P.experNames))
    dFiles = dir([P.rootdir, birdName, filesep, birdName, '_', P.prefix, '_', P.dataType, '_*.mat']);
else
    if(~iscell(P.experNames))
        P.experNames = {P.experNames};
    end
    dFiles = [];
    for nExper = 1:length(P.experNames)
        dFiles = [dFiles; dir([P.rootdir, birdName, filesep, birdName, '_', P.prefix, '_', P.dataType, '_', P.experNames{nExper}, '*.mat'])];
    end
end
folder = [P.rootdir, birdName, filesep];