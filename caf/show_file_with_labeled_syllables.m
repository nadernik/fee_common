function labeledspecgram(varargin)
% Spectrogram with labeled syllables from processed annotation files
%
% USAGE:
%   labeledspecgram(exper, filenum)
%   labeledspecgram('birdname', 'expername', filenum)
%   labeledspecgram('birdname', 'expername', filenum, 'RootDir', 'c:\your\data\dir')
%
% Always plots the spectrogram in figure 3628. Calls displaySpecgramQuick()
% to plot the spectrogram.

%% Parameters
P.RootDir = 'c:\stetner\data';
P = parseargs(P, varargin{:});

%% Get exper and file number from arguments
switch nargin
    case 2
        exper = varargin{1};
        filenum = varargin{2};
    case 3
        exper = loadExper(varargin{1}, varargin{2}, P.rootdir);
        filenum = varargin{3};
    case 5
        P = parseargs(P, varargin{4:end});
        exper = loadExper(varargin{1}, varargin{2}, P.rootdir);
        filenum = varargin{3};
    otherwise
        error('wrong number of arugments')
end

%% Get syllable labels from processed annotation file
filename = getExperAudioFilename(exper, filenum); % file we are looking for

for part = 1:1000
    % look through annotations to find this file
    annofile = annofilename(exper.birdname, exper.expername, ...
        'Part', part, 'RootDir', P.RootDir, 'Type', 'annotation');
    if exist(annofile, 'file')
        hash = aaLoadHashtable(annofile);
        element = hash.get(filename);
        if ~isempty(element) % if we found this file
            break
        end
    end
end

%% Plot labels
figure(3628)
ax(1) = subplot(10,1,1); % height of spectrogram is 9x height of labels
cla
hold on
segtypes = unique(element.segType);
colors = get(gca,'ColorOrder');
chash = mhashtable;
cidx = mod(1:length(segtypes),size(colors,1)) + 1;
for n = 1:length(segtypes)
    chash.put(segtypes(n), colors(cidx(n),:));
end
for syll = 1:length(element.segType)
    x = [element.segFileStartTimes(syll) element.segFileEndTimes(syll) element.segFileEndTimes(syll) element.segFileStartTimes(syll)];
    y = [0 0 1 1];
    fill(x,y,chash.get(element.segType(syll)))
    text(element.segFileStartTimes(syll),0.5,num2str(element.segType(syll)))
end
axis off
hold off


%% Plot spectrogram
[audio, timeFileCreated, startTime, startSamp, names, values, info] = loadAudio(exper,filenum);

ax(2) = subplot(10,1,2:10); % height of spectrogram is 9x height of labels
displaySpecgramQuick(audio, info.fs)
linkaxes(ax,'x') % linking x axis makes zooming on spectrogram also adjust labels to match