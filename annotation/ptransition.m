function [P, lookup] = ptransition(birdname, expername, varargin)
% Syllable transition matrix from processed annotation files

% P = ptransition(birdname, expername, ... )
% [P, lookup] = ptransition(birdname, expername, ... )

% row is first syllable, col is second syllable (matrix is not symmetric)
% lookup is an array that maps 
% Uses misc.segs.segType as syllable labels
% By default, ignores syllables with segType == -1 or 0

P.Ignore = [-1 0]; % syllable labels to ignore
P.MaxGap = 0.3; % seconds
P.Part = 1:1000;
P.Files = [];
P.RootDir = 'c:\stetner\data';
P = parseargs(P, varargin{:});

exper = loadExper(birdname, expername, P.RootDir);

% get syllable labels, file numbers, and absolute start and end times
filenum = [];
label   = [];
tstart  = [];
tend    = [];
for ii = 1:length(P.Part)
    miscfile = annofilename(birdname, expername, 'Type', 'misc', 'Part', P.Part(ii));
    if ~exist(miscfile, 'file')
        continue
    end
    load(miscfile)
    
    filenum = [filenum, ...
        cellfun(@extractDatafileNumber, ...
        repmat({exper}, length(misc.segs), 1), {misc.segs.key})];
    label   = [label,  [misc.segs.segType]];
    tnew = [misc.segs.absStart];
    tstart  = [tstart, tnew];
    tend    = [tend,   tnew + [misc.segs.duration]]; 
end


ok = true(size(label));
% selected files only
if ~isempty(P.Files)
    ok = ok & ismember(filenum, P.Files);
end
% throw out syllables on the ignore list
ok = ok & ~ismember(label, P.Ignore);

% apply selection
label  = label(ok);
tstart = tstart(ok);
tend   = tend(ok);

lookup = unique(label); % use this to map syllable labels to rows/cols of P
gap = tend(1:end-1) - tstart(2:end); 
P = zeros(length(lookup));
for row = 1:length(lookup) % pre syllable
    for col = 1:length(lookup) % post syllable
        % count all transitions between this pair
        trans = gap <= P.MaxGap & ...
            label(1:end-1) == lookup(row) & ...
            label(2:end)   == lookup(col);
        P(row, col) = sum(trans);
    end
end