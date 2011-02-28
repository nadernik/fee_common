function vcdb_all = annotation2vcdb(birdname, expername, varargin)
P.rootdir = 'c:\stetner\data';
P.audio = true;
P.part = 1:1000;
P = parseargs(P, varargin{:});

for part = P.part
    miscfile = get_annotation_filename(birdname, expername, ...
        'type', 'misc', ...
        'part', part, ...
        'rootdir', P.rootdir);
    pitchfile = get_annotation_filename(birdname, expername, ...
        'type', 'pitch', ...
        'part', part, ...
        'rootdir', P.rootdir);
    if ~exist(miscfile, 'file') || ~exist(pitchfile, 'file')
        continue
    end
    load(miscfile)
    load(pitchfile)

    % audio
    if P.audio
        audiofile = get_annotation_filename(birdname, expername, ...
            'type', 'audio', ...
            'part', part, ...
            'rootdir', P.rootdir);
        load(audiofile)
        vcdb.d.v = {rawaudio.segs.audio};
    else
        vcdb.d.v = repmat({[]},length(misc.segs),1);
    end
    
    % vector features
    vcdb.f.vfname{1,1}  = 'pitch';
    vcdb.f.vffcn{1,1}   = mfilename;
    vcdb.f.vfparam{1,1} = varargin;
    vcdb.d.vf{1,1}    = {pitch.segs.pitch}';

    vcdb.f.vfname{2,1}  = 'pitchGoodness';
    vcdb.f.vffcn{2,1}   = mfilename;
    vcdb.f.vfparam{2,1} = varargin;
    vcdb.d.vf{2,1}    = {pitch.segs.pitchGoodness}';
    
    vcdb.f.vfname{3,1}  = 'harmonicPower';
    vcdb.f.vffcn{3,1}   = mfilename;
    vcdb.f.vfparam{3,1} = varargin;
    vcdb.d.vf{3,1}    = {pitch.segs.harmonicPower}';
    
    vcdb.f.vfname{4}  = 'pitchTime';
    vcdb.f.vffcn{4}   = mfilename;
    vcdb.f.vfparam{4} = varargin;
    vcdb.d.vf{4}    = {pitch.segs.pitchTime}';
    
    vcdb.f.vfname{5}  = 'entropy';
    vcdb.f.vffcn{5}   = mfilename;
    vcdb.f.vfparam{5} = varargin;
    vcdb.d.vf{5}    = {pitch.segs.entropy}';
        
    % scalar features
    vcdb.d.sf = nan(size(vcdb.d.v));
    
    vcdb.f.sfname{1}  = 'duration';
    vcdb.f.sffcn{1}   = mfilename;
    vcdb.f.sfparam{1} = varargin;
    vcdb.d.sf(:,1)    = [misc.segs.duration];
    
    vcdb.f.sfname{2}  = 'imported cluster';
    vcdb.f.sffcn{2}   = mfilename;
    vcdb.f.sfparam{2} = varargin;
    vcdb.d.sf(:,2)    = [misc.segs.segType];
    
    % Other stuff
    vcdb.d.i = repmat({[]}, size(vcdb.d.v)); %FIXME
    vcdb.d.icn = [misc.segs.segType]'; %column vector
    vcdb.d.t = [misc.segs.absStart]'; %column vector
    vcdb.d.cn = nan(size(vcdb.d.v));
    vcdb.c = [];
    [pathname, filename, ext, versn] = fileparts(miscfile);
    vcdb.fileName = pathname;
    vcdb.pathName = filename;

    % merge with other parts
    if exist('vcdb_all', 'var')
        vcdb_all = merge_vcdb(vcdb_all, vcdb);
    else
        vcdb_all = vcdb;
    end
end