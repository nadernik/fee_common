function num = getvfnum(vcdb, name)

ndx = strcmp(allvfnames(vcdb), name);
if sum(ndx) == 1
    num = find(ndx);
else
    num = [];
end