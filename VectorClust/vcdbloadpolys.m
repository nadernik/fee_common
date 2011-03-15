function vcdb = vcdbloadpolys(vcdb, polygon_file)

load(polygon_file)
if ~exist('c', 'var')
    error('Invalid polygon file.')
end

% Compute missing features
for ii = 1:length(c)
    for jj = 1:length(c(ii).polys)
        % X
        sfname = c(ii).polys{jj}.xfeatName;
        oldsfnum = c(ii).polys{jj}.xfeat;
        if ~any(strcmp(sfname, allsfnames(vcdb))) % if feature missing
            vcdb = feval(f.sffcn{oldsfnum}, vcdb, f.sfparam{oldsfnum}{:});
        end
        newsfnum = getsfnum(vcdb, sfname);
        c(ii).polys{jj}.xfeat = newsfnum;
        
        % Y
        sfname = c(ii).polys{jj}.yfeatName;
        oldsfnum = c(ii).polys{jj}.yfeat;
        if ~any(strcmp(sfname, allsfnames(vcdb))) % if feature missing
            vcdb = feval(f.sffcn{oldsfnum}, vcdb, f.sfparam{oldsfnum}{:});
        end
        newsfnum = getsfnum(vcdb, sfname);
        c(ii).polys{jj}.yfeat = newsfnum;
    end
end

vcdb.c = c;
vcdb = vcdbcluster(vcdb);