function names = getAllSFNames(vcdb)
names = [vcdb.f.sfname; {'PrevClusterNum'}; {'NextClusterNum'}; {'PrevPrevClusterNum'}; {'NextNextClusterNum'}];
