function varargout = CAFGUI(varargin)
% CAFGUI M-file for CAFGUI.fig
%      CAFGUI, by itself, creates a new CAFGUI or raises the existing
%      singleton*.
%
%      H = CAFGUI returns the handle to a new CAFGUI or the handle to
%      the existing singleton*.
%
%      CAFGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CAFGUI.M with the given input arguments.
%
%      CAFGUI('Property','Value',...) creates a new CAFGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before CAFGUI_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to CAFGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help CAFGUI

% Last Modified by GUIDE v2.5 10-Feb-2010 18:22:47

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @CAFGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @CAFGUI_OutputFcn, ...
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


% --- Executes just before CAFGUI is made visible.
function CAFGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to CAFGUI (see VARARGIN)

% Choose default command line output for CAFGUI
set(0,'defaulttextinterpreter','none'); % turn off the tex interpreter
handles.output = hObject;
guidata(hObject, handles);
% Update handles structure

% UIWAIT makes CAFGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = CAFGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in buttonCalculate.
function buttonCalculate_Callback(hObject, eventdata, handles)
% hObject    handle to buttonCalculate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

axes(handles.axesFreqResp); % clear axis
cla;
axes(handles.axesTest);
cla;
set(handles.textFilterOrder,'String',''); % clear text
set(handles.textBandFilterOrder,'String','');
set(handles.textFilterDelay,'String','');
set(handles.textStackThreshold,'String','');

handles = Refresh(handles);
guidata(hObject, handles);
%[ja,jb,jc,jd,je,jf,jg,jh,ji,jj, tdt] = feval(handles.cafProgramFunc, 'fcnBirdInfo', ...
%                ['getinfo_',handles.birdName], 'bDebug', false, 'audio', zeros(40000,1));

handles.bandFilters = makeFilter('bUp',handles.bUp,'pitchTarget',handles.pitchTarget,'nudge',handles.nudge,'width',handles.width,...
    'bottomFreq',handles.bottomFreq,'passIn',handles.passIn,'dbDown',handles.dbDown,...
    'filterOverlap',handles.filterOverlap,'harmonics',handles.harmonics,'fs',handles.tdt_fs);

handles = ZeroPad(handles); % pad zero for TDT exporting
axes(handles.axesFreqResp);
cla;
if handles.bUp % pushing up
    F_min = floor((handles.pitchTarget-handles.passIn-handles.width-handles.nudge)/500)*500;
else 
    F_min = 0;
end
F_max = ceil((handles.pitchTarget+handles.passIn+handles.width)*max(handles.harmonics)/500)*500;
F_range = F_min:50:F_max;

% hold on
% for i=handles.harmonics
%     In{i} = freqz(handles.bandFilters.in(i).Numerator,1,F_range,handles.tdt_fs);
%     Out{i} = freqz(handles.bandFilters.out(i).Numerator,1,F_range,handles.tdt_fs);
%     h_in(i) = semilogy(F_range,20*log10(abs(In{i})));
%     h_out(i) = semilogy(F_range,20*log10(abs(Out{i})));
%     h_line(i) = line([handles.pitchTarget*i handles.pitchTarget*i],ylim); % plot pitchTarget
% end
% set(h_line,'color','g','linewidth',2); % pitchTarget line
% xlim([F_min,F_max]);
% ylim([-handles.dbDown 5])


In1 = freqz(handles.bandFilters.in(1).Numerator,1,F_range,handles.tdt_fs);
In2 = freqz(handles.bandFilters.in(2).Numerator,1,F_range,handles.tdt_fs);
In3 = freqz(handles.bandFilters.in(3).Numerator,1,F_range,handles.tdt_fs);
Out1 = freqz(handles.bandFilters.out(1).Numerator,1,F_range,handles.tdt_fs);
Out2 = freqz(handles.bandFilters.out(2).Numerator,1,F_range,handles.tdt_fs);
Out3 = freqz(handles.bandFilters.out(3).Numerator,1,F_range,handles.tdt_fs);
hold on
xlim([F_min,F_max]);
ylim([-handles.dbDown 5])
for i=handles.harmonics
    h_line(i) = line([handles.pitchTarget*i handles.pitchTarget*i],ylim); % plot pitchTarget
end
set(h_line,'color','g','linewidth',2);
% magnitude response of the filter
h_in(1) = semilogy(F_range,20*log10(abs(In1)));
h_in(2) = semilogy(F_range,20*log10(abs(In2)));
h_in(3) = semilogy(F_range,20*log10(abs(In3)));
h_out(1) = semilogy(F_range,20*log10(abs(Out1)));
h_out(2) = semilogy(F_range,20*log10(abs(Out2)));
h_out(3) = semilogy(F_range,20*log10(abs(Out3)));

set(h_in,'color','r','linewidth',2)
set(h_out,'color','b','linewidth',2)
xlabel('Frequency (Hz)','fontsize',12)
ylabel('Magnitude (dB)','fontsize',12)
hold off
grid on

%%% make other filters
handles.lpBands = v3lp(1, handles.tdt_fs, handles.fcBand, handles.dbDownBand); %% low-pass output of filters
handles.lpBands.Numerator = handles.lpBands.Numerator ./ sum(handles.lpBands.Numerator); % normalize

handles.lpBird = v3lp(50, handles.tdt_fs, 400, 50);
handles.lpBird.Numerator = handles.lpBird.Numerator ./ sum(handles.lpBird.Numerator);

handles.delay = (length(handles.bandFilters.in(1).Numerator)/(2*handles.tdt_fs)) + (length(handles.lpBands.Numerator)/(2*handles.tdt_fs));
set(handles.textFilterOrder,'String',num2str(length(handles.bandFilters.in(1).Numerator)-1)); % display fitler bank order
set(handles.textBandFilterOrder,'String',num2str(length(handles.lpBands.Numerator)-1)); % display band filter order
set(handles.textFilterDelay,'String',[num2str(handles.delay*1000,3),' ms']); % display total delay
guidata(hObject, handles);

set(handles.buttonTest,'Enable','on');
set(handles.buttonTestFile,'Enable','on');
set(handles.buttonAllSyllables,'Enable','on');

set(handles.buttonRunTDT,'Enable','on');
set(handles.buttonSampleAudio,'Enable','on');
%set(handles.textFreqLow,'String',floor((handles.pitchTarget-200)/200)*200);
%set(handles.textFreqHigh,'String',ceil((handles.pitchTarget+200)/200)*200),
buttonTest_Callback(hObject, eventdata, handles); % automatically update theoretical response

% --- Executes on selection change in listFiles.
function listFiles_Callback(hObject, eventdata, handles)
% hObject    handle to listFiles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns listFiles contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listFiles

% --- Executes during object creation, after setting all properties.
function listFiles_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listFiles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function textFreqLow_Callback(hObject, eventdata, handles)
% hObject    handle to textFreqLow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of textFreqLow as text
%        str2double(get(hObject,'String')) returns contents of textFreqLow as a double

% --- Executes during object creation, after setting all properties.
function textFreqLow_CreateFcn(hObject, eventdata, handles)
% hObject    handle to textFreqLow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function textFreqHigh_Callback(hObject, eventdata, handles)
% hObject    handle to textFreqHigh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of textFreqHigh as text
%        str2double(get(hObject,'String')) returns contents of textFreqHigh as a double

% --- Executes during object creation, after setting all properties.
function textFreqHigh_CreateFcn(hObject, eventdata, handles)
% hObject    handle to textFreqHigh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function textFreqStep_Callback(hObject, eventdata, handles)
% hObject    handle to textFreqStep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of textFreqStep as text
%        str2double(get(hObject,'String')) returns contents of textFreqStep
%        as a double

% --- Executes during object creation, after setting all properties.
function textFreqStep_CreateFcn(hObject, eventdata, handles)
% hObject    handle to textFreqStep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function textBirdName_Callback(hObject, eventdata, handles)
% hObject    handle to textBirdName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of textBirdName as text
%        str2double(get(hObject,'String')) returns contents of textBirdName as a double


% --- Executes during object creation, after setting all properties.
function textBirdName_CreateFcn(hObject, eventdata, handles)
% hObject    handle to textBirdName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','gray');
end


function textRootDir_Callback(hObject, eventdata, handles)
% hObject    handle to textRootDir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of textRootDir as text
%        str2double(get(hObject,'String')) returns contents of textRootDir as a double


% --- Executes during object creation, after setting all properties.
function textRootDir_CreateFcn(hObject, eventdata, handles)
% hObject    handle to textRootDir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Test on artificial harmonic stack
function buttonTest_Callback(hObject, eventdata, handles)
% hObject    handle to buttonTest (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = Refresh(handles);
guidata(hObject, handles);

axes(handles.axesTest)
cla;

% if exist(['getinfo_',handles.birdName])==0 % getinfo file doesn't exist
%     errordlg('Prepare getinfo file.')
%     return;
% end
[pitchRange, dbLoudnessRelSong] = artificialStack(handles.pitchRange(1), handles.pitchRange(2), handles.stepSize,... %%
    handles.tdt_fs, 'calculateCAF',1,handles);

%%% 
tempThres = -5; % [dB]
temp1 = dbLoudnessRelSong(1:end-1);
temp2 = dbLoudnessRelSong(2:end); % shifted one sample
if handles.bUp
    idx = find((temp1>tempThres).*(temp2<tempThres)); % downward threshold crossing    
else
    idx = find((temp1<tempThres).*(temp2>tempThres)); % upward threshold crossing
end

ylim([-50 5]);
if ~isempty(idx)
    if handles.bUp
        handles.StackThreshold = pitchRange(idx(1)); % first downward threshold crossing
    else
        handles.StackThreshold = pitchRange(idx(1)+1); % first upward threshold crossing
    end
    h = line([handles.StackThreshold handles.StackThreshold],ylim);
    set(h,'color','g');
    set(handles.textStackThreshold,'String',[num2str(handles.StackThreshold),' Hz']);
end
xlabel('Frequency (Hz)','fontsize',12)
grid on
box off
guidata(hObject, handles);

% --- Executes on button press in buttonTestFile.
function buttonTestFile_Callback(hObject, eventdata, handles)
% hObject    handle to buttonTestFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = UpdateDisplay(handles);

testFile([handles.rootdir,handles.birdName,filesep,handles.experName,filesep] , handles.fileNum, handles.tdt_fs, handles.fs, ...
    handles.audioCh, handles);
%caf_chooseFilter([handles.rootdir,handles.birdName,filesep,handles.experName,filesep] , fileNum, 24414, 40000, ...
    %handles.cafProgramFunc, ['getinfo_',handles.birdName], handles.audioCh)

function textExperName_Callback(hObject, eventdata, handles)
% hObject    handle to textExperName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of textExperName as text
%        str2double(get(hObject,'String')) returns contents of textExperName as a double


% --- Executes during object creation, after setting all properties.
function textExperName_CreateFcn(hObject, eventdata, handles)
% hObject    handle to textExperName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function textPitchTarget_Callback(hObject, eventdata, handles)
% hObject    handle to textPitchTarget (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of textPitchTarget as text
%        str2double(get(hObject,'String')) returns contents of textPitchTarget as a double


% --- Executes during object creation, after setting all properties.
function textPitchTarget_CreateFcn(hObject, eventdata, handles)
% hObject    handle to textPitchTarget (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function textNudge_Callback(hObject, eventdata, handles)
% hObject    handle to textNudge (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of textNudge as text
%        str2double(get(hObject,'String')) returns contents of textNudge as a double


% --- Executes during object creation, after setting all properties.
function textNudge_CreateFcn(hObject, eventdata, handles)
% hObject    handle to textNudge (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function textWidth_Callback(hObject, eventdata, handles)
% hObject    handle to textWidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of textWidth as text
%        str2double(get(hObject,'String')) returns contents of textWidth as a double


% --- Executes during object creation, after setting all properties.
function textWidth_CreateFcn(hObject, eventdata, handles)
% hObject    handle to textWidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function textOverlap_Callback(hObject, eventdata, handles)
% hObject    handle to textOverlap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of textOverlap as text
%        str2double(get(hObject,'String')) returns contents of textOverlap as a double


% --- Executes during object creation, after setting all properties.
function textOverlap_CreateFcn(hObject, eventdata, handles)
% hObject    handle to textOverlap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function textBottomFreq_Callback(hObject, eventdata, handles)
% hObject    handle to textBottomFreq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of textBottomFreq as text
%        str2double(get(hObject,'String')) returns contents of textBottomFreq as a double


% --- Executes during object creation, after setting all properties.
function textBottomFreq_CreateFcn(hObject, eventdata, handles)
% hObject    handle to textBottomFreq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function textPassIn_Callback(hObject, eventdata, handles)
% hObject    handle to textPassIn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of textPassIn as text
%        str2double(get(hObject,'String')) returns contents of textPassIn as a double


% --- Executes during object creation, after setting all properties.
function textPassIn_CreateFcn(hObject, eventdata, handles)
% hObject    handle to textPassIn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function textDbDown_Callback(hObject, eventdata, handles)
% hObject    handle to textDbDown (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of textDbDown as text
%        str2double(get(hObject,'String')) returns contents of textDbDown as a double


% --- Executes during object creation, after setting all properties.
function textDbDown_CreateFcn(hObject, eventdata, handles)
% hObject    handle to textDbDown (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function textHarmonics_Callback(hObject, eventdata, handles)
% hObject    handle to texthandles.harmonics (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of texthandles.harmonics as text
%        str2double(get(hObject,'String')) returns contents of texthandles.harmonics as a double


% --- Executes during object creation, after setting all properties.
function textHarmonics_CreateFcn(hObject, eventdata, handles)
% hObject    handle to texthandles.harmonics (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function sliderOverlap_Callback(hObject, eventdata, handles)
% hObject    handle to sliderOverlap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function sliderOverlap_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderOverlap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on selection change in popupHarmonics.
function popupHarmonics_Callback(hObject, eventdata, handles)
% hObject    handle to popupHarmonics (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupHarmonics contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupHarmonics


% --- Executes during object creation, after setting all properties.
function popupHarmonics_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupHarmonics (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function textTargetSyll_CreateFcn(hObject, eventdata, handles)
% hObject    handle to textTargetSyll (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function textRangeStart_Callback(hObject, eventdata, handles)
% hObject    handle to textRangeStart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of textRangeStart as text
%        str2double(get(hObject,'String')) returns contents of textRangeStart as a double


% --- Executes during object creation, after setting all properties.
function textRangeStart_CreateFcn(hObject, eventdata, handles)
% hObject    handle to textRangeStart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function textRangeEnd_Callback(hObject, eventdata, handles)
% hObject    handle to textRangeEnd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of textRangeEnd as text
%        str2double(get(hObject,'String')) returns contents of textRangeEnd as a double


% --- Executes during object creation, after setting all properties.
function textRangeEnd_CreateFcn(hObject, eventdata, handles)
% hObject    handle to textRangeEnd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function textTargRegMin_Callback(hObject, eventdata, handles)
% hObject    handle to textTargRegMin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of textTargRegMin as text
%        str2double(get(hObject,'String')) returns contents of textTargRegMin as a double


% --- Executes during object creation, after setting all properties.
function textTargRegMin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to textTargRegMin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function textTargRegMax_Callback(hObject, eventdata, handles)
% hObject    handle to textTargRegMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of textTargRegMax as text
%        str2double(get(hObject,'String')) returns contents of textTargRegMax as a double


% --- Executes during object creation, after setting all properties.
function textTargRegMax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to textTargRegMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in buttonZoomOn.
function buttonZoomOn_Callback(hObject, eventdata, handles)
% hObject    handle to buttonZoomOn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
axes(handles.axesFreqResp)
zoom xon

% --- Executes on button press in buttonZoomOff.
function buttonZoomOff_Callback(hObject, eventdata, handles)
% hObject    handle to buttonZoomOff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
axes(handles.axesFreqResp)
zoom off

% --- Executes on button press in buttonSyllable.
function buttonSyllable_Callback(hObject, eventdata, handles)
% hObject    handle to buttonSyllable (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = Refresh(handles);
guidata(hObject, handles);

axes(handles.axesSyllable);
cla;

bStretch = true; %stretch all pitch trajectores to stretchN 
bStretchFast = true; %specified which stretching algorithm to use.
stretchN = 100;

%Code
[pitchTrajs, absTime] = getProcessedPitchTrajectories(handles.birdName,'experNames',handles.experName,...
    'targetSyll',handles.targetSyll, 'timeRanges', handles.timeRanges, 'selMode', 'randFrac', ...
    'selParam', handles.randFrac, 'rootdir', handles.rootdir);

if isempty(pitchTrajs)
    errordlg('No syllable detected','windowstyle','modal')
    return
end

%-- display only the last N syllables
% if handles.lastN~=0
%     pitchTrajs_lastN = {};
%     for n=1:handles.lastN
%         pitchTrajs_lastN{n,1} = pitchTrajs{end-n+1,1};
%     end
%     pitchTrajs = pitchTrajs_lastN;    
% end

handles.TotalSyllable = size(pitchTrajs,1); % number of targeted syllables
set(handles.textTotalSyllables,'String',['Total: ',num2str(handles.TotalSyllable)]);

%Stretch vectors
if(bStretch)
    if(~bStretchFast)
        len = cellfun(@length,pitchTrajs,'UniformOutput',false);
        pitchTrajs = cellfun(@resample,pitchTrajs,repmat({stretchN}, size(pitchTrajs)),len,'UniformOutput',false);
    else
        len = cellfun(@length,pitchTrajs);
        for nVect = 1:length(pitchTrajs)
            rendx = round(linspace(1,len(nVect),stretchN));
            pitchTrajs{nVect} = pitchTrajs{nVect}(rendx);
        end
    end
end

handles.pitchTrajs = pitchTrajs;
handles.absTime = absTime;

hold on
for(nTraj = 1:length(pitchTrajs))
    plot(pitchTrajs{nTraj},'r'); % plot pitch trajectory in red
end
xlabel('Strech scale')
ylabel('Pitch (Hz)')

yl = ylim;
X = [handles.targetRegion(1) handles.targetRegion(2) handles.targetRegion(2) handles.targetRegion(1)]*100;
Y = [yl(1) yl(1) yl(2) yl(2)];
h=patch(X,Y,'y'); % show target region
set(h,'EdgeColor','w')
set(h,'FaceAlpha',0.3);  % set transparency
hold off

set(handles.textTargRegMin,'BackgroundColor',[1.0000    0.9922    0.7255]);
set(handles.textTargRegMax,'BackgroundColor',[1.0000    0.9922    0.7255]);
set(handles.buttonDistribution,'Enable','on');
guidata(hObject, handles);
buttonDistribution_Callback(hObject, eventdata, handles);

% --- Executes on button press in buttonDistribution.
function buttonDistribution_Callback(hObject, eventdata, handles)
% hObject    handle to buttonDistribution (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ~isfield(handles,'pitchTrajs')
    buttonSyllable_Callback(hObject, eventdata, handles); % get handles.pitchTrajs
end

axes(handles.axesDistribution);
cla reset;
handles.targetRegion = [eval(get(handles.textTargRegMin,'String')),eval(get(handles.textTargRegMax,'String'))]/100; % per cent
handles.lastN = round(eval(get(handles.textLastN,'String'))) ; %Only use the last N syllables.
guidata(hObject, handles);

avgPitch = zeros(size(handles.pitchTrajs));
for nTraj = 1:length(handles.pitchTrajs)
    traj = handles.pitchTrajs{nTraj};
    avgPitch(nTraj) = mean(traj((handles.targetRegion(1)*100):(handles.targetRegion(2)*100)));%(traj>handles.pitchRange(1) & traj<pitchRange(2));
end
handles.avgPitch = avgPitch;
handles.Mean = round(mean(avgPitch));
handles.Median = round(median(avgPitch));
handles.SD = std(avgPitch);
set(handles.textMean,'String',[num2str(handles.Mean),' Hz']); % display mean pitch
set(handles.textMedian,'String',[num2str(handles.Median),' Hz']); % display median pitch
set(handles.textSD,'String',[num2str(handles.SD,3),' Hz']); % display median pitch


if get(handles.radioDistribution,'Value') % moment-to-moment pitch
%     if(isempty(handles.lastN) | handles.lastN ==0 | handles.lastN >= handles.TotalSyllable)
%         allPitchs = cell2mat(handles.pitchTrajs'); % expand all the pitch trajectories into one array
%     else
%         allPitchs = cell2mat(handles.pitchTrajs(end-handles.lastN+1:end)');
%     end
    allPitchs = cell2mat(handles.pitchTrajs'); % expand all the pitch trajectories into one array
    
    edges = unique(allPitchs);
    counts = histc(allPitchs,edges);
    Prob = counts./sum(counts);

    plot(edges, Prob,'r'); % plot distribution
    xlabel('Pitch (Hz)')
    title('Distribution of moment-to-moment pitch for the targeted syllable')
    handles.pitchTarget = eval(get(handles.textPitchTarget,'String'));
    %xlim([handles.pitchTarget-200,handles.pitchTarget+200]); % set x-axis limit according to pitch target
else %either a histogram or a cumulative histogram of mean pitch per syllable
    if get(handles.radioHistogram,'Value')
%         if(isempty(handles.lastN) | handles.lastN ==0 | handles.lastN >= handles.TotalSyllable)
%             hist(avgPitch,20);
%         else
%             hist(avgPitch(end-handles.lastN+1:end),20);
%         end
        hist(avgPitch,20);
        title('Histogram of average pitch of the target region')
    elseif get(handles.radioCumulative,'Value')
        cdfplot(avgPitch)
        title('') % cumulative distribution of pitch
        ylabel('')
        xlabel('Pitch (Hz)')
        
        h=line(xlim,[0.5 0.5]); % 50 percentile line
        set(h,'Color','r','linestyle',':','linewidth',2);
        handles.pitchTarget = eval(get(handles.textPitchTarget,'String'));
        h2=line([handles.Median,handles.Median],ylim);
        set(h2,'Color','r','linewidth',2);
    elseif get(handles.radioTimecourse,'Value')
        plot(handles.absTime,avgPitch,'.');
        datetick('x',15); % change the x-axis to actual time
        title('Time course of average pitch of target region');
        hold on
        %plot(smooth(handles.absTime,25), smooth(avgPitch,25),'r-');
        hold off
        ylabel('Pitch (Hz)')
    end
end

guidata(hObject, handles);

% --- Executes on button press in radioHistogram.
function radioHistogram_Callback(hObject, eventdata, handles)
% hObject    handle to radioHistogram (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radioHistogram


% --- Executes on button press in radioCumulative.
function radioCumulative_Callback(hObject, eventdata, handles)
% hObject    handle to radioCumulative (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radioCumulative




% --- Executes on slider movement.
function sliderRandFrac_Callback(hObject, eventdata, handles)
% hObject    handle to sliderRandFrac (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

handles.randFrac = get(handles.sliderRandFrac,'Value');
set(handles.textRandFrac,'String',num2str(handles.randFrac,2));

% --- Executes during object creation, after setting all properties.
function sliderRandFrac_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderRandFrac (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in buttonLoad.
function buttonLoad_Callback(hObject, eventdata, handles)
% hObject    handle to buttonLoad (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% TO DO, ask whether to save or not
handles=ClearDisplay(handles);
[file,path] = uigetfile('cafgui*','Specify cafgui file'); % TO DO cancel
cd(path);
load(file);

% basic info
handles.rootdir = cafguidb.rootdir;
handles.pathName = cafguidb.pathName;
handles.fileName = cafguidb.fileName;
handles.birdName = cafguidb.birdName;
handles.experName = cafguidb.experName;

handles.fs = cafguidb.fs;
handles.tdt_fs = cafguidb.tdt_fs;
handles.audioCh = cafguidb.audioCh;

% syllable parameters
handles.bUp = cafguidb.bUp;
handles.targetSyll = cafguidb.targetSyll;
handles.randFrac = cafguidb.randFrac;
handles.targetRegion = cafguidb.targetRegion;
handles.lastN = cafguidb.lastN;

% filter parameters
handles.pitchTarget = cafguidb.pitchTarget;
handles.nudge = cafguidb.nudge;
handles.width = cafguidb.width;
handles.bottomFreq = cafguidb.bottomFreq;
handles.filterOverlap = cafguidb.filterOverlap;
handles.thres = cafguidb.thres;
handles.passIn = cafguidb.passIn;
handles.dbDown = cafguidb.dbDown;
handles.harmonics = cafguidb.harmonics;

handles.fcBand = cafguidb.fcBand;
handles.dbDownBand = cafguidb.dbDownBand;
if isfield(cafguidb,'order')%%% TO DO: eventually remove this
    handles.order = cafguidb.order; 
end
    
handles.maxamp = cafguidb.maxamp;
handles.beta = cafguidb.beta;
handles.minsongpower = cafguidb.minsongpower;

handles.avgPitch = cafguidb.avgPitch;

% test on artificial harmonic stack
handles.pitchRange = cafguidb.pitchRange;
handles.stepSize = cafguidb.stepSize;

set(handles.textBirdName,'String',handles.birdName,'Enable','off');
set(handles.textExperName,'String',handles.experName,'Enable','off');
set(handles.buttonSyllable,'Enable','on');
set(handles.buttonSave,'Enable','on');
guidata(hObject, handles);
handles = UpdateDisplay(handles);
guidata(hObject, handles);

%buttonSyllable_Callback(hObject, eventdata, handles);
%buttonCalculate_Callback(hObject, eventdata, handles);

% --- Executes on button press in pushZoomOn1.
function pushZoomOn1_Callback(hObject, eventdata, handles)
% hObject    handle to pushZoomOn1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

axes(handles.axesDistribution)
zoom xon

% --- Executes on button press in pushZoomOff1.
function pushZoomOff1_Callback(hObject, eventdata, handles)
% hObject    handle to pushZoomOff1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

axes(handles.axesDistribution)
zoom off

function textRandFrac_Callback(hObject, eventdata, handles)
% hObject    handle to textRandFrac (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of textRandFrac as text
%        str2double(get(hObject,'String')) returns contents of textRandFrac as a double


% --- Executes during object creation, after setting all properties.
function textRandFrac_CreateFcn(hObject, eventdata, handles)
% hObject    handle to textRandFrac (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function textSyllable_Callback(hObject, eventdata, handles)
% hObject    handle to textSyllable (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of textSyllable as text
%        str2double(get(hObject,'String')) returns contents of textSyllable as a double


% --- Executes during object creation, after setting all properties.
function textSyllable_CreateFcn(hObject, eventdata, handles)
% hObject    handle to textSyllable (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function textLastN_Callback(hObject, eventdata, handles)
% hObject    handle to textLastN (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of textLastN as text
%        str2double(get(hObject,'String')) returns contents of textLastN as a double


% --- Executes during object creation, after setting all properties.
function textLastN_CreateFcn(hObject, eventdata, handles)
% hObject    handle to textLastN (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on button press in radioDistribution.
function radioDistribution_Callback(hObject, eventdata, handles)
% hObject    handle to radioDistribution (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radioDistribution





function textPitchThreshold_Callback(hObject, eventdata, handles)
% hObject    handle to textPitchThreshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of textPitchThreshold as text
%        str2double(get(hObject,'String')) returns contents of textPitchThreshold as a double


% --- Executes during object creation, after setting all properties.
function textPitchThreshold_CreateFcn(hObject, eventdata, handles)
% hObject    handle to textPitchThreshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushXZoomSyllable.
function pushXZoomSyllable_Callback(hObject, eventdata, handles)
% hObject    handle to pushXZoomSyllable (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

axes(handles.axesSyllable)
zoom xon

% --- Executes on button press in pushZoomOffSyllable.
function pushZoomOffSyllable_Callback(hObject, eventdata, handles)
% hObject    handle to pushZoomOffSyllable (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

axes(handles.axesSyllable)
zoom off

% --- Executes on button press in pushYZoomSyllable.
function pushYZoomSyllable_Callback(hObject, eventdata, handles)
% hObject    handle to pushYZoomSyllable (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

axes(handles.axesSyllable)
zoom yon



function textminsong_Callback(hObject, eventdata, handles)
% hObject    handle to textminsong (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of textminsong as text
%        str2double(get(hObject,'String')) returns contents of textminsong as a double


% --- Executes during object creation, after setting all properties.
function textminsong_CreateFcn(hObject, eventdata, handles)
% hObject    handle to textminsong (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function textMinsongpower_Callback(hObject, eventdata, handles)
% hObject    handle to textMinsongpower (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of textMinsongpower as text
%        str2double(get(hObject,'String')) returns contents of textMinsongpower as a double


% --- Executes during object creation, after setting all properties.
function textMinsongpower_CreateFcn(hObject, eventdata, handles)
% hObject    handle to textMinsongpower (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function textBeta_Callback(hObject, eventdata, handles)
% hObject    handle to textBeta (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of textBeta as text
%        str2double(get(hObject,'String')) returns contents of textBeta as a double


% --- Executes during object creation, after setting all properties.
function textBeta_CreateFcn(hObject, eventdata, handles)
% hObject    handle to textBeta (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function textBandFilter_CreateFcn(hObject, eventdata, handles)
% hObject    handle to textRandFrac (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function textDbDownBandFilter_CreateFcn(hObject, eventdata, handles)
% hObject    handle to textRandFrac (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function textMaxamp_Callback(hObject, eventdata, handles)
% hObject    handle to textMaxamp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of textMaxamp as text
%        str2double(get(hObject,'String')) returns contents of textMaxamp as a double


% --- Executes during object creation, after setting all properties.
function textMaxamp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to textMaxamp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushVectorClust.
function pushVectorClust_Callback(hObject, eventdata, handles)
% hObject    handle to pushVectorClust (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if exist([handles.rootdir,handles.birdName])
    cd([handles.rootdir,handles.birdName]);
end
pn = [handles.rootdir,handles.birdName,filesep];
fn = [handles.birdName,'_all_misc_',handles.experName,'.mat'];

vectorClust('pathName',pn,'fileName',fn);


% --- Executes on button press in buttonSave.
function buttonSave_Callback(hObject, eventdata, handles)
% hObject    handle to buttonSave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = Refresh(handles);
guidata(hObject, handles);

cafguidb.rootdir = handles.rootdir;
cafguidb.pathName = handles.pathName;
cafguidb.fileName = handles.fileName;
cafguidb.birdName = handles.birdName;
cafguidb.experName = handles.experName;

cafguidb.fs = handles.fs;
cafguidb.tdt_fs = handles.tdt_fs;
cafguidb.audioCh = handles.audioCh;

cafguidb.bUp = handles.bUp;
cafguidb.targetSyll = handles.targetSyll;
cafguidb.randFrac = handles.randFrac;
cafguidb.targetRegion = handles.targetRegion;
cafguidb.lastN = handles.lastN;

cafguidb.pitchTarget = handles.pitchTarget;
cafguidb.nudge = handles.nudge;
cafguidb.width = handles.width;
cafguidb.filterOverlap = handles.filterOverlap;
cafguidb.thres = handles.thres;
cafguidb.bottomFreq = handles.bottomFreq;
cafguidb.passIn = handles.passIn;
cafguidb.dbDown = handles.dbDown;
cafguidb.harmonics = handles.harmonics;

cafguidb.fcBand = handles.fcBand;
cafguidb.dbDownBand = handles.dbDownBand;
cafguidb.order = handles.order;

cafguidb.maxamp = handles.maxamp;
cafguidb.beta = handles.beta;
cafguidb.minsongpower = handles.minsongpower;

cafguidb.pitchRange = handles.pitchRange;
cafguidb.stepSize = handles.stepSize;

cafguidb.avgPitch = handles.avgPitch; % save pitch data for comparison across multiple days

if exist('Z:\Data\LMANstim')
    cd('Z:\Data\LMANstim');
    if exist(handles.birdName)
        cd(handles.birdName);
    end
end
DefaultName = ['cafgui_',handles.birdName,'_',handles.experName,'.mat'];
%DefaultName = ['cafgui_',handles.birdName,'_',datestr(date,29),'.mat']; %
%use current date as default
[file, path] = uiputfile('*.mat','Save CAFGUI database',DefaultName);
if ~isstr(file)
    return
end
save([path file],'cafguidb');

% --- Executes on button press in buttonLoadExper.
function buttonLoadExper_Callback(hObject, eventdata, handles)
% hObject    handle to buttonLoadExper (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% TO DO, ask save

% loading exper.mat
[fileName,pathName] = uigetfile('exper*','Specify exper.mat');
handles.pathName = pathName;
handles.fileName = fileName;
cd(pathName); % move to directory where the exper.mat is
load(fileName); % load exper.mat
handles.birdName = exper.birdname;
handles.experName = exper.expername;
handles.fs = exper.desiredInSampRate;
handles.audioCh = exper.audioCh;
cd ../../ % going up exper and bird directory
handles.rootdir = [pwd,filesep]; % file separater \ in the end!!
handles.tdt_fs = 24414; % sampling frequency of the TDT [Hz]
set(handles.textBirdName,'String',handles.birdName,'Enable','off');
set(handles.textExperName,'String',handles.experName,'Enable','off');

set(handles.buttonSyllable,'Enable','on');
set(handles.buttonSave,'Enable','on');
handles.exper = exper;
handles = ClearDisplay(handles); % clear axes and textboxes
guidata(hObject, handles);


% --- Executes on button press in buttonAllSyllables.
function buttonAllSyllables_Callback(hObject, eventdata, handles)
% hObject    handle to buttonAllSyllables (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = Refresh(handles);
set(handles.textProbability,'String',''); % clear display
AllSyllables(handles.birdName, handles.experName, 'all', ...
   'randFraction',handles.randFrac, 'syllType', handles.targetSyll, 'lastN',handles.lastN,...
   'rootdir', handles.rootdir,'handles',handles);

part = '';
prefix = 'all';

load([handles.rootdir,handles.birdName,filesep,handles.birdName,'_',prefix,'_misc_',handles.experName,part,'.mat']); 
load([handles.rootdir,handles.birdName,filesep,handles.birdName,'_',prefix,'_audio_',handles.experName,part,'.mat']); 
load([handles.rootdir,handles.birdName,filesep,handles.birdName,'_',prefix,'_cafProgram_',handles.experName,part,'.mat']); 
load([handles.rootdir,handles.birdName,filesep,handles.birdName,'_',prefix,'_pitch_',handles.experName,part,'.mat']); 

cafProgram.songPower = [];
if(~isempty(handles.targetSyll))
    ndxsum = find(ismember([misc.segs(:).segType],handles.targetSyll) & ~(cellfun(@isempty, {cafProgram.segs(:).songPower})));
else
    ndxsum = find(~(cellfun(@isempty, {cafProgram.segs(:).songPower})));
end

set(handles.buttonSummary,'Enable','on');

handles.n = 0;
handles.ndxsum = ndxsum;
handles.rawaudio = rawaudio;
handles.cafProgram = cafProgram;
guidata(hObject, handles);
buttonNextSyllable_Callback(hObject, eventdata, handles);

guidata(hObject, handles);

% --- Executes on button press in buttonSummary.
function buttonSummary_Callback(hObject, eventdata, handles)
% hObject    handle to buttonSummary (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Parameters

N = length(handles.ndxsum); % number of syllables analyzed
cafThreshold = 80; % dB

for n=1:N
    caf = handles.cafProgram.segs(handles.ndxsum(n)).dafPower; % get cafPower trajectory
    cafPower = 94+20*log10(caf); % convert to dB
    Idx = find(cafPower(1:end-1)<cafThreshold & cafPower(2:end)>cafThreshold);
    if ~isempty(Idx) % threshold crossing event
        Onset(n) = Idx(1)+1; % onset defined as the first threshold crossing event
    else
        Onset(n) = -1; % no feedback
    end
end

M = sum(Onset~=-1); % count the number of non-zero events (FB trials)
Probability = M/N;

set(handles.textProbability,'String',[num2str(M),'/',num2str(N),' = ',num2str(Probability,2)]);

%Code
[cafTrajs, absTime] = getProcessedCAFTrajectories(handles.birdName,'experNames',handles.experName,...
    'targetSyll',handles.targetSyll,'timeRanges', handles.timeRanges, 'targetRegion',[],...
'selMode', 'randFrac', 'selParam', handles.randFrac, 'rootdir', handles.rootdir);
[pitchTraj, absTime, syllType, dura] = getProcessedPitchTrajectories(handles.birdName,'experNames',handles.experName,...
    'targetSyll',handles.targetSyll,'timeRanges', handles.timeRanges, ...
    'selMode', 'randFrac', 'selParam', handles.randFrac, 'rootdir', handles.rootdir);

%%%%%%%%%%%
cafThreshold = 80; %DB SPL
bStretchFast = true; %specified which stretching algorithm to use.
stretchN = 100;

%Code
% get CAF trajectorys
bBlank = cellfun(@isempty, cafTrajs);
cafTrajs = cafTrajs(~bBlank);
pitchTraj = pitchTraj(~bBlank);
absTime = absTime(~bBlank);

%Stretch trajectories to be same length
if(~bStretchFast)
    len = cellfun(@length,cafTrajs,'UniformOutput',false);
    cafTrajs = cellfun(@resample,cafTrajs,repmat({stretchN}, size(cafTrajs)),len,'UniformOutput',false);
    pitchTraj = cellfun(@resample,pitchTraj,repmat({stretchN}, size(pitchTraj)),len,'UniformOutput',false);
else
    len = cellfun(@length,cafTrajs);
    len_pitch = cellfun(@length,pitchTraj);
    for nVect = 1:length(cafTrajs)
        rendx = round(linspace(1,len(nVect),stretchN));
        cafTrajs{nVect} = cafTrajs{nVect}(rendx);
        rendx = round(linspace(1,len_pitch(nVect),stretchN));
        pitchTraj{nVect} = pitchTraj{nVect}(rendx);
    end
end

%merge into matrix;
M = cell2mat(cafTrajs');
P = cell2mat(pitchTraj)';
isHit = any(94+20*log10(M)>cafThreshold, 1);
figure(8477)
plot(P(:,isHit),'r')
hold on
plot(P(:,~isHit),'b')
hold off
%Merge into probabilities of feedback at each time point
figure(38); clf;
subplot(3,1,1);
prob = sum(94+20*log10(M)>cafThreshold, 2);
prob = prob./length(cafTrajs)
plot(prob);
xlabel('Stretch scale','fontsize',16);
ylabel('Prob of FB','fontsize',16);

subplot(3,1,2);
imagesc(94+20*log10(M'+eps));

xlabel('Stretch scale','fontsize',16);
ylabel('Syllable #','fontsize',16);

subplot(3,1,3);
edges = [-1:1:100];
counts = histc(Onset, edges);
bar(edges, counts, 'histc');
xlim([-1,100]);

title(['std = ', num2str(std(Onset(Onset>=0)))]);


%%% refresh all the values
function handles = Refresh(handles)
% hObject    handle to buttonCalculate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.targetSyll = eval(get(handles.textSyllable,'String'));
handles.timeRanges = {};
handles.randFrac = eval(get(handles.textRandFrac,'String'));
handles.targetRegion = [eval(get(handles.textTargRegMin,'String')),eval(get(handles.textTargRegMax,'String'))]/100; % per cent
handles.lastN = round(eval(get(handles.textLastN,'String'))) ; %Only use the last N syllables.

handles.bUp = logical(get(handles.buttonUp,'Value'));
handles.pitchTarget = eval(get(handles.textPitchTarget,'String'));
handles.nudge = eval(get(handles.textNudge,'String'));
handles.width = eval(get(handles.textWidth,'String'));
handles.bottomFreq = eval(get(handles.textBottomFreq,'String'));
handles.passIn = eval(get(handles.textPassIn,'String'));
handles.dbDown = eval(get(handles.textDbDown,'String'));
handles.filterOverlap = eval(get(handles.textOverlap,'String'));
handles.harmonics = [1:get(handles.popupHarmonics,'Value')];
handles.thres = eval(get(handles.textPitchThreshold,'String'));

handles.fcBand = eval(get(handles.textBandFilter,'String')); % cutoff frequency for the band filter
handles.dbDownBand = eval(get(handles.textDbDownBandFilter,'String')); % dB down for the band filter
handles.order = eval(get(handles.textOrder,'String'));

handles.minsongpower = eval(get(handles.textMinsongpower,'String')); % min power for song detection
handles.beta = eval(get(handles.textBeta,'String')); % gain of the amp
handles.maxamp = eval(get(handles.textMaxamp,'String')); % sets maximum amplitude of TDT output

handles.pitchRange = [eval(get(handles.textFreqLow,'String')),eval(get(handles.textFreqHigh,'String'))];
handles.stepSize = eval(get(handles.textFreqStep,'String'));


%%% Update the display
function handles = UpdateDisplay(handles)

set(handles.textBirdName,'String',handles.birdName,'Enable','off');
set(handles.textExperName,'String',handles.experName,'Enable','off');

set(handles.buttonUp,'Value',handles.bUp);
set(handles.buttonDown,'Value',~handles.bUp);
set(handles.buttonUp,'Value',handles.bUp);
set(handles.textSyllable,'String',handles.targetSyll);
set(handles.textTargRegMin,'String',handles.targetRegion(1)*100);
set(handles.textTargRegMax,'String',handles.targetRegion(2)*100);
set(handles.textRandFrac,'String',handles.randFrac);
set(handles.textLastN,'String',handles.lastN);

set(handles.textPitchTarget,'String',handles.pitchTarget);
set(handles.textNudge,'String',handles.nudge);
set(handles.textWidth,'String',handles.width);
set(handles.textOverlap,'String',handles.filterOverlap);
set(handles.textPitchThreshold,'String',handles.thres);
set(handles.textBottomFreq,'String',handles.bottomFreq);
set(handles.textPassIn,'String',handles.passIn);
set(handles.textDbDown,'String',handles.dbDown);
set(handles.popupHarmonics,'Value',max(handles.harmonics));

set(handles.textBandFilter,'String',handles.fcBand);
set(handles.textDbDownBandFilter,'String',handles.dbDownBand);
set(handles.textOrder,'String',handles.order);

set(handles.textMaxamp,'String',handles.maxamp);
set(handles.textBeta,'String',handles.beta);
set(handles.textMinsongpower,'String',handles.minsongpower);

set(handles.textFreqLow,'String',handles.pitchRange(1));
set(handles.textFreqHigh,'String',handles.pitchRange(2));
set(handles.textFreqStep,'String',handles.stepSize);

% update file list
cd([handles.rootdir,handles.birdName,filesep,handles.experName]);
FileList = dir(['*chan',num2str(handles.audioCh),'.dat']);
if isempty(FileList)
    errordlg('No files or wrong audio ch!')
end
TotalFile = length(FileList);

set(handles.listFiles,'String',num2str((1:TotalFile)'));
cd([handles.rootdir,handles.birdName]);

Idx = get(handles.listFiles,'Value');
FileList = str2num(get(handles.listFiles,'String')); % convert to double
handles.fileNum = FileList(Idx);

% --- Executes on button press in buttonNextSyllable.
function buttonNextSyllable_Callback(hObject, eventdata, handles)
% hObject    handle to buttonNextSyllable (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.n = handles.n+1; % go to the next syllable
if handles.n > length(handles.ndxsum)
    handles.n = 1; % circular
end
guidata(hObject, handles);
PlotSyllable(handles);

% --- Executes on button press in buttonPreviousSyllable.
function buttonPreviousSyllable_Callback(hObject, eventdata, handles)
% hObject    handle to buttonPreviousSyllable (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.n = handles.n-1; % go to the previous syllable
if handles.n < 1
    handles.n = handles.TotalSyllable; % circular
end
guidata(hObject, handles);
PlotSyllable(handles);

%
function PlotSyllable(handles)
figure(55)
clf;
s1=subplot(3,1,1);
displaySpecgramQuick(handles.rawaudio.segs(handles.ndxsum(handles.n)).audio,handles.fs,[500,3000]); 
title(['n = ',num2str(handles.n)],'fontsize',20);
xl = xlim;
yl = ylim;

s2=subplot(3,1,2);
hold on
[pitch, pitchGoodness, harmonicPower, time, entropy] = estimatePitch(handles.rawaudio.segs(handles.ndxsum(handles.n)).audio, handles.fs);
plot(time,pitch); % pitch trajectory
ylabel('Pitch (Hz)');
if handles.bUp
    h=patch([xl(1),xl(2),xl(2),xl(1)],[handles.StackThreshold-100 handles.StackThreshold-100 handles.StackThreshold handles.StackThreshold],'r');
else
    h=patch([xl(1),xl(2),xl(2),xl(1)],[handles.StackThreshold handles.StackThreshold handles.StackThreshold+100 handles.StackThreshold+100],'r');
end
set(h,'FaceAlpha',0.2);
axis tight; 
ylim([handles.StackThreshold-200,handles.StackThreshold+200]); 
hold off
linkaxes([s1,s2],'x');

s3=subplot(3,1,3); 
plot([94+10*log10(handles.cafProgram.segs(handles.ndxsum(handles.n)).songPower),94+10*log10(handles.cafProgram.segs(handles.ndxsum(handles.n)).dafPower)]);
axis tight;
ylim([50,140]);
ylabel('Sound pressure level')
xlabel('Time (s)');

function textBandFilter_Callback(hObject, eventdata, handles)
% hObject    handle to textBandFilter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of textBandFilter as text
%        str2double(get(hObject,'String')) returns contents of
%        textBandFilter as a double


% --- Executes on button press in buttonRunTDT.
function buttonRunTDT_Callback(hObject, eventdata, handles)
% hObject    handle to buttonRunTDT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


handles.TDTpathName = 'C:\Documents and Settings\Tatsuo\My Documents\DSP_programs\Tatsuo\CAF';
handles.TDTfileName = ['caf_',handles.birdName,'_',handles.experName,'.rcx']; % .rcx file for TDT
msgbox(['Create     ',handles.TDTfileName]);

%% TDT Connection parameters
connectionType = 'USB';
deviceNumber = 1;
circuit = strcat(handles.TDTpathName,filesep,handles.TDTfileName); % circuit is the .rcx file

% check for file existance
fileExists=(exist(circuit,'file'));
if fileExists==0
    disp('   File doesn''t exist'); return;
end

%% Load circuit onto device and run
RP = actxcontrol('RPco.x',[5 5 26 26]);

RP.ConnectRX8(connectionType, deviceNumber); % Connects RP2 via USB or GB given the proper device number
RP.Halt; % Stops any processing chains running on RP2
RP.ClearCOF; % Clears all the buffers and circuits on RP2
disp(['Loading ' circuit]);
RP.LoadCOF(circuit); % Loads circuit

%% Get status of the device
status=double(RP.GetStatus); % Get status
if bitget(status,1)==0; % Checks for connection
    disp('Error connecting to RP2');
elseif bitget(status,2)==0; % Checks for errors in loading circuit
    disp('Error loading circuit');
else
    disp('Circuit loaded');
end

%-- export filters
RP.WriteTagV('in1',0,handles.bandFilters.in(1).Numerator);
RP.WriteTagV('in2',0,handles.bandFilters.in(2).Numerator);
RP.WriteTagV('in3',0,handles.bandFilters.in(3).Numerator);
RP.WriteTagV('out1',0,handles.bandFilters.out(1).Numerator);
RP.WriteTagV('out2',0,handles.bandFilters.out(2).Numerator);
RP.WriteTagV('out3',0,handles.bandFilters.out(3).Numerator);
RP.WriteTagV('lpBands',0,handles.lpBands.Numerator);
RP.WriteTagV('lpBird',0,handles.lpBird.Numerator);

%-- export parameters
handles.IsTest = 0; % 0: normal mode, 1: test mode

e(1)=RP.SetTagVal('IsTest',handles.IsTest);
e(2)=RP.SetTagVal('thres', handles.thres); % threshold for pitch score
e(3)=RP.SetTagVal('maxamp',handles.maxamp); % maximum amplitude of the feedback
e(4)=RP.SetTagVal('minamp',-handles.maxamp);
e(5)=RP.SetTagVal ('minsongpower',handles.minsongpower); % not considered as song if under this threshold
e(6)=RP.SetTagVal('beta',handles.beta); % gain

if sum(e)~=length(e) % not all elements in e are 1
    errordlg('Error in changing parameters','SetTagVal error')
end

%--- run the program
RP.Run;
status=double(RP.GetStatus); % Get status
if bitget(status,1)==0; % Checks for connection
    disp('Error connecting to RP2');
elseif bitget(status,2)==0; % Checks for errors in loading circuit
    disp('Error loading circuit');
elseif bitget(status,3)==0 % Checks for errors in running circuit
    disp('Error running circuit');
else
    disp('Circuit loaded and running');
end

pause

% --- Executes on button press in buttonSampleAudio.
function buttonSampleAudio_Callback(hObject, eventdata, handles)
% hObject    handle to buttonSampleAudio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%This wav is preloaded in the TDT program, so use this code to compare the
%TDT output to the matlab output.

%STEP 1: Load the same sample audio as you have loaded on the tdt.  If
%should be 24414.
%Note: all TDT wav files have to be 16bit, otherwise the TDT will not load the
%file.

if ~isfield(handles,'exper') % no handles.exper
    load([handles.rootdir,handles.birdName,filesep,handles.experName,filesep,'exper.mat']);
    handles.exper = exper;
end

handles = UpdateDisplay(handles); % get fileNum
cd([handles.rootdir,handles.birdName,filesep,handles.experName]); % move to the directory that has the data

audio = loadAudio(handles.exper, handles.fileNum);

fig=figure;
displaySpecgramQuick(audio, handles.fs)
input = inputdlg({'Start(s)','End(s)'},'Clip audio file',1,{'0','2'});
Start = max(1,floor(handles.fs*eval(input{1})));
End = min(length(audio),(handles.fs*eval(input{2})));
if Start > End
    errordlg('Invalid start and end times'); return;
end
audio = audio(Start:End); %clip during singing
handles.audio = audio; % save test audio
audio = resample(audio, handles.tdt_fs, handles.fs); % make it the sample rate of TDT
audio = audio/ceil(max(abs(audio)));% avoid clippling TO
guidata(hObject, handles);
wavwrite(audio, handles.tdt_fs, 16, 'c:\testaudio.wav'); % save it as a test file 
msgbox('Saved sample audio as c:\testaudio.wav')
close(fig)

set(handles.buttonTestTDT,'Enable','on');

% --- Executes on button press in buttonTestTDT.
function buttonTestTDT_Callback(hObject, eventdata, handles)
% hObject    handle to buttonTestTDT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.TDTpathName = 'C:\Documents and Settings\Tatsuo\My Documents\DSP_programs\Tatsuo\CAF';
temp = pwd; % save current directory
cd(handles.TDTpathName);
[fn,pn] = uigetfile('*.rcx','Specify TDT file');
handles.TDTfileName = fn;
guidata(hObject, handles);
cd(temp) % return to the original directory

%% TDT Connection parameters
connectionType = 'USB';
deviceNumber = 1;
circuit = strcat(handles.TDTpathName,filesep,handles.TDTfileName); % circuit is the .rcx file

% check for file existance
fileExists=(exist(circuit,'file'));
if fileExists==0
    disp('   File doesn''t exist'); return;
end

%% Load circuit onto device and run
RP = actxcontrol('RPco.x',[5 5 26 26]);
handles.RP = RP;
guidata(hObject, handles);

RP.ConnectRX8(connectionType, deviceNumber); % Connects RP2 via USB or GB given the proper device number
RP.Halt; % Stops any processing chains running on RP2
RP.ClearCOF; % Clears all the buffers and circuits on RP2
disp(['Loading ' circuit]);
RP.LoadCOF(circuit); % Loads circuit

%% Get status of the device
status=double(RP.GetStatus); % Get status
if bitget(status,1)==0; % Checks for connection
    disp('Error connecting to RP2');
elseif bitget(status,2)==0; % Checks for errors in loading circuit
    disp('Error loading circuit');
else
    disp('Circuit loaded');
end

%-- export filters
RP.WriteTagV('in1',0,handles.bandFilters.in(1).Numerator);
RP.WriteTagV('in2',0,handles.bandFilters.in(2).Numerator);
RP.WriteTagV('in3',0,handles.bandFilters.in(3).Numerator);
RP.WriteTagV('out1',0,handles.bandFilters.out(1).Numerator);
RP.WriteTagV('out2',0,handles.bandFilters.out(2).Numerator);
RP.WriteTagV('out3',0,handles.bandFilters.out(3).Numerator);
RP.WriteTagV('lpBands',0,handles.lpBands.Numerator);
RP.WriteTagV('lpBird',0,handles.lpBird.Numerator);

%-- export parameters
handles.IsTest = 1; % 0: normal mode, 1: test mode

e(1)=RP.SetTagVal('IsTest',handles.IsTest);
e(2)=RP.SetTagVal('thres', handles.thres); % threshold for pitch score
e(3)=RP.SetTagVal('maxamp',handles.maxamp); % maximum amplitude of the feedback
e(4)=RP.SetTagVal('minamp',-handles.maxamp);
e(5)=RP.SetTagVal ('minsongpower',handles.minsongpower); % not considered as song if under this threshold
e(6)=RP.SetTagVal('beta',handles.beta); % gain

if sum(e)~=length(e) % not all elements in e are 1
    errordlg('Error in changing parameters','SetTagVal error')
end

%--- TO DO: by using RP.ReadTag, RP.GetTagVal, record a log of values used
%in TDT

%--- run the program
RP.Run;
status=double(RP.GetStatus); % Get status
if bitget(status,1)==0; % Checks for connection
    disp('Error connecting to RP2');
elseif bitget(status,2)==0; % Checks for errors in loading circuit
    disp('Error loading circuit');
elseif bitget(status,3)==0 % Checks for errors in running circuit
    disp('Error running circuit');
else
    disp('Circuit loaded and running');
end
RP

% fig = figure;
% set(fig,'MenuBar','none','Position',[500,500,300,150],'NumberTitle','off','Name','Filter export');
% text(0.0,0.8,{'Start recording in AcquisitionGUI'},'fontsize',12);
% axis off
% h = uicontrol('Position',[120 20 80 40],'String','Continue','Callback','uiresume(gcbf)');
% uiwait(gcf);
% close(fig);

RP.SoftTrg(1);
RP
pause(5)
RP.Halt;
%msgbox('Stop Recording')
%clear RP;

%--- simulation
% handles.audio;
% [h, equalizedSong, equalizedDAF, amp, dafDB, songDB, dafPowerSPL94, songPowerSPL94, songStat, intermediates] = feval('calculateCAF', ...
%                                          'bDebug', true, ...
%                                          'fcnBirdInfo', ['getinfo_',handles.birdName], ...
%                                          'audio', handles.audio, ...
%                                          'fs', handles.fs, ...
%                                          'tdt_fs', handles.tdt_fs,...
%                                          'handles',handles);
% input = inputdlg('AcqGUI File Number?');
% nFile = eval(input{1}); % file number in acquisitionGui
% figure
% exper = loadExper('tdttest','tdttest','c:\');
% sp(1) = subplot(2,1,1); plot(amp); title('MALAB simulation'); % MATLAB
% sp(2) = subplot(2,1,2); a = loadAudio(exper,nFile); plot(a);  title('TDT'); % TDT
% zoom xon

%%% clear display
function handles = ClearDisplay(handles)
                   
%--- clear axes
cla(handles.axesSyllable);
axes(handles.axesDistribution);
title('');
grid off
cla(handles.axesDistribution);
axes(handles.axesFreqResp);
grid off
cla(handles.axesFreqResp);
axes(handles.axesTest);
grid off
cla(handles.axesTest);

%--- clear textboxes
set(handles.textTotalSyllables,'String','');
set(handles.textMean,'String','');
set(handles.textMedian,'String','');
set(handles.textSD,'String','');
set(handles.textFilterOrder,'String','');
set(handles.textBandFilterOrder,'String','');
set(handles.textFilterDelay,'String','');
set(handles.textStackThreshold,'String','');


% --- Executes on button press in buttonComparePitch.
function buttonComparePitch_Callback(hObject, eventdata, handles)
% hObject    handle to buttonComparePitch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% ComparePitch(handles)
% specify  two cafguidb files

After = handles.avgPitch;

[file,path] = uigetfile('cafgui*','Specify cafgui file (before)'); % TO DO cancel
cd(path);
load(file);
Before = cafguidb.avgPitch;
bUp = cafguidb.bUp; % pushing up or down

%%% Two-sample Kolmogorov-Smirnov test
Alpha = 0.05; % significance level
if bUp
    [H,P] = kstest2(Before,After,Alpha,'larger'); % one-tail test
else
    [H,P] = kstest2(Before,After,Alpha,'smaller'); % one-tail test
end

% figure(31)
% BeforeHist = hist(Before,30);
% AfterHist = hist(After,30);
% hold on
% plot(BeforeHist)
% plot(AfterHist)
% hold off

figure(32)
hold on
h1=cdfplot(Before);
set(h1,'color','b')
h2=cdfplot(After);
set(h2,'color','r')
hold off
legend([cafguidb.experName],[handles.experName],'location','northwest')
title(['Two sample K-S test (p = ',num2str(P,2),')'],'fontsize',12);
xlabel('Pitch (Hz)','fontsize',16)
ylabel('Cumulative distribution','fontsize',16)



function textOrder_Callback(hObject, eventdata, handles)
% hObject    handle to textOrder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of textOrder as text
%        str2double(get(hObject,'String')) returns contents of textOrder as a double


% --- Executes during object creation, after setting all properties.
function textOrder_CreateFcn(hObject, eventdata, handles)
% hObject    handle to textOrder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%--- zero padding for TDT exporting
function handles = ZeroPad(handles); % pad zero for TDT exporting
for i=handles.harmonics
    handles.bandFilters.in(i).Numerator(1,handles.order+1) = 0; % zero padding
    handles.bandFilters.out(i).Numerator(1,handles.order+1) = 0; % zero padding
end


% --- Executes on selection change in popupCage.
function popupCage_Callback(hObject, eventdata, handles)
% hObject    handle to popupCage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupCage contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupCage


% --- Executes during object creation, after setting all properties.
function popupCage_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupCage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in buttonExportTDT.
function buttonExportTDT_Callback(hObject, eventdata, handles)
% hObject    handle to buttonExportTDT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

fig = figure;
set(fig,'MenuBar','none','Position',[500,500,300,150],'NumberTitle','off','Name','Filter export');
text(0.0,0.8,{'Open the DSP program',['Filter order: ',num2str(length(handles.bandFilters.('in')(1).Numerator)-1)]},'fontsize',12);
axis off
h = uicontrol('Position',[120 20 80 40],'String','Continue','Callback','uiresume(gcbf)','fontsize',12);
uiwait(gcf);
close(fig);

format long; % important to show many digits of the filter coefficients

f = 'in';
for n = 1:3;
    str = sprintf('0\n%6.15f',handles.bandFilters.(f)(n).Numerator(1));
    for(nCoef = 2:length(handles.bandFilters.(f)(n).Numerator))
        str = [str, sprintf('\n%6.15f',handles.bandFilters.(f)(n).Numerator(nCoef))];
    end
    clipboard('copy', str);
    fig = figure(55);
    set(fig,'MenuBar','none','Position',[500,500,200,200],'NumberTitle','off','Name','Filter export');
    text(0.1,0.8,{['Filter: ',upper(f),' ',num2str(n),],[],['Order:', num2str(length(handles.bandFilters.(f)(n).Numerator)-1)],...
        ['First:', num2str(handles.bandFilters.(f)(n).Numerator(1))]},'fontsize',14);
    axis off
    h = uicontrol('Position',[50 20 100 40],'String','Next filter','Callback','uiresume(gcbf)');
    uiwait(gcf);
    close(fig);
end

f = 'out';
for n = 1:3;
    str = sprintf('0\n%6.15f',handles.bandFilters.(f)(n).Numerator(1));
    for(nCoef = 2:length(handles.bandFilters.(f)(n).Numerator))
        str = [str, sprintf('\n%6.15f',handles.bandFilters.(f)(n).Numerator(nCoef))];
    end
    clipboard('copy', str);
    fig = figure(55);
    set(fig,'MenuBar','none','Position',[500,500,200,200],'NumberTitle','off','Name','Filter export');
    text(0.1,0.8,{['Filter: ',upper(f),' ',num2str(n),],[],['Order:', num2str(length(handles.bandFilters.(f)(n).Numerator)-1)],...
        ['First:', num2str(handles.bandFilters.(f)(n).Numerator(1))]},'fontsize',14);
    axis off

    h = uicontrol('Position',[50 20 100 40],'String','Next filter','Callback','uiresume(gcbf)');
    
    uiwait(gcf);
    close(fig);
end

%-- export lpBands
str = sprintf('0\n%6.15f',handles.lpBands.Numerator(1));
for(nCoef = 2:length(handles.lpBands.Numerator))
    str = [str, sprintf('\n%6.15f',handles.lpBands.Numerator(nCoef))];
end
clipboard('copy', str);
fig = figure(55);
set(fig,'MenuBar','none','Position',[500,500,200,200],'NumberTitle','off','Name','Filter export');
text(0.1,0.8,{['lpBands'],[],['Order:', num2str(length(handles.lpBands.Numerator)-1)],...
    ['First:', num2str(handles.lpBands.Numerator(1))]},'fontsize',14);
axis off
h = uicontrol('Position',[50 20 100 40],'String','Next filter','Callback','uiresume(gcbf)');
uiwait(gcf);
close(fig);

%-- export lpBird
str = sprintf('0\n%6.15f',handles.lpBird.Numerator(1));
for(nCoef = 2:length(handles.lpBird.Numerator))
    str = [str, sprintf('\n%6.15f',handles.lpBird.Numerator(nCoef))];
end
clipboard('copy', str);
fig = figure(55);
set(fig,'MenuBar','none','Position',[500,500,200,200],'NumberTitle','off','Name','Filter export');
text(0.1,0.8,{['lpBird',],[],['Order:', num2str(length(handles.lpBird.Numerator)-1)],...
    ['First:', num2str(handles.lpBird.Numerator(1))]},'fontsize',14);
axis off
h = uicontrol('Position',[50 20 100 40],'String','Next','Callback','uiresume(gcbf)');
uiwait(gcf);
close(fig);

fig = figure(55);
set(fig,'MenuBar','none','Position',[500,500,300,300],'NumberTitle','off','Name','Parameter check');
text(0.1,0.8,{['Pitch thres: ',num2str(handles.thres)],['beta:', num2str(handles.beta)],...
    ['minsongpower: ',num2str(handles.minsongpower)],['maxamp: ', num2str(handles.maxamp)]},'fontsize',14);
axis off
h = uicontrol('Position',[100 50 100 40],'String','Done!','Callback','uiresume(gcbf)');
uiwait(gcf);
close(fig);

%--- save  filter coefficients
Filters.bandFilters = handles.bandFilters; % 6 filters
Filters.lpBands = handles.lpBands;
Filters.lpBird = handles.lpBird;
Filters.thres = handles.thres;
Filters.beta = handles.beta;
Filters.minsongpower = handles.minsongpower;
Filters.maxamp = handles.maxamp;

if exist('Z:\Data\LMANstim')
    cd('Z:\Data\LMANstim');
    if exist(handles.birdName)
        cd(handles.birdName);
    end
end
DateVec = round(datevec(now));
DateStr = [num2str(DateVec(1)),'-',num2str(DateVec(2)),'-',num2str(DateVec(3)),'-',num2str(DateVec(4)),'-',...
    num2str(DateVec(5)),'-',num2str(DateVec(6))];
if handles.bUp
    Direction = 'up'; % pushing up
else
    Direction = 'down';
end
DefaultName = [handles.birdName,'_filter_',DateStr,'-',Direction,'.mat']; % use current date as default
[file, path] = uiputfile('*.mat','Save filters',DefaultName);
if ~isstr(file)
    return
end
save([path file],'Filters')
