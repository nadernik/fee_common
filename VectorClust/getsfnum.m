function num = getsfnum(vcdb, name)
% GETSFNUM gets number of scalar feature
%   num = getsfnum(vcdb, name)
%   Returns empty matrix if feature does not exist.

switch name
    case 'PrevClusterNum'
        num = -1;
    case 'NextClusterNum'
        num = -2;
    case 'PrevPrevClusterNum'
        num = -3;
    case 'NextNextClusterNum'
        num = -4;
    otherwise
        ndx = strcmp(vcdb.f.sfname, name);
        if sum(ndx) == 1
            num = find(ndx);
        else
            num = [];
        end
end