function varargout = aSAP_TemplateDesigner(varargin)
% ASAP_TEMPLATEDESIGNER M-file for aSAP_TemplateDesigner.fig
%      ASAP_TEMPLATEDESIGNER, by itself, creates a new ASAP_TEMPLATEDESIGNER or raises the existing
%      singleton*.
%
%      H = ASAP_TEMPLATEDESIGNER returns the handle to a new ASAP_TEMPLATEDESIGNER or the handle to
%      the existing singleton*.
%
%      ASAP_TEMPLATEDESIGNER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ASAP_TEMPLATEDESIGNER.M with the given input arguments.
%
%      ASAP_TEMPLATEDESIGNER('Property','Value',...) creates a new ASAP_TEMPLATEDESIGNER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before aSAP_TemplateDesigner_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to aSAP_TemplateDesigner_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help aSAP_TemplateDesigner

% Last Modified by GUIDE v2.5 01-Mar-2006 15:05:53

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @aSAP_TemplateDesigner_OpeningFcn, ...
                   'gui_OutputFcn',  @aSAP_TemplateDesigner_OutputFcn, ...
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


% --- Executes just before aSAP_TemplateDesigner is made visible.
function aSAP_TemplateDesigner_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to aSAP_TemplateDesigner (see VARARGIN)

%Either pass:  aSAP_TemplateDesigner(birdID, ageStr, wavfullfilenames)
%         or:  aSAP_TemplateDesigner(templatesFile, wavfullfilenames)

% Choose default command line output for aSAP_TemplateDesigner
handles.output = hObject;

linkaxes([handles.axesSD,handles.axesSegment], 'x');

%Load arguments
if(length(varargin)==3)
    handles.birdId = varargin{1};
    handles.ageStr = varargin{2};
    set(handles.editTemplateFilename, 'String', ['templates-',handles.birdId,'-',handles.ageStr,'.mat']);
    handles.wavfiles = varargin{3};
    handles.templates = {};
else
    load(varargin{1});
    handles.templates = templates; 
    handles.birdId = handles.templates{1}.birdId;
    handles.ageStr = handles.templates{1}.ageStr;
    set(handles.editTemplateFilename, 'String', varargin{1}); 
    handles.wavfiles = varargin{2};
end
handles.nFile = 1;

set(handles.textBirdID, 'String', handles.birdId);
set(handles.textAge, 'String', handles.ageStr);

handles = updateTemplateDisplay(handles);
handles = updateCurrentFile(handles);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes aSAP_TemplateDesigner wait for user response (see UIRESUME)
% uiwait(handles.aSAP_TemplateDesigner);


% --- Outputs from this function are returned to the command line.
function varargout = aSAP_TemplateDesigner_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.templates;

% --- Executes on button press in pushbutton1.
function buttonPrevFile_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.nFile = max(1,handles.nFile - 1)
handles = updateCurrentFile(handles);
guidata(hObject, handles);

% --- Executes on button press in pushbutton2.
function buttonNextFile_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.nFile = min(length(handles.wavfiles),handles.nFile + 1)
handles = updateCurrentFile(handles);
guidata(hObject, handles);

function editFlexName_Callback(hObject, eventdata, handles)
% hObject    handle to editFlexName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editFlexName as text
%        str2double(get(hObject,'String')) returns contents of editFlexName as a double
nTemplate = get(handles.popupFlex, 'Value');
handles.templates{nTemplate}.name = get(handles.editFlexName,'String');
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function editFlexName_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editFlexName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu1.
function popupFlex_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1
handles = updateTemplateDisplay(handles);

% --- Executes during object creation, after setting all properties.
function popupFlex_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editTemplateFilename_Callback(hObject, eventdata, handles)
% hObject    handle to editTemplateFilename (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editTemplateFilename as text
%        str2double(get(hObject,'String')) returns contents of editTemplateFilename as a double


% --- Executes during object creation, after setting all properties.
function editTemplateFilename_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editTemplateFilename (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in buttonSave.
function buttonSave_Callback(hObject, eventdata, handles)
% hObject    handle to buttonSave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
templates = handles.templates;
uisave('templates',get(handles.editTemplateFilename,'String'));


% --- Executes on button press in buttonDeleteTemplate.
function buttonDeleteTemplate_Callback(hObject, eventdata, handles)
% hObject    handle to buttonDeleteTemplate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
nTemplate = get(handles.popupFlex, 'Value');
handles.templates = [handles.templates(1:nTemplate-1);handles.templates(nTemplate+1:end)];

set(handles.popupFlex,'Value',1);
set(handles.popupFlex,'Min',1);
set(handles.popupFlex,'Max',length(handles.templates));
set(handles.popupFlex,'String',num2str([1:length(handles.templates)]'));
set(handles.popupFlex,'Value',length(handles.templates));

handles = updateTemplateDisplay(handles);
guidata(hObject, handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5

function handles = updateCurrentFile(handles)
wavfilename = handles.wavfiles{handles.nFile};

%Load Audio and filter below 300hz with hamming filter.
[audio,fs] = wavread(wavfilename);
filtOrder = 200; %suffiencity for 44100Hz of lower
filtwin = hann(filtOrder+1);
freqCutoff = 300; %Hz
hpf = fir1(filtOrder, freqCutoff/(fs/2), 'high', filtwin);
audio = filter(hpf, 1, audio);

%Store it..
handles.currAudio = audio;
handles.currRawAudioFS = fs;

%Plot the audio
handles = plotAudioAxes(handles);
drawnow; 

%Load the features
handles = loadOrComputeCurrentFileFeatures(handles);

%Plot the SD axes
handles = plotSD(handles);
drawnow;

%Segment
[handles.syllStartTimes, handles.syllEndTimes] = aSAP_segSyllablesFromRawAudio(audio, fs);
[handles.boutStartSyll, handles.boutEndSyll] = aSAP_segBoutsFromRawAudio(handles.syllStartTimes, handles.syllEndTimes);

handles = plotSegment(handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function handles = loadOrComputeCurrentFileFeatures(handles)
wavfilename = handles.wavfiles{handles.nFile};

%Load Features
[path,name,ext] = fileparts(wavfilename);
featfilename = [path,filesep,name,'.feat','.mat'];
d = dir(featfilename);
if(length(d)==0)
    aSAP_generateASAPFeatureFileFromWav(wavfilename);        
end

load(featfilename);
handles.SAPFeats = SAPFeats;

%Load lossy spectral derivative 
try
    handles.m_spec_deriv = aSAP_uncompressSpectralDeriv(handles.SAPFeats.specDerivFileName);
catch 
    handles.m_spec_deriv = aSAP_uncompressSpectralDeriv([path, filesep, name,'.sd']);
end
% ---------------------------------------------------------

function handles = plotAudioAxes(handles)
fs = handles.currRawAudioFS;
audio = handles.currAudio;

subplot(handles.axesAudio); 
plot([0:(length(audio)/fs)/(length(audio)-1):length(audio)/fs],audio); axis tight;
%plot(audio(1:100:end)); axis tight;
set(gca, 'Color', [0 0 0]);
set(gca, 'XTickLabelMode', 'manual');
set(gca, 'XTickLabel',[]);
clearVisibleLimitsOnAudio(handles);

set(handles.axesAudio, 'ButtonDownFcn', {@CBAudioAxesButtonPress, handles});

%-----------------------------------------------------

function CBAudioAxesButtonPress(hObj, event, oldhandles)
%get the rectangle
handles = guidata(hObj);
zoomRect = rbbox;
zoomRect = convertFigUnits2AxesValues(zoomRect, handles.aSAP_TemplateDesigner, handles.axesAudio); 
startPos = zoomRect(1);
widthPos = zoomRect(3);
if(widthPos > .005)
    handles = panSD(handles, startPos, widthPos);
    guidata(hObj, handles);
end

%------------------------------------------

function handles = panSD(handles, start, width)
axes(handles.axesSD);

%pan time axis
xlim([start,start+width]);

%demarcate limits on AudioAxes
markVisibleLimitsOnAudio(handles);

% ----------------------------------------------

function markVisibleLimitsOnAudio(handles)
clearVisibleLimitsOnAudio(handles);
timeLimits = xlim(handles.axesSD);
axes(handles.axesAudio);
y = ylim;
y = [y(1), y(2), y(2), y(1)];
x = [timeLimits(1), timeLimits(1),timeLimits(2), timeLimits(2)];
p = patch(x,y, 'red');
set(p,'Tag','limitPatch');
set(p,'EraseMode','XOR');

% ----------------------------------------------

function clearVisibleLimitsOnAudio(handles)
delete(findobj(handles.axesAudio, 'Tag', 'limitPatch'));

% ---------------------------------------------------

function handles = plotSD(handles)
%don't set anything on handles within this function.
axes(handles.axesSD);
m_spec_deriv = handles.m_spec_deriv;

startTime = 0;
startPos = 0;
endPos = -Inf;
inchPerSec = 5;
inchPerkHz = 0;
bAutoScale = true;
fScale = 0;
bSigmoid = true;
bModifyAxesW = false;
bModifyAxesH = false;

aSAP_displaySpectralDerivative(m_spec_deriv, handles.SAPFeats.param, startTime, startPos, endPos, bSigmoid, fScale, inchPerSec, inchPerkHz, bModifyAxesW, bModifyAxesH);
    
title(datestr(handles.SAPFeats.time,0));
xlabel('');
set(gca, 'XTickLabelMode', 'manual');
set(gca, 'XTickLabel',[]);
set(gca, 'TickLength', [.0025, .025]);  
markVisibleLimitsOnAudio(handles);

% -----------------------------------------------------

function handles = plotSegment(handles)
axes(handles.axesSegment);
cla;
xlimits = xlim(handles.axesSD);

for(nSyll = 1:length(handles.syllStartTimes))
    time = [handles.syllStartTimes(nSyll), handles.syllEndTimes(nSyll)];
    x = [time(1),time(1),time(2),time(2)];
    y = [.6,.9,.9,.6];
    p = patch(x,y,'red');
    set(p,'ButtonDownFcn',@CBTemplateSelected);
    set(p,'UserData',time);
end

for(nBout = 1:length(handles.boutStartSyll))
    time = [handles.syllStartTimes(handles.boutStartSyll(nBout)), handles.syllEndTimes(handles.boutEndSyll(nBout))];
    x = [time(1),time(1),time(2),time(2)];
    y = [.1,.4,.4,.1];
    p = patch(x,y,'blue');
    set(p,'ButtonDownFcn',{@CBTemplateSelected, handles});
    set(p,'UserData',time);
end

xlabel('time (s)');
xlim(xlimits);
ylim([0,1]);

% ---------------------------------------------------------

function CBTemplateSelected(hObj, event, junk)
%get the rectangle
handles = guidata(hObj);
type = get(handles.aSAP_TemplateDesigner,'SelectionType');
if(strcmp(type,'open'))
    time = get(hObj,'UserData');
    
    %add buffer to segment
    time(1) = time(1) - .015;
    time(2) = time(2) + .005;
    
    %store basic like name, number, bird...
    newTemplate.name = '';
    newTemplate.birdId = handles.birdId;
    newTemplate.ageStr = handles.ageStr;
    number = 1;
    %find an available number
    for(nTemp = 1:length(handles.templates))
        number = max(number,handles.templates{nTemp}.number + 1);
    end
    newTemplate.number = number;
    
    %add audio information to the template
    newTemplate.file = handles.wavfiles{handles.nFile};
    newTemplate.fileStartTime = time(1);
    newTemplate.fileEndTime = time(2);
    newTemplate.fileFs = handles.currRawAudioFS;
    fs = handles.currRawAudioFS;
    newTemplate.audio = handles.currAudio(round(time(1)*fs) + 1: round(time(2)*fs) + 1);
    
    %Add feature and spectral derivative info to the template
    newTemplate.param = handles.SAPFeats.param;
    newTemplate.featS = max(1,aSAP_conTime2FeatNdx(time(1), handles.SAPFeats.param.fs, handles.SAPFeats.param.winstep));
    newTemplate.featE = min(size(handles.m_spec_deriv,1),aSAP_conTime2FeatNdx(time(2), handles.SAPFeats.param.fs, handles.SAPFeats.param.winstep));
    newTemplate.m_spec_deriv = handles.m_spec_deriv(newTemplate.featS:newTemplate.featE,:);
    newTemplate.m_AM = handles.SAPFeats.m_AM(newTemplate.featS:newTemplate.featE);
    newTemplate.m_FM = handles.SAPFeats.m_FM(newTemplate.featS:newTemplate.featE);
    newTemplate.m_Entropy = handles.SAPFeats.m_Entropy(newTemplate.featS:newTemplate.featE);
    newTemplate.m_amplitude = handles.SAPFeats.m_amplitude(newTemplate.featS:newTemplate.featE);
    newTemplate.gravity_center = handles.SAPFeats.gravity_center(newTemplate.featS:newTemplate.featE);
    newTemplate.m_PitchGoodness = handles.SAPFeats.m_PitchGoodness(newTemplate.featS:newTemplate.featE);            
    newTemplate.m_Pitch = handles.SAPFeats.m_Pitch(newTemplate.featS:newTemplate.featE);       
    newTemplate.Pitch_chose = handles.SAPFeats.Pitch_chose(newTemplate.featS:newTemplate.featE);       
    newTemplate.Pitch_weight = handles.SAPFeats.Pitch_weight(newTemplate.featS:newTemplate.featE);       
    newTemplate.filt = handles.SAPFeats.filt;
    
    %Add the new template to the template cell array.
    handles.templates = [handles.templates, {newTemplate}];

    set(handles.popupFlex,'Value',1);
    set(handles.popupFlex,'Min',1);
    set(handles.popupFlex,'Max',length(handles.templates));
    set(handles.popupFlex,'String',num2str([1:length(handles.templates)]'));
    set(handles.popupFlex,'Value',length(handles.templates));

    handles = updateTemplateDisplay(handles);
end

guidata(hObj,handles);

% --------------------------------------------------------------

function handles = updateTemplateDisplay(handles)
temps = handles.templates;


for(nTemp = 1:6)
    axes(getField(handles,['axes',num2str(nTemp),'SD']));
    if(nTemp<=length(temps))       
        aSAP_displaySpectralDerivative(temps{nTemp}.m_spec_deriv, temps{nTemp}.param);
        xlabel('');
        set(gca, 'XTickLabelMode', 'manual');
        set(gca, 'XTickLabel',[]);
        set(gca, 'TickLength', [.0025, .025]);         
    else
        cla;
    end
end

axes(handles.axesFlexSD);
if(length(temps) > 0)
    nTemp = get(handles.popupFlex,'Value');
    set(handles.editFlexName,'String',temps{nTemp}.name);
    aSAP_displaySpectralDerivative(temps{nTemp}.m_spec_deriv, temps{nTemp}.param);
    xlabel('');
    set(gca, 'XTickLabelMode', 'manual');
    set(gca, 'XTickLabel',[]);
    set(gca, 'TickLength', [.0025, .025]); 
else
    set(handles.editFlexName,'String','');
    cla;
end
        
        
