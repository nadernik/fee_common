function featNum = mapFeatureName2Number(featNames, importName, importNum)
% Maps an imported feature to a current feature.
switch importName
    case 'PrevClusterNum'
        featNum = -1;
    case 'NextClusterNum'
        featNum = -2;
    case 'PrevPrevClusterNum'
        featNum = -3;
    case 'NextNextClusterNum'
        featNum = -4;
    otherwise
        bMatch = cellfun(@strcmp, featNames, repmat({importName},size(featNames)));
        if sum(bMatch) == 1
            featNum = find(bMatch);
        else
            featNum = [];
        end
end