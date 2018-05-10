function varargout = Parse_segments(varargin)
% PARSE_SEGMENTS M-file for Parse_segments.fig
%      PARSE_SEGMENTS, by itself, creates a new PARSE_SEGMENTS or raises the existing
%      singleton*.
%
%      H = PARSE_SEGMENTS returns the handle to a new PARSE_SEGMENTS or the handle to
%      the existing singleton*.
%
%      PARSE_SEGMENTS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PARSE_SEGMENTS.M with the given input arguments.
%
%      PARSE_SEGMENTS('Property','Value',...) creates a new PARSE_SEGMENTS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Parse_segments_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Parse_segments_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Parse_segments

% Last Modified by GUIDE v2.5 09-Jun-2009 15:23:29

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Parse_segments_OpeningFcn, ...
                   'gui_OutputFcn',  @Parse_segments_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT
end


% --- Executes just before Parse_segments is made visible.
function Parse_segments_OpeningFcn(hObject, ~, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Parse_segments (see VARARGIN)

% Choose default command line output for Parse_segments
handles.output = hObject;

[filename, pathname] = uigetfile('*.mat', 'Pick an analysis file');
if ~ischar(filename)
    return
end
handles.filename = filename;
handles.pathname = pathname;

load([pathname, filename], 'dbase');
handles.dbase = dbase;

handles.symbols = [97:122 48:57 65:90];
handles.currentletter = [];

handles.clim = [17 24]; % changed from [15 20] TO
handles.volume = 0.5; % changed from 5 TO

handles.colormap = colormap;
handles.colormap(1,:) = [0 0 0];

handles = load_file(handles);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Parse_segments wait for user response (see UIRESUME)
% uiwait(handles.main_fig);
end

function handles = load_file(handles)

fnum = handles.dbase.AnalysisState.CurrentFile;
handles.currentletter = [];

try
    loader_func = str2func(['egl_', handles.dbase.SoundLoader]);
    sound_path = fullfile(handles.dbase.PathName, handles.dbase.SoundFiles(fnum).name);
    [handles.snd, handles.fs, ~, ~, ~] = loader_func(sound_path, 1);
catch
    handles.snd = zeros(1000,1);
    handles.fs = 40000;
end

subplot(handles.axes_Sonogram);
cla
xlim([0 length(handles.snd)/handles.fs]);
ylim([0 10000])
AA_quick_sonogram(gca,handles.snd,handles.fs);
set(gca,'ydir','normal')
axis off
colormap(handles.colormap);

title(['File ' num2str(fnum) ' of ' num2str(length(handles.dbase.Times)) ' : ' handles.dbase.SoundFiles(fnum).name ' at ' datestr(handles.dbase.Times(fnum))])

subplot(handles.axes_Segments)
cla
if isempty(handles.dbase.SegmentTimes{fnum})
    xs = [];
    ys = [];
else
    xs = [handles.dbase.SegmentTimes{fnum}(:,1)'; handles.dbase.SegmentTimes{fnum}(:,2)'; handles.dbase.SegmentTimes{fnum}(:,2)'; handles.dbase.SegmentTimes{fnum}(:,1)'; handles.dbase.SegmentTimes{fnum}(:,1)']/handles.dbase.Fs;
    ys = repmat([0; 0; 1; 1; 0],1,size(handles.dbase.SegmentTimes{fnum},1));
end
handles.lines = line(xs,ys);
set(handles.lines,'linewidth',2);
xlim(get(handles.axes_Sonogram,'xlim'));
ylim([-1 3]);
axis off

handles = color_lines(handles);
hold on
for c = 1:length(handles.lines)
    if c <= length(handles.symbols)
        text((xs(1,c)+xs(2,c))/2,2,char(handles.symbols(c)),'horizontalalignment','center');
    end
end
end

function handles = color_lines(handles)

set(handles.lines,'color',[0.6 0.6 0.6]);
fnum = handles.dbase.AnalysisState.CurrentFile;
sel_mask = handles.dbase.SegmentIsSelected{fnum}==1;
set(handles.lines(sel_mask),'color',[1 0 0]);
if ~isempty(handles.currentletter)
    sel_mask = find(handles.symbols==handles.currentletter);
    if sel_mask <= length(handles.lines)
        set(handles.lines(sel_mask),'color',[1 1 0]);
    end
end

set(handles.axes_Sonogram,'clim',handles.clim);
end

function AA_quick_sonogram(ax,wv,fs)
% ElectroGui spectrum algorithm
% Aaron Andalman's algorithm that accounts for screen resolution

bck = get(ax,'units');

NFFT = 512;
nCourse = 1;
windowSize = 512;
freqRange = get(ax,'ylim');

%determine size of axis relative to size of the signal,
%use this to adapt the window overlap and downsampling of the signal.
%no need to worry about size of fftwindow, this doesn't effect speed.
set(ax,'Units','pixels');
pixSize = get(ax,'Position');
numPixels = pixSize(3) / nCourse;
numWindows = length(wv) / windowSize;
if(numWindows < numPixels)
    %If we have more pixels than ffts, then increase the overlap
    %of fft windows accordingly.
    ratio = ceil(numPixels/numWindows);
    windowOverlap = min(.999, 1 - (1/ratio));
    windowOverlap = floor(windowOverlap*windowSize);
else
    %If we have more ffts then pixels, then we can do things, we can
    %downsample the signal, or we can skip signal between ffts.
    %Skipping signal mean we may miss bits of song altogether.
    %Decimating throws away high frequency information.
    ratio = floor(numWindows/numPixels);
    %windowOverlap = -1*ratio;
    %windowOverlap = floor(windowOverlap*windowSize);
    windowOverlap = 0;
    wv = decimate(wv, ratio);
    fs = fs / ratio;
end

%Compute the spectrogram
%[S,F,T,P] = spectrogram(sss,windowSize,windowOverlap,NFFT,Fs);
[S,F,~] = specgram(wv, NFFT, fs, windowSize, windowOverlap);

f_mask = (F>=freqRange(1)) & (F<=freqRange(2));

%The spectrogram
p = 2*log(abs(S(f_mask,:))+eps)+20;
f = linspace(freqRange(1),freqRange(2),size(p,1));

set(ax,'units',bck);

xl = xlim;
imagesc(linspace(xl(1),xl(2),size(p,2)),f,p);
end

% --- Outputs from this function are returned to the command line.
function varargout = Parse_segments_OutputFcn(~, ~, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
    varargout{1} = handles.output;
end

% --- Executes on button press in pushbutton1.
function key_press(hObject, ~, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


if isempty(double(get(gcf,'currentcharacter')))
    return
end

switch double(get(gcf,'currentcharacter'))
    case 28
        handles.dbase.AnalysisState.CurrentFile = handles.dbase.AnalysisState.CurrentFile - 1;
        if handles.dbase.AnalysisState.CurrentFile == 0
            handles.dbase.AnalysisState.CurrentFile = length(handles.dbase.Times);
        end
        handles = load_file(handles);
    case 29
        handles.dbase.AnalysisState.CurrentFile = handles.dbase.AnalysisState.CurrentFile + 1;
        if handles.dbase.AnalysisState.CurrentFile > length(handles.dbase.Times)
            handles.dbase.AnalysisState.CurrentFile = 1;
        end
        handles = load_file(handles);
    case 32
        col = round(mean(handles.dbase.SegmentIsSelected{handles.dbase.AnalysisState.CurrentFile}));
        handles.dbase.SegmentIsSelected{handles.dbase.AnalysisState.CurrentFile}(:) = 1-col;
        handles = color_lines(handles);
    case 27
        handles.dbase.SegmentIsSelected{handles.dbase.AnalysisState.CurrentFile}(:) = 0;
        handles.dbase.AnalysisState.CurrentFile = handles.dbase.AnalysisState.CurrentFile + 1;
        if handles.dbase.AnalysisState.CurrentFile > length(handles.dbase.Times)
            handles.dbase.AnalysisState.CurrentFile = 1;
        end
        handles = load_file(handles);
    case 8
        for c = 1:20
            handles.dbase.SegmentIsSelected{handles.dbase.AnalysisState.CurrentFile}(:) = 0;
            handles.dbase.AnalysisState.CurrentFile = handles.dbase.AnalysisState.CurrentFile + 1;
            if handles.dbase.AnalysisState.CurrentFile > length(handles.dbase.Times)
                handles.dbase.AnalysisState.CurrentFile = length(handles.dbase.Times);
            end
        end
        handles = load_file(handles);
    case 61
        for c = 1:10
            handles.dbase.SegmentIsSelected{handles.dbase.AnalysisState.CurrentFile}(:) = 1;
            handles.dbase.AnalysisState.CurrentFile = handles.dbase.AnalysisState.CurrentFile - 1;
            if handles.dbase.AnalysisState.CurrentFile == 0
                handles.dbase.AnalysisState.CurrentFile = 1;
            end
        end
        handles = load_file(handles);
    case 13
        switch char(handles.currentletter)
            case 's'
                [filename, pathname] = uiputfile([handles.pathname handles.filename], 'Pick an analysis file');
                if ~ischar(filename)
                    return
                else
                    dbase = handles.dbase;
                    handles.filename = filename;
                    handles.pathname = pathname;
                    save([handles.pathname handles.filename],'dbase');
                end
            case 'c'
                answer = inputdlg({'Offset','Brightness'},'Color scale',1,{num2str(handles.clim(1)),num2str(handles.clim(2))});
                if isempty(answer)
                    return
                end
                handles.clim = [str2double(answer{1}), str2double(answer{2})];
            case 'p'
                b = fir1(200,[500 10000]/(handles.fs/2));
                snd = filtfilt(b, 1, handles.snd);
                sound(snd*handles.volume,handles.fs);
            case 'v'
                answer = inputdlg({'Volume'},'Volume',1,{num2str(handles.volume)});
                if isempty(answer)
                    return
                end
                handles.volume = str2double(answer{1});
            case 'r'
                handles = Parse_radio(handles);
        end
        handles.currentletter = [];
        handles = color_lines(handles);
    otherwise
        if isempty(handles.currentletter)
            handles.currentletter = double(get(gcf,'currentcharacter'));
        else
            f = find(handles.symbols==handles.currentletter);
            g = find(handles.symbols==double(get(gcf,'currentcharacter')));
            if ~isempty(g)                          
                col = round(mean([handles.dbase.SegmentIsSelected{handles.dbase.AnalysisState.CurrentFile}(f:g) 0.5]));
                handles.dbase.SegmentIsSelected{handles.dbase.AnalysisState.CurrentFile}(f:g) = 1-col;
                handles.currentletter = [];
            end
        end
        handles = color_lines(handles);
end

guidata(hObject, handles);
end