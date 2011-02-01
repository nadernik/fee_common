function varargout = song_gui(varargin)
% SONG_GUI M-file for song_gui.fig
%      SONG_GUI, by itself, creates a new SONG_GUI or raises the existing
%      singleton*.
%
%      H = SONG_GUI returns the handle to a new SONG_GUI or the handle to
%      the existing singleton*.
%
%      SONG_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SONG_GUI.M with the given input arguments.
%
%      SONG_GUI('Property','Value',...) creates a new SONG_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before song_gui_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to song_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help song_gui

% Last Modified by GUIDE v2.5 06-Apr-2006 17:23:10

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @song_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @song_gui_OutputFcn, ...
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


% --- Executes just before song_gui is made visible.
function song_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to song_gui (see VARARGIN)

set(0,'units','characters');
set(gcf,'units','characters');

ss = get(0,'screensize');
fp = get(gcf,'position');

set(gcf,'position',[ss(1)+0.04*ss(3) ss(2)+0.04*ss(4) 0.92*ss(3) 0.92*ss(4)]);
np = get(gcf,'position');

np(3) = np(3) * 1;
np(4) = np(4) * 1;

% h = get(gcf,'children');
h = findobj('visible','on');
h = h(find(h>0));
for i = 1:length(h)
    ps = get(h(i),'position');
    ps(1) = ps(1)/fp(3)*np(3);
    ps(2) = ps(2)/fp(4)*np(4);
    ps(3) = ps(3)/fp(3)*np(3);
    ps(4) = ps(4)/fp(4)*np(4);
    set(h(i),'position',ps);
end    



% Choose default command line output for song_gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);


% UIWAIT makes song_gui wait for user response (see UIRESUME)
% uiwait(handles.song_gui);


% --- Outputs from this function are returned to the command line.
function varargout = song_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on slider movement.
function slide_time_Callback(hObject, eventdata, handles)
% hObject    handle to slide_time (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

handles.starttime = get(handles.slide_time,'value');
guidata(hObject, handles);
song_gui('edit_timescale_Callback',gcbo,[],guidata(gcbo));


% --- Executes during object creation, after setting all properties.
function slide_time_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slide_time (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slide_colormap_Callback(hObject, eventdata, handles)
% hObject    handle to slide_colormap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

subplot(handles.axes_spectrum);
colormap(bbyrp(handles))


% --- Executes during object creation, after setting all properties.
function slide_colormap_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slide_colormap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in check_derivative.
function check_derivative_Callback(hObject, eventdata, handles)
% hObject    handle to check_derivative (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of check_derivative

set(handles.slide_colormap,'value',1-get(handles.slide_colormap,'value'));
song_gui('push_sonogram_Callback',gcbo,[],guidata(gcbo))


function edit_timescale_Callback(hObject, eventdata, handles)
% hObject    handle to edit_timescale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_timescale as text
%        str2double(get(hObject,'String')) returns contents of edit_timescale as a double

tscale = str2num(get(handles.edit_timescale,'string'));
subplot(handles.axes_sound);
xlim([handles.starttime handles.starttime+tscale]);
subplot(handles.axes_spectrum);
xlim([handles.starttime handles.starttime+tscale]);
subplot(handles.axes_segments);
xlim([handles.starttime handles.starttime+tscale]);
subplot(handles.axes_amplitude);
xlim([handles.starttime handles.starttime+tscale]);
set(handles.slide_time,'sliderstep',[min([1 0.01*tscale/(length(handles.wav)/handles.fs)]) min([1 0.4*tscale/(length(handles.wav)/handles.fs)])]);


% --- Executes during object creation, after setting all properties.
function edit_timescale_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_timescale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in push_timeleft.
function push_timeleft_Callback(hObject, eventdata, handles)
% hObject    handle to push_timeleft (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

tscale = str2num(get(handles.edit_timescale,'string'));
ord = 10^floor(log(tscale)/log(10));
mult = tscale/ord;
if mult >= 5
    tscale = 10 * ord;
elseif mult >= 2 & mult < 5
    tscale = 5 * ord;
elseif mult >= 1 & mult < 2
    tscale = 2 * ord;
end
set(handles.edit_timescale,'string',num2str(tscale));
song_gui('edit_timescale_Callback',gcbo,[],guidata(gcbo));


% --- Executes on button press in push_timeright.
function push_timeright_Callback(hObject, eventdata, handles)
% hObject    handle to push_timeright (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

tscale = str2num(get(handles.edit_timescale,'string'));
ord = 10^floor(log(tscale)/log(10));
mult = tscale/ord;
if mult == 1
    tscale = 0.5 * ord;
elseif mult > 1 & mult <= 2
    tscale = ord;
elseif mult > 2 & mult <= 5
    tscale = 2 * ord;
elseif mult > 5;
    tscale = 5 * ord;
end
set(handles.edit_timescale,'string',num2str(tscale));
song_gui('edit_timescale_Callback',gcbo,[],guidata(gcbo));


function edit_threshold_Callback(hObject, eventdata, handles)
% hObject    handle to edit_threshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_threshold as text
%        str2double(get(hObject,'String')) returns contents of edit_threshold as a double

set(handles.thresline,'ydata',repmat(str2num(get(handles.edit_threshold,'string')),1,2));


% --- Executes during object creation, after setting all properties.
function edit_threshold_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_threshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_minduration_Callback(hObject, eventdata, handles)
% hObject    handle to edit_minduration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_minduration as text
%        str2double(get(hObject,'String')) returns contents of edit_minduration as a double


% --- Executes during object creation, after setting all properties.
function edit_minduration_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_minduration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_mininterval_Callback(hObject, eventdata, handles)
% hObject    handle to edit_mininterval (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_mininterval as text
%        str2double(get(hObject,'String')) returns contents of edit_mininterval as a double


% --- Executes during object creation, after setting all properties.
function edit_mininterval_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_mininterval (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function slide_amplitude_Callback(hObject, eventdata, handles)
% hObject    handle to slide_amplitude (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

subplot(handles.axes_amplitude);
ylim([0 max(handles.amplitude)*(1-get(handles.slide_amplitude,'value'))+eps]);

% --- Executes during object creation, after setting all properties.
function slide_amplitude_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slide_amplitude (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in push_segment.
function push_segment_Callback(hObject, eventdata, handles)
% hObject    handle to push_segment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isfield(handles,'dbase') & ~isempty(find(handles.dbase.DateAndTime==handles.filetime)) & handles.dbase.BirdNumber(find(handles.dbase.DateAndTime==handles.filetime)) == handles.birdnumber
    f = find(handles.dbase.DateAndTime==handles.filetime);
    handles.segments = handles.dbase.SegmentTimes{f};
    handles.selectedseg = handles.dbase.IsSelected{f};
    handles.segmenttitles = handles.dbase.SegmentTitles{f};
else
    handles.segments = segment_song(handles.amplitude,handles.fs,str2num(get(handles.edit_mininterval,'string'))/1000,str2num(get(handles.edit_minduration,'string'))/1000,str2num(get(handles.edit_threshold,'string')),str2num(get(handles.edit_buffer,'string'))/1000);
    handles.selectedseg = ones(1,size(handles.segments,1));
    handles.segmenttitles = cell(1,size(handles.segments,1));
    for c = 1:length(handles.segmenttitles)
        handles.segmenttitles{c} = '';
    end
end

subplot(handles.axes_segments)
cla
set(gca,'color',get(gcf,'color'),'xcolor',get(gcf,'color'),'ycolor',get(gcf,'color'));
hold on
handles.segmentplots = zeros(1,size(handles.segments,1));
handles.segmentlabels = zeros(1,size(handles.segments,1));
cols = {'g','r'};
for c = 1:size(handles.segments,1)
    handles.segmentplots(c) = plot([handles.segments(c,1) handles.segments(c,2)]/handles.fs,[0 0],cols{handles.selectedseg(c)+1},'linewidth',4);
    set(handles.segmentplots(c),'ButtonDownFcn','song_gui(''clicksegment'',gcbo,[],guidata(gcbo))');
    handles.segmentlabels(c) = text((handles.segments(c,1)+handles.segments(c,2))/handles.fs/2, .75, handles.segmenttitles{c});
end
set(handles.segmentlabels,'horizontalalignment','center')
ylim([-1 1]);

guidata(hObject, handles);
song_gui('edit_timescale_Callback',gcbo,[],guidata(gcbo));


% --- Executes on segment click
function clicksegment(hObject, eventdata, handles)

f = find(handles.segmentplots==hObject);
if strcmp(get(gcf,'selectiontype'),'extend') % assign labels in case shift was pressed
    str = inputdlg('Input syllable name','Syllable name');
    if isempty(str)
        return
    else
        for c = 1:length(f)
            handles.segmenttitles{f(c)} = str{1};
            set(handles.segmentlabels(f(c)),'string',str{1});
        end
    end
    handles.selectedseg(f) = 1;
elseif strcmp(get(gcf,'selectiontype'),'normal') % change syllable selection
    handles.selectedseg(f) = 1 - handles.selectedseg(f);
elseif strcmp(get(gcf,'selectiontype'),'open') % join segment with the next one
    if f < length(handles.segmentplots)
        handles.segments(f,2) = handles.segments(f+1,2);
        handles.segments = handles.segments([1:f f+2:end],:);
        
        set(handles.segmentplots(f),'xdata',[handles.segments(f,1) handles.segments(f,2)]/handles.fs);
        delete(handles.segmentplots(f+1));
        handles.segmentplots = handles.segmentplots([1:f f+2:end]);
        
        handles.selectedseg = handles.selectedseg([1:f f+2:end]);
        
        delete(handles.segmentlabels(f+1));
        handles.segmentlabels = handles.segmentlabels([1:f f+2:end]);
        ps = get(handles.segmentlabels(f),'position');
        ps(1) = (handles.segments(f,1)+handles.segments(f,2))/handles.fs/2;
        set(handles.segmentlabels(f),'position',ps);
        
        t = cell(1,length(handles.segments));
        for c = 1:length(t)
            if c <= f
                t{c} = handles.segmenttitles{c};
            else
                t{c} = handles.segmenttitles{c+1};
            end
        end
        handles.segmenttitles = t;
        
        handles.selectedseg(f) = 1;
    end
end

set(handles.segmentplots(find(handles.selectedseg==1)),'color','r');
set(handles.segmentplots(find(handles.selectedseg==0)),'color','g');

guidata(hObject, handles);


% --- Executes on segment axis click
function clicksegmentaxis(hObject, eventdata, handles)

rect = rbbox;
axpos = get(handles.axes_segments,'position');
x1 = (rect(1)-axpos(1))/axpos(3);
y1 = (rect(2)-axpos(2))/axpos(4);
x2 = x1+rect(3)/axpos(3);
y2 = y1+rect(4)/axpos(4);
if ~(y1<0.5 & y2>0.5)
    return
end
xl = xlim;
x1 = xl(1)+x1*(xl(2)-xl(1));
x2 = xl(1)+x2*(xl(2)-xl(1));

f = find(handles.segments(:,1)>x1*handles.fs & handles.segments(:,2)<x2*handles.fs);
if strcmp(get(gcf,'selectiontype'),'extend') % assign labels in case shift was pressed
    str = inputdlg('Input syllable name','Syllable name');
    if isempty(str)
        return
    else
        for c = 1:length(f)
            handles.segmenttitles{f(c)} = str{1};
            set(handles.segmentlabels(f(c)),'string',str{1});
        end
    end
    handles.selectedseg(f) = 1;
else
    handles.selectedseg(f) = 1 - handles.selectedseg(f);
end

set(handles.segmentplots(find(handles.selectedseg==1)),'color','r');
set(handles.segmentplots(find(handles.selectedseg==0)),'color','g');

guidata(hObject, handles);


% --- Executes on sonogram click
function clicksonogram(hObject, eventdata, handles)

pos = get(gca,'CurrentPoint');
if strcmp(get(gcf,'selectiontype'),'normal')
    if pos(1,1) > get(handles.slide_time,'max')
        return
    else
        handles.starttime = pos(1,1);
        set(handles.slide_time,'value',handles.starttime);
    end
elseif strcmp(get(gcf,'selectiontype'),'alt')
    tscale = pos(1,1)-handles.starttime;
    set(handles.edit_timescale,'string',num2str(tscale));
    song_gui('edit_timescale_Callback',gcbo,[],guidata(gcbo));
end

guidata(hObject, handles);
song_gui('edit_timescale_Callback',gcbo,[],guidata(gcbo));


% --- Executes on button press in push_open.
function push_open_Callback(hObject, eventdata, handles)
% hObject    handle to push_open (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

directory_name = uigetdir(pwd,'Select directory');
if ~isstr(directory_name)
    return
else
    handles.directory_name = directory_name;
    cd(handles.directory_name);
    handles.filelist = dir('*.wav');
    
    % Sorts files to figure out the order
    for c = 1:length(handles.filelist)
        fname = handles.filelist(c).name;
        f = findstr(fname,'_');
        if length(f)==6 % SAP format
            f = [f findstr(fname,'.wav')];
            fhour = str2num(fname(f(4)+1:f(5)-1));
            fminute = str2num(fname(f(5)+1:f(6)-1));
            fsecond = str2num(fname(f(6)+1:f(7)-1));
            secofday(c) = fhour+fminute/60+fsecond/3600;
        else
            dv = datevec(handles.filelist(c).date);
            secofday(c) = dv(4)+dv(5)/60+dv(6)/3600;
        end
    end
    ord = sortrows([secofday' (1:length(handles.filelist))']);
    handles.fileorder = ord(:,2)';
    handles.secofday = ord(:,1)';
    
    str = cell(1,length(handles.filelist));
    for c = 1:length(handles.filelist)
        str{c} = handles.filelist(handles.fileorder(c)).name(1:end-4);
    end
    set(handles.list_files,'string',str);
    
    subplot(handles.axes_time)
    hs = histc(handles.secofday,0:24);
    h = bar(.5:1:23.5,hs(1:end-1));
    set(h,'facecolor',[.5 .5 .5])
    xlim([0 24]);
    box off;
    xlabel('Time of day');
    ylabel('# of files')
    
    subplot(handles.axes_spectrum)
    xlabel('Time (sec)');
    ylabel('Frequency (kHz)')
    
    handles.currentfile = 1;
    handles.starttime = 0;
    handles = new_file(handles);
    
    if ~isfield(handles,'bgcolor')
        handles.bgcolor = [.5 .5 .5];
    end
    if ~isfield(handles,'ws_times')
        handles.ws_times = [];
        handles.ws_sonograms = cell(1,0);
        handles.ws_sounds = cell(1,0);
        handles.ws_fs = [];
        handles.ws_page = 1;
        handles.ws_segments = cell(1,0);
        handles.ws_segmenttitles = cell(1,0);
    end
    handles = update_worksheet(handles);
    
    guidata(hObject, handles);
    song_gui('push_segment_Callback',gcbo,[],guidata(gcbo))
    song_gui('slide_colormap_Callback',gcbo,[],guidata(gcbo));
end

% --- Executes when a new file is opened
function handles = new_file(handles)

% Save current data into a structure
handles = updatedbase(handles);
handles.old_file = handles.currentfile;

set(handles.list_files,'value',find(handles.fileorder==handles.currentfile));

% Open the sound
handles.filename = handles.filelist(handles.fileorder(handles.currentfile)).name;
[handles.wav handles.fs] = wavread(handles.filelist(handles.fileorder(handles.currentfile)).name);

% Determine bird number and date from the filename
f = findstr(handles.filename,'_');

if length(f)==6 % SAP files
    f = [f findstr(handles.filename,'.wav')];

    handles.birdnumber = str2num(handles.filename(1:f(1)-1));

    fyear = datevec(handles.filelist(handles.fileorder(handles.currentfile)).date); % SAP titles don't have year; get it from the actual file info
    fyear = fyear(1);
    fmonth = str2num(handles.filename(f(2)+1:f(3)-1));
    fday = str2num(handles.filename(f(3)+1:f(4)-1));
    fhour = str2num(handles.filename(f(4)+1:f(5)-1));
    fminute = str2num(handles.filename(f(5)+1:f(6)-1));
    fsecond = str2num(handles.filename(f(6)+1:f(7)-1));

    handles.filetime = datenum(fyear,fmonth,fday,fhour,fminute,fsecond);
else
    handles.birdnumber = NaN;
    handles.filetime = datenum(handles.filelist(handles.fileorder(handles.currentfile)).date);
end
set(handles.text_datetime,'string',datestr(handles.filetime));
set(handles.text_birdnum,'string',['Bird ' num2str(handles.birdnumber)]);
set(handles.text_filecount,'string',[num2str(handles.currentfile) '/' num2str(length(handles.filelist))]);

% Set time slider parameters
set(handles.slide_time,'value',0);
set(handles.slide_time,'min',0,'max',length(handles.wav)/handles.fs);

% Erase sonogram
subplot(handles.axes_spectrum)
cla

% Plot sound wave
subplot(handles.axes_sound);
handles.wav = bp_filt(handles.wav);

% plot((0:length(handles.wav)-1)/handles.fs,bp_filt(handles.wav),'c');
plot((0:length(handles.wav)-1)/handles.fs,handles.wav,'c');
yl = max(abs(handles.wav))*1.05;
ylim([-yl yl]);
set(gca,'color',[0 0 0],'xtick',[],'ytick',[]);

% Plot sound amplitude
handles.amplitude = 1000*abs(handles.wav);
% handles.amplitude = 1000*bp_filt(handles.amplitude); %band-pass filter
subplot(handles.axes_amplitude);
plot((0:length(handles.wav)-1)/handles.fs,handles.amplitude,'b');
hold on
handles.thresline = plot([0 (length(handles.wav)-1)/handles.fs],repmat(str2num(get(handles.edit_threshold,'string')),1,2),':r');
hold off
box off
ylim([0 max(handles.amplitude)*(1-get(handles.slide_amplitude,'value'))+eps]);
ylabel('Amplitude (ADU)')

% Auto timescale
if get(handles.check_autoscale,'value')==1
    set(handles.edit_timescale,'string',num2str(length(handles.wav)/handles.fs));
end


% --- Executes on button press in push_play.
function push_play_Callback(hObject, eventdata, handles)
% hObject    handle to push_play (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

st = max([1 round(handles.starttime*handles.fs)]);
fn = min([round((handles.starttime+str2num(get(handles.edit_timescale,'string')))*handles.fs) length(handles.wav)]);
sound(handles.wav(st:fn),handles.fs);


% --- Executes on button press in push_prevfile.
function push_prevfile_Callback(hObject, eventdata, handles)
% hObject    handle to push_prevfile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.currentfile = handles.currentfile-1;
if handles.currentfile == 0
    handles.currentfile = length(handles.filelist);
end
handles.starttime = 0;
handles = new_file(handles);
guidata(hObject, handles);
song_gui('push_segment_Callback',gcbo,[],guidata(gcbo))

% --- Executes on button press in push_nextfile.
function push_nextfile_Callback(hObject, eventdata, handles)
% hObject    handle to push_nextfile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.currentfile = handles.currentfile+1;
if handles.currentfile > length(handles.filelist)
    handles.currentfile = 1;
end
handles.starttime = 0;
handles = new_file(handles);
guidata(hObject, handles);
song_gui('push_segment_Callback',gcbo,[],guidata(gcbo))




function b = bp_filt(a)
% Band-pass filter the data between 860 and 8600 Hz

bp = [   0.01015209302807
   0.00793240918940
   0.00565578664915
   0.00047697044400
  -0.00500335604779
  -0.00826972257002
  -0.00822370033329
  -0.00549191239613
  -0.00211168264328
  -0.00058917028475
  -0.00213569073635
  -0.00521771589476
  -0.00649022546793
  -0.00416862920787
  -0.00042553126833
   0.00060295197027
  -0.00232832050412
  -0.00564227299342
  -0.00495165744412
  -0.00060202153323
   0.00236023296021
   0.00036814886779
  -0.00387712466237
  -0.00453620255391
  -0.00016460129994
   0.00411691299721
   0.00310603260660
  -0.00156124283665
  -0.00323757765955
   0.00097660066463
   0.00616173521841
   0.00589108310574
   0.00089955182367
  -0.00160520003743
   0.00245767427414
   0.00830848205998
   0.00847681942370
   0.00298707896549
  -0.00034880904820
   0.00360941451998
   0.01005028954559
   0.01041332900644
   0.00412249508044
  -0.00019396457329
   0.00370336640281
   0.01078795886858
   0.01117762035021
   0.00373671754061
  -0.00180761980281
   0.00209893169491
   0.01003380060160
   0.01041071271326
   0.00144177720713
  -0.00566228794223
  -0.00164530466657
   0.00753054891372
   0.00801682368567
  -0.00285515763978
  -0.01190848094527
  -0.00757175477597
   0.00351487154425
   0.00442139265986
  -0.00883699406109
  -0.02042164033262
  -0.01544592560748
  -0.00134039073806
   0.00055544064232
  -0.01584008530519
  -0.03096559219355
  -0.02483226088828
  -0.00575337163390
  -0.00183221608001
  -0.02290278103378
  -0.04375819182604
  -0.03563560135969
  -0.00752459971611
   0.00066996505740
  -0.02896153341791
  -0.06169080026431
  -0.05006838980121
  -0.00117186466628
   0.01929357358494
  -0.03304867798414
  -0.10753662976540
  -0.09223392712453
   0.06325801333558
   0.26978884235729
   0.36550737617323
   0.26978884235729
   0.06325801333558
  -0.09223392712453
  -0.10753662976540
  -0.03304867798414
   0.01929357358494
  -0.00117186466628
  -0.05006838980121
  -0.06169080026431
  -0.02896153341791
   0.00066996505740
  -0.00752459971611
  -0.03563560135969
  -0.04375819182604
  -0.02290278103378
  -0.00183221608001
  -0.00575337163390
  -0.02483226088828
  -0.03096559219355
  -0.01584008530519
   0.00055544064232
  -0.00134039073806
  -0.01544592560748
  -0.02042164033262
  -0.00883699406109
   0.00442139265986
   0.00351487154425
  -0.00757175477597
  -0.01190848094527
  -0.00285515763978
   0.00801682368567
   0.00753054891372
  -0.00164530466657
  -0.00566228794223
   0.00144177720713
   0.01041071271326
   0.01003380060160
   0.00209893169491
  -0.00180761980281
   0.00373671754061
   0.01117762035021
   0.01078795886858
   0.00370336640281
  -0.00019396457329
   0.00412249508044
   0.01041332900644
   0.01005028954559
   0.00360941451998
  -0.00034880904820
   0.00298707896549
   0.00847681942370
   0.00830848205998
   0.00245767427414
  -0.00160520003743
   0.00089955182367
   0.00589108310574
   0.00616173521841
   0.00097660066463
  -0.00323757765955
  -0.00156124283665
   0.00310603260660
   0.00411691299721
  -0.00016460129994
  -0.00453620255391
  -0.00387712466237
   0.00036814886779
   0.00236023296021
  -0.00060202153323
  -0.00495165744412
  -0.00564227299342
  -0.00232832050412
   0.00060295197027
  -0.00042553126833
  -0.00416862920787
  -0.00649022546793
  -0.00521771589476
  -0.00213569073635
  -0.00058917028475
  -0.00211168264328
  -0.00549191239613
  -0.00822370033329
  -0.00826972257002
  -0.00500335604779
   0.00047697044400
   0.00565578664915
   0.00793240918940
   0.01015209302807];

b = filter(bp, 1, a);


% --- Executes on button press in push_sonogram.
function push_sonogram_Callback(hObject, eventdata, handles)
% hObject    handle to push_sonogram (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

subplot(handles.axes_spectrum);
cla
hold on

colormap(bbyrp(handles))
set(handles.text_warn,'visible','on')
handles.spectrumplots = [];
if get(handles.check_usesegments,'value')==1
    seg_list = find(handles.selectedseg==1);
    if get(handles.check_currentwindow,'value')==1
        isin = (handles.segments/handles.fs > handles.starttime) & (handles.segments/handles.fs < handles.starttime+str2num(get(handles.edit_timescale,'string')));
        isin = sum(isin,2)';
        seg_list = intersect(seg_list,find(isin>0));
    end
    for c = seg_list
        [p freq t] = power_spectrum(handles.wav(max([1 round(handles.segments(c,1))]):min([round(handles.segments(c,2)) length(handles.wav)])),handles.fs,get(handles.check_derivative,'value'));
        handles.satur = str2num(get(handles.edit_saturation,'string'));
        if get(handles.check_derivative,'value')==1
            set(gca,'color',handles.bgcolor);
            subplot(handles.axes_spectrum);
            h = imagesc(t+handles.segments(c,1)/handles.fs,freq/1000,atan(p/(handles.satur*10^10)));
        else
            set(gca,'color',[0 0 0]);
            subplot(handles.axes_spectrum);
            h = imagesc(t+handles.segments(c,1)/handles.fs,freq/1000,p);
            set(gca,'clim',[0 handles.satur]);
        end
        set(h,'ButtonDownFcn','song_gui(''clicksonogram'',gcbo,[],guidata(gcbo))');
        drawnow
    end
else
    if get(handles.check_currentwindow,'value')==0
        lst = [0:handles.fs:length(handles.wav) length(handles.wav)];
    else
        lst = fix(handles.starttime)*handles.fs:handles.fs:ceil(handles.starttime+str2num(get(handles.edit_timescale,'string')))*handles.fs;
        lst = lst(find(lst<length(handles.wav)));
        if lst(end) > length(handles.wav)-handles.fs
            lst = [lst length(handles.wav)];
        end
    end
    for c = 1:length(lst)-1
        [p freq t] = power_spectrum(handles.wav(lst(c)+1:min([lst(c+1)+round(0.1*handles.fs) length(handles.wav)])),handles.fs,get(handles.check_derivative,'value'));
        handles.satur = str2num(get(handles.edit_saturation,'string'));
        if get(handles.check_derivative,'value')==1
            set(gca,'color',handles.bgcolor);
            subplot(handles.axes_spectrum);
            h = imagesc(t+lst(c)/handles.fs,freq/1000,atan(p/(handles.satur*10^10)));
        else
            set(gca,'color',[0 0 0]);
            subplot(handles.axes_spectrum);
            h = imagesc(t+lst(c)/handles.fs,freq/1000,p);
            set(gca,'clim',[0 handles.satur]);
        end
        set(h,'ButtonDownFcn','song_gui(''clicksonogram'',gcbo,[],guidata(gcbo))');
        drawnow
    end
end
    
subplot(handles.axes_spectrum);
set(gca,'ydir','normal');
ylim([.5 9]);
hold off
colormap(bbyrp(handles))
xlabel('Time (sec)');
ylabel('Frequency (kHz)')
set(handles.text_warn,'visible','off')


% --- Executes on button press in check_autosegment.
function check_autosegment_Callback(hObject, eventdata, handles)
% hObject    handle to check_autosegment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of check_autosegment


% -- Function to segment song into syllables
function f = segment_song(a,fs,min_stop,min_dur,th,buff)
% Segment the song into syllables
% f has two columns: starts of syllables (in data points) and ends


% Find threshold crossing points
f = [];
a = [0; a; 0];
f(:,1) = find(a(1:end-1)<th & a(2:end)>=th)-1;
f(:,2) = find(a(1:end-1)>=th & a(2:end)<th)-1;
a = a(2:end-1);

% Eliminate short intervals
i = [find(f(2:end,1)-f(1:end-1,2) > min_stop*fs); length(f)];
f = [f([1; i(1:end-1)+1],1) f(i,2)];

% Eliminate short syllables
i = find(f(:,2)-f(:,1)>min_dur*fs);
f = f(i,:);

% Attach buffer
f(:,1) = f(:,1) - buff*fs;
f(find(f(:,1)<1),1) = 1;
f(:,2) = f(:,2) + buff*fs;
f(find(f(:,1)>length(a)),2) = length(a);

% --- Power spectrum of a song segment
function [p f t] = power_spectrum(wv,fs,issd)

winstep = 0.1;
npad = 1024;

E = [0.10082636028528   0.48810350894928
   0.10532280057669   0.50016260147095
   0.10990284383297   0.51226782798767
   0.11456660926342   0.52441596984863
   0.11931420862675   0.53660380840302
   0.12414572387934   0.54882800579071
   0.12906123697758   0.56108516454697
   0.13406077027321   0.57337194681168
   0.13914434611797   0.58568495512009
   0.14431197941303   0.59802067279816
   0.14956362545490   0.61037564277649
   0.15489923954010   0.62274640798569
   0.16031874716282   0.63512933254242
   0.16582205891609   0.64752095937729
   0.17140907049179   0.65991759300232
   0.17707960307598   0.67231565713882
   0.18283350765705   0.68471157550812
   0.18867060542107   0.69710153341293
   0.19459065794945   0.70948195457458
   0.20059344172478   0.72184902429581
   0.20667870342732   0.73419916629791
   0.21284613013268   0.74652844667435
   0.21909542381764   0.75883322954178
   0.22542624175549   0.77110970020294
   0.23183822631836   0.78335398435593
   0.23833100497723   0.79556238651276
   0.24490414559841   0.80773097276688
   0.25155723094940   0.81985598802566
   0.25828978419304   0.83193349838257
   0.26510134339333   0.84395974874497
   0.27199140191078   0.85593080520630
   0.27895939350128   0.86784279346466
   0.28600478172302   0.87969189882278
   0.29312700033188   0.89147418737411
   0.30032539367676   0.90318578481674
   0.30759936571121   0.91482281684875
   0.31494826078415   0.92638140916824
   0.32237139344215   0.93785762786865
   0.32986804842949   0.94924771785736
   0.33743748068809   0.96054774522781
   0.34507897496223   0.97175377607346
   0.35279172658920   0.98286205530167
   0.36057496070862   0.99386870861054
   0.36842781305313   1.00476980209351
   0.37634941935539   1.01556169986725
   0.38433897495270   1.02624034881592
   0.39239549636841   1.03680217266083
   0.40051811933518   1.04724323749542
   0.40870589017868   1.05755984783173
   0.41695779561996   1.06774818897247
   0.42527288198471   1.07780468463898
   0.43365013599396   1.08772540092468
   0.44208851456642   1.09750676155090
   0.45058691501617   1.10714507102966
   0.45914432406425   1.11663687229156
   0.46775957942009   1.12597823143005
   0.47643154859543   1.13516581058502
   0.48515912890434   1.14419603347778
   0.49394109845161   1.15306520462036
   0.50277632474899   1.16176998615265
   0.51166349649429   1.17030680179596
   0.52060145139694   1.17867243289948
   0.52958887815475   1.18686318397522
   0.53862458467483   1.19487595558167
   0.54770720005035   1.20270740985870
   0.55683541297913   1.21035408973694
   0.56600785255432   1.21781289577484
   0.57522326707840   1.22508060932159
   0.58448016643524   1.23215413093567
   0.59377723932266   1.23903024196625
   0.60311305522919   1.24570596218109
   0.61248612403870   1.25217819213867
   0.62189501523972   1.25844407081604
   0.63133829832077   1.26450049877167
   0.64081448316574   1.27034485340118
   0.65032202005386   1.27597427368164
   0.65985941886902   1.28138577938080
   0.66942512989044   1.28657686710358
   0.67901766300201   1.29154479503632
   0.68863534927368   1.29628694057465
   0.69827669858932   1.30080080032349
   0.70794004201889   1.30508399009705
   0.71762382984161   1.30913388729095
   0.72732639312744   1.31294822692871
   0.73704612255096   1.31652474403381
   0.74678134918213   1.31986105442047
   0.75653040409088   1.32295513153076
   0.76629155874252   1.32580471038818
   0.77606326341629   1.32840788364410
   0.78584367036820   1.33076262474060
   0.79563117027283   1.33286690711975
   0.80542397499084   1.33471894264221
   0.81522035598755   1.33631694316864
   0.82501864433289   1.33765923976898
   0.83481699228287   1.33874404430389
   0.84461367130279   1.33956992626190
   0.85440695285797   1.34013533592224
   0.86419498920441   1.34043884277344
   0.87397605180740   1.34047901630402
   0.88374835252762   1.34025466442108
   0.89351004362106   1.33976447582245
   0.90325933694840   1.33900737762451
   0.91299438476563   1.33798217773438
   0.92271345853805   1.33668816089630
   0.93241471052170   1.33512413501740
   0.94209629297257   1.33328926563263
   0.95175635814667   1.33118307590485
   0.96139311790466   1.32880449295044
   0.97100472450256   1.32615327835083
   0.98058933019638   1.32322859764099
   0.99014514684677   1.32003021240234
   0.99967026710510   1.31655764579773
   1.00916278362274   1.31281065940857
   1.01862108707428   1.30878901481628
   1.02804315090179   1.30449247360229
   1.03742706775665   1.29992127418518
   1.04677128791809   1.29507517814636
   1.05607366561890   1.28995430469513
   1.06533253192902   1.28455901145935
   1.07454609870911   1.27888941764832
   1.08371245861053   1.27294600009918
   1.09282970428467   1.26672899723053
   1.10189616680145   1.26023912429810
   1.11090993881226   1.25347697734833
   1.11986923217773   1.24644303321838
   1.12877237796783   1.23913824558258
   1.13761734962463   1.23156344890594
   1.14640247821808   1.22371935844421
   1.15512585639954   1.21560716629028
   1.16378593444824   1.20722794532776
   1.17238080501556   1.19858264923096
   1.18090879917145   1.18967282772064
   1.18936800956726   1.18049955368042
   1.19775688648224   1.17106437683105
   1.20607352256775   1.16136872768402
   1.21431636810303   1.15141415596008
   1.22248351573944   1.14120233058929
   1.23057353496552   1.13073492050171
   1.23858451843262   1.12001371383667
   1.24651479721069   1.10904061794281
   1.25436294078827   1.09781765937805
   1.26212716102600   1.08634674549103
   1.26980578899384   1.07462990283966
   1.27739727497101   1.06266951560974
   1.28489995002747   1.05046772956848
   1.29231238365173   1.03802680969238
   1.29963290691376   1.02534937858582
   1.30685997009277   1.01243758201599
   1.31399202346802   0.99929422140122
   1.32102763652802   0.98592185974121
   1.32796525955200   0.97232311964035
   1.33480334281921   0.95850080251694
   1.34154057502747   0.94445770978928
   1.34817540645599   0.93019676208496
   1.35470652580261   0.91572093963623
   1.36113238334656   0.90103322267532
   1.36745178699493   0.88613671064377
   1.37366318702698   0.87103462219238
   1.37976539134979   0.85573017597198
   1.38575696945190   0.84022665023804
   1.39163672924042   0.82452732324600
   1.39740324020386   0.80863571166992
   1.40305554866791   0.79255521297455
   1.40859210491180   0.77628940343857
   1.41401195526123   0.75984185934067
   1.41931378841400   0.74321621656418
   1.42449653148651   0.72641617059708
   1.42955899238586   0.70944553613663
   1.43450009822845   0.69230806827545
   1.43931877613068   0.67500764131546
   1.44401395320892   0.65754824876785
   1.44858467578888   0.63993370532990
   1.45302975177765   0.62216812372208
   1.45734846591949   0.60425555706024
   1.46153962612152   0.58620011806488
   1.46560251712799   0.56800597906113
   1.46953618526459   0.54967725276947
   1.47333967685699   0.53121829032898
   1.47701227664948   0.51263326406479
   1.48055315017700   0.49392655491829
   1.48396146297455   0.47510254383087
   1.48723638057709   0.45616558194161
   1.49037742614746   0.43712010979652
   1.49338376522064   0.41797062754631
   1.49625468254089   0.39872157573700
   1.49898970127106   0.37937757372856
   1.50158810615540   0.35994309186935
   1.50404930114746   0.34042277932167
   1.50637280941010   0.32082122564316
   1.50855803489685   0.30114310979843
   1.51060461997986   0.28139305114746
   1.51251196861267   0.26157575845718
   1.51427984237671   0.24169597029686
   1.51590764522552   0.22175838053226
   1.51739513874054   0.20176777243614
   1.51874196529388   0.18172888457775
   1.51994776725769   0.16164653003216
   1.52101242542267   0.14152547717094
   1.52193558216095   0.12137054651976
   1.52271711826324   0.10118655860424
   1.52335667610168   0.08097834140062
   1.52385437488556   0.06075073406100
   1.52420985698700   0.04050857573748
   1.52442324161530   0.02025671303272
   1.52449429035187  -0.00000000211473
   1.52442324161530  -0.02025671675801
   1.52420985698700  -0.04050857946277
   1.52385437488556  -0.06075073778629
   1.52335667610168  -0.08097834885120
   1.52271711826324  -0.10118656605482
   1.52193558216095  -0.12137055397034
   1.52101242542267  -0.14152547717094
   1.51994776725769  -0.16164653003216
   1.51874196529388  -0.18172889947891
   1.51739513874054  -0.20176777243614
   1.51590764522552  -0.22175839543343
   1.51427984237671  -0.24169597029686
   1.51251196861267  -0.26157575845718
   1.51060461997986  -0.28139305114746
   1.50855803489685  -0.30114310979843
   1.50637280941010  -0.32082122564316
   1.50404930114746  -0.34042277932167
   1.50158810615540  -0.35994309186935
   1.49898970127106  -0.37937757372856
   1.49625468254089  -0.39872160553932
   1.49338376522064  -0.41797062754631
   1.49037742614746  -0.43712010979652
   1.48723638057709  -0.45616558194161
   1.48396146297455  -0.47510254383087
   1.48055315017700  -0.49392655491829
   1.47701227664948  -0.51263326406479
   1.47333967685699  -0.53121829032898
   1.46953618526459  -0.54967725276947
   1.46560251712799  -0.56800597906113
   1.46153962612152  -0.58620011806488
   1.45734846591949  -0.60425561666489
   1.45302975177765  -0.62216812372208
   1.44858467578888  -0.63993370532990
   1.44401395320892  -0.65754824876785
   1.43931877613068  -0.67500770092010
   1.43450009822845  -0.69230806827545
   1.42955899238586  -0.70944553613663
   1.42449653148651  -0.72641617059708
   1.41931378841400  -0.74321621656418
   1.41401195526123  -0.75984185934067
   1.40859210491180  -0.77628940343857
   1.40305554866791  -0.79255521297455
   1.39740324020386  -0.80863571166992
   1.39163672924042  -0.82452732324600
   1.38575696945190  -0.84022665023804
   1.37976539134979  -0.85573017597198
   1.37366318702698  -0.87103468179703
   1.36745178699493  -0.88613677024841
   1.36113238334656  -0.90103322267532
   1.35470652580261  -0.91572093963623
   1.34817540645599  -0.93019676208496
   1.34154057502747  -0.94445770978928
   1.33480334281921  -0.95850080251694
   1.32796525955200  -0.97232311964035
   1.32102763652802  -0.98592185974121
   1.31399202346802  -0.99929428100586
   1.30685997009277  -1.01243758201599
   1.29963290691376  -1.02534937858582
   1.29231238365173  -1.03802680969238
   1.28489995002747  -1.05046772956848
   1.27739727497101  -1.06266951560974
   1.26980578899384  -1.07462990283966
   1.26212716102600  -1.08634674549103
   1.25436294078827  -1.09781765937805
   1.24651479721069  -1.10904061794281
   1.23858451843262  -1.12001371383667
   1.23057353496552  -1.13073492050171
   1.22248351573944  -1.14120233058929
   1.21431636810303  -1.15141415596008
   1.20607352256775  -1.16136872768402
   1.19775688648224  -1.17106437683105
   1.18936800956726  -1.18049955368042
   1.18090879917145  -1.18967282772064
   1.17238080501556  -1.19858264923096
   1.16378593444824  -1.20722794532776
   1.15512585639954  -1.21560716629028
   1.14640247821808  -1.22371935844421
   1.13761734962463  -1.23156344890594
   1.12877237796783  -1.23913824558258
   1.11986923217773  -1.24644303321838
   1.11090993881226  -1.25347697734833
   1.10189616680145  -1.26023912429810
   1.09282970428467  -1.26672899723053
   1.08371245861053  -1.27294600009918
   1.07454609870911  -1.27888941764832
   1.06533253192902  -1.28455901145935
   1.05607366561890  -1.28995430469513
   1.04677128791809  -1.29507517814636
   1.03742706775665  -1.29992127418518
   1.02804315090179  -1.30449247360229
   1.01862108707428  -1.30878901481628
   1.00916278362274  -1.31281065940857
   0.99967020750046  -1.31655764579773
   0.99014514684677  -1.32003021240234
   0.98058933019638  -1.32322859764099
   0.97100472450256  -1.32615327835083
   0.96139311790466  -1.32880449295044
   0.95175635814667  -1.33118307590485
   0.94209629297257  -1.33328926563263
   0.93241471052170  -1.33512413501740
   0.92271345853805  -1.33668816089630
   0.91299438476563  -1.33798217773438
   0.90325933694840  -1.33900737762451
   0.89351004362106  -1.33976447582245
   0.88374835252762  -1.34025466442108
   0.87397605180740  -1.34047901630402
   0.86419498920441  -1.34043884277344
   0.85440695285797  -1.34013533592224
   0.84461367130279  -1.33956992626190
   0.83481699228287  -1.33874404430389
   0.82501864433289  -1.33765923976898
   0.81522035598755  -1.33631694316864
   0.80542397499084  -1.33471894264221
   0.79563117027283  -1.33286690711975
   0.78584367036820  -1.33076262474060
   0.77606326341629  -1.32840788364410
   0.76629155874252  -1.32580471038818
   0.75653040409088  -1.32295513153076
   0.74678134918213  -1.31986105442047
   0.73704612255096  -1.31652474403381
   0.72732639312744  -1.31294822692871
   0.71762382984161  -1.30913388729095
   0.70794004201889  -1.30508399009705
   0.69827669858932  -1.30080080032349
   0.68863534927368  -1.29628694057465
   0.67901766300201  -1.29154479503632
   0.66942512989044  -1.28657686710358
   0.65985941886902  -1.28138577938080
   0.65032202005386  -1.27597427368164
   0.64081448316574  -1.27034485340118
   0.63133829832077  -1.26450049877167
   0.62189501523972  -1.25844407081604
   0.61248612403870  -1.25217819213867
   0.60311305522919  -1.24570596218109
   0.59377723932266  -1.23903024196625
   0.58448016643524  -1.23215413093567
   0.57522326707840  -1.22508060932159
   0.56600785255432  -1.21781289577484
   0.55683541297913  -1.21035408973694
   0.54770720005035  -1.20270740985870
   0.53862458467483  -1.19487595558167
   0.52958887815475  -1.18686318397522
   0.52060145139694  -1.17867243289948
   0.51166349649429  -1.17030680179596
   0.50277632474899  -1.16176998615265
   0.49394109845161  -1.15306520462036
   0.48515912890434  -1.14419603347778
   0.47643154859543  -1.13516581058502
   0.46775957942009  -1.12597823143005
   0.45914432406425  -1.11663687229156
   0.45058691501617  -1.10714507102966
   0.44208851456642  -1.09750676155090
   0.43365013599396  -1.08772540092468
   0.42527288198471  -1.07780468463898
   0.41695779561996  -1.06774818897247
   0.40870586037636  -1.05755984783173
   0.40051811933518  -1.04724323749542
   0.39239549636841  -1.03680217266083
   0.38433894515037  -1.02624034881592
   0.37634941935539  -1.01556169986725
   0.36842781305313  -1.00476980209351
   0.36057496070862  -0.99386870861054
   0.35279172658920  -0.98286205530167
   0.34507897496223  -0.97175377607346
   0.33743748068809  -0.96054774522781
   0.32986804842949  -0.94924771785736
   0.32237139344215  -0.93785762786865
   0.31494826078415  -0.92638140916824
   0.30759936571121  -0.91482281684875
   0.30032539367676  -0.90318578481674
   0.29312697052956  -0.89147418737411
   0.28600478172302  -0.87969189882278
   0.27895939350128  -0.86784279346466
   0.27199140191078  -0.85593080520630
   0.26510134339333  -0.84395974874497
   0.25828978419304  -0.83193349838257
   0.25155723094940  -0.81985598802566
   0.24490414559841  -0.80773097276688
   0.23833100497723  -0.79556238651276
   0.23183822631836  -0.78335398435593
   0.22542624175549  -0.77110970020294
   0.21909542381764  -0.75883322954178
   0.21284613013268  -0.74652844667435
   0.20667870342732  -0.73419916629791
   0.20059344172478  -0.72184902429581
   0.19459065794945  -0.70948195457458
   0.18867060542107  -0.69710153341293
   0.18283350765705  -0.68471157550812
   0.17707960307598  -0.67231565713882
   0.17140905559063  -0.65991759300232
   0.16582205891609  -0.64752095937729
   0.16031874716282  -0.63512933254242
   0.15489923954010  -0.62274640798569
   0.14956361055374  -0.61037564277649
   0.14431196451187  -0.59802067279816
   0.13914434611797  -0.58568495512009
   0.13406075537205  -0.57337194681168
   0.12906122207642  -0.56108516454697
   0.12414572387934  -0.54882800579071
   0.11931420117617  -0.53660380840302
   0.11456660181284  -0.52441596984863
   0.10990284383297  -0.51226782798767
   0.10532280057669  -0.50016260147095
   0.10082635283470  -0.48810350894928];

winlen = size(E,1);
winstep = round(winlen*winstep);

[x y] = meshgrid(1:winstep:length(wv)-winlen,0:winlen-1);
vals = wv(x+y);
clear x y
TSM=vals';

multconst = 27539;
J1=(fft(TSM(:,:).*(ones(size(TSM,1),1)*(E(:,1))'),2^10,2)) * multconst;
J2=(fft(TSM(:,:).*(ones(size(TSM,1),1)*(E(:,2))'),2^10,2)) * multconst;

if issd==1
    m_time_deriv=-1*(real(J1).*real(J2)+imag(J1).*imag(J2));
    m_freq_deriv=((imag(J1).*real(J2)-real(J1).*imag(J2)));
    m_time_deriv_max=max(m_time_deriv.^2,[],2);
    m_freq_deriv_max=max(m_freq_deriv.^2,[],2);
    m_FM=atan(m_time_deriv_max./(m_freq_deriv_max+eps));
    cFM=cos(m_FM);
    sFM=sin(m_FM);
    m_powSpec = m_time_deriv.*(sFM*ones(1,size(m_time_deriv,2)))+m_freq_deriv.*(cFM*ones(1,size(m_freq_deriv,2)));
else
    m_powSpec = real(J1).^2+real(J2).^2+imag(J1).^2+imag(J1).^2;
end

if issd==1
    p = m_powSpec;
else
    p = log(m_powSpec+eps);
end

t = (0:size(m_powSpec,1)-1)*winstep/fs;
f = fs*(0:size(m_powSpec,2)-1)/size(m_powSpec,2);

num = size(p,2)/2;
p = p(:,1:num)';
f = f(1:num);

% --- Black-blue-yellow-red-purple colormap
function col = bbyrp(handles)

val = 1-get(handles.slide_colormap,'value');

if get(handles.check_derivative,'value')==1
    col = repmat(linspace(0,1,256)',1,3);
    set(handles.axes_spectrum,'color',handles.bgcolor);
    coeffs = [.5 .5 .5]-handles.bgcolor;
    col(:,1) = col(:,1) - coeffs(1)*exp(-5*linspace(-1,1,256).^2)';
    col(:,2) = col(:,2) - coeffs(2)*exp(-5*linspace(-1,1,256).^2)';
    col(:,3) = col(:,3) - coeffs(3)*exp(-5*linspace(-1,1,256).^2)';
    col(find(col<0)) = 0;
    col(find(col>1)) = 1;
    set(handles.axes_spectrum,'clim',[-pi/2 pi/2]*(val+eps)^7);
else
    numblack = round(100*0.75*val);
    numother = round(100*(1-0.75*val)/4);

    col1 = zeros(numblack,3); % Black
    col2 = [linspace(0,0,numother)' linspace(0,0,numother)' linspace(0,0.5,numother)']; % Black to blue
    col3 = [linspace(0,1,numother)' linspace(0,1,numother)' linspace(0.5,0,numother)']; % Blue to yellow
    col4 = [linspace(1,1,numother)' linspace(1,0,numother)' linspace(0,0,numother)']; % Yellow to red
    col5 = [linspace(1,0.25,numother)' linspace(0,0,numother)' linspace(0,0.25,numother)']; % Red to purple

    col = [col1; col2; col3; col4; col5];
end



function edit_buffer_Callback(hObject, eventdata, handles)
% hObject    handle to edit_buffer (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_buffer as text
%        str2double(get(hObject,'String')) returns contents of edit_buffer as a double


% --- Executes during object creation, after setting all properties.
function edit_buffer_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_buffer (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





function edit_timejump_Callback(hObject, eventdata, handles)
% hObject    handle to edit_timejump (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_timejump as text
%        str2double(get(hObject,'String')) returns contents of edit_timejump as a double


% --- Executes during object creation, after setting all properties.
function edit_timejump_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_timejump (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in push_timejump.
function push_timejump_Callback(hObject, eventdata, handles)
% hObject    handle to push_timejump (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


dv = datevec(get(handles.edit_timejump,'string'));
dv = dv(4)+dv(5)/60+dv(6)/3600;
f = find(handles.secofday > dv);
if ~isempty(f)
    handles.currentfile = f(1);
else
    handles.currentfile = length(handles.secofday);
end

handles.starttime = 0;
handles = new_file(handles);
guidata(hObject, handles);
song_gui('push_segment_Callback',gcbo,[],guidata(gcbo))


% --- Executes on button press in check_filter.
function check_filter_Callback(hObject, eventdata, handles)
% hObject    handle to check_filter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of check_filter




% --- Executes on selection change in list_files.
function list_files_Callback(hObject, eventdata, handles)
% hObject    handle to list_files (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns list_files contents as cell array
%        contents{get(hObject,'Value')} returns selected item from list_files

if strcmp(get(gcf,'selectiontype'),'open')
    handles.currentfile = handles.fileorder(get(handles.list_files,'value'));
else
    return
end

handles.starttime = 0;
handles = new_file(handles);
guidata(hObject, handles);
song_gui('push_segment_Callback',gcbo,[],guidata(gcbo))



% --- Executes during object creation, after setting all properties.
function list_files_CreateFcn(hObject, eventdata, handles)
% hObject    handle to list_files (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on button press in push_snap.
function push_snap_Callback(hObject, eventdata, handles)
% hObject    handle to push_snap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

h = figure(2);
set(h,'visible','off');
set(h,'units','inches');
set(h,'position',get(handles.axes_spectrum,'position'));
set(h,'color',get(handles.axes_spectrum,'color'));
subplot('position',[0 0 1 1]);
hold on

m = get(handles.axes_spectrum,'children');
for c = 1:length(m)
    imagesc(get(m(c),'xdata'),get(m(c),'ydata'),get(m(c),'cdata'));
end
xlim(get(handles.axes_spectrum,'xlim'));
ylim(get(handles.axes_spectrum,'ylim'));
set(gca,'clim',get(handles.axes_spectrum,'clim'));
colormap(bbyrp(handles))
axis off

ps = get(h,'position');
ps(3) = str2num(get(handles.edit_inpsec,'string'))*str2num(get(handles.edit_timescale,'string'));
ps(4) = str2num(get(handles.edit_height,'string'));
set(h,'position',ps);

print -dmeta -f2
delete(h)


function edit_saturation_Callback(hObject, eventdata, handles)
% hObject    handle to edit_saturation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_saturation as text
%        str2double(get(hObject,'String')) returns contents of edit_saturation as a double


% --- Executes during object creation, after setting all properties.
function edit_saturation_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_saturation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





function edit_inpsec_Callback(hObject, eventdata, handles)
% hObject    handle to edit_inpsec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_inpsec as text
%        str2double(get(hObject,'String')) returns contents of edit_inpsec as a double

handles = update_worksheet(handles);
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function edit_inpsec_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_inpsec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





function edit_height_Callback(hObject, eventdata, handles)
% hObject    handle to edit_height (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_height as text
%        str2double(get(hObject,'String')) returns contents of edit_height as a double

handles = update_worksheet(handles);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit_height_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_height (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on button press in check_usesegments.
function check_usesegments_Callback(hObject, eventdata, handles)
% hObject    handle to check_usesegments (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of check_usesegments




% --- Executes on button press in push_tofile.
function push_tofile_Callback(hObject, eventdata, handles)
% hObject    handle to push_tofile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get file name
dv = datestr(handles.filetime+handles.starttime/(24*60*60),'yy_mm_dd_HH_MM_SS');
[file, path] = uiputfile(['Bird' num2str(handles.birdnumber) '_at_' dv '.jpg'],'Save image');
if ~isstr(file)
    return
end

h = figure(2);
set(h,'visible','off');
set(h,'units','inches');
set(h,'position',get(handles.axes_spectrum,'position'));
set(h,'color',get(handles.axes_spectrum,'color'));
subplot('position',[0 0 1 1]);
hold on

m = get(handles.axes_spectrum,'children');
for c = 1:length(m)
    imagesc(get(m(c),'xdata'),get(m(c),'ydata'),get(m(c),'cdata'));
end
xlim(get(handles.axes_spectrum,'xlim'));
ylim(get(handles.axes_spectrum,'ylim'));
set(gca,'clim',get(handles.axes_spectrum,'clim'));
colormap(bbyrp(handles))
axis off

ps = get(h,'position');
ps(3) = str2num(get(handles.edit_inpsec,'string'))*str2num(get(handles.edit_timescale,'string'));
ps(4) = str2num(get(handles.edit_height,'string'));
set(h,'position',ps);
set(gcf,'paperpositionmode','auto');

print('-djpeg','-f2',[path file]);
delete(h)


% --- Executes on button press in push_exportsound.
function push_exportsound_Callback(hObject, eventdata, handles)
% hObject    handle to push_exportsound (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get file name
dv = datestr(handles.filetime+handles.starttime/(24*60*60),'yy_mm_dd_HH_MM_SS');
[file, path] = uiputfile(['Bird' num2str(handles.birdnumber) '_at_' dv '.wav'],'Save sound');
if ~isstr(file)
    return
end

% Save sound to a file
subplot(handles.axes_spectrum)
xl = xlim;
xl = round(xl*handles.fs);
if xl(1) < 1
    xl(1) = 1;
end
if xl(2) > length(handles.wav)
    xl(2) = length(handles.wav)
end
wavwrite(handles.wav(xl(1):xl(2)),handles.fs,16,[path file]);



function edit_timefrom_Callback(hObject, eventdata, handles)
% hObject    handle to edit_timefrom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_timefrom as text
%        str2double(get(hObject,'String')) returns contents of edit_timefrom as a double


% --- Executes during object creation, after setting all properties.
function edit_timefrom_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_timefrom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_timeto_Callback(hObject, eventdata, handles)
% hObject    handle to edit_timeto (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_timeto as text
%        str2double(get(hObject,'String')) returns contents of edit_timeto as a double


% --- Executes during object creation, after setting all properties.
function edit_timeto_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_timeto (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in push_random.
function push_random_Callback(hObject, eventdata, handles)
% hObject    handle to push_random (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


dv = datevec(get(handles.edit_timefrom,'string'));
tfrom = dv(4)+dv(5)/60+dv(6)/3600;
dv = datevec(get(handles.edit_timeto,'string'));
tto = dv(4)+dv(5)/60+dv(6)/3600;
f = find(handles.secofday >= tfrom & handles.secofday < tto);
if isempty(f)
    errordlg('No files found in the specified range','Error')
    return
else
    handles.currentfile = f(fix(rand*length(f))+1);
end

handles.starttime = 0;
handles = new_file(handles);
guidata(hObject, handles);
song_gui('push_segment_Callback',gcbo,[],guidata(gcbo))


% --- Executes on button press in push_loaddbase.
function push_loaddbase_Callback(hObject, eventdata, handles)
% hObject    handle to push_loaddbase (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get file name
[file, path] = uigetfile('*.mat','Load file name');
if ~isstr(file)
    return
end

load([path file]);
if exist('dbase')
    handles.dbase = dbase;
    guidata(hObject, handles);
    song_gui('push_segment_Callback',gcbo,[],guidata(gcbo))
else
    errordlg('No dbase variable found in the file','Error')
    return
end


% --- Executes on button press in push_savedbase.
function push_savedbase_Callback(hObject, eventdata, handles)
% hObject    handle to push_savedbase (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get file name
[file, path] = uiputfile('*.mat','Save file name');
if ~isstr(file)
    return
end

% Save current data into a structure
handles = updatedbase(handles);

% Save database to a file
dbase = handles.dbase;
save([path file],'dbase');

% --- Updates the database
function handles = updatedbase(handles)

if isfield(handles,'old_file')
    fnum = handles.old_file;
    if isfield(handles,'dbase')
        f = find(handles.dbase.DateAndTime==handles.filetime);
        if isempty(f)
            j = length(handles.dbase.DateAndTime)+1;
        else
            j = f;
        end
    else
        j = 1;
    end
    handles.dbase.BirdNumber(j) = handles.birdnumber;
    handles.dbase.DateAndTime(j) = handles.filetime;
    handles.dbase.SegmentTimes{j} = handles.segments;
    handles.dbase.SegmentTitles{j} = handles.segmenttitles;
    handles.dbase.IsSelected{j} = handles.selectedseg;
end


% --- Executes on button press in push_cleardbase.
function push_cleardbase_Callback(hObject, eventdata, handles)
% hObject    handle to push_cleardbase (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isfield(handles,'dbase')
    handles = rmfield(handles,'dbase');
    guidata(hObject, handles);
end


% --- Executes on button press in push_selectall.
function push_selectall_Callback(hObject, eventdata, handles)
% hObject    handle to push_selectall (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.selectedseg = ones(size(handles.selectedseg));
guidata(hObject, handles);
set(handles.segmentplots(find(handles.selectedseg==1)),'color','r');
set(handles.segmentplots(find(handles.selectedseg==0)),'color','g');

% --- Executes on button press in push_unselect.
function push_unselect_Callback(hObject, eventdata, handles)
% hObject    handle to push_unselect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.selectedseg = zeros(size(handles.selectedseg));
guidata(hObject, handles);
set(handles.segmentplots(find(handles.selectedseg==1)),'color','r');
set(handles.segmentplots(find(handles.selectedseg==0)),'color','g');


% --- Executes on button press in push_exportsyllables.
function push_exportsyllables_Callback(hObject, eventdata, handles)
% hObject    handle to push_exportsyllables (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

direct = uigetdir(pwd,'Directory name');
if ~isstr(direct)
    return
end

seg_list = find(handles.selectedseg==1);
isin = (handles.segments/handles.fs > handles.starttime) & (handles.segments/handles.fs < handles.starttime+str2num(get(handles.edit_timescale,'string')));
isin = sum(isin,2)';
seg_list = intersect(seg_list,find(isin>0));

for c = seg_list
    dv = datestr(handles.filetime,'_yy_mm_dd_HH_MM_SS');
    fname = [handles.segmenttitles{c} '_syll_' num2str(c,'%03.f') '_bird' num2str(handles.birdnumber) '_in' dv '.wav'];
    wavwrite(handles.wav(round(handles.segments(c,1):min([handles.segments(c,2) length(handles.wav)]))),handles.fs,16,[direct '\' fname]);
end

msgbox([num2str(length(seg_list)) ' syllables written.'],'Done');


% --- Executes on button press in push_color.
function push_color_Callback(hObject, eventdata, handles)
% hObject    handle to push_color (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.bgcolor = uisetcolor(handles.bgcolor, 'Background color');
guidata(hObject, handles);
subplot(handles.axes_spectrum);
colormap(bbyrp(handles))



function edit_wsheight_Callback(hObject, eventdata, handles)
% hObject    handle to edit_wsheight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_wsheight as text
%        str2double(get(hObject,'String')) returns contents of edit_wsheight as a double

handles = update_worksheet(handles);
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function edit_wsheight_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_wsheight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_wswidth_Callback(hObject, eventdata, handles)
% hObject    handle to edit_wswidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_wswidth as text
%        str2double(get(hObject,'String')) returns contents of edit_wswidth as a double

handles = update_worksheet(handles);
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function edit_wswidth_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_wswidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_wstitle_Callback(hObject, eventdata, handles)
% hObject    handle to edit_wstitle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_wstitle as text
%        str2double(get(hObject,'String')) returns contents of edit_wstitle as a double


% --- Executes during object creation, after setting all properties.
function edit_wstitle_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_wstitle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in push_wsexport.
function push_wsexport_Callback(hObject, eventdata, handles)
% hObject    handle to push_wsexport (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


height = str2num(get(handles.edit_wsheight,'string'));
width = str2num(get(handles.edit_wswidth,'string'));
margin = str2num(get(handles.edit_wsmargin,'string'));

imgheight = str2num(get(handles.edit_height,'string'));
imgwidth = str2num(get(handles.edit_inpsec,'string'));

topbar = 0.3;
vertspace = 0.2;
horspace = 0.1;

aretitles = 0;
for c = 1:length(handles.ws_segmenttitles)
    ie = cellfun('isempty',handles.ws_segmenttitles{c});
    if sum(1-ie) > 0
        aretitles = 1;
    end
end
if aretitles == 1
    vertspace = vertspace * 2;
end

numlines = fix((height-2*margin-topbar)/(imgheight+vertspace));

lns = cell(1,0);
durs = [];
if get(handles.check_wschrono,'value')==0
    for c = 1:length(handles.ws_times)
        if length(lns)==0 | get(handles.check_wsoneperline,'value')==1
            indx = length(lns)+1;
            lns{indx} = [];
            durs(indx) = -horspace;
        else
            f = find(durs + horspace + length(handles.ws_sounds{c})/handles.ws_fs(c)*imgwidth + 2*margin <= width);
            if isempty(f)
                indx = length(lns)+1;
                lns{indx} = [];
                durs(indx) = -horspace;
            else
                indx = f(find(durs(f)==max(durs(f))));
                indx = indx(1);
            end
        end

        lns{indx} = [lns{indx} c];
        durs(indx) = durs(indx) + horspace + length(handles.ws_sounds{c})/handles.ws_fs(c)*imgwidth;
    end
else
    k = sortrows([handles.ws_times' (1:length(handles.ws_times))']);
    if ~isempty(k)
        for i = 1:size(k,1)
            c = k(i,2);
            if length(lns)==0 | get(handles.check_wsoneperline,'value')==1
                indx = length(lns)+1;
                lns{indx} = [];
                durs(indx) = -horspace;
            else
                if durs(end) + horspace + length(handles.ws_sounds{c})/handles.ws_fs(c)*imgwidth + 2*margin > width
                    indx = length(lns)+1;
                    lns{indx} = [];
                    durs(indx) = -horspace;
                else
                    indx = length(lns);
                end
            end

            lns{indx} = [lns{indx} c];
            durs(indx) = durs(indx) + horspace + length(handles.ws_sounds{c})/handles.ws_fs(c)*imgwidth;
        end
    end
end


max_page = ceil(length(lns)/numlines);
if max_page == 0
    max_page = 1;
end
for pg = max_page:-1:1
    
    h(pg) = figure(pg);

    ud.sounds = {};
    ud.fs = [];
    
    uicontrol('Style','text','String',get(handles.edit_wstitle,'string'),'units','normalized','Position', [margin/width (height-margin-topbar)/height (width-2*margin)/width/2 topbar/height],'horizontalalignment','left','fontsize',12,'backgroundcolor',get(gcf,'color'));
    uicontrol('Style','text','String',['Page ' num2str(pg)],'units','normalized','Position', [.5 (height-margin-topbar)/height (width-2*margin)/width/2 topbar/height],'horizontalalignment','right','fontsize',12,'backgroundcolor',get(gcf,'color'));

    for c = numlines*(pg-1)+1:numlines*pg
        if c <= length(lns)
            indent = (width-durs(c))/2;
            for i = 1:length(lns{c})
                d = mod(c-1,numlines)+1;
                
                xs = [indent indent+range(handles.ws_sonograms{lns{c}(i)}.xlim)*imgwidth];
                ys = height-[margin+topbar+imgheight*(d)+vertspace*d margin+topbar+imgheight*(d-1)+vertspace*d];
                im(1) = subplot('position',[xs(1)/width ys(1)/height range(xs)/width range(ys)/height]);
                set(gca,'color',handles.ws_sonograms{lns{c}(i)}.color);
                hold on
                for j = 1:length(handles.ws_sonograms{lns{c}(i)}.cdata)
                    m = handles.ws_sonograms{lns{c}(i)}.cdata{j};
                    m3 = zeros(size(m,1),size(m,2),3);
                    m(find(m<handles.ws_sonograms{lns{c}(i)}.clim(1))) = handles.ws_sonograms{lns{c}(i)}.clim(1);
                    m(find(m>handles.ws_sonograms{lns{c}(i)}.clim(2))) = handles.ws_sonograms{lns{c}(i)}.clim(2);
                    m = (m-handles.ws_sonograms{lns{c}(i)}.clim(1))/range(handles.ws_sonograms{lns{c}(i)}.clim);
                    m = fix(m*(size(handles.ws_sonograms{lns{c}(i)}.colormap,1)-1))+1;
                    for k = 1:3
                        m3(:,:,k) = reshape(handles.ws_sonograms{lns{c}(i)}.colormap(m,k),size(m));
                    end
                    im(j+1) = imagesc(handles.ws_sonograms{lns{c}(i)}.xdata{j},handles.ws_sonograms{lns{c}(i)}.ydata{j},m3);
                end
                xlim(handles.ws_sonograms{lns{c}(i)}.xlim);
                ylim(handles.ws_sonograms{lns{c}(i)}.ylim);
                set(gca,'xtick',[],'ytick',[],'xcolor',handles.ws_sonograms{lns{c}(i)}.color,'ycolor',handles.ws_sonograms{lns{c}(i)}.color)

                indx = length(ud.fs)+1;
                ud.sounds{indx} = handles.ws_sounds{lns{c}(i)};
                ud.fs(indx) = handles.ws_fs(lns{c}(i));
                set(im,'ButtonDownFcn',['ud=get(gcf,''UserData''); sound(ud.sounds{' num2str(indx) '},ud.fs(' num2str(indx) '))']);
                
                if aretitles == 0
                    uicontrol('Style','text','String',datestr(handles.ws_times(lns{c}(i)),'mm/dd/yy HH:MM:SS'),'units','normalized','Position', [xs(1)/width ys(2)/height range(xs)/width vertspace/height/2],'horizontalalignment','center','backgroundcolor',get(gcf,'color'));
                else
                    uicontrol('Style','text','String',datestr(handles.ws_times(lns{c}(i)),'mm/dd/yy HH:MM:SS'),'units','normalized','Position', [xs(1)/width ys(2)/height range(xs)/width vertspace/height*(2/3)],'horizontalalignment','center','backgroundcolor',get(gcf,'color'));
                    for j = 1:length(handles.ws_segments{lns{c}(i)})
                        uicontrol('Style','text','String',handles.ws_segmenttitles{lns{c}(i)}{j},'units','normalized','Position', [(xs(1)+handles.ws_segments{lns{c}(i)}(j)*imgwidth-.1)/width ys(2)/height .2/width vertspace/height/4],'horizontalalignment','center','backgroundcolor',get(gcf,'color'));
                    end
                end
                indent = indent + length(handles.ws_sounds{lns{c}(i)})/handles.ws_fs(lns{c}(i))*imgwidth + horspace;
            end
        end
    end
    
    set(gcf,'Userdata',ud);
end

set(h, 'PaperUnits', 'inches');
set(h, 'PaperSize', [min([width height]) max([width height])]);
set(h, 'PaperPosition', [0 0 width height]);
if width > height
    set(h, 'PaperOrientation', 'landscape');
else
    set(h, 'PaperOrientation', 'portrait');
end

% --- Executes on button press in push_wsappend.
function push_wsappend_Callback(hObject, eventdata, handles)
% hObject    handle to push_wsappend (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


indx = length(handles.ws_times)+1;

handles.ws_times(indx) = handles.filetime + handles.starttime/(24*60*60);

% set(handles.axes_spectrum,'tickdir','out','xcolor',get(handles.axes_spectrum,'color'),'ycolor',get(handles.axes_spectrum,'color'))
% img = getframe(handles.axes_spectrum);
% handles.ws_sonograms{indx} = img.cdata;
% set(handles.axes_spectrum,'tickdir','in','xcolor',[0 0 0],'ycolor',[0 0 0])

m = get(handles.axes_spectrum,'children');
for c = 1:length(m)
    handles.ws_sonograms{indx}.xdata{c} = get(m(c),'xdata');
    f = find(get(m(c),'ydata')>.5 & get(m(c),'ydata')<9);
    handles.ws_sonograms{indx}.ydata{c} = get(m(c),'ydata');
    handles.ws_sonograms{indx}.ydata{c} = handles.ws_sonograms{indx}.ydata{c}(f);
    handles.ws_sonograms{indx}.cdata{c} = get(m(c),'cdata');
    handles.ws_sonograms{indx}.cdata{c} = handles.ws_sonograms{indx}.cdata{c}(f,:);
end
handles.ws_sonograms{indx}.xlim = get(handles.axes_spectrum,'xlim');
handles.ws_sonograms{indx}.ylim = get(handles.axes_spectrum,'ylim');
handles.ws_sonograms{indx}.clim = get(handles.axes_spectrum,'clim');
handles.ws_sonograms{indx}.color = get(handles.axes_spectrum,'color');
handles.ws_sonograms{indx}.colormap = bbyrp(handles);

st = max([1 round(handles.starttime*handles.fs)]);
fn = min([round((handles.starttime+str2num(get(handles.edit_timescale,'string')))*handles.fs) length(handles.wav)]);
handles.ws_sounds{indx} = handles.wav(st:fn);
handles.ws_sounds{indx} = [handles.ws_sounds{indx}; zeros(round(str2num(get(handles.edit_timescale,'string'))*handles.fs-length(handles.ws_sounds{indx})),1)];
handles.ws_fs(indx) = handles.fs;

seg_list = find(handles.selectedseg==1);
if get(handles.check_currentwindow,'value')==1
    isin = (handles.segments/handles.fs > handles.starttime) & (handles.segments/handles.fs < handles.starttime+str2num(get(handles.edit_timescale,'string')));
    isin = sum(isin,2)';
    seg_list = intersect(seg_list,find(isin>0));
end

handles.ws_segments{indx} = mean(handles.segments(seg_list,:),2)/handles.fs - handles.starttime;
handles.ws_segmenttitles{indx} = handles.segmenttitles(seg_list);

handles.ws_page = 0; % jump to the last page

guidata(hObject, handles);
handles = update_worksheet(handles);
guidata(hObject, handles);


% --- Updates the worksheet plot
function handles = update_worksheet(handles);

subplot(handles.axes_worksheet);
cla

height = str2num(get(handles.edit_wsheight,'string'));
width = str2num(get(handles.edit_wswidth,'string'));
margin = str2num(get(handles.edit_wsmargin,'string'));

imgheight = str2num(get(handles.edit_height,'string'));
imgwidth = str2num(get(handles.edit_inpsec,'string'));

topbar = 0.3;
vertspace = 0.2;
horspace = 0.1;

aretitles = 0;
for c = 1:length(handles.ws_segmenttitles)
    ie = cellfun('isempty',handles.ws_segmenttitles{c});
    if sum(1-ie) > 0
        aretitles = 1;
    end
end
if aretitles == 1
    vertspace = vertspace * 2;
end

numlines = fix((height-2*margin-topbar)/(imgheight+vertspace));

lns = cell(1,0);
durs = [];
if get(handles.check_wschrono,'value')==0
    for c = 1:length(handles.ws_times)
        if length(lns)==0 | get(handles.check_wsoneperline,'value')==1
            indx = length(lns)+1;
            lns{indx} = [];
            durs(indx) = -horspace;
        else
            f = find(durs + horspace + length(handles.ws_sounds{c})/handles.ws_fs(c)*imgwidth + 2*margin <= width);
            if isempty(f)
                indx = length(lns)+1;
                lns{indx} = [];
                durs(indx) = -horspace;
            else
                indx = f(find(durs(f)==max(durs(f))));
                indx = indx(1);
            end
        end

        lns{indx} = [lns{indx} c];
        durs(indx) = durs(indx) + horspace + length(handles.ws_sounds{c})/handles.ws_fs(c)*imgwidth;
    end
else
    k = sortrows([handles.ws_times' (1:length(handles.ws_times))']);
    if ~isempty(k)
        for i = 1:size(k,1)
            c = k(i,2);
            if length(lns)==0 | get(handles.check_wsoneperline,'value')==1
                indx = length(lns)+1;
                lns{indx} = [];
                durs(indx) = -horspace;
            else
                if durs(end) + horspace + length(handles.ws_sounds{c})/handles.ws_fs(c)*imgwidth + 2*margin > width
                    indx = length(lns)+1;
                    lns{indx} = [];
                    durs(indx) = -horspace;
                else
                    indx = length(lns);
                end
            end

            lns{indx} = [lns{indx} c];
            durs(indx) = durs(indx) + horspace + length(handles.ws_sounds{c})/handles.ws_fs(c)*imgwidth;
        end
    end
end

plot([0 width width 0 0],[0 0 height height 0],'-k');
hold on
axis equal
axis tight

handles.ws_patches = [];
patch([margin width-margin width-margin margin],[margin margin margin+topbar margin+topbar],[.5 .5 .5])
max_page = ceil(length(lns)/numlines);
if max_page == 0;
    max_page = 1;
end
if handles.ws_page < 1
    handles.ws_page = max_page;
end
if handles.ws_page > max_page
    handles.ws_page = 1;
end
set(handles.text_wspage,'string',num2str(handles.ws_page));
for c = numlines*(handles.ws_page-1)+1:numlines*handles.ws_page
    if c <= length(lns)
        indent = (width-durs(c))/2;
        for i = 1:length(lns{c})
            d = mod(c-1,numlines)+1;
            xs = [indent repmat(indent+length(handles.ws_sounds{lns{c}(i)})/handles.ws_fs(lns{c}(i))*imgwidth,1,2) indent];
            ys = [repmat(margin+topbar+imgheight*(d-1)+vertspace*d,1,2) repmat(margin+topbar+imgheight*d+vertspace*d,1,2)];
            handles.ws_patches(lns{c}(i)) = patch(xs,ys,[.5 .5 .75]);
            indent = indent + length(handles.ws_sounds{lns{c}(i)})/handles.ws_fs(lns{c}(i))*imgwidth + horspace;
        end
    end
end

set(handles.ws_patches,'buttondownfcn','song_gui(''selectpatch'',gcbo,[],guidata(gcbo))');
if ~isempty(handles.ws_patches)
    set(handles.ws_patches(end),'facecolor',[1 0 0])
end

set(gca,'ydir','reverse');
axis off


% --- Select a worksheet patch
function selectpatch(hObject, eventdata, handles)

h = findobj('type','patch');
h = intersect(h,handles.ws_patches);
set(h,'facecolor',[.5 .5 .75]);

set(hObject,'facecolor',[1 0 0]);

if strcmp(get(gcf,'selectiontype'),'open')
    song_gui('push_wsview_Callback',gcbo,[],guidata(gcbo));
end


function edit_wsmargin_Callback(hObject, eventdata, handles)
% hObject    handle to edit_wsmargin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_wsmargin as text
%        str2double(get(hObject,'String')) returns contents of edit_wsmargin as a double

handles = update_worksheet(handles);
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function edit_wsmargin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_wsmargin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in push_wsnew.
function push_wsnew_Callback(hObject, eventdata, handles)
% hObject    handle to push_wsnew (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.ws_times = [];
handles.ws_sonograms = cell(1,0);
handles.ws_sounds = cell(1,0);
handles.ws_fs = [];
handles.ws_segments = cell(1,0);
handles.ws_segmenttitles = cell(1,0);
handles.ws_page = 1;

guidata(hObject, handles);
handles = update_worksheet(handles);
guidata(hObject, handles);


% --- Executes on button press in check_wsoneperline.
function check_wsoneperline_Callback(hObject, eventdata, handles)
% hObject    handle to check_wsoneperline (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of check_wsoneperline

handles = update_worksheet(handles);
guidata(hObject, handles);


% --- Executes on button press in check_wschrono.
function check_wschrono_Callback(hObject, eventdata, handles)
% hObject    handle to check_wschrono (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of check_wschrono

handles = update_worksheet(handles);
guidata(hObject, handles);


% --- Executes on button press in push_wsdelete.
function push_wsdelete_Callback(hObject, eventdata, handles)
% hObject    handle to push_wsdelete (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isempty(handles.ws_patches)
    return
end

for c = 1:length(handles.ws_patches)
    if strcmp(get(handles.ws_patches(c),'type'),'patch')
        cl = get(handles.ws_patches(c),'facecolor');
        if sum(cl==[1 0 0])==3
            indx = c;
        end
    end
end

handles.ws_times = handles.ws_times([1:indx-1 indx+1:end]);
handles.ws_sonograms(indx) = [];
handles.ws_sounds(indx) = [];
handles.ws_segments(indx) = [];
handles.ws_segmenttitles(indx) = [];
handles.ws_fs = handles.ws_fs([1:indx-1 indx+1:end]);;

guidata(hObject, handles);
handles = update_worksheet(handles);
guidata(hObject, handles);

% --- Executes on button press in push_wsview.
function push_wsview_Callback(hObject, eventdata, handles)
% hObject    handle to push_wsview (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isempty(handles.ws_patches)
    return
end

h = findobj('type','patch','facecolor',[1 0 0]);
h = intersect(h,handles.ws_patches);
indx = find(handles.ws_patches==h);

h = figure;
set(h,'units','inches');
subplot('position',[0 0 1 1]);

set(gca,'color',handles.ws_sonograms{indx}.color);
hold on
for c = 1:length(handles.ws_sonograms{indx}.cdata)
    imagesc(handles.ws_sonograms{indx}.xdata{c},handles.ws_sonograms{indx}.ydata{c},handles.ws_sonograms{indx}.cdata{c});
end
xlim(handles.ws_sonograms{indx}.xlim);
ylim(handles.ws_sonograms{indx}.ylim);
set(gca,'clim',handles.ws_sonograms{indx}.clim);
colormap(handles.ws_sonograms{indx}.colormap)
axis off

ps = get(h,'position');
ps(3) = str2num(get(handles.edit_inpsec,'string'))*length(handles.ws_sounds{indx})/handles.ws_fs(indx);
ps(4) = str2num(get(handles.edit_height,'string'));
set(h,'position',ps);


% --- Executes on button press in push_wsleft.
function push_wsleft_Callback(hObject, eventdata, handles)
% hObject    handle to push_wsleft (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.ws_page = handles.ws_page-1;
guidata(hObject, handles);
handles = update_worksheet(handles);
guidata(hObject, handles);

% --- Executes on button press in push_wsright.
function push_wsright_Callback(hObject, eventdata, handles)
% hObject    handle to push_wsright (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.ws_page = handles.ws_page+1;
guidata(hObject, handles);
handles = update_worksheet(handles);
guidata(hObject, handles);


% --- Executes on button press in check_currentwindow.
function check_currentwindow_Callback(hObject, eventdata, handles)
% hObject    handle to check_currentwindow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of check_currentwindow




% --- Executes on button press in push_wsexportsounds.
function push_wsexportsounds_Callback(hObject, eventdata, handles)
% hObject    handle to push_wsexportsounds (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


direct = uigetdir(pwd,'Directory name');
if ~isstr(direct)
    return
end

for c = 1:length(handles.ws_sounds)
    fname = [get(handles.edit_wstitle,'string') '_' datestr(handles.ws_times(c),'yy_mm_dd_HH_MM_SS')];
    wavwrite(handles.ws_sounds{c},handles.ws_fs(c),16,[direct '\' fname]);
end

msgbox([num2str(length(handles.ws_sounds)) ' files written.'],'Done');


% --- Executes on button press in check_autoscale.
function check_autoscale_Callback(hObject, eventdata, handles)
% hObject    handle to check_autoscale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of check_autoscale


if get(handles.check_autoscale,'value')==1
    set(handles.edit_timescale,'string',num2str(length(handles.wav)/handles.fs));
    song_gui('edit_timescale_Callback',gcbo,[],guidata(gcbo));
end