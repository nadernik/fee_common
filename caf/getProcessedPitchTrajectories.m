function [pitchTraj, absTime, syllType, dura] = getProcessedPitchTrajectories(birdName, varargin)

%Default Parameters
%To get files
P.experNames = []; %pass single or cell of experNames
P.prefix = 'all';
P.rootdir = 'c:\aadata\AuditoryFeedback\';
%To select syllables
P.targetSyll = [];
P.timeRanges = [];
P.selMode = {'none','randFrac'};
P.selParam = [];
%Other
P.targetRegion = [];
P = parseargs(P, varargin{:});


[dMisc, folder] = getProcessedDataFiles(birdName, 'dataType', 'misc', 'experNames', P.experNames, 'prefix', P.prefix, 'rootdir', P.rootdir);
dPitch = getProcessedDataFiles(birdName, 'dataType', 'pitch', 'experNames', P.experNames, 'prefix', P.prefix, 'rootdir', P.rootdir);
bSel = getProcessedSyllableSelection(dMisc, folder, 'targetSyll', P.targetSyll, 'timeRanges', P.timeRanges, 'selMode', P.selMode, 'selParam', P.selParam);
numSylls = sum(cellfun(@sum, bSel));

%load the data
pitchTraj = cell(numSylls,1);
absTime = nan(numSylls,1);
syllType = nan(numSylls,1);
dura = nan(numSylls,1);
currNdx = 0;
for nFile = 1:length(dMisc)
    if(sum(bSel{nFile})>0)       
        load([folder, dMisc(nFile).name]);
        load([folder, dPitch(nFile).name]);
        absTime(currNdx+1:currNdx+sum(bSel{nFile})) = [misc.segs(bSel{nFile}).absStart];
        syllType(currNdx+1:currNdx+sum(bSel{nFile})) = [misc.segs(bSel{nFile}).segType];
        dura(currNdx+1:currNdx+sum(bSel{nFile})) = [misc.segs(bSel{nFile}).duration];
        pitchTraj(currNdx+1:currNdx+sum(bSel{nFile})) = {pitch.segs(bSel{nFile}).pitch};
        currNdx = currNdx + sum(bSel{nFile});
    end
end

%sort the data
[absTime, sndx] = sort(absTime);
syllType = syllType(sndx);
dura = dura(sndx);
pitchTraj = pitchTraj(sndx);

%extract the targetRegion
if(~isempty(P.targetRegion))    
    pitchTraj = cellfun(@extractFragment, pitchTraj, repmat({P.targetRegion},length(pitchTraj),1), 'UniformOutput', false);
end

function ts = extractFragment(ts, syllFragment)
if(isempty(ts))
    return;
end
ndxStart = ceil((length(ts)-1) * syllFragment(1)) + 1;
ndxEnd = floor((length(ts)-1) * syllFragment(2)) + 1;
ts = ts(ndxStart:ndxEnd);