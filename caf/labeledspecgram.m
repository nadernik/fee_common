function labeledspecgram(varargin)
% Spectrogram with labeled syllables from processed annotation files
%
% USAGE:
%   labeledspecgram(exper)
%   labeledspecgram(exper, filenum)
%   labeledspecgram('birdname', 'expername')
%   labeledspecgram('birdname', 'expername', filenum)
%   labeledspecgram( ..., 'RootDir', 'c:\your\data\dir')
%
% When in the figure, you can push these keys to navigate:
%     leftarrow   previous file
%     rightarrow  next file
%     uparrow     10 files back
%     downarrow   10 files forward
%     pageup      50 files back
%     pagedown    50 files forward
%     home        first file
%     end         last file
%
% Always plots the spectrogram in figure 3628. Calls displaySpecgramQuick()
% to plot the spectrogram.

%% Default parameters
P.RootDir = 'c:\stetner\data';

%% Parse arguments

% (Bird name and exper name) or (exper struct)
if ischar(varargin{1})
    birdname = varargin{1};
    expername = varargin{2};
    nextarg = 3;
elseif isstruct(varargin{1})
    exper = varargin{1};
    nextarg = 2;
else
    error('First input must be a bird name or an exper struct.')
end

% filenum, if given 
if nextarg <= length(varargin) && isnumeric(varargin{nextarg})
    filenum = varargin{nextarg};
    nextarg = nextarg + 1;
else
    filenum = 1;
end

% parameters
P = parseargs(P, varargin{nextarg:end});

% load exper if it wasn't an argument
if ~exist('exper', 'var')
    exper = loadExper(birdname, expername, P.RootDir);
end

% If not in the root dir, remap
try
    L = length(P.RootDir);
    if ~strcmpi(P.RootDir, exper.dir(1:L))
        exper.dir = [fullfile(P.RootDir, birdname, expername) filesep];
    end
catch
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
fh = figure(3628);
ax(1) = subplot(10,1,1); % height of spectrogram is 9x height of labels
cla
hold on
if ~isempty(element)
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
end
hold off
title(sprintf('%s %s file %g', exper.birdname, exper.expername, filenum))

%% Plot spectrogram
[audio, timeFileCreated, startTime, startSamp, names, values, info] = loadAudio(exper,filenum);

ax(2) = subplot(10,1,2:10); % height of spectrogram is 9x height of labels
displaySpecgramQuick(audio, info.fs)
linkaxes(ax,'x') % linking x axis makes zooming on spectrogram also adjust labels to match

ud.exper = exper;
ud.filenum = filenum;
ud.rootdir = P.RootDir;
set(fh, 'UserData', ud)
set(fh, 'KeyPressFcn', @nextjprevk)

%% Callback
function nextjprevk(src,evnt)
% Push j to see next file. Push k to see previous file.
ud = get(src, 'UserData');
switch evnt.Key
    case 'j'
        filenum = ud.filenum + 1;
    case 'rightarrow'
        filenum = ud.filenum + 1;
    case 'k'
        filenum = ud.filenum - 1;
    case 'leftarrow'
        filenum = ud.filenum - 1;
    case 'uparrow'
        filenum = ud.filenum - 10;
    case 'downarrow'
        filenum = ud.filenum + 10;
    case 'pageup'
        filenum = ud.filenum - 50;
    case 'pagedown'
        filenum = ud.filenum + 50;
    case 'home'
        filenum = 1;
    case 'end'
        filenum = Inf;
end
filenum = max(1, filenum);
filenum = min(filenum, getLatestDatafileNumber(ud.exper));

labeledspecgram(ud.exper, filenum, 'RootDir', ud.rootdir);   