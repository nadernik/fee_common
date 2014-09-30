function vcdb = vcdbslice(vcdb, ndx)
%VCDBSLICE Reorder or get subset of segments in vcdb (vectorClust database)
%
%Usage:
%  VCDB = VCDBSLICE(VCDB, NDX)
%
% VCDB is a vectorClust database (typically created by vectorClust or
% anno2vcdb). You can verify that a variable is a vcdb using the function
% ISVCDB.
%
% NDX is the indices of the segments to keep. It can be a logical array
% with length equal to the number of segments in vcdb, or it can be a list
% of indices.

vcdb.d.v   = vcdb.d.v(  ndx, 1);
vcdb.d.cn  = vcdb.d.cn( ndx, 1);
vcdb.d.t   = vcdb.d.t(  ndx, 1);
vcdb.d.i   = vcdb.d.i(  ndx, 1);
vcdb.d.icn = vcdb.d.icn(ndx, 1);
vcdb.d.sf  = vcdb.d.sf( ndx, :);

for ii = 1:length(vcdb.d.vf)
    vcdb.d.vf{ii} = vcdb.d.vf{ii}(ndx);
end
