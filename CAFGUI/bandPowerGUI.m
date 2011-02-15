function varargout = bandPowerGUI(varargin)
% BANDPOWERGUI M-file for bandPowerGUI.fig
%      BANDPOWERGUI, by itself, creates a new BANDPOWERGUI or raises the existing
%      singleton*.
%
%      H = BANDPOWERGUI returns the handle to a new BANDPOWERGUI or the handle to
%      the existing singleton*.
%
%      BANDPOWERGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BANDPOWERGUI.M with the given input arguments.
%
%      BANDPOWERGUI('Property','Value',...) creates a new BANDPOWERGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before bandPowerGUI_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to bandPowerGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help bandPowerGUI

% Last Modified by GUIDE v2.5 24-Aug-2010 13:47:53

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @bandPowerGUI_OpeningFcn, ...
    'gui_OutputFcn',  @bandPowerGUI_OutputFcn, ...
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


% --- Executes just before bandPowerGUI is made visible.
function bandPowerGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to bandPowerGUI (see VARARGIN)

% Choose default command line output for bandPowerGUI
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
    handles.tdt_fs = 24414;
    handles.params.Fs = handles.tdt_fs; 
    handles.params.freqLo1 = 5000;
    handles.params.freqHi1 = 7000;
    handles.params.width1 = 200;
    handles.params.dbDown1 = 50;
    handles.params.freqLo2 = 500;
    handles.params.freqHi2 = 8000;
    handles.params.width2 = 200;
    handles.params.dbDown2 = 50;
    handles.params.timeAbove = 20; %milliseconds
    handles.params.threshold = 0.8; %ratio between 0 and 1
    if isfield(rulesHandles.rules(rulesHandles.rSel),'params') && ~isempty(rulesHandles.rules(rulesHandles.rSel).params)
        % use catstruct from matlab central to merge default parameters
        % with parameters passed from rules. parameters from rules take
        % precedence. supress warning message about the same field in both
        % structs
        warning('off','catstruct:DuplicatesFound')
        handles.params = catstruct(handles.params, ...
            rulesHandles.rules(rulesHandles.rSel).params);
        warning('on','catstruct:DuplicatesFound')
    end
    set(handles.editFreqLo1,'String',num2str(handles.params.freqLo1));
    set(handles.editFreqLo2,'String',num2str(handles.params.freqLo2));
    set(handles.editFreqHi2,'String',num2str(handles.params.freqHi2));
    set(handles.editFreqHi1,'String',num2str(handles.params.freqHi1));
    set(handles.editWidth1,'String',num2str(handles.params.width1));
    set(handles.editWidth2,'String',num2str(handles.params.width2));
    set(handles.editDbDown1,'String',num2str(handles.params.dbDown1));
    set(handles.editDbDown2,'String',num2str(handles.params.dbDown2));
    set(handles.editThresh,'String',num2str(handles.params.threshold));
    set(handles.editTimeThresh,'String',num2str(handles.params.timeAbove));
end

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes bandPowerGUI wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = bandPowerGUI_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.params.filterFunc = @bandPowerFilterFunc;
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
handles.params.threshold = str2double(get(hObject,'String'));
guidata(hObject,handles)

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
audio = audio - mean(audio);
audio_tdt = resample(audio, handles.tdt_fs, handles.fs);
% run filter on audio
[tf, sigfilt] = bandPowerFilterFunc(audio_tdt, handles.params);

% plot results
dt = 1/handles.tdt_fs;
t = (0:length(tf)-1) .* dt;
yrange = max(sigfilt)-min(sigfilt);
ymax = max(sigfilt) + 0.1*yrange;
ymin = min(sigfilt) - 0.1*yrange;
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
temp = v3strong(...
    handles.params.freqLo1, ...
    handles.params.Fs, ...
    handles.params.width1, ...
    handles.params.dbDown1, ...
    handles.params.freqHi1);
handles.params.coefs1 = temp.Numerator ./ sum(temp.Numerator);
temp = v3strong(...
    handles.params.freqLo2, ...
    handles.params.Fs, ...
    handles.params.width2, ...
    handles.params.dbDown2, ...
    handles.params.freqHi2);
handles.params.coefs2 = temp.Numerator ./ sum(temp.Numerator);
% temp = v3lp(1, handles.tdt_fs, 1000, 40); %% low-pass output of filters
clear temp
temp.Numerator = ones(1,33);
handles.params.lpcoefs = temp.Numerator ./ sum(temp.Numerator);
p = handles.params;
length(p.coefs1)
length(p.coefs2)

function [tf, varargout] = bandPowerFilterFunc(sig, p, r)
filtered1 = (filter(p.coefs1, 1, sig.^2)).^2;
filtered2 = (filter(p.coefs2, 1, sig.^2)).^2;
pow1 = filter(p.lpcoefs,1,filtered1);
pow2 = filter(p.lpcoefs,1,filtered2);
ratio = pow1 ./ (pow1 + pow2);
threshed = ratio > p.threshold;
stepsAbove = ceil(p.timeAbove/1000 * p.Fs);
kernel = ones(1,stepsAbove) / stepsAbove;
tf = filter(kernel,1,threshed) >= (1-2/stepsAbove);
if nargout > 1
    varargout{1} = pow2;%ratio; %%%DEBUG
end
% figure(1)
% ah(1) = subplot(3,1,1);
% plot(filtered1)
% ah(2) = subplot(3,1,2);
% plot(filtered2)
% ah(3) = subplot(3,1,3);
% plot(ratio)
% linkaxes(ah,'x')
% keyboard


function editTimeThresh_Callback(hObject, eventdata, handles)
% hObject    handle to editTimeThresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editTimeThresh as text
%        str2double(get(hObject,'String')) returns contents of editTimeThresh as a double
handles.params.timeAbove = str2double(get(hObject,'String'));
guidata(hObject,handles)

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





function editFreqLo1_Callback(hObject, eventdata, handles)
% hObject    handle to editFreqLo1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editFreqLo1 as text
%        str2double(get(hObject,'String')) returns contents of editFreqLo1 as a double
handles.params.freqLo1 = str2double(get(hObject,'String'));
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function editFreqLo1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editFreqLo1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editFreqHi1_Callback(hObject, eventdata, handles)
% hObject    handle to editFreqHi1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editFreqHi1 as text
%        str2double(get(hObject,'String')) returns contents of editFreqHi1 as a double
handles.params.freqHi1 = str2double(get(hObject,'String'));
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function editFreqHi1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editFreqHi1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editWidth1_Callback(hObject, eventdata, handles)
% hObject    handle to editWidth1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editWidth1 as text
%        str2double(get(hObject,'String')) returns contents of editWidth1 as a double
handles.params.width1 = str2double(get(hObject,'String'));
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function editWidth1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editWidth1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editDbDown1_Callback(hObject, eventdata, handles)
% hObject    handle to editDbDown1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editDbDown1 as text
%        str2double(get(hObject,'String')) returns contents of editDbDown1 as a double
handles.params.dbDown1 = str2double(get(hObject,'String'));
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function editDbDown1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editDbDown1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in buttonCalculate.
function buttonCalculate_Callback(hObject, eventdata, handles)
% hObject    handle to buttonCalculate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function editFreqLo2_Callback(hObject, eventdata, handles)
% hObject    handle to editFreqLo2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editFreqLo2 as text
%        str2double(get(hObject,'String')) returns contents of editFreqLo2 as a double
handles.params.freqLo2 = str2double(get(hObject,'String'));
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function editFreqLo2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editFreqLo2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit13_Callback(hObject, eventdata, handles)
% hObject    handle to edit13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit13 as text
%        str2double(get(hObject,'String')) returns contents of edit13 as a double


% --- Executes during object creation, after setting all properties.
function edit13_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit14_Callback(hObject, eventdata, handles)
% hObject    handle to edit14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit14 as text
%        str2double(get(hObject,'String')) returns contents of edit14 as a double


% --- Executes during object creation, after setting all properties.
function edit14_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editDbDown2_Callback(hObject, eventdata, handles)
% hObject    handle to editDbDown2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editDbDown2 as text
%        str2double(get(hObject,'String')) returns contents of editDbDown2 as a double
handles.params.dbDown2 = str2double(get(hObject,'String'));
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function editDbDown2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editDbDown2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editFreqHi2_Callback(hObject, eventdata, handles)
% hObject    handle to editFreqHi2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editFreqHi2 as text
%        str2double(get(hObject,'String')) returns contents of editFreqHi2 as a double
handles.params.freqHi2 = str2double(get(hObject,'String'));
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function editFreqHi2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editFreqHi2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editWidth2_Callback(hObject, eventdata, handles)
% hObject    handle to editWidth2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editWidth2 as text
%        str2double(get(hObject,'String')) returns contents of editWidth2 as a double
handles.params.width2 = str2double(get(hObject,'String'));
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function editWidth2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editWidth2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


