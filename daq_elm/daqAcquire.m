function varargout = daqAcquire(varargin)
% DAQACQUIRE M-file for daqAcquire.fig
%      DAQACQUIRE, by itself, creates a new DAQACQUIRE or raises the existing
%      singleton*.
%
%      H = DAQACQUIRE returns the handle to a new DAQACQUIRE or the handle to
%      the existing singleton*.
%
%      DAQACQUIRE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DAQACQUIRE.M with the given input arguments.
%
%      DAQACQUIRE('Property','Value',...) creates a new DAQACQUIRE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before daqAcquire_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to daqAcquire_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help daqAcquire

% Last Modified by GUIDE v2.5 07-Jan-2009 17:38:07

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @daqAcquire_OpeningFcn, ...
    'gui_OutputFcn',  @daqAcquire_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_State.gui_Name='daqAcquire';
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before daqAcquire is made visible.
function daqAcquire_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to daqAcquire (see VARARGIN)


set(handles.edit_Folder,'string',pwd);
handles.channels = zeros(1,8);

handles.Times = {};
handles.Files = {};
handles.RecChannels = {};
handles.DataAvailableInfo = {};

% Choose default command line output for daqAcquire
handles.output = hObject;
daq.reset;
d = daq.getDevices();
assert(numel(d) > 0, 'No DAQ found');
niIdx = 0;
for dNo = 1:numel(d)
    if strcmp(d(dNo).Vendor.ID, 'ni')
        niIdx = dNo;
    end
end
assert(niIdx > 0, 'No working NI daq found');
dID = d(niIdx).ID;
s = daq.createSession('ni');
handles.s = s;
handles.dID = dID;
lh = addlistener(s, 'DataAvailable', @(src, event) DataAvailableCallback(hObject, src, event));
handles.listeners = {lh};
set(handles, 'CloseRequestFcn', @my_closereq);
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes daqAcquire wait for user response (see UIRESUME)
% uiwait(handles.fig_daq);


% --- Outputs from this function are returned to the command line.
function varargout = daqAcquire_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in list_Times.
function list_Times_Callback(hObject, eventdata, handles)
% hObject    handle to list_Times (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns list_Times contents as cell array
%        contents{get(hObject,'Value')} returns selected item from list_Times

handles = LoadFiles(handles);


function handles = LoadFiles(handles)

subplot(handles.axes_Main);
cla
hold on
if isempty(handles.Files)
    set(handles.edit_Comment,'string','');
    return
end

indx = get(handles.list_Times,'value');
fls = handles.Files{indx};
data = [];
for c = 1:length(fls)
    load(fls{c});
    data(:,c) = rec.Data;
end

set(handles.edit_Comment,'string',rec.Properties.Values{1});

cols = hsv(size(data,2))*.8;
set(findobj(handles.fig_daq,'style','checkbox'),'backgroundcolor',[.5 .5 .5]);

for c = 1:length(handles.RecChannels{indx})
    plot((0:size(data,1)-1)/rec.Fs,data(:,c),'color',cols(c,:));
    %     plot((0:size(data,1)-1)/rec.Fs,filter(ones(1000,1),1,data(:,c).^2),'color',cols(c,:));
    set(handles.(['check' num2str(handles.RecChannels{indx}(c))]),'backgroundcolor',cols(c,:));
end
xlim([0 size(data,1)-1]/rec.Fs);

axis tight
zoom on


% --- Executes during object creation, after setting all properties.
function list_Times_CreateFcn(hObject, eventdata, handles)
% hObject    handle to list_Times (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in push_Prev.
function push_Prev_Callback(hObject, eventdata, handles)
% hObject    handle to push_Prev (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

indx = get(handles.list_Times,'value');
indx = indx - 1;
if indx == 0
    indx = length(get(handles.list_Times,'string'));
end
set(handles.list_Times,'value',indx);
handles = LoadFiles(handles);

% --- Executes on button press in push_Next.
function push_Next_Callback(hObject, eventdata, handles)
% hObject    handle to push_Next (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

indx = get(handles.list_Times,'value');
indx = indx + 1;
if indx > length(get(handles.list_Times,'string'))
    indx = 1;
end
set(handles.list_Times,'value',indx);
handles = LoadFiles(handles);

function edit_Folder_Callback(hObject, eventdata, handles)
% hObject    handle to edit_Folder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_Folder as text
%        str2double(get(hObject,'String')) returns contents of edit_Folder as a double


% --- Executes during object creation, after setting all properties.
function edit_Folder_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_Folder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in push_Browse.
function push_Browse_Callback(hObject, eventdata, handles)
% hObject    handle to push_Browse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

folder = uigetdir('D:\APPLICATIONS\MATLAB', 'Pick a Directory');
if isstr(folder)
    set(handles.edit_Folder,'string',folder);
end


function edit_Rate_Callback(hObject, eventdata, handles)
% hObject    handle to edit_Rate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_Rate as text
%        str2double(get(hObject,'String')) returns contents of edit_Rate as a double


% --- Executes during object creation, after setting all properties.
function edit_Rate_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_Rate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_Duration_Callback(hObject, eventdata, handles)
% hObject    handle to edit_Duration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_Duration as text
%        str2double(get(hObject,'String')) returns contents of edit_Duration as a double


% --- Executes during object creation, after setting all properties.
function edit_Duration_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_Duration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in check0.
function check0_Callback(hObject, eventdata, handles)
% hObject    handle to check0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of check0

handles = readChecks(handles);
guidata(hObject, handles);

% --- Executes on button press in check4.
function check4_Callback(hObject, eventdata, handles)
% hObject    handle to check4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of check4

handles = readChecks(handles);
guidata(hObject, handles);

% --- Executes on button press in check5.
function check5_Callback(hObject, eventdata, handles)
% hObject    handle to check5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of check5

handles = readChecks(handles);
guidata(hObject, handles);

% --- Executes on button press in check6.
function check6_Callback(hObject, eventdata, handles)
% hObject    handle to check6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of check6

handles = readChecks(handles);
guidata(hObject, handles);

% --- Executes on button press in check1.
function check1_Callback(hObject, eventdata, handles)
% hObject    handle to check1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of check1

handles = readChecks(handles);
guidata(hObject, handles);

% --- Executes on button press in check7.
function check7_Callback(hObject, eventdata, handles)
% hObject    handle to check7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of check7

handles = readChecks(handles);
guidata(hObject, handles);

% --- Executes on button press in check2.
function check2_Callback(hObject, eventdata, handles)
% hObject    handle to check2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of check2

handles = readChecks(handles);
guidata(hObject, handles);

% --- Executes on button press in check3.
function check3_Callback(hObject, eventdata, handles)
% hObject    handle to check3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of check3

handles = readChecks(handles);
guidata(hObject, handles);


function handles = readChecks(handles)
oldChannels = handles.channels;
for c = 0:7
    handles.channels(c+1) = get(handles.(['check' num2str(c)]),'value');
    if handles.channels(c+1) ~= oldChannels(c+1) %Status has changed
        if handles.channels(c+1) %channel has been added
            addAnalogInputChannel(handles.s, handles.dID, c, 'Voltage');
        else %channel has been removed
            removeChannel(handles.s, c);
        end
    end
end


% --- Executes on button press in push_Record.
function push_Record_Callback(hObject, eventdata, handles)
% hObject    handle to push_Record (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%[SoundData,fs]=wavread('C:\Documents and Settings\nsb\Desktop\yael_AIV\2611\BOS_2611\data.wav');
if sum(handles.channels)==0
    return
end

set(handles.push_Record,'ForegroundColor',[1 0 0],'string','STOP');
set(handles.edit_Comment,'string','');
drawnow;

sampleTime = str2num(get(handles.edit_Duration,'string'));
sampRate = str2num(get(handles.edit_Rate,'string'));
chans = find(handles.channels==1)-1;
s = handles.s;
s.Rate = sampRate;% up to 200000
actRate = s.Rate;
s.DurationInSeconds = sampleTime;
startBackground(s);
recTime = now;
bck = get(handles.push_Record,'callback');
set(handles.push_Record,'callback','set(gco,''foregroundcolor'',[0 0 0])')
while (now - recTime)*24*60*60 < sampleTime && sum(get(handles.push_Record,'foregroundcolor'))>0
    set(handles.text_Count,'string',num2str(round((now - recTime)*24*60*60*10)/10));
    drawnow;
    %     if abs(round((now - rec.Time)*24*60*60*10)/10-1)<0.0001 %%%YM  15 Dec %%%%
    %         sound(SoundData(1:min(length(SoundData),(sampleTime-1)*44100)),44100);
    %         t=(now - rec.Time)*24*60*60;
    %     end
    pause(0.1);
end
set(handles.push_Record,'callback',bck);
stop(s);
set(handles.text_Count,'string','');

% rec.Data=[zeros(t*44100,1) ;SoundData(1:min(length(SoundData),(sampleTime-1)*44100))];
% rec.Fs=44100;
%save([filename(1:end-4) 'sound.mat'],'rec');
set(handles.push_Record,'ForegroundColor',[0 0 0],'string','RECORD');

guidata(hObject, handles);


function DataAvailableCallback(hObject, src, event)
handles = guidata(hObject);
handles.DataAvailableInfo = event;
data = event.Data;
rec.Time = event.TriggerTime;
rec.Fs = handles.s.Rate;
rec.Properties.Names = {'Comment'};
rec.Properties.Types = [1];
rec.Properties.Values = {''};
cd(get(handles.edit_Folder,'string'));
cols = hsv(size(data,2))*.8;
set(findobj(handles.fig_daq,'style','checkbox'),'backgroundcolor',[.5 .5 .5]);
fls = {};
for c = 1:length(chans)
    rec.Data = data(:,c);
    filename = ['ds_' datestr(rec.Time,'yyyymmddTHHMMSS') '_chan' num2str(chans(c)) '.mat'];
    fls{end+1} = filename;
    save(filename,'rec');
    set(handles.(['check' num2str(chans(c))]),'backgroundcolor',cols(c,:));
end
subplot(handles.axes_Main);
cla
hold on
for c = 1:length(chans)
    plot((0:size(data,1)-1)/sampRate,data(:,c),'color',cols(c,:));
end
xlim([0 size(data,1)-1]/rec.Fs);

axis tight
zoom on

handles.Times{end+1} = datestr(rec.Time);
handles.Files{end+1} = fls;
handles.RecChannels{end+1} = chans;
str = handles.Times;
for c = 1:length(str)
    str{c} = [num2str(c) ') ' str{c}];
end
set(handles.list_Times,'string',str);
set(handles.list_Times,'value',length(handles.Times));

y = chirp(0:0.00025:0.1,12000,1,20000);
pause(0.2);
if get(handles.check_Chirp,'value')==1
    for c = 0:3;
        pause(0.01);
        sound(y,10000*2^c);
    end
end
guidata(hObject, handles);


function edit_Comment_Callback(hObject, eventdata, handles)
% hObject    handle to edit_Comment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_Comment as text
%        str2double(get(hObject,'String')) returns contents of edit_Comment as a double

indx = get(handles.list_Times,'value');
fls = handles.Files{indx};
data = [];
for c = 1:length(fls)
    load(fls{c});
    rec.Properties.Values{1} = get(handles.edit_Comment,'string');
    save(fls{c},'rec');
end

% --- Executes during object creation, after setting all properties.
function edit_Comment_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_Comment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in push_Delete.
function push_Delete_Callback(hObject, eventdata, handles)
% hObject    handle to push_Delete (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isempty(handles.Files)
    return
end

button = questdlg('Delete file(s)?', 'Delete record', 'No');

if isstr(button) & strcmp(button,'Yes')
    indx = get(handles.list_Times,'value');
    str = get(handles.list_Times,'string');
    handles.Times(indx) = [];
    fls = handles.Files{indx};
    for c = 1:length(fls)
        delete(fls{c});
    end
    handles.Files(indx) = [];
    handles.RecChannels(indx) = [];
    str(indx) = [];
    if isempty(str)
        str = {'No recordings'};
    end
    if indx > length(str)
        set(handles.list_Times,'value',length(str));
    end
    
    for c = 1:length(handles.Files)
        f = findstr(str{c},')');
        str{c}(1:f+1) = [];
        str{c} = [num2str(c) ') ' str{c}];
    end
    set(handles.list_Times,'string',str);
    handles = LoadFiles(handles);
end

guidata(hObject, handles);

function my_closereq(src,callbackdata)
% Close request function
% to display a question dialog box
keyboard;
daq_cleanup(src);
cosereq();
end

function daq_cleanup(hObject)
    handles = guidata(hObject);
    for lNo = 1:numel(handles.listeners)
        delete(handles.listeners{lNo});
    end
    handles.listeners = {};
    delete(handles.s);
    daq.reset;
    guidata(hObject, handles);
end

% --- Executes on button press in check_Chirp.
function check_Chirp_Callback(hObject, eventdata, handles)
% hObject    handle to check_Chirp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of check_Chirp


