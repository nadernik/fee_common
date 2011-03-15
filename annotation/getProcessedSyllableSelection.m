function bSel = getProcessedSyllableSelection(dMisc, folder, varargin)

%To select syllables
P.targetSyll = [];
P.timeRanges = [];
P.selMode = {'none','randFrac'};
P.selParam = [];
P = parseargs(P, varargin{:});

if(isempty(P.timeRanges))
    P.timesRanges = {};
elseif(~iscell(P.timeRanges))
    P.timeRanges = {P.timeRanges};
end

%load the data
bSel = {};
for nFile = 1:length(dMisc)
    load([folder, dMisc(nFile).name]);
    absTime = [misc.segs.absStart];
    bndx = true(size(absTime));
    if(~isempty(P.targetSyll))
        bndx = ismember([misc.segs.segType],P.targetSyll);
    end
    if(~isempty(P.timeRanges))
        tempndx = false(size(absTime));
        for nRange = 1:length(P.timeRanges)
            tempndx = tempndx | absTime>=P.timeRanges{nRange}(1) & absTime<=P.timeRanges{nRange}(2);            
        end
        bndx = bndx & tempndx;
    end
    if(strcmpi(P.selMode,'randFrac'))
        bndx = bndx & rand(size(bndx))<P.selParam;
    end
    bSel{nFile} = logical(bndx);
end