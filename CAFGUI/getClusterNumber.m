function clust = getClusterNumber(nf,elements,keys,misc)
key = keys{nf};
element = elements{nf};
totalSyllables = length(element.segFileStartTimes);
% initialize
clust = nan(totalSyllables,1);
s = 0;

for n = 1:length(misc.segs)
    % if this syllable is in the file, record its cluster number and start time
    if strcmp(misc.segs(n).key, key)
        s = s+1;
        clust(s) = misc.segs(n).segType;
        t(s) = misc.segs(n).fStartTime;
    end
    if s == totalSyllables
        % if we have all syllables in this file, just stop now (for speed)
        break
    end
end
% make sure syllables are in order by time
if s > 0
[junk, idx] = sort(t);
clust = clust(idx);
end