function varargout = annotateExperAudio(varargin)
% ANNOTATEEXPERAUDIO M-file for annotateExperAudio.fig
%      ANNOTATEEXPERAUDIO, by itself, creates a new ANNOTATEEXPERAUDIO or raises the existing
%      singleton*.
%
%      H = ANNOTATEEXPERAUDIO returns the handle to a new ANNOTATEEXPERAUDIO or the handle to
%      the existing singleton*.
%
%      ANNOTATEEXPERAUDIO('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ANNOTATEEXPERAUDIO.M with the given input arguments.
%
%      ANNOTATEEXPERAUDIO('Property','Value',...) creates a new ANNOTATEEXPERAUDIO or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before annotateExperAudio_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to annotateExperAudio_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help annotateExperAudio

% Last Modified by GUIDE v2.5 28-Oct-2006 19:25:52

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @annotateExperAudio_OpeningFcn, ...
                   'gui_OutputFcn',  @annotateExperAudio_OutputFcn, ...
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


% --- Executes just before annotateExperAudio is made visible.
function annotateExperAudio_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to annotateExperAudio (see VARARGIN)

% Choose default command line output for annotateExperAudio
handles.output = hObject;
handles.exper = [];
handles.filenum = -1;
handles.selectedSyll = -1;
handles.startNdx = -1;
handles.endNdx = -1;
handles.txtHandles = [];
handles.rectHandles = [];
handles.navRect = [];
handles.audioAnnotation = mhashtable;
handles.bWaitingForAddClick = false;
handles.bWaitingForSeparationClick = false;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes annotateExperAudio wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = annotateExperAudio_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
if(~isequal(handles.exper,[]))
    saveExper(handles.exper);
end
varargout{1} = handles.output;


% --- Executes on button press in buttonNewAnnotation.
function buttonNewAnnotation_Callback(hObject, eventdata, handles)
% hObject    handle to buttonNewAnnotation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%If annotation is already open check whether they want to append or clear.
if(isfield(handles, 'annotationFileName'))
    ansButton = questdlg('Would you like to clear the current annotations, or append to them?','',{'Clear','Append'});
end

%Get the new filename.
[file,path] = uiputfile('*.mat', 'Create a .mat file for the audioAnnotation:');

if isequal(file,0) || isequal(path,0)
else
    %if they don't his cancel..
    if(isfield(handles,'annotationFileName') && strcmp(ansButton, 'Clear'))
        %already have an annotation object loaded, then save clear current annotation.
        saveAnnotation(handles);
        guidata(hObject, handles);
        buttonClearAll_Callback(hObject, eventdata, handles);
        handles = guidata(hObject);
        handles.audioAnnotation.delete;        
    elseif(~isfield(handles,'annotationFilename'))
        handles.audioAnnotation = mhashtable;
    end
    handles.annotationFileName = [path,filesep,file];
    saveAnnotation(handles);
end
guidata(hObject, handles);

function saveAnnotation(handles)
if(isfield(handles,'annotationFileName'))
    aaSaveHashtable(handles.annotationFileName, handles.audioAnnotation);
else
    warndlg('You have not yet created an annotation.');
    uiwait;
end

% --- Executes on button press in buttonLoadAnnotation.
function buttonLoadAnnotation_Callback(hObject, eventdata, handles)
% hObject    handle to buttonLoadAnnotation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Get the new filename.
[file,path] = uigetfile('*.mat', 'Choose an audio annotation .mat file to load:');

if isequal(file,0) || isequal(path,0)
else
    %if they don't his cancel..
    if(isfield(handles,'annotationFileName'))
        %already have an annotation object loaded, then save clear current annotation.
        saveAnnotation(handles);
        guidata(hObject, handles);
        buttonClearAll_Callback(hObject, eventdata, handles);
        handles = guidata(hObject);
        handles.audioAnnotation.delete;
        handles.audioAnnotation = mhashtable;        
    end
    handles.annotationFileName = [path,filesep,file];
    audioAnnotation = aaLoadHashtable(handles.annotationFileName);
    handles.audioAnnotation = audioAnnotation;
    handles = drawNavBarSyllableRects(handles);
    handles = drawZoomSyllableRects(handles);
end
guidata(hObject, handles);

% --- Executes on buttonUnknown press in buttonSubsong.
function buttonSubsong_Callback(hObject, eventdata, handles)
% hObject    handle to buttonSubsong (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = labelSyllable(handles, 100);
guidata(hObject, handles);

% --- Executes on buttonUnknown press in buttonNoise.
function buttonNoise_Callback(hObject, eventdata, handles)
% hObject    handle to buttonNoise (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = labelSyllable(handles, 101);
guidata(hObject, handles);

% --- Executes on buttonUnknown press in buttonCall.
function buttonCall_Callback(hObject, eventdata, handles)
% hObject    handle to buttonCall (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = labelSyllable(handles, 102);
guidata(hObject, handles);

% --- Executes on buttonUnknown press in buttonUnknown.
function buttonUnknown_Callback(hObject, eventdata, handles)
% hObject    handle to buttonUnknown (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = labelSyllable(handles, 103);
guidata(hObject, handles);

% --- Executes on buttonUnknown press in buttonLoadExper.
function buttonLoadExper_Callback(hObject, eventdata, handles)
% hObject    handle to buttonLoadExper (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[file, path] = uigetfile;
try,
    load([path,filesep,file]);
    exper.dir = path;
    handles.exper = exper;
    handles.chan = exper.sigCh(1);
    saveExper(handles.exper);
    if(length(exper.sigCh)>1)
        set(handles.popupChannel,'String',exper.sigCh);
        set(handles.popupChannel,'Value',1);
    else
        set(handles.popupChannel,'String',exper.audioCh);
        set(handles.popupChannel,'Value',1);
    end
    cla(handles.axesNavBar);
    cla(handles.axesSpecgram);
    cla(handles.axesPower);
    cla(handles.axesSignal);
catch,
end
guidata(hObject, handles);
updateTemplates(handles);


function editFileNum_Callback(hObject, eventdata, handles)
% hObject    handle to editFileNum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editFileNum as text
%        str2double(get(hObject,'String')) returns contents of editFileNum as a double
filenum = get(handles.editFileNum, 'String');
filenum = str2num(filenum);
handles = loadfile(handles, filenum);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function editFileNum_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editFileNum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on buttonUnknown press in buttonPrevFile.
function buttonPrevFile_Callback(hObject, eventdata, handles)
% hObject    handle to buttonPrevFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
filenum = handles.filenum - 1;
handles = loadfile(handles, filenum);
guidata(hObject, handles);

% --- Executes on buttonUnknown press in buttonNextFile.
function buttonNextFile_Callback(hObject, eventdata, handles)
% hObject    handle to buttonNextFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
filenum = handles.filenum + 1;
handles = loadfile(handles, filenum);
guidata(hObject, handles);


function editPowerThreshold_Callback(hObject, eventdata, handles)
% hObject    handle to editPowerThreshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editPowerThreshold as text
%        str2double(get(hObject,'String')) returns contents of editPowerThreshold as a double


% --- Executes during object creation, after setting all properties.
function editPowerThreshold_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editPowerThreshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on buttonUnknown press in buttonDeleteSyll.
function buttonDeleteSyll_Callback(hObject, eventdata, handles)
% hObject    handle to buttonDeleteSyll (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if(handles.selectedSyll ~= -1)
    nSyll = handles.selectedSyll;
    handles = deleteSyllableRectAndTxt(handles, nSyll);
    if(size(handles.txtHandles,1) >= nSyll)
        handles.txtHandles(nSyll,:) = [];
    end
    if(size(handles.rectHandles,1) >= nSyll)
        handles.rectHandles(nSyll,:) = [];
    end
    currAnnotation = handles.audioAnnotation.get(handles.filename)
    currAnnotation.segAbsStartTimes(nSyll) = [];
    currAnnotation.segFileStartTimes(nSyll) = [];
    currAnnotation.segFileEndTimes(nSyll) = [];
    currAnnotation.segType(nSyll) = [];
    selectedSyll = handles.selectedSyll;
    handles.audioAnnotation.put(handles.filename, currAnnotation);
    if(length(currAnnotation.segAbsStartTimes)== 0)
        selectedSyll = -1;
    elseif(selectedSyll > length(currAnnotation.segAbsStartTimes));
        selectedSyll = selectedSyll - 1;
    end    
    
    handles = setSelectedSyllable(handles, selectedSyll);    
    guidata(hObject, handles);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
function handles = deleteSyllableRectAndTxt(handles, nSyll)
if(size(handles.txtHandles,1) >= nSyll)
    for(nTxt = size(handles.txtHandles,2))
        if(ishandle(handles.txtHandles(nSyll,nTxt)))
            delete(handles.txtHandles(nSyll,nTxt));
            handles.txtHandles(nSyll,nTxt) = -1;
        end
    end
end
if(size(handles.rectHandles,1) >= nSyll)
    for(nRect = 1:size(handles.rectHandles,2))
        if(ishandle(handles.rectHandles(nSyll,nRect)))
            delete(handles.rectHandles(nSyll,nRect));
            handles.rectHandles(nSyll,nRect) = -1;
        end
    end
end
    

% --- Executes on buttonUnknown press in buttonAddSyll.
function buttonAddSyll_Callback(hObject, eventdata, handles)
% hObject    handle to buttonAddSyll (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.bWaitingForAddClick = true;
handles.bWaitingForSeparationClick = false;
set(handles.buttonAddSyll, 'BackgroundColor', 'red');
guidata(hObject, handles);

% --- Executes on buttonUnknown press in buttonDeletePause.
function buttonDeletePause_Callback(hObject, eventdata, handles)
% hObject    handle to buttonDeletePause (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if(handles.selectedSyll ~= -1)
    filenum = handles.filenum;
    nSyll = handles.selectedSyll;
    nSyllNext = nSyll + 1;
    currAnnotation = handles.audioAnnotation.get(handles.filename);
    numSyll = length(currAnnotation.segAbsStartTimes);
    if(nSyll<numSyll)
        %if there is a syllable beyond the selected one, then delete
        %the pause in between.
        %delete the rectangles and text for both syllables.
        handles = deleteSyllableRectAndTxt(handles,nSyll);
        handles = deleteSyllableRectAndTxt(handles,nSyllNext);
        if((size(handles.txtHandles,1)) >= nSyllNext)
            handles.txtHandles(nSyllNext,:) = [];
        end
        if((size(handles.rectHandles,1)) >= nSyllNext)
            handles.rectHandles(nSyllNext,:) = [];
        end       
        
        currAnnot = handles.audioAnnotation.get(handles.filename);
        currAnnot.segAbsStartTimes(nSyllNext) = [];
        currAnnot.segFileStartTimes(nSyllNext) = [];
        currAnnot.segFileEndTimes(nSyll) = [];
        currAnnot.segType(nSyll) = -1;
        currAnnot.segType(nSyllNext) = [];
        handles.audioAnnotation.put(handles.filename, currAnnot);
        handles = drawSyllableRect(handles, nSyll);
        if(ishandle(handles.rectHandles(nSyll,:)))
            set(handles.rectHandles(nSyll,:),'FaceColor','green');
        end
        guidata(hObject, handles);
    end
end

% --- Executes on buttonUnknown press in buttonAddPause.
function buttonAddPause_Callback(hObject, eventdata, handles)
% hObject    handle to buttonAddPause (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.bWaitingForAddClick = false;
handles.bWaitingForSeparationClick = true;
guidata(hObject, handles);

% --- Executes on button press in buttonClearAll.
function buttonClearAll_Callback(hObject, eventdata, handles)
% hObject    handle to buttonClearAll (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
for(nSyll = 1:max(size(handles.txtHandles,1),size(handles.rectHandles,1)))
    handles = deleteSyllableRectAndTxt(handles, nSyll);
end
handles.txtHandles = [];
handles.rectHandles = [];
handles.audioAnnotation.remove(handles.filename);
handles.selectedSyll = -1;
guidata(hObject, handles);

% --- Executes on button press in buttonAutoSeg.
function buttonAutoSeg_Callback(hObject, eventdata, handles)
% hObject    handle to buttonAutoSeg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fs = handles.exper.desiredInSampRate;
startTime = (handles.startNdx-1)/handles.fs;
endTime = (handles.endNdx-1)/handles.fs;
startNdx = handles.startNdx;
endNdx = handles.endNdx;

[syllStartTimes, syllEndTimes, noiseEst, noiseStd, soundEst, soundStd] = aSAP_segSyllablesFromRawAudio(handles.audio, fs);
time = extractExperFilenumTime(handles.exper,handles.filenum)

currAnnot.exper = handles.exper;
currAnnot.filenum = handles.filenum;
currAnnot.segAbsStartTimes = time + (syllStartTimes/(24*60*60));
currAnnot.segFileStartTimes = syllStartTimes;
currAnnot.segFileEndTimes = syllEndTimes;
currAnnot.segType = repmat(-1,length(syllStartTimes), 1);
currAnnot.fs = fs;
handles.audioAnnotation.put(handles.filename, currAnnot);

%draw syllable information
handles.rectHandles = [];
handles.txtHandles = [];
filenum = handles.filenum;
handles = drawNavBarSyllableRects(handles);
handles = drawZoomSyllableRects(handles);
guidata(hObject, handles);


% --- Executes on selection change in popupChannel.
function popupChannel_Callback(hObject, eventdata, handles)
% hObject    handle to popupChannel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupChannel contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupChannel
channels = get(handles.popupChannel, 'String');
nValue = get(handles.popupChannel, 'Value');
chan = channels(nValue);
axes(handles.axesSignal);
try,
    handles.sig = loadData(handles.exper, handles.filenum, chan)
    plotTimeSeriesQuick(handles.time(handles.startNdx:handles.endNdx), handles.sig(handles.startNdx:handles.endNdx));
    set(handles.axesSignal, 'ButtonDownFcn', '');
    axes tight;
catch,
    gca;
end
guidata(hObject, handles);

function chan = getChan(handles)
channels = get(handles.popupChannel, 'String');
nValue = get(handles.popupChannel, 'Value');
chan = channels(nValue);

% --- Executes during object creation, after setting all properties.
function popupChannel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupChannel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in buttonSaveTemplates.
function buttonSaveTemplates_Callback(hObject, eventdata, handles)
% hObject    handle to buttonSaveTemplates (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if(isfield(handles,'templates'))
    uisave('templates')
else
    warndlg('No templates to save.');
    uiwait;
end

% --- Executes on button press in buttonLoadTemplates.
function buttonLoadTemplates_Callback(hObject, eventdata, handles)
% hObject    handle to buttonLoadTemplates (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
uiload;
handles.templates = templates;
guidata(hObject, handles);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function handles = labelSyllable(handles, label)
if(handles.filenum > 0 && handles.selectedSyll > 0)
    filenum = handles.filenum;
    nSyll = handles.selectedSyll;
    fs = handles.fs;
    
    %set the label value
    currAnnot = handles.audioAnnotation.get(handles.filename);
    currAnnot.segType(nSyll) = label;
    handles.audioAnnotation.put(handles.filename, currAnnot);
    
    %delete any old text handles.
    if((size(handles.txtHandles,1)) >= nSyll)
        for(nTxt = 1:size(handles.txtHandles,2))
            if ishandle(handles.txtHandles(nSyll,nTxt))
                delete(handles.txtHandles(nSyll,nTxt));
                handles.txtHandles(nSyll,nTxt) = -1;
            end
        end
    end
    
    %Compute middle of syllable
    midSyll = (currAnnot.segFileEndTimes(nSyll) + currAnnot.segFileStartTimes(nSyll)) / 2;
    
    %create a new text
    axes(handles.axesSpecgram);
    handles.txtHandles(nSyll, 1) = text(midSyll,mean(ylim),num2str(label));
    axes(handles.axesPower);
    handles.txtHandles(nSyll, 2) = text(midSyll,mean(ylim),num2str(label));
    axes(handles.axesSignal);
    handles.txtHandles(nSyll, 3) = text(midSyll,mean(ylim),num2str(label));
    set(handles.txtHandles(nSyll,1:3), 'Color', 'black');
    set(handles.txtHandles(nSyll,1:3), 'FontSize', 14);
    set(handles.txtHandles(nSyll,1:3), 'FontWeight', 'bold');
    set(handles.txtHandles(nSyll,1:3), 'HitTest', 'off');
    set(handles.txtHandles(nSyll,1:3), 'HorizontalAlignment', 'center'); 
 
    %change rect colors to blue
    if(ishandle(handles.rectHandles(nSyll,:)))
        set(handles.rectHandles(nSyll,:),'FaceColor','blue');
    end
    
    %set the current lable text
    set(handles.textCurrentLabel,'String', ['Current Label: ', num2str(label)]);
    %select next syllable and shift specgram axis.
    handles = setSelectedSyllable(handles, handles.selectedSyll + 1);
    if(currAnnot.segFileEndTimes(nSyll) > (handles.endNdx-1)/fs)
        width = handles.endNdx - handles.startNdx;
        handles.startNdx = max(0,round(round((midSyll*fs)+1) - width/2));
        handles.endNdx = min(length(handles.audio), round(round((midSyll*fs)+1) + width/2));
        handles = updateZoomOrPan(handles);
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function handles = drawSyllableRect(handles, nSyll, bInsert)
fs = handles.fs;
windowStartTime = (handles.startNdx-1)/fs;
windowEndTime = (handles.endNdx-1)/fs;
currAnnot = handles.audioAnnotation.get(handles.filename);
startTime = currAnnot.segFileStartTimes(nSyll);
endTime = currAnnot.segFileEndTimes(nSyll);
label = currAnnot.segType(nSyll);
if(label ~= -1)
    color = [0 0 1];
else
    color = [1 0 0];
end
if(handles.selectedSyll == nSyll)
    color = [0,1,0];
end

if(~exist('bInsert') || ~bInsert)
    handles = deleteSyllableRectAndTxt(handles, nSyll);
end

x = [startTime, startTime, endTime, endTime, startTime];
axes(handles.axesNavBar)
lims = ylim;
y = [lims(1), lims(2), lims(2), lims(1), lims(1)];

if(exist('bInsert') && bInsert)
    handles.rectHandles = [handles.rectHandles([1:nSyll-1],:);repmat(-1,1,size(handles.rectHandles,2));handles.rectHandles([nSyll:end],:)];
    handles.txtHandles = [handles.txtHandles([1:nSyll-1],:);repmat(-1,1,size(handles.txtHandles,2));handles.txtHandles([nSyll:end],:)];
end

handles.rectHandles(nSyll, 1) = patch(x,y, color, 'EdgeColor', 'none', 'FaceAlpha', .5);
set(handles.rectHandles(nSyll,1), 'HitTest', 'off'); 

if(startTime<=windowEndTime & endTime>=windowStartTime)    
    axes(handles.axesSpecgram)
    lims = ylim;
    y = [lims(1), lims(2), lims(2), lims(1), lims(1)];
    handles.rectHandles(nSyll, 2) = patch(x,y, color, 'EdgeColor', 'none', 'FaceAlpha', .5);

    axes(handles.axesPower)
    lims = ylim;
    y = [lims(1), lims(2), lims(2), lims(1), lims(1)];
    handles.rectHandles(nSyll, 3) = patch(x,y, color, 'EdgeColor', 'none', 'FaceAlpha', .5);

    axes(handles.axesSignal)
    lims = ylim;
    y = [lims(1), lims(2), lims(2), lims(1), lims(1)];
    handles.rectHandles(nSyll, 4) = patch(x,y, color, 'EdgeColor', 'none', 'FaceAlpha', .5);
    
    set(handles.rectHandles(nSyll,2:4), 'HitTest', 'off'); 

    if(label ~= -1) 
        midSyll = mean([startTime,endTime]);
        %create a new text handles
        axes(handles.axesSpecgram);
        handles.txtHandles(nSyll, 1) = text(midSyll,mean(ylim),num2str(label));
        axes(handles.axesPower);
        handles.txtHandles(nSyll, 2) = text(midSyll,mean(ylim),num2str(label));
        axes(handles.axesSignal);
        handles.txtHandles(nSyll, 3) = text(midSyll,mean(ylim),num2str(label));
        set(handles.txtHandles(nSyll,:), 'Color', 'black');
        set(handles.txtHandles(nSyll,:), 'FontSize', 14);
        set(handles.txtHandles(nSyll,:), 'FontWeight', 'bold');
        set(handles.txtHandles(nSyll,:), 'HitTest', 'off');   
        set(handles.txtHandles(nSyll,:), 'HorizontalAlignment', 'center');         
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function handles = loadfile(handles, filenum)
saveAnnotation(handles);
if(filenum == handles.filenum)
    return;
end
try,
    fs = handles.exper.desiredInSampRate;
    handles.filename = getExperDatafile(handles.exper,filenum,handles.exper.audioCh);
    handles.audio = loadAudio(handles.exper, filenum);
    handles.sig = loadData(handles.exper, filenum, getChan(handles));
catch
    warndlg('File number specified does not exist.');
    set(handles.editFileNum,'String',num2str(handles.filenum));
    uiwait;
    return;
end
handles.filenum = filenum;
set(handles.editFileNum,'String',num2str(handles.filenum));
handles.time = linspace(0, (length(handles.audio)-1)/fs, length(handles.audio));
if(handles.endNdx - handles.startNdx > .01)
    width = min(handles.endNdx - handles.startNdx, length(handles.audio));
else
    width = length(handles.audio);
end
handles.startNdx = 1;
handles.endNdx = width;
handles.fs = fs;
[pow, filtAud] = aSAP_getLogPower(handles.audio, fs);
handles.audio = filtAud;
handles.power = pow;
handles.selectedSyll = -1;
handles.rectHandles = [];
handles.txtHandles = [];

axes(handles.axesNavBar);
plotTimeSeriesQuick(handles.time, handles.audio);
set(handles.axesNavBar,'Color','black');

%Draw rectangles on the nav bar...
if(handles.audioAnnotation.containsKey(handles.filename))
    currAnnot = handles.audioAnnotation.get(handles.filename);
    syllStartTimes = currAnnot.segFileStartTimes;
    syllEndTimes = currAnnot.segFileEndTimes;
    x = [syllStartTimes; syllStartTimes; syllEndTimes; syllEndTimes; syllStartTimes];
    axes(handles.axesNavBar)
    lims = ylim;
    y = [lims(1); lims(2); lims(2); lims(1); lims(1)];
    for(nSyll = 1:length(syllStartTimes))
        handles.rectHandles(nSyll, 1) = patch(x(:,nSyll),y, [1,0,0], 'EdgeColor', 'none', 'FaceAlpha', .5);
    end
    set(handles.rectHandles(:,1), 'HitTest', 'off');
end

handles = updateZoomOrPan(handles);

% 
% axes(handles.axesSpecgram);
% displaySpecgramQuick(handles.audio, fs, [0,10000]);
% 
% axes(handles.axesPower);
% plotTimeSeriesQuick(handles.time, handles.power);
% set(handles.axesPower, 'ButtonDownFcn', '');
% 
% axes(handles.axesSignal);
% plotTimeSeriesQuick(handles.time, handles.sig);
% set(handles.axesSignal,'Color','black');
% set(handles.axesSignal, 'ButtonDownFcn', '');
% 
% linkaxes([handles.axesSignal, handles.axesPower, handles.axesSpecgram],'x');
% set(get(handles.axesNavBar,'Parent'), 'KeyPressFcn', @cb_keypress);
% set(handles.axesNavBar, 'ButtonDownFcn', @cb_navbar_click);
% set(handles.axesSpecgram, 'ButtonDownFcn', @cb_specgram_click);
% 
% 
% if((filenum <= length(handles.audioAnnotation)) && ~isequal(handles.audioAnnotation{filenum},[]))
%     for(nSyll = 1:length(handles.audioAnnotation{filenum}.segFileStartTimes))
%         handles = drawSyllableRect(handles, nSyll);
%     end
% end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
function handles = setSelectedSyllable(handles, newSelectedSyll)
%make sure selection is in bounds
currAnnot = handles.audioAnnotation.get(handles.filename);
if(newSelectedSyll == -1)
    handles.selectedSyll = -1;
    return;
elseif(newSelectedSyll < 1 | newSelectedSyll > length(currAnnot.segAbsStartTimes))
    return
end

if(handles.selectedSyll ~= -1 && handles.selectedSyll < length(currAnnot.segAbsStartTimes))
    %unhighlight the old selected syll
    if(currAnnot.segType(handles.selectedSyll) == -1)
        color = 'red';
    else
        color = 'blue';
    end
    if(size(handles.rectHandles,1) >= handles.selectedSyll)
        for(nRect = 1:size(handles.rectHandles,2))
            if(ishandle(handles.rectHandles(handles.selectedSyll,nRect)))
                set(handles.rectHandles(handles.selectedSyll,nRect),'FaceColor',color);
            end
        end
    end
end

%set the selected syllable to return.
selectedSyll = newSelectedSyll;
handles.selectedSyll = selectedSyll;

%highlight the new selected syllable
if(size(handles.rectHandles,1) >= selectedSyll)
    for(nRect = 1:size(handles.rectHandles,2))
        if(ishandle(handles.rectHandles(selectedSyll,nRect)))
            set(handles.rectHandles(selectedSyll,nRect),'FaceColor','green');
        end
    end
end

%recenter if necessary
filenum = handles.filenum;
fs = handles.exper.desiredInSampRate;
startTime = (handles.startNdx-1)/handles.fs;
endTime = (handles.endNdx-1)/handles.fs;
syllEndTime = currAnnot.segFileEndTimes(selectedSyll);
syllStartTime = currAnnot.segFileStartTimes(selectedSyll);
if(syllEndTime > endTime || syllStartTime < startTime)
    width = handles.endNdx - handles.startNdx;
    mid = (syllStartTime*fs) + 1;
    handles.startNdx = round(mid - width/2);
    handles.endNdx = round(mid + width/2);
    if(handles.startNdx<1)
        handles.startNdx = 1;
        handles.endNdx = width + handles.startNdx;
    end
    if(handles.endNdx > length(handles.audio))
        handles.startNdx = length(handles.audio) - width;
        handles.endNdx = length(handles.audio);
    end        
    handles = updateZoomOrPan(handles);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function updateTemplates(handles)
cla(handles.axesTemplates);

if(isfield(handles, 'templates'))
    stdfs = 40000;
    allwavs = [];
    edges = [0];
    for(nWav = 1:length(handles.templates.wavs))
        fs = handles.templates.wavs(nWav).fs;
        wav = handles.templates.wavs(nWav).wav;
        label = handles.templates.wavs(nWav).segType;
        wav = resample(wav, stdfs, fs);
        allwavs = [allwavs; wav];
        edges = [edges, edges(end) + (length(wav) - 1)/stdfs];
    end
    
    %zero pad to 1 sec in length.
    if(edges(end) < 1)
        allwavs(end+1:stdfs) = 0;
    end
    
    %display the templates
    axes(handles.axesTemplates);
    displaySpecgramQuick(allwavs, stdfs, [0,10000], [-5,20]);
    
    %[SAPFeats, m_spec_deriv] = aSAP_generateASAPFeatures(allwavs, fs, Parameters);
    %aSAP_displaySpectralDerivative(m_spec_deriv, ...
    %    Parameters, 0, 0, -inf, false, ...
    %    0, 1, .11, ...
    %    false, false);
    
    %seperate with lines and label.
    for(nWav = 1:length(edges)-1)
        l = line([edges(nWav),edges(nWav)], ylim);
        set(l,'Color','k');
        set(l,'LineWidth', 2);
        mid = mean(edges([nWav,nWav+1]));
        if(handles.templates.wavs(nWav).segType ~= -1)
            t = text(mid, mean(ylim), num2str(handles.templates.wavs(nWav).segType));
        end
    end
    
    set(handles.axesTemplates, 'ButtonDownFcn', @cb_templates_click);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function handles = updateZoomOrPan(handles)

fs = handles.exper.desiredInSampRate;
startTime = (handles.startNdx-1)/handles.fs;
endTime = (handles.endNdx-1)/handles.fs;
startNdx = handles.startNdx;
endNdx = handles.endNdx;

%fix navigator rect
axes(handles.axesNavBar);
if(ishandle(handles.navRect))
    delete(handles.navRect);
end
x = [startTime, startTime, endTime, endTime, startTime];
y = ylim;
y = [y(1), y(2), y(2), y(1), y(1)];
handles.navRect = line(x,y);
set(handles.navRect,'Color', 'red');
set(handles.navRect,'LineWidth', 2);
set(handles.navRect,'HitTest','off');

%replot everything
axes(handles.axesSpecgram);
displaySpecgramQuick(handles.audio(startNdx:endNdx), fs, [0,10000],[-5,20],startTime);

axes(handles.axesPower);
plotTimeSeriesQuick(handles.time(startNdx:endNdx), handles.power(startNdx:endNdx));
set(handles.axesPower,'ButtonDownFcn','');

axes(handles.axesSignal);
plotTimeSeriesQuick(handles.time(startNdx:endNdx), handles.sig(startNdx:endNdx));
set(handles.axesSignal,'Color','black');
set(handles.axesSignal,'ButtonDownFcn','');

linkaxes([handles.axesSignal, handles.axesPower, handles.axesSpecgram],'x');
set(get(handles.axesNavBar,'Parent'), 'KeyPressFcn', @cb_keypress);
set(handles.axesNavBar, 'ButtonDownFcn', @cb_navbar_click);
set(handles.axesSpecgram, 'ButtonDownFcn', @cb_specgram_click);

handles.rectHandles(:,2:4) = -1;
handles.txtHandles(:,1:3) = -1;
handles = drawZoomSyllableRects(handles);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
function cb_keypress(hObject, evnt)
% hObject    handle to buttonAutoSeg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = guidata(hObject);

%get modifier booleans
bShift = false;
bControl = false;
if(length(evnt.Modifier) >= 1)
    for(nMod = 1:length(evnt.Modifier))
        bShift = bShift || strcmp(evnt.Modifier{nMod}, 'shift');
        bControl = bControl || strcmp(evnt.Modifier{nMod}, 'control');
    end
end

[label, ok] = str2num(evnt.Key)
if(ok)
    if(bShift)
        label = label + 200;
    elseif(bControl)
        label = label + 300
    end
    handles = labelSyllable(handles, label);
else
    if(strcmp(evnt.Key,'u')) 
        handles = labelSyllable(handles, 103);
    elseif(strcmp(evnt.Key,'s')) 
        handles = labelSyllable(handles, 100);
    elseif(strcmp(evnt.Key,'n')) 
        handles = labelSyllable(handles, 101);
    elseif(strcmp(evnt.Key,'c')) 
        handles = labelSyllable(handles, 102);
    elseif(strcmp(evnt.Key,'period')) 
        width = handles.endNdx - handles.startNdx;
        if(handles.endNdx + width/2 > length(handles.audio))
            handles.startNdx = length(handles.audio) - width;
            handles.endNdx = length(handles.audio);
        else
            handles.startNdx = round(handles.startNdx + width/2);
            handles.endNdx = round(handles.endNdx + width/2);
        end
        handles = updateZoomOrPan(handles);
    elseif(strcmp(evnt.Key,'comma'))
        width = handles.endNdx - handles.startNdx;
        if(handles.startNdx - width/2 < 1)
            handles.startNdx = 1;
            handles.endNdx = width;
        else
            handles.startNdx = round(handles.startNdx - width/2);
            handles.endNdx = round(handles.endNdx - width/2);
        end
        handles = updateZoomOrPan(handles);
    elseif(strcmp(evnt.Key,'space')) 
        if(bShift)
            handles = setSelectedSyllable(handles, handles.selectedSyll - 1)   
        else
            handles = setSelectedSyllable(handles, handles.selectedSyll + 1)
        end
    elseif(strcmp(evnt.Key,'p')) 
        soundsc(handles.audio(handles.startNdx:handles.endNdx), handles.exper.desiredInSampRate);
    elseif(strcmp(evnt.Key,'delete'))
        guidata(hObject, handles);
        buttonDeleteSyll_Callback(hObject, [], handles)
        handles = guidata(hObject);
    end
end
guidata(hObject, handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
function cb_navbar_click(hObject, evnt)
handles = guidata(hObject);
fs = handles.exper.desiredInSampRate;
mouseMode = get(get(hObject,'Parent'), 'SelectionType');
clickLocation = get(handles.axesNavBar, 'CurrentPoint');
axes(handles.axesNavBar);
if(strcmp(mouseMode, 'open'))
    %if double click then zoom out
    %disp('open');
    %handles.startNdx = 1;
    %handles.endNdx = length(handles.audio);
    %handles = updateZoomOrPan(handles);
elseif(strcmp(mouseMode, 'alt'))
    %pan length of drag.
elseif(strcmp(mouseMode, 'normal'))
    %zoom 
    rect = rbbox;
    endPoint = get(gca,'CurrentPoint'); 
    point1 = clickLocation(1,1:2);              % extract x and y
    point2 = endPoint(1,1:2);
    p1 = min(point1,point2);             % calculate locations
    offset = abs(point1-point2);         % and dimensions
    l = xlim;
    if((offset(1) / l(2))< .005)
        %if didn't drag a rectangle...
        %recenter on the click location.
        width = handles.endNdx - handles.startNdx;
        mid = (p1(1)*fs) + 1;
        handles.startNdx = round(mid - width/2);
        handles.endNdx = round(mid + width/2);
        if(handles.startNdx<1)
            handles.startNdx = 1;
            handles.endNdx = width + handles.startNdx;
        end
        if(handles.endNdx > length(handles.audio))
            handles.startNdx = length(handles.audio) - width;
            handles.endNdx = length(handles.audio);
        end        
        handles = updateZoomOrPan(handles);
    else
        handles.startNdx = max(1,round((p1(1)*fs) + 1));
        handles.endNdx = min(length(handles.audio), round(((p1(1) + offset(1))*fs) + 1));
        handles = updateZoomOrPan(handles);
    end
end
guidata(hObject, handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function cb_specgram_click(hObject, evnt)
handles = guidata(hObject);
fs = handles.exper.desiredInSampRate;
filenum = handles.filenum;
mouseMode = get(get(hObject,'Parent'), 'SelectionType');
clickLocation = get(handles.axesSpecgram, 'CurrentPoint');
axes(handles.axesSpecgram);

if(handles.bWaitingForAddClick)
    %handle add syllable click...
    handles.bWaitingForAddClick = false;
    set(handles.buttonAddSyll, 'BackgroundColor', 'white');
    
    %create audio annotation if it doesn't already exist:
    if(~handles.audioAnnotation.containsKey(handles.filename))
        currAnnot.exper = handles.exper;
        currAnnot.filenum = handles.filenum;
        currAnnot.segAbsStartTimes = [];
        currAnnot.segFileStartTimes = [];
        currAnnot.segFileEndTimes = [];
        currAnnot.segType = [];
        currAnnot.fs = handles.fs;
    else
        currAnnot = handles.audioAnnotation.get(handles.filename);
    end

    %get region for addition
    rect = rbbox;
    endPoint = get(gca,'CurrentPoint'); 
    point1 = clickLocation(1,1:2);              % extract x and y
    point2 = endPoint(1,1:2);
    p1 = min(point1,point2);             % calculate locations
    offset = abs(point1-point2);         % and dimensions
    
    if(get(handles.checkboxEdgefind, 'Value'))
        %adjust p1 and offset accordingly.
        startNdx = round((p1(1)*handles.fs) + 1);
        endNdx = round(((p1(1)+ offset(1))*handles.fs) + 1);
        edgeThres = get(handles.editEdgeThreshold, 'String');
        [edgeThres,ok] = str2num(edgeThres);
        if(ok)
            ndx = find(handles.power(startNdx:endNdx) > edgeThres);
            if(length(ndx)>=2)
                p1(1) = ((startNdx + ndx(1) - 1) - 1) / handles.fs;
                offset(1) = (((startNdx + ndx(end) - 1) - 1) / handles.fs) - p1(1);
            end
        end
    end
    
    %be sure the region doesn't overlap another syllable.
    syllStartTimes = currAnnot.segFileStartTimes;
    syllEndTimes = currAnnot.segFileEndTimes;
    nSyllAfter = find(p1(1) + offset(1) < [syllStartTimes,Inf]); nSyllAfter = nSyllAfter(1);
    nSyllBefore = find(p1(1) > [-Inf, syllEndTimes]); nSyllBefore = nSyllBefore(end)-1;
    if(nSyllBefore - nSyllAfter == -1)
        time = extractExperFilenumTime(handles.exper,handles.filenum);
        currAnnot.segAbsStartTimes = [currAnnot.segAbsStartTimes([1:nSyllBefore]),time + (p1(1)/(24*60*60)),currAnnot.segAbsStartTimes([nSyllAfter:end])];
        currAnnot.segFileStartTimes = [currAnnot.segFileStartTimes([1:nSyllBefore]),p1(1),currAnnot.segFileStartTimes([nSyllAfter:end])];
        currAnnot.segFileEndTimes = [currAnnot.segFileEndTimes([1:nSyllBefore]),p1(1) + offset(1),currAnnot.segFileEndTimes([nSyllAfter:end])];
        currAnnot.segType = [currAnnot.segType([1:nSyllBefore]);-1;currAnnot.segType([nSyllAfter:end])];
        handles.audioAnnotation.put(handles.filename, currAnnot);
        handles = drawSyllableRect(handles, nSyllBefore + 1, true);
    else
        warndlg('Specified segment overlaps another segment.');
        uiwait;
    end    
elseif(handles.bWaitingForSeparationClick)
    handles.bWaitingForSeparationClick = false;
elseif(handles.audioAnnotation.containsKey(handles.filename))
    %Otherwise check for syllable to select.
    currAnnot = handles.audioAnnotation.get(handles.filename);
    nSelect = find(clickLocation(1,1) >= currAnnot.segFileStartTimes & ...
                   clickLocation(1,1) <= currAnnot.segFileEndTimes);
    if(length(nSelect) == 1)
        if(nSelect ~= handles.selectedSyll)
            handles = setSelectedSyllable(handles, nSelect);
        end
        if(strcmp(mouseMode, 'open'))
            if(~isfield(handles, 'templates'))
                handles.templates = [];
                handles.templates.wavs = [];
            end
            startTime = currAnnot.segFileStartTimes(handles.selectedSyll);
            endTime = currAnnot.segFileEndTimes(handles.selectedSyll);
            handles.templates.wavs(end + 1).filename = getExperDatafile(handles.exper, handles.filenum, getChan(handles));
            handles.templates.wavs(end).startTime = startTime;
            handles.templates.wavs(end).endTime = endTime;
            handles.templates.wavs(end).fs = fs;
            handles.templates.wavs(end).wav = handles.audio(round((startTime*fs)+1):round((endTime*fs)+1));
            handles.templates.wavs(end).segType = currAnnot.segType(handles.selectedSyll);        
            updateTemplates(handles);
        end
    end
end
guidata(hObject, handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function cb_templates_click(hObject, evnt)
handles = guidata(hObject);
fs = handles.exper.desiredInSampRate;
filenum = handles.filenum;
mouseMode = get(get(hObject,'Parent'), 'SelectionType');
clickLocation = get(handles.axesTemplates, 'CurrentPoint');
axes(handles.axesTemplates);
if(strcmp(mouseMode, 'open'))
    if(isfield(handles, 'templates'))
        stdfs = 40000;
        edges = [0];
        allwavs = [];
        for(nWav = 1:length(handles.templates.wavs))
            fs = handles.templates.wavs(nWav).fs;
            wav = handles.templates.wavs(nWav).wav;
            label = handles.templates.wavs(nWav).segType;
            wav = resample(wav, stdfs, fs);
            allwavs = [allwavs; wav];
            edges = [edges, edges(end) + (length(wav) - 1)/stdfs];
        end
        nSelect = find(clickLocation(1,1) < edges);
        if(length(nSelect) > 0)
            nSelect = nSelect(1) - 1;
            handles.templates.wavs(nSelect) = [];
            updateTemplates(handles);
        end
    end
end
guidata(hObject, handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function handles = drawNavBarSyllableRects(handles)
filenum = handles.filenum;
fs = handles.exper.desiredInSampRate;
startTime = (handles.startNdx-1)/handles.fs;
endTime = (handles.endNdx-1)/handles.fs;
startNdx = handles.startNdx;
endNdx = handles.endNdx;

if(handles.audioAnnotation.containsKey(handles.filename))
    currAnnot = handles.audioAnnotation.get(handles.filename);
    syllStartTimes = currAnnot.segFileStartTimes;
    syllEndTimes = currAnnot.segFileEndTimes;
    syllType = currAnnot.segType;
    x = [syllStartTimes; syllStartTimes; syllEndTimes; syllEndTimes; syllStartTimes];   
    color = zeros(3,length(syllStartTimes));
    color(3,syllType~=-1) = 1;
    color(1,syllType==-1) = 1;
    if(handles.selectedSyll~=-1)
        color(:,handles.selectedSyll) = [0,1,0];
    end
    
    %draw nav bar rectangles.
    axes(handles.axesNavBar)
    lims = ylim;
    y = [lims(1); lims(2); lims(2); lims(1); lims(1)];
    for(nSyll = 1:length(syllStartTimes))
        handles.rectHandles(nSyll, 1) = patch(x(:,nSyll),y, color(:,nSyll)', 'EdgeColor', 'none', 'FaceAlpha', .5);
    end
    set(handles.rectHandles(:,1), 'HitTest', 'off');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function handles = drawZoomSyllableRects(handles)
filenum = handles.filenum;
fs = handles.exper.desiredInSampRate;
startTime = (handles.startNdx-1)/handles.fs;
endTime = (handles.endNdx-1)/handles.fs;
startNdx = handles.startNdx;
endNdx = handles.endNdx;

if(handles.audioAnnotation.containsKey(handles.filename))
    currAnnot = handles.audioAnnotation.get(handles.filename);
    syllStartTimes = currAnnot.segFileStartTimes;
    syllEndTimes = currAnnot.segFileEndTimes;
    midSyll = (syllStartTimes + syllEndTimes) / 2;
    syllType = currAnnot.segType;
    x = [syllStartTimes; syllStartTimes; syllEndTimes; syllEndTimes; syllStartTimes];   
    color = zeros(3,length(syllStartTimes));
    color(3,syllType~=-1) = 1;
    color(1,syllType==-1) = 1;
    if(handles.selectedSyll~=-1)
        color(:,handles.selectedSyll) = [0,1,0];
    end
 
    %Only the visible rectangles need be drawn in the other axes.
    ndx = find(syllStartTimes < endTime & syllEndTimes> startTime);

    axes(handles.axesSpecgram)
    lims = ylim;
    y = [lims(1); lims(2); lims(2); lims(1); lims(1)];
    for(nSyll = ndx)
        handles.rectHandles(nSyll, 2) = patch(x(:,nSyll),y, color(:,nSyll)', 'EdgeColor', 'none', 'FaceAlpha', .5);
        if(syllType(nSyll) ~= -1)
            handles.txtHandles(nSyll, 1) = text(midSyll(nSyll),mean(ylim),num2str(syllType(nSyll)));
            set(handles.txtHandles(nSyll,1), 'Color', 'black');
            set(handles.txtHandles(nSyll,1), 'FontSize', 14);
            set(handles.txtHandles(nSyll,1), 'FontWeight', 'bold');
            set(handles.txtHandles(nSyll,1), 'HitTest', 'off'); 
            set(handles.txtHandles(nSyll,1), 'HorizontalAlignment', 'center'); 
        else
            handles.txtHandles(nSyll,1) = -1;
        end
    end

    axes(handles.axesPower)
    lims = ylim;
    y = [lims(1); lims(2); lims(2); lims(1); lims(1)];
    for(nSyll = ndx)
        handles.rectHandles(nSyll, 3) = patch(x(:,nSyll),y, color(:,nSyll)', 'EdgeColor', 'none', 'FaceAlpha', .5);
        if(syllType(nSyll) ~= -1)
            handles.txtHandles(nSyll, 2) = text(midSyll(nSyll),mean(ylim),num2str(syllType(nSyll)));
            set(handles.txtHandles(nSyll,2), 'Color', 'black');
            set(handles.txtHandles(nSyll,2), 'FontSize', 14);
            set(handles.txtHandles(nSyll,2), 'FontWeight', 'bold');
            set(handles.txtHandles(nSyll,2), 'HitTest', 'off'); 
            set(handles.txtHandles(nSyll,2), 'HorizontalAlignment', 'center'); 
        else
            handles.txtHandles(nSyll,2) = -1;
        end
    end
    
    axes(handles.axesSignal)
    lims = ylim;
    y = [lims(1); lims(2); lims(2); lims(1); lims(1)];
    for(nSyll = ndx)
        handles.rectHandles(nSyll, 4) = patch(x(:,nSyll),y, color(:,nSyll)', 'EdgeColor', 'none', 'FaceAlpha', .5);
        if(syllType(nSyll) ~= -1)
            handles.txtHandles(nSyll, 3) = text(midSyll(nSyll),mean(ylim),num2str(syllType(nSyll)));
            set(handles.txtHandles(nSyll,3), 'Color', 'black');
            set(handles.txtHandles(nSyll,3), 'FontSize', 14);
            set(handles.txtHandles(nSyll,3), 'FontWeight', 'bold');
            set(handles.txtHandles(nSyll,3), 'HitTest', 'off'); 
            set(handles.txtHandles(nSyll,3), 'HorizontalAlignment', 'center'); 
        else
            handles.txtHandles(nSyll,3) = -1;
        end
    end
    
    set(handles.rectHandles(ndx,2:4), 'HitTest', 'off'); 
    handles.rectHandles(handles.rectHandles==0) = -1;
    handles.rectHandles(handles.txtHandles==0) = -1;
end






function editEdgeThreshold_Callback(hObject, eventdata, handles)
% hObject    handle to editEdgeThreshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editEdgeThreshold as text
%        str2double(get(hObject,'String')) returns contents of editEdgeThreshold as a double


% --- Executes during object creation, after setting all properties.
function editEdgeThreshold_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editEdgeThreshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end







% --- Executes on button press in checkboxEdgefind.
function checkboxEdgefind_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxEdgefind (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkboxEdgefind


