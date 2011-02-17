function varargout = rawPowerGUI(varargin)
% RAWPOWERGUI M-file for rawPowerGUI.fig
%      RAWPOWERGUI, by itself, creates a new RAWPOWERGUI or raises the existing
%      singleton*.
%
%      H = RAWPOWERGUI returns the handle to a new RAWPOWERGUI or the handle to
%      the existing singleton*.
%
%      RAWPOWERGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in RAWPOWERGUI.M with the given input arguments.
%
%      RAWPOWERGUI('Property','Value',...) creates a new RAWPOWERGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before rawPowerGUI_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to rawPowerGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help rawPowerGUI

% Last Modified by GUIDE v2.5 16-Feb-2011 17:13:35

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @rawPowerGUI_OpeningFcn, ...
    'gui_OutputFcn',  @rawPowerGUI_OutputFcn, ...
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


% --- Executes just before rawPowerGUI is made visible.
function rawPowerGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to rawPowerGUI (see VARARGIN)

% Choose default command line output for rawPowerGUI
handles.output = hObject;

if nargin > 3
    % we were passed handles from rulesGUI
    rulesHandles = varargin{1};
    exper = rulesHandles.exper;
    if ~isempty(exper)
        handles.pathName = exper.dir;
        handles.fileName = 'exper.mat'; %%%FIXME
        handles.birdName = exper.birdname;
        handles.experName = exper.expername;
        handles.fs = exper.desiredInSampRate;
        handles.audioCh = exper.audioCh;
        handles.exper = exper;
        % put list of files in box
        handles.files = dir([handles.pathName '*.dat']);
        n = (1:length(handles.files))';
        str = mat2cell(n,ones(size(n)), 1);
        set(handles.listFile,'String',str);
        set(handles.listFile,'Value',1);
        % if(get(handles.checkAutoshow,'Value') == 1)
        %     showFile(1,handles)
        % end
    end
    try
        p = rulesHandles.rules(rulesHandles.rSel).params;
        set(handles.editFilterLength,'String',num2str(p.filterLength))
        set(handles.editThresh,'String',num2str(p.threshold))
        set(handles.editTimeThresh,'String',num2str(p.timeAbove))
        handles.params = p;
    catch
        e = lasterror;
        if strcmp(e.identifier,'MATLAB:nonExistentField')
            % params field or one of its subfields doesn't exist. Recover
            % by just not loading anyting
            handles.params.stepsAbove = 0;
        end
    end
end

handles.tdt_fs = 24414; %%%FIXME

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes rawPowerGUI wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = rawPowerGUI_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.params.filterFunc = @rawPowerFilterFunc;
handles.params.dependencies = [];
varargout{1} = handles.params;
delete(handles.figure1)


% --- Executes on selection change in listFile.
function listFile_Callback(hObject, eventdata, handles)
% hObject    handle to listFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns listFile contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listFile
if(get(handles.checkAutoshow,'Value') == 1)
    showFile(get(hObject,'Value'),handles)
end


% --- Executes during object creation, after setting all properties.
function listFile_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in buttonShow.
function buttonShow_Callback(hObject, eventdata, handles)
% hObject    handle to buttonShow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
showFile(get(handles.listFile,'Value'),handles)



% --- Executes on button press in buttonPlay.
function buttonPlay_Callback(hObject, eventdata, handles)
% hObject    handle to buttonPlay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
audio = loadAudio(handles.exper, get(handles.listFile,'Value'));
sound(audio,handles.fs);


function editThresh_Callback(hObject, eventdata, handles)
% hObject    handle to editThresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editThresh as text
%        str2double(get(hObject,'String')) returns contents of editThresh as a double


% --- Executes during object creation, after setting all properties.
function editThresh_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editThresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in buttonDone.
function buttonDone_Callback(hObject, eventdata, handles)
% hObject    handle to buttonDone (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.params = createFilter(handles);
guidata(hObject,handles)
uiresume(handles.figure1)

% --- Executes on button press in checkAutoshow.
function checkAutoshow_Callback(hObject, eventdata, handles)
% hObject    handle to checkAutoshow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkAutoshow

function showFile(n, handles)
cla(handles.axesFiltered)
cla(handles.axesSpecgram)
% make filter
handles.params = createFilter(handles);
% load audio
audio = loadAudio(handles.exper, get(handles.listFile,'Value'));
% audio = audio - mean(audio); %%%DEBUG
audio_tdt = resample(audio, handles.tdt_fs, handles.fs);
% run filter on audio
[tf, sigfilt] = rawPowerFilterFunc(audio_tdt, handles.params);

% plot results
dt = 1/handles.tdt_fs;
t = (0:length(tf)-1) .* dt;
yrange = max(sigfilt)-min(sigfilt);
ymax = max(sigfilt) + 0.1*yrange;
ymin = min(sigfilt) - 0.1*yrange;
% ymin = max(-40,ymin); % do not let min go below -40. The only time this seems to happen is if there is a glitch in recording.
hold(handles.axesFiltered,'off')
plot(handles.axesFiltered, t, sigfilt,'k')
hold(handles.axesFiltered,'on')
plot(handles.axesFiltered, t, handles.params.threshold*ones(size(t)),'b:')
% fill in area where tf = true
x = [t t(end) t(1)];
y = ones(1,length(t)+2)*handles.params.threshold;
y(tf) = sigfilt(tf);
set(0,'CurrentFigure',handles.figure1)
set(handles.figure1,'CurrentAxes',handles.axesFiltered)
fill(x, y, 'r','LineStyle','none')
axis(handles.axesFiltered, [t(1) t(end) ymin ymax])
% tf = double(tf);
% tf(tf==0) = nan;
% plot(handles.axesFiltered, t, ymin*tf,'r','LineWidth',7,'MarkerSize',10)
hold(handles.axesFiltered,'off')
% plot spectrogram
set(handles.figure1,'CurrentAxes',handles.axesSpecgram)
displaySpecgramQuick(audio_tdt, handles.tdt_fs, [0000,7000], [-15,5]);
linkaxes([handles.axesSpecgram, handles.axesFiltered],'x')


function p = createFilter(handles)
p.filterLength = str2double(get(handles.editFilterLength,'String'));
p.threshold    = str2double(get(handles.editThresh,'String'));
p.timeAbove    = str2double(get(handles.editTimeThresh,'String'));
p.timeMax      = str2double(get(handles.editTimeMax,'String'));
p.stepsAbove   = floor(p.timeAbove/1000 * handles.tdt_fs)+1;
p.stepsMax     = floor(p.timeMax  /1000 * handles.tdt_fs)+1;
p.Fs           = handles.tdt_fs;

p.Numerator = ones(1,p.filterLength) ./ p.filterLength; %normalize

function [tf, varargout] = rawPowerFilterFunc(sig, p, r)
if ~isfield(p, 'stepsMax')
    p.stepsMax = Inf;% for backwards compatability
end
sig = sig-mean(sig);
temp = filter(p.Numerator, 1, sig.^2);
sigfilt = 20*log10(temp); %convert to dB
threshed = sigfilt > p.threshold;
tf = false(size(threshed));
count = 0;
for ii = 1:length(threshed)
    if threshed(ii)
        count = count + 1;
        if count >= p.stepsAbove && count < p.stepsMax
            tf(ii) = true;
        end
    else
        count = 0;
    end
end
if nargout > 1
    varargout{1} = sigfilt;
end


function editTimeThresh_Callback(hObject, eventdata, handles)
% hObject    handle to editTimeThresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editTimeThresh as text
%        str2double(get(hObject,'String')) returns contents of editTimeThresh as a double


% --- Executes during object creation, after setting all properties.
function editTimeThresh_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editTimeThresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





function editFilterLength_Callback(hObject, eventdata, handles)
% hObject    handle to editFilterLength (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editFilterLength as text
%        str2double(get(hObject,'String')) returns contents of editFilterLength as a double


% --- Executes during object creation, after setting all properties.
function editFilterLength_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editFilterLength (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





function editTimeMax_Callback(hObject, eventdata, handles)
% hObject    handle to editTimeMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editTimeMax as text
%        str2double(get(hObject,'String')) returns contents of editTimeMax as a double


% --- Executes during object creation, after setting all properties.
function editTimeMax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editTimeMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


