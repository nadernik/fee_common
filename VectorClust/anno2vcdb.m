function vcdb_all = anno2vcdb(birdname, expername, varargin)
% anno2vcdb converts processed annotation file to vectorClust format
%
% Usage:
%   vcdb = anno2vcdb(birdname, expername)
%   vcdb = anno2vcdb(birdname, expername, 'Parameter', value ...)
% 
% Parameter (default value)
%   Explanation
% 
% RootDir (c:\stetner\data)
%   Directory where data is. Looks for annotation files in birdname
%   subdirectory of RootDir.
% Audio (true)
%   Boolean controls whether audio is loaded into vcdb.d.v. Setting to
%   false saves time and memory.
% Part (1:1000)
%   If annotation is divided into multiple parts, you can convert only a
%   subset of those parts. Part must be an array of part numbers. Part
%   numbers in Part that do not exist are skipped silently. Default is to
%   use all parts.

P.RootDir = 'c:\stetner\data';
P.Audio = true;
P.Part = 1:1000;
P = parseargs(P, varargin{:});

exper = loadExper(birdname, expername, P.RootDir);

for part = P.Part
    miscfile = annofilename(birdname, expername, ...
        'Type', 'misc', ...
        'Part', part, ...
        'RootDir', P.RootDir);
    pitchfile = annofilename(birdname, expername, ...
        'Type', 'pitch', ...
        'Part', part, ...
        'RootDir', P.RootDir);
    if ~exist(miscfile, 'file') || ~exist(pitchfile, 'file')
        continue
    end
    load(miscfile)
    load(pitchfile)

    % audio
    if P.Audio
        audiofile = annofilename(birdname, expername, ...
            'Type', 'audio', ...
            'Part', part, ...
            'RootDir', P.RootDir);
        load(audiofile)
        vcdb.d.v = {rawaudio.segs.audio}';
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
%     vcdb.d.sf = nan(size(vcdb.d.v));
    
    vcdb.f.sfname{1}  = 'duration';
    vcdb.f.sffcn{1}   = mfilename;
    vcdb.f.sfparam{1} = varargin;
    vcdb.d.sf(:,1)    = [misc.segs.duration]';
    
    vcdb.f.sfname{2}  = 'imported cluster';
    vcdb.f.sffcn{2}   = mfilename;
    vcdb.f.sfparam{2} = varargin;
    vcdb.d.sf(:,2)    = [misc.segs.segType];
    
    vcdb.f.sfname{3} = 'file number';
    vcdb.f.sffcn{3} = mfilename;
    vcdb.f.sfparam{3} = varargin;
    vcdb.d.sf(:, 3) = extractDatafileNumber(exper, {misc.segs.key});
    
    % Other stuff
    vcdb.d.i = repmat({[]}, size(vcdb.d.v)); %FIXME
    vcdb.d.icn = [misc.segs.segType]'; %column vector
    vcdb.d.t = [misc.segs.absStart]'; %column vector
    vcdb.d.cn = nan(size(vcdb.d.v));
    vcdb.c = [];
    [pathname, filename, ext] = fileparts(miscfile);
    vcdb.fileName = pathname;
    vcdb.pathName = filename;

    % merge with other parts
    if exist('vcdb_all', 'var')
        vcdb_all = vcdbmerge(vcdb_all, vcdb);
    else
        vcdb_all = vcdb;
    end
    clear vcdb
end
vcdb_all.f.sfname = vcdb_all.f.sfname';
vcdb_all.f.vfname = vcdb_all.f.vfname';