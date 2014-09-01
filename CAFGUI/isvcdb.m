function y = isvcdb(vcdb)
%ISVCDB True for valid vcdb data structure (produced by vectorClust)
try
    y = true;
    
    % check for presence of fields
    yand(isfield(vcdb, 'f'), 'Missing field vcdb.f')
    yand(isfield(vcdb, 'd'), 'Missing field vcdb.d')
    yand(isfield(vcdb.d, 'v'),   'Missing field vcdb.d.v')
    yand(isfield(vcdb.d, 'cn'),  'Missing field vcdb.d.cn')
    yand(isfield(vcdb.d, 't'),   'Missing field vcdb.d.t')
    yand(isfield(vcdb.d, 'i'),   'Missing field vcdb.d.i')
    yand(isfield(vcdb.d, 'icn'), 'Missing field vcdb.d.icn')
    yand(isfield(vcdb.d, 'vf'),  'Missing field vcdb.d.vf')
    yand(isfield(vcdb.d, 'sf'),  'Missing field vcdb.d.sf')
    yand(isfield(vcdb.f, 'vfname'),  'Missing field vcdb.f.vfname')
    yand(isfield(vcdb.f, 'vffcn'),   'Missing field vcdb.f.vffcn')
    yand(isfield(vcdb.f, 'vfparam'), 'Missing field vcdb.f.vfparam')
    yand(isfield(vcdb.f, 'sfname'),  'Missing field vcdb.f.sfname')
    yand(isfield(vcdb.f, 'sffcn'),   'Missing field vcdb.f.sffcn')
    yand(isfield(vcdb.f, 'sfparam'), 'Missing field vcdb.f.sfparam')
    
    % consistent number of syllables
    nsyll = size(vcdb.d.v, 1);
    yand(size(vcdb.d.cn, 1)  == nsyll, 'Inconsistent number of syllables in vcdb.d.cn')
    yand(size(vcdb.d.t, 1)   == nsyll, 'Inconsistent number of syllables in vcdb.d.t')
    yand(size(vcdb.d.i, 1)   == nsyll, 'Inconsistent number of syllables in vcdb.d.i')
    yand(size(vcdb.d.icn, 1) == nsyll, 'Inconsistent number of syllables in vcdb.d.icn')
    yand(size(vcdb.d.sf, 1)  == nsyll, 'Inconsistent number of syllables in vcdb.d.sf')
    for ii = 1:length(vcdb.d.vf)
        yand(size(vcdb.d.vf{ii}, 1) == nsyll, 'Inconsistent number of syllables in vcdb.d.vf')
    end
    
    % consistent number of scalar features
    nsf = size(vcdb.f.sfname, 1);
    yand(size(vcdb.d.sf, 2)      == nsf, 'Inconsistent number of scalar features in vcdb.d.sf')
    yand(size(vcdb.f.sffcn, 2)   == nsf, 'Inconsistent number of scalar features in vcdb.f.sffcn')
    yand(size(vcdb.f.sfparam, 2) == nsf, 'Inconsistent number of scalar features in vcdb.f.sfparam')
    
    % consistent number of vector features
    nvf = size(vcdb.f.vfname, 2);
    yand(size(vcdb.d.vf, 1)      == nvf, 'Inconsistent number of vector features in vcdb.d.vf')
    yand(size(vcdb.f.vffcn, 1)   == nvf, 'Inconsistent number of vector features in vcdb.f.vffcn')
    yand(size(vcdb.f.vfparam, 1) == nvf, 'Inconsistent number of vector features in vcdb.f.vfparam')
    
    % make sure things are vectors
    yand(isvector(vcdb.d.v),   'Not a vector: vcdb.d.v')
    yand(isvector(vcdb.d.cn),  'Not a vector: vcdb.d.cn')
    yand(isvector(vcdb.d.t),   'Not a vector: vcdb.d.t')
    yand(isvector(vcdb.d.i),   'Not a vector: vcdb.d.i')
    yand(isvector(vcdb.d.icn), 'Not a vector: vcdb.d.icn')
    yand(isvector(vcdb.d.vf),  'Not a vector: vcdb.d.vf')
    yand(isvector(vcdb.f.vfname),  'Not a vector: vcdb.f.vfname')
    yand(isvector(vcdb.f.vffcn),   'Not a vector: vcdb.f.vffcn')
    yand(isvector(vcdb.f.vfparam), 'Not a vector: vcdb.f.vfparam')
    yand(isvector(vcdb.f.sfname),  'Not a vector: vcdb.f.sfname')
    yand(isvector(vcdb.f.sffcn),   'Not a vector: vcdb.f.sffcn')
    yand(isvector(vcdb.f.sfparam), 'Not a vector: vcdb.f.sfparam')
    
catch
    keyboard
    y = false;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function yand(tf, msg)
        if ~tf
            warning(msg)
        end
        y = y && tf;
    end
end
