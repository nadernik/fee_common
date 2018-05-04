function varargout = aSAP_SyllableCatagorizer(varargin)
% ASAP_SYLLABLECATAGORIZER M-file for aSAP_SyllableCatagorizer.fig
%      ASAP_SYLLABLECATAGORIZER, by itself, creates a new ASAP_SYLLABLECATAGORIZER or raises the existing
%      singleton*.
%
%      H = ASAP_SYLLABLECATAGORIZER returns the handle to a new ASAP_SYLLABLECATAGORIZER or the handle to
%      the existing singleton*.
%
%      ASAP_SYLLABLECATAGORIZER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ASAP_SYLLABLECATAGORIZER.M with the given input arguments.
%
%      ASAP_SYLLABLECATAGORIZER('Property','Value',...) creates a new ASAP_SYLLABLECATAGORIZER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before aSAP_SyllableCatagorizer_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to aSAP_SyllableCatagorizer_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help aSAP_SyllableCatagorizer

% Last Modified by GUIDE v2.5 20-Mar-2006 16:33:33

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @aSAP_SyllableCatagorizer_OpeningFcn, ...
                   'gui_OutputFcn',  @aSAP_SyllableCatagorizer_OutputFcn, ...
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


% --- Executes just before aSAP_SyllableCatagorizer is made visible.
function aSAP_SyllableCatagorizer_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to aSAP_SyllableCatagorizer (see VARARGIN)

%Call:  aSAP_SyllableCatagorizer(sylls): sylls a structure of syllable
%start and end times for a set of files.
%Call:  aSAP_SyllableCatagorizer(sylls, currSyll);
%Call:  aSAP_SyllableCatagorizer(sylls, currSyll);
%Call:  aSAP_SyllableCatagorizer(sylls, currSyll, autoSyllCatagories);
%Call:  aSAP_SyllableCatagorizer(sylls, currSyll, autoSyllCatagories, templates);
%Call:  aSAP_SyllableCatagorizer(sylls, currSyll, autoSyllCatagories, templates, matchScores);

% Choose default command line output for aSAP_SyllableCatagorizer
handles.output = hObject;

handles.sylls = varargin{1};
if(length(varargin)>1)
    handles.currSyll = varargin{2};
else
    handles.currSyll = 1;
end
if(length(varargin)>2)
    if(isequal(varargin{3},[]))
        handles.syllCatagory = zeros(length(handles.sylls.startTFile),1);
    else
        handles.syllCatagory = varargin{3};
    end
else
    handles.syllCatagory = zeros(length(handles.sylls.startTFile),1);
end
if(length(varargin)>3)
    handles.templates = varargin{4};
end
if(length(varargin)>4)
    handles.matchScores = varargin{5};
end

handles.currFile = '';
handles.currFullFile = '';
handles.currTplHighlightNdx = 0;
handles.currSyllRect = [];

handles = updateCatagoryList(handles);
handles = updateTemplates(handles);
handles = displayCurrentSyllable(handles);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes aSAP_SyllableCatagorizer wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = aSAP_SyllableCatagorizer_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.syllCatagory;

% --- Executes on button press in buttonNextSyll.
function buttonNextSyll_Callback(hObject, eventdata, handles)
% hObject    handle to buttonNextSyll (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.currSyll = min(handles.currSyll + 1, length(handles.sylls.startTFile));
if(mod(handles.currSyll,50))
    autosaveSyllCatagories(handles);
end
handles = displayCurrentSyllable(handles);
guidata(hObject, handles);

% --- Executes on button press in buttonPrevSyll.
function buttonPrevSyll_Callback(hObject, eventdata, handles)
% hObject    handle to buttonPrevSyll (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.currSyll = max(handles.currSyll - 1,1);
handles = displayCurrentSyllable(handles);
guidata(hObject, handles);

% --- Executes on selection change in listCatagories.
function listCatagories_Callback(hObject, eventdata, handles)
% hObject    handle to listCatagories (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns listCatagories contents as cell array
%        contents{get(hObject,'Value')} returns selected item from
%        listCatagories
handles.syllCatagory(handles.currSyll) = get(handles.listCatagories,'Value')-1;
handles = updateSyllableCatagory(handles);
%if double click go to next syllable
type = get(handles.aSAP_SyllableCatagorizer,'SelectionType');
if(strcmp(type,'open'))
    handles.currSyll = handles.currSyll + 1;
    handles = displayCurrentSyllable(handles);
end
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function listCatagories_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listCatagories (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in buttonSave.
function buttonSave_Callback(hObject, eventdata, handles)
% hObject    handle to buttonSave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
saveSyllCatagories(handles);

function editAutoScores_Callback(hObject, eventdata, handles)
% hObject    handle to editAutoScores (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editAutoScores as text
%        str2double(get(hObject,'String')) returns contents of editAutoScores as a double


% --- Executes during object creation, after setting all properties.
function editAutoScores_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editAutoScores (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function handles = updateCatagoryList(handles)
catagories{1} = '0 - not assigned.';
if(isfield(handles,'templates'))
    for(nTpl = 1:length(handles.templates))
        catagories{nTpl+1} = [num2str(nTpl), ' - ', handles.templates{nTpl}.name];
    end
else
    for(nTpl = 1:15)
        catagories{nTpl+1} = num2str(nTpl);
    end
end
set(handles.listCatagories, 'String', catagories);

%------------------------------------------------------------------
function handles = updateTemplates(handles)
if(isfield(handles,'templates'))
    m_spec_deriv = [];
    for(nTpl = 1:length(handles.templates))
        tpl = handles.templates{nTpl};
        boundary(nTpl,1) = aSAP_conFeatNdx2Time(size(m_spec_deriv,1), handles.templates{nTpl}.param.fs, handles.templates{nTpl}.param.winstep);
        boundary(nTpl,2) = boundary(nTpl,1) + aSAP_conFeatNdx2Time(size(tpl.m_spec_deriv,1), handles.templates{nTpl}.param.fs, handles.templates{nTpl}.param.winstep);
        m_spec_deriv = [m_spec_deriv;tpl.m_spec_deriv];
     end
    
    axes(handles.axesTemplates);
    startTime = 0;
    startPos = 0;
    endPos = -Inf;
    inchPerSec = 4.5;
    inchPerkHz = 0;
    bAutoScale = true;
    fScale = 0;
    bSigmoid = true;
    bModifyAxesW = false;
    bModifyAxesH = false;
    aSAP_displaySpectralDerivative(m_spec_deriv, handles.templates{1}.param, startTime, startPos, endPos, bSigmoid, fScale, inchPerSec, inchPerkHz, bModifyAxesW, bModifyAxesH);

    for(nTpl = 1:length(handles.templates))
        tpl = handles.templates{nTpl};
        x = (boundary(nTpl,2) + boundary(nTpl,1)) / 2;
        ylimits = ylim; y = .1*ylimits(1) + .9*ylimits(2);
        ylimits = [.99*ylimits(1) + .01*ylimits(2), .01*ylimits(1) + .99*ylimits(2)];
        t = text(x, y, [num2str(nTpl), ' - ', tpl.name]);
        set(t,'HorizontalAlignment','center');
        set(t,'FontSize',8);
        x_rect = [boundary(nTpl,1)+.002, boundary(nTpl,2)-.002, boundary(nTpl,2)-.002, boundary(nTpl,1)+.002,boundary(nTpl,1)+.002];
        y_rect = [ylimits(1), ylimits(1), ylimits(2), ylimits(2), ylimits(1)];
        handles.tplBox(nTpl) = line(x_rect,y_rect,'Color','blue');
    end
    
end

%------------------------------------------------------------------

function handles = displayCurrentSyllable(handles)
sylls = handles.sylls;
nSyll = handles.currSyll;

if(~strcmp(handles.currFile, sylls.filename(nSyll)))
    axes(handles.axesSD);
    handles.currFile = sylls.filename{nSyll};
    if(strcmp(sylls.filepath{nSyll},''));
        handles.currFullFile = sylls.filename{nSyll};
    else
        handles.currFullFile = [sylls.filepath{nSyll}, filesep, sylls.filename{nSyll}];
    end
    %Load Features
    [path,name,ext] = fileparts(handles.currFullFile);
    featfilename = [path,filesep,name,'.feat','.mat'];
    d = dir(featfilename);
    if(length(d)==0)
        aSAP_generateASAPFeatureFileFromWav(handles.currFullFile);        
    end
    load(featfilename);
    handles.SAPFeats = SAPFeats;
    %Load lossy spectral derivative 
    
    try
        m_spec_deriv = aSAP_uncompressSpectralDeriv(handles.SAPFeats.specDerivFileName);
    catch
        m_spec_deriv = aSAP_uncompressSpectralDeriv([path,filesep,name,'.sd']);
    end
    %Display SD
    startTime = 0;
    startPos = 0;
    endPos = -Inf;
    inchPerSec = 7;
    inchPerkHz = 0;
    bAutoScale = true;
    fScale = 0;
    bSigmoid = true;
    bModifyAxesW = false;
    bModifyAxesH = false;
    aSAP_displaySpectralDerivative(m_spec_deriv, handles.SAPFeats.param, startTime, startPos, endPos, bSigmoid, fScale, inchPerSec, inchPerkHz, bModifyAxesW, bModifyAxesH);

    %Put text label on the syllables in the file...
    %Get ndx of first syll in file.
    fileStartSyll = nSyll;
    while((fileStartSyll - 1)>=1) && strcmp(handles.currFile, sylls.filename(fileStartSyll-1))
        fileStartSyll = fileStartSyll - 1;
    end
    %Get ndx of last syll in file.
    fileEndSyll = nSyll;
    while((fileEndSyll + 1)<=length(sylls.startTFile)) && strcmp(handles.currFile, sylls.filename(fileEndSyll+1))
        fileEndSyll = fileEndSyll + 1;
    end 
    for(ndx = fileStartSyll:fileEndSyll)
        cat = handles.syllCatagory(ndx);
        if(cat ~=0)
            if(isfield(handles,'templates') && cat < length(handles.templates))
                label = [num2str(cat),'-',handles.templates{cat}.name];
            else
                label = num2str(cat);
            end
            x = (sylls.endTFile(ndx) + sylls.startTFile(ndx)) / 2;
            ylimits = ylim; y = ylimits(1)*.1 + ylimits(2)*.9;
            t = text(x,y,label);
            set(t,'Tag',['syllText',num2str(ndx)]);
            set(t,'HorizontalAlignment', 'center');
        end
    end
end

%Center the syllable
xRange = diff(xlim);
xCenter = (sylls.startTFile(nSyll) + sylls.endTFile(nSyll)) / 2;
xlim([xCenter-xRange/2,xCenter+xRange/2]);

%Plot rectangle delinateing start and finish
if(ishandle(handles.currSyllRect))  
    delete(handles.currSyllRect);
    handles.currSyllRect = [];
end
xrect = [sylls.startTFile(nSyll),sylls.endTFile(nSyll),sylls.endTFile(nSyll),sylls.startTFile(nSyll),sylls.startTFile(nSyll)];
ylimits = ylim;
yrect = [ylimits(1), ylimits(1), ylimits(2),ylimits(2), ylimits(1)];
handles.currSyllRect = line(xrect,yrect);
set(handles.currSyllRect,'Color','red');

%Plot the syllable scores
if(isfield(handles,'matchScores'))
    axes(handles.axesScores);
    bar(handles.matchScores(nSyll,:));
end

%update syllable syllection
handles = updateSyllableCatagory(handles);

% ------------------------------------------------------------------
function handles = updateSyllableCatagory(handles)
nSyll = handles.currSyll;
cat = handles.syllCatagory(nSyll);

%Set the list box to current label
set(handles.listCatagories,'Value',cat + 1);

%Highlight the selection in the catagory
if(handles.currTplHighlightNdx > 0)    
    set(handles.tplBox(handles.currTplHighlightNdx), 'Color', 'blue');
    set(handles.tplBox(handles.currTplHighlightNdx), 'LineWidth', 1);
end
handles.currTplHighlightNdx = 0;
if((cat > 0) &&isfield(handles,'templates') && cat <= length(handles.templates))
    handles.currTplHighlightNdx = cat;
    set(handles.tplBox(cat), 'Color', 'red');
    set(handles.tplBox(handles.currTplHighlightNdx), 'LineWidth', 3);
end

%Plot the syllable scores
if(isfield(handles,'matchScores') && (cat > 0) && isfield(handles,'templates') && cat <= length(handles.templates))
  %  set(handles.barScores(cat),'Color','red');
  %highlight selected bar
end

%Update syllable text
axes(handles.axesSD);
delete(findobj(handles.axesSD, 'Tag', ['syllText',num2str(nSyll)]));
if(cat ~=0)
    if(isfield(handles,'templates') && cat < length(handles.templates))
        label = [num2str(cat),'-',handles.templates{cat}.name];
    else
        label = num2str(cat);
    end
    x = (handles.sylls.endTFile(nSyll) + handles.sylls.startTFile(nSyll)) / 2;
    ylimits = ylim; y = ylimits(1)*.1 + ylimits(2)*.9;
    t = text(x,y,label);
    set(t,'Tag',['syllText',num2str(nSyll)]);
    set(t,'HorizontalAlignment', 'center');
    set(t,'Color', 'blue');
    set(t,'FontSize', 12);
end

%Update count histogram
axes(handles.axesSyllCount);
numCatagories = length(get(handles.listCatagories, 'String')) - 1;
hist(handles.syllCatagory(1:handles.currSyll), numCatagories);

axes(handles.axesSD);

% --------------------------------------------------------------
function saveSyllCatagories(handles)
syllCatagory = handles.syllCatagory;
ndxCurrentSyll = handles.currSyll;
uisave({'syllCatagory','ndxCurrentSyll'}, 'syllCatagories.mat'); 

% --------------------------------------------------------------
function autosaveSyllCatagories(handles)
syllCatagory = handles.syllCatagory;
ndxCurrentSyll = handles.currSyll;
save('syllCatagoriesTemp.mat', 'syllCatagory','ndxCurrentSyll');

%function CB_handleSDClick
%double click on template
%set catagory
%call update catagory.

%function CB_handleKeyboardPress
%> next syllable
%< prev syllable
%1-9,0: set syllable and advance

