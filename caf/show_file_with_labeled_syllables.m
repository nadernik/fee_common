function show_file_with_labeled_syllables(varargin)
% show_file_with_labeled_syllables(exper, filenum)
% show_file_with_labeled_syllables('birdname', 'expername', filenum)
% show_file_with_labeled_syllables('birdname', 'expername', filenum, 'rootdir', 'c:\your\data\dir')

P.rootdir = 'c:\stetner\data\';

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

% get the audio to make spectrogram
[audio, timeFileCreated, startTime, startSamp, names, values, info] = loadAudio(exper,filenum);
% get syllable labels from this file only (based on start and end time of
% file)
filename = getExperAudioFilename(exper, filenum);
anno_files = dir([P.rootdir filesep exper.birdname filesep exper.birdname '_annotation_' exper.expername '*']);
for n = 1:length(anno_files)
    % look through annotations to find this file
    hash = aaLoadHashtable(anno_files(n).name);
    element = hash.get(filename);
    if ~isempty(element)
        break
    end
end    

% make unique color for each segType (up to 


% plot results
figure(3628)
ax(1) = subplot(10,1,1);
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
ax(2) = subplot(10,1,2:10);
displaySpecgramQuick(audio, info.fs)
linkaxes(ax,'x')