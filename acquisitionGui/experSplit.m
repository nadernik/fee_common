function newexpers = experSplit(oldexper, newnames, filenums)
%EXPERSPLIT splits exper by file number
% Creates new expers with the provided names and moves and renumbers the
% datafiles into the new exper directories. Returns a struct array of
% expers. Each new exper is also saved as exper.mat in the appropriate
% directory.
% 
% Usage: 
%   newexpers = experSplit(oldexper, newnames, filenums)
%
%   newexpers is a struct array of the newly split expers
%
%   oldexper is the original exper to split
%   
%   newnames is a cell array of names for the new expers
%
%   filenums is a cell array of file numbers in oldexper. Each cell
%   contains a list of the file numbers to be put into the corresponding
%   new exper. The length of newnames and filenums must match.
%
% Example: 
% % You left acquisitionGui open on Friday (2014-09-26) and it recorded all
% % weekend. You want to split the data from Saturday and Sunday into their
% % own expers.
% exper = loadExper('mybird', '2014-09-26');
% experSplit(exper, {'2014-09-27', '2014-09-28'}, {1479:2194, 2195:3428})
% 
%  

%% Check arguments
assert(isexper(oldexper), 'oldexper must be an exper')
assert(iscellstr(newnames), 'newnames must be a cell array of strings')
assert(iscell(filenums), 'filenums must be a cell array')
assert(length(newnames) == length(filenums), ...
    'number of new expernames and new filenums must match')
assert(~any(ismember(lower(oldexper.expername), lower(newnames))), ...
    'None of the new expers can have the same name as the old one')

numnew = length(newnames);
rootdir = getExperRootdir(oldexper);
birdname = oldexper.birdname;

% Append something like this to the exper description: 'Split from
% expername into expers named (newname1, newname2, newname3) by
% experSplit()'
newnamesummary = strjoin(newnames, ', ');
experdesc = sprintf(...
    'Split from %s into expers named (%s) by experSplit()', ....
    oldexper.expername, newnamesummary);
if ~isempty(oldexper.experdesc)
    experdesc = [oldexper.experdesc ' ' experdesc];
end

%% Initialize new expers
newexpers = repmat(oldexper, numnew, 1);
for n = 1:numnew
    newexpers(n).dir = [fullfile(rootdir, birdname, newnames{n}) filesep];
    newexpers(n).expername = newnames{n};
    newexpers(n).experdesc = experdesc;
    
    % Check to make sure this exper does not already exist
    if exist(fullfile(newexpers(n).dir, 'exper.mat'), 'file')
        error('FeeLab:acquisitionGui:experSplit:experExists', ...
            'Cannot create new exper %s because it already exists', ...
            newnames{n})
    end
end

%% Move files
getNewFilename = @(oldname, n) regexprep(oldname, '_d\d{6}_', sprintf('_d%06.f_', n));
for ne = 1:numnew
    mkdir(newexpers(ne).dir)
    chans = [newexpers(ne).audioCh, newexpers(ne).sigCh];
    for nf = 1:length(filenums{ne})
        for ch = chans
            oldFilename = getExperDatafile(oldexper, filenums{ne}(nf), ch);
            newFilename = getNewFilename(oldFilename, nf);
            oldFilenameFull = fullfile(     oldexper.dir, oldFilename);
            newFilenameFull = fullfile(newexpers(ne).dir, newFilename);
            movefile(oldFilenameFull, newFilenameFull)
        end
    end
    exper = newexpers(ne);
    experfilename = fullfile(exper.dir, 'exper.mat');
    save(experfilename, 'exper')
    clear exper
end
