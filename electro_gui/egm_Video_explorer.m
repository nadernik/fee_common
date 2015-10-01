function varargout = egm_Video_explorer(varargin)
% EGM_VIDEO_EXPLORER MATLAB code for egm_Video_explorer.fig
%      EGM_VIDEO_EXPLORER, by itself, creates a new EGM_VIDEO_EXPLORER or raises the existing
%      singleton*.
%
%      H = EGM_VIDEO_EXPLORER returns the handle to a new EGM_VIDEO_EXPLORER or the handle to
%      the existing singleton*.
%
%      EGM_VIDEO_EXPLORER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EGM_VIDEO_EXPLORER.M with the given input arguments.
%
%      EGM_VIDEO_EXPLORER('Property','Value',...) creates a new EGM_VIDEO_EXPLORER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before egm_Video_explorer_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to egm_Video_explorer_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help egm_Video_explorer

% Last Modified by GUIDE v2.5 01-Oct-2015 15:14:51

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @egm_Video_explorer_OpeningFcn, ...
    'gui_OutputFcn',  @egm_Video_explorer_OutputFcn, ...
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


% --- Executes just before egm_Video_explorer is made visible.
function egm_Video_explorer_OpeningFcn(hObject, ~, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to egm_Video_explorer (see VARARGIN)

handles.VIDEO_PROPERTY_NAME = 'VideoFile';
handles.OFFSET_PROPERTY_NAME = 'VideoOffsetSeconds';
handles.LINESPEC_DATA = '-k';
handles.LINESPEC_DATANAV = '-k';
handles.LONGEST_CLIP_TO_PLAY = Inf; % seconds

if verLessThan('matlab', 'R2015b')
    warndlg('Must have R2015b or newer!')
    delete(handles.figure1)
end

handles.egh = varargin{1};
dbase = handles.egh.dbase;
handles.filenum = dbase.AnalysisState.CurrentFile;
ndx = strcmp(handles.OFFSET_PROPERTY_NAME, dbase.Properties.Names{handles.filenum});
handles.offset = str2double(dbase.Properties.Values{handles.filenum}{ndx});

set(handles.popupSource, 'String', dbase.AnalysisState.SourceList);
set(handles.popupSource, 'Value', 2); % Sound

set(handles.popupFunction, 'String', eg_FunctionNames());
set(handles.popupFunction, 'Value', 1); % (Raw)

handles.sourceName = getSelectedString(handles.popupSource);
handles.functionName = getSelectedString(handles.popupFunction);
handles.fparams = struct;

handles.tlim = [nan nan];
handles.old.sourceName = '';
handles.old.functionName = '';
handles.old.tlim = [nan nan];
handles.old.vidtime = nan;

% If there is no video associated with the current data file, prompt the
% user for video.
propnum = find(strcmp(handles.VIDEO_PROPERTY_NAME, dbase.Properties.Names{handles.filenum}), 1);
if isempty(propnum)
    propnum = length(dbase.Properties.Names{handles.filenum}) + 1;
    [filename, pathname] = uigetfile('*.*', 'Select video file');
    if isnumeric(filename) && filename == 0
        guidata(hObject, handles)
        return
    end
    dbase.Properties.Name{handles.filenum}{propnum} = handles.VIDEO_PROPERTY_NAME;
    dbase.Properties.Values{handles.filenum}{propnum} = fullfile(pathname, filename);
    dbase.Properties.Types{handles.filenum}{propnum} = 1; % 1=string, 2=boolean, 3=combobox
end
handles.vidreader = VideoReader(dbase.Properties.Values{handles.filenum}{propnum});

handles.fudgefactor = 0.067; % IMPORTANT- this is added to all times before getting frames
handles.vidbufferlength = 100;
handles.vidbuffer = zeros(handles.vidreader.Height, ...
            handles.vidreader.Width, 3, handles.vidbufferlength, 'uint8');
handles.vidbuffertime = inf(1, handles.vidbufferlength);

% Choose default command line output for egm_Video_explorer
handles.fs = dbase.Fs;

axis(handles.axesVideo, 'off')

% Update handles structure
guidata(hObject, handles);
vexupdate(hObject)

% UIWAIT makes egm_Video_explorer wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = egm_Video_explorer_OutputFcn(~, ~, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.egh;


% --- Executes on selection change in popupSource.
function popupSource_Callback(hObject, ~, handles) %#ok<DEFNU>
% hObject    handle to popupSource (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupSource contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupSource
handles.sourceName = getSelectedString(hObject);
guidata(hObject, handles)
vexupdate(hObject)

% --- Executes during object creation, after setting all properties.
function popupSource_CreateFcn(hObject, ~, ~) %#ok<DEFNU>
% hObject    handle to popupSource (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function vexupdate(hObject)
%vexupdate updates the video explorer gui

handles = guidata(hObject);
isChangedAbove = false;

set(handles.sliderTime, 'Enable', 'off')

% If data source changed, load data
if ~strcmp(handles.sourceName, handles.old.sourceName)
    isChangedAbove = true;
    [handles.data, ~, ~, handles.label, ~] = eg_LoadData(handles.egh.dbase, ...
        handles.filenum, handles.sourceName);
end

% If function changed, apply function
if ~strcmp(handles.functionName, handles.old.functionName) || isChangedAbove
    isChangedAbove = true;
    if strcmp(handles.functionName, '(Raw)')
        handles.fdata = handles.data;
    else
        [handles.fdata, handles.label] = feval(['egf_' handles.functionName], ...
            handles.data, handles.fs, handles.fparams);
    end
    
    % plot data nav
    if isempty(handles.fdata)
        handles.fdata = [0 0];
    end
    y = decimateToAxesWidth(handles.fdata, handles.axesDataNav);
    t = linspace(0, length(handles.fdata) / handles.fs, length(y));
    plot(handles.axesDataNav, t, y, handles.LINESPEC_DATANAV)
    xlim(handles.axesDataNav, [t(1) t(end)])
    set(handles.axesDataNav, 'ButtonDownFcn', 'egm_Video_explorer(''clickAxesDataNav'',gcbo,[])')
end

% If window changed, replot
if any(handles.old.tlim ~= handles.tlim) || isChangedAbove
    isChangedAbove = true;
    if isempty(handles.fdata)
        handles.fdata = [0 0];
    end
    if any(isnan(handles.tlim))
        handles.tlim = [0, (length(handles.fdata) - 1) / handles.fs];
    end
    
    handles.vidtime = handles.tlim(1) - handles.offset;
    
    % decimate data so there is at most 1 point per pixel of x axis
    samplim = round(handles.tlim .* handles.fs) + 1;
    y = decimateToAxesWidth(handles.fdata(samplim(1):samplim(2)), handles.axesData);
    t = linspace(handles.tlim(1), handles.tlim(2), length(y));
    ud = get(handles.axesData, 'UserData');% preserve user data
    plot(handles.axesData, t, y, handles.LINESPEC_DATA)
    xlim(handles.axesData, handles.tlim)
    set(handles.axesData, 'ButtonDownFcn', 'egm_Video_explorer(''clickAxesData'',gcbo,[])')
    set(handles.axesData, 'UserData', ud)
    
    % plot rectangle
    delete(findobj('Tag', 'vexZoomBox'));
    axes(handles.axesDataNav);
    yy = ylim;
    w = handles.tlim(2) - handles.tlim(1);
    h = yy(2) - yy(1);
    rectangle('Position', [handles.tlim(1), yy(1), w, h], 'LineWidth', 3, 'LineStyle', '--', 'EdgeColor', [1 0 0], 'Tag', 'vexZoomBox');
    
    xlabel(handles.axesData, 'Time (s)')
end

% If frame changed, show new frame
if handles.old.vidtime ~= handles.vidtime || isChangedAbove
    
    % If the requested frame is outside the buffer, make a new buffer
    % starting at the requested time
    if      handles.vidtime < handles.vidbuffertime(1) || ...
            handles.vidtime > handles.vidbuffertime(end)
        handles.vidbuffer = zeros(handles.vidreader.Height, ...
            handles.vidreader.Width, 3, handles.vidbufferlength, 'uint8');
        handles.vidbuffertime = nan(1, handles.vidbufferlength);
        handles.vidreader.CurrentTime = handles.vidtime + handles.fudgefactor;
        numframes = 0;
        wbh = waitbar(0, 'Buffering...');
        while numframes < handles.vidbufferlength && handles.vidreader.hasFrame()
            numframes = numframes + 1;
            waitbar(numframes/handles.vidbufferlength, wbh);
            handles.vidbuffertime(numframes) = handles.vidreader.CurrentTime - handles.fudgefactor;
            handles.vidbuffer(:,:,:,numframes) = handles.vidreader.readFrame();
        end
        delete(wbh)
            isInWindow = handles.tlim(1) <= handles.vidbuffertime + handles.offset & ...
        handles.vidbuffertime + handles.offset <= handles.tlim(2);
    maxx = find(isInWindow, 1, 'last');
    minn = find(isInWindow, 1, 'first');
    set(handles.sliderTime, 'Min', minn)
    set(handles.sliderTime, 'Max', maxx)
    set(handles.sliderTime, 'SliderStep', [1 10] ./ (maxx - minn))
    end
    
    
    % Get frame from buffer
    handles.vidbufferpos = find(handles.vidbuffertime <= handles.vidtime, 1, 'last');
    axes(handles.axesVideo);
    image(handles.vidbuffer(:,:,:,handles.vidbufferpos))
    
    % Transparent yellow box on data to highlight the current frame. Remove
    % the old box and create a new one.
    axes(handles.axesData);
    yy = ylim;
    tt1 = handles.vidbuffertime(handles.vidbufferpos) + handles.offset;
    if handles.vidbufferpos < handles.vidbufferlength
        tt2 = handles.vidbuffertime(handles.vidbufferpos + 1) + handles.offset;
    else
        tt2 = handles.vidreader.CurrentTime + handles.offset;
    end
    delete(findobj('Tag', 'vexFramePatch'))
    patch([tt1 tt1 tt2 tt2], [yy(1) yy(2) yy(2) yy(1)], 'k', ...
        'FaceAlpha', 0.5, 'FaceColor', [1 1 0], 'Tag', 'vexFramePatch')
    
    % Slider
    set(handles.sliderTime, 'Value', handles.vidbufferpos)
end

handles.old.sourceName   = handles.sourceName;
handles.old.functionName = handles.functionName;
handles.old.tlim         = handles.tlim;

set(handles.sliderTime, 'Enable', 'on')

guidata(hObject, handles)
drawnow;


% --- Executes on selection change in popupFunction.
function popupFunction_Callback(hObject, ~, handles) %#ok<DEFNU>
% hObject    handle to popupFunction (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.functionName = getSelectedString(hObject);
if ~strcmp(handles.functionName, '(Raw)')
    handles.fparams = feval(['egf_' handles.functionName], 'params');
end
guidata(hObject, handles)
vexupdate(hObject)

% --- Executes during object creation, after setting all properties.
function popupFunction_CreateFcn(hObject, ~, ~) %#ok<DEFNU>
% hObject    handle to popupFunction (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during mouse click on axesData.
function clickAxesData(hObject, eventdata) %#ok<DEFNU>
zoomboxCallback(hObject, eventdata);
handles = guidata(hObject);
handles.tlim = xlim(hObject);
guidata(hObject, handles)
vexupdate(hObject)


% --- Executes during mouse click on axesData
function clickAxesDataNav(hObject, ~) %#ok<DEFNU>
[xmin, xmax, ~, ~] = getBoxCoordinates(hObject);
handles = guidata(hObject);
handles.tlim = [xmin, xmax];
guidata(hObject, handles);
vexupdate(hObject);


function vexTimerFcn(timerObj, ~)
fig = timerObj.UserData;
handles = guidata(fig);
newpos = handles.vidbufferpos + 1;
if      newpos > handles.vidbufferlength || ...
        handles.vidbuffertime(newpos) + handles.offset >= handles.tlim(2)
    newpos = find(handles.vidbuffertime >= handles.tlim(1), 1, 'first');
end
debugdisp('Playing at pos %g', newpos);
handles.vidtime = handles.vidbuffertime(newpos);
guidata(fig, handles);
vexupdate(fig);


% --- Executes on slider movement.
function sliderTime_Callback(hObject, ~, handles) %#ok<DEFNU>
% hObject    handle to sliderTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

newpos = round(get(hObject, 'Value'));
debugdisp('Slider position: %g', newpos)
handles.vidtime = handles.vidbuffertime(newpos);
guidata(hObject, handles);
vexupdate(hObject);

% --- Executes during object creation, after setting all properties.
function sliderTime_CreateFcn(hObject, ~, ~) %#ok<DEFNU>
% hObject    handle to sliderTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in pushPlay.
function pushPlay_Callback(~, ~, handles) %#ok<DEFNU>
% hObject    handle to pushPlay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
vexTimer = timerfind('Name', 'vexFrameAdvance');
if isempty(vexTimer)
    debugdisp('No timer running. Starting video playback.')

    vexTimer = timer;
    vexTimer.BusyMode = 'drop';
    vexTimer.ExecutionMode = 'fixedRate';
    vexTimer.Period = 1 / handles.vidreader.FrameRate;
    vexTimer.Name = 'vexFrameAdvance';
    vexTimer.Tag  = 'vexFrameAdvance';
    vexTimer.TimerFcn = @vexTimerFcn;
    vexTimer.UserData = handles.figure1;
    start(vexTimer);
else
    debugdisp('Stopping playback')
    stop(vexTimer);
    delete(vexTimer);
end
