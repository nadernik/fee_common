function vcdb = vcdbcluster(vcdb)
c = vcdb.c;
d = vcdb.d;
cn_old = vcdb.d.cn;
hasCluster = false(size(vcdb.d.cn));
for i = 1:10
    for nc = 1:length(c)
        
        %Find vectors in all polygons.
        if ~isempty(c(nc).polys)
            bIN = true(size(d.v)); % set all values to true
            for nPoly = 1:length(c(nc).polys) % all the polygons
                poly = c(nc).polys{nPoly};
                bIN = bIN & inpolygon(getsf(vcdb,poly.xfeat),getsf(vcdb,poly.yfeat), poly.xverts, poly.yverts);
            end
        else % no polygon
            bIN = false(size(d.v));
        end
        
        %Overide with manual modifications.
        for nInc = 1:length(c(nc).incs)
            bIN(c(nc).incs{nInc}) = true;
        end
        for nExc = 1:length(c(nc).excs)
            bIN(c(nc).excs{nExc}) = false;
        end
        
        %Set the cluster number
        vcdb.d.cn(bIN) = c(nc).number;
        hasCluster = hasCluster | bIN;
    end
    
    if all(vcdb.d.cn == cn_old)
        break % we have reached a stable classification
    end
    cn_old = vcdb.d.cn;
end
vcdb.d.cn(~hasCluster) = NaN;