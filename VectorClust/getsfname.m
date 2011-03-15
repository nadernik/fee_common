function name = getSFName(vcdb, nFeat)
if(nFeat == -1)
    name = 'PrevClusterNum';
elseif(nFeat == -2)
    name = 'NextClusterNum';
elseif(nFeat == -3)
    name = 'PrevPrevClusterNum';
elseif(nFeat == -4)
    name = 'NextNextClusterNum';
else
    name = vcdb.f.sfname{nFeat};
end