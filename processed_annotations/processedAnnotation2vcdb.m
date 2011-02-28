function vcdb_all = processedAnnotation2vcdb(birdname, expername, varargin)
P.rootdir = 'c:\stetner\data';
P.load_audio = false;
P.part = 1:1000;
P = parseargs(P, varargin{:});

for part = P.part
    miscfile = get_annotation_filename(birdname, expername, ...
        'type', 'misc', ...
        'part', part, ...
        'rootdir', P.rootdir);
    if ~exist(miscfile, 'file')
        continue
    end

    %load data.
    searchString = strrep(miscfile, '_misc_', '_*_');
    [v, sf, vf, icn, t, i, sfname, vfname] = vc_imp_ProcessedAnnotationFiles('batch', searchString, false, false, false);

    %add basic features to the scalar feature list.
    sf(:,end+1) = cellfun(@length,v);
    sfname{end+1} = 'length';
    sf(:,end+1) = t;
    sfname{end+1} = 'time';
    sf(:,end+1) = (t - floor(t))*24;
    sfname{end+1} = 'hourOfDay';
    sf(:,end+1) = icn;
    sfname{end+1} = 'imported cluster';

    %Construct data struction
    [pathname, filename, ext, versn] = fileparts(miscfile);
    vcdb.fileName = pathname;
    vcdb.pathName = filename;
    if P.load_audio
        vcdb.d.v = v;
    else
        vcdb.d.v = repmat({[]},length(v),1);
    end
    vcdb.d.sf = sf;
    vcdb.d.vf = vf;
    vcdb.d.cn = nan(length(v),1);
    vcdb.d.icn = icn;
    vcdb.d.t = t;
    vcdb.d.i = i;
    vcdb.f.sfname = sfname;
    vcdb.f.sffcn = repmat({func2str(@vc_imp_ProcessedAnnotationFiles)}, length(sfname), 1);
    vcdb.f.sfparam = cell(length(sfname),1);
    vcdb.f.vfname = vfname;
    vcdb.f.vffcn = repmat({func2str(@vc_imp_ProcessedAnnotationFiles)}, length(vfname), 1);
    vcdb.f.vfparam = cell(length(vfname),1);
    vcdb.c = [];

    if exist('vcdb_all', 'var')
        vcdb_all = merge_vcdb(vcdb_all, vcdb);
    else
        vcdb_all = vcdb;
    end
end