function deglitch_all_pitch(birdname, expername, varargin)

P.rootdir = 'c:\stetner\data';
ftemplate = '%s_all_pitch_%s%s.mat';
P.bDebug = 0;
P = parseargs(P, varargin{:});

%find files
%for each file
filename = [P.rootdir filesep birdname filesep ...
    sprintf(ftemplate, birdname, expername, '')];
part = 1;
while exist(filename,'file')
    % load this file and add collect elements and keys
    load(filename)
    total_syllables = length(pitch.segs);
    for syllable = 1:total_syllables
        pitch.segs(syllable).pitch = deglitch(pitch.segs(syllable).pitch, 'bDebug',P.bDebug);
    end
    save(filename, 'pitch');
    clear pitch
    % make the next filename. keep going until file doesn't exist.
    part = part + 1;
    partstr = sprintf('-pt%03.g',part); %like -pt002
    filename = [P.rootdir filesep birdname filesep ...
    sprintf(ftemplate, birdname, expername, partstr)];
end