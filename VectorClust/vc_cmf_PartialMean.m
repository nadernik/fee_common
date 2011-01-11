function varargout = vc_cmf_PartialMean(varargin)
%VC_CMF_PARTIALMEAN M-file for vc_cmf_PartialMean.fig
%      VC_CMF_PARTIALMEAN, by itself, creates a new VC_CMF_PARTIALMEAN or raises the existing
%      singleton*.
%
%      H = VC_CMF_PARTIALMEAN returns the handle to a new VC_CMF_PARTIALMEAN or the handle to
%      the existing singleton*.
%
%      VC_CMF_PARTIALMEAN('Property','Value',...) creates a new VC_CMF_PARTIALMEAN using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to vc_cmf_PartialMean_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      VC_CMF_PARTIALMEAN('CALLBACK') and VC_CMF_PARTIALMEAN('CALLBACK',hObject,...) call the
%      local function named CALLBACK in VC_CMF_PARTIALMEAN.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help vc_cmf_PartialMean

% Last Modified by GUIDE v2.5 14-Jul-2009 15:37:43

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @vc_cmf_PartialMean_OpeningFcn, ...
                   'gui_OutputFcn',  @vc_cmf_PartialMean_OutputFcn, ...
                   'gui_LayoutFcn',  [], ...
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


% --- Executes just before vc_cmf_PartialMean is made visible.
function vc_cmf_PartialMean_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)

handles.output = '';
if(~isempty(varargin) && strcmpi(varargin{1},'parameters'))
    handles.output = 'params';
else
    handles.vcdb = varargin{1};
end
set(handles.popupVector, 'String', [{'vectors'}; handles.vcdb.f.vfname]);
set(handles.popupVector, 'Value', 1);
    
% Update handles structure
guidata(hObject, handles);

% Determine the position of the dialog - centered on the callback figure
% if available, else, centered on the screen
FigPos=get(0,'DefaultFigurePosition');
OldUnits = get(hObject, 'Units');
set(hObject, 'Units', 'pixels');
OldPos = get(hObject,'Position');
FigWidth = OldPos(3);
FigHeight = OldPos(4);
if isempty(gcbf)
    ScreenUnits=get(0,'Units');
    set(0,'Units','pixels');
    ScreenSize=get(0,'ScreenSize');
    set(0,'Units',ScreenUnits);

    FigPos(1)=1/2*(ScreenSize(3)-FigWidth);
    FigPos(2)=2/3*(ScreenSize(4)-FigHeight);
else
    GCBFOldUnits = get(gcbf,'Units');
    set(gcbf,'Units','pixels');
    GCBFPos = get(gcbf,'Position');
    set(gcbf,'Units',GCBFOldUnits);
    FigPos(1:2) = [(GCBFPos(1) + GCBFPos(3) / 2) - FigWidth / 2, ...
                   (GCBFPos(2) + GCBFPos(4) / 2) - FigHeight / 2];
end
FigPos(3:4)=[FigWidth FigHeight];
set(hObject, 'Position', FigPos);
set(hObject, 'Units', OldUnits);

% Make the GUI modal
set(handles.figure1,'WindowStyle','modal')

% UIWAIT makes vc_imp_ProcessedAnnotationFiles wait for user response (see UIRESUME)
if(~strcmpi(handles.output,'params') || (length(varargin)==1))
    uiwait(handles.figure1);
else
    set(handles.figure1,'Visible','off');
end

if(length(varargin)>1)
    vectorNdx = varargin{2};
    handles = compute(handles, vectorNdx);
    guidata(hObject, handles);
end


% --- Outputs from this function are returned to the command line.
function varargout = vc_cmf_PartialMean_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
if(strcmpi(handles.output,'')) %Canceled
    if(nargout>0), varargout{1} = handles.vcdb; end
    if(nargout>1), varargout{2} = ''; end
    for nOut = 3:nargout
        varargout{nOut} = [];
    end
elseif(strcmpi(handles.output,'params'))
    params.name = 'Matlab Workspace Variable';
    if(nargout>0), varargout{1} = params; end
elseif(strcmpi(handles.output,'success'))
    handles.vcdb.d.sf = [handles.vcdb.d.sf, handles.sf];
    handles.vcdb.d.vf = [handles.vcdb.d.vf, handles.vf];
    handles.vcdb.f.sfname = [handles.vcdb.f.sfname; handles.sfname];
    handles.vcdb.f.sffcn = [handles.vcdb.f.sffcn; handles.sffcn];
    handles.vcdb.f.sfparam = [handles.vcdb.f.sfparam; handles.sfparam];
    handles.vcdb.f.vfname = [handles.vcdb.f.vfname; handles.vfname];
    handles.vcdb.f.vffcn = [handles.vcdb.f.vffcn; handles.vffcn];
    handles.vcdb.f.vfparam = [handles.vcdb.f.vfparam; handles.vfparam];    
    if(nargout>0), varargout{1} = handles.vcdb; end
    if(nargout>1), varargout{2} = 'success'; end
    if(nargout>2), varargout{3} = handles.sf; end
    if(nargout>3), varargout{4} = handles.vf; end
    if(nargout>4), varargout{5} = handles.sfname; end
    if(nargout>5), varargout{6} = handles.vfname; end
    if(nargout>6), varargout{7} = handles.sfparam; end
    if(nargout>7), varargout{8} = handles.vfparam; end
else
    if(nargout>0), varargout{1} = handles.vcdb; end
    if(nargout>1), varargout{2} = handles.output; end
    for nOut = 3:nargout
        varargout{nOut} = [];
    end
end

% The figure can be deleted now
delete(handles.figure1);

% --- Executes on key press with focus on figure1 and no controls selected.
function figure1_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isequal(get(handles.figure1, 'waitstatus'), 'waiting')
    % The GUI is still in UIWAIT, us UIRESUME
    uiresume(handles.figure1);
else
    % The GUI is no longer waiting, just close it
    delete(handles.figure1);
end


% --- Executes on button press in buttonCompute.
function buttonCompute_Callback(hObject, eventdata, handles)
% hObject    handle to buttonCompute (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

vectorNdx = get(handles.popupVector, 'Value');
vectorNdx = vectorNdx-1;
%vectorNdx of 0 specified the original vectors,
%otherwise vectorNdx is the index of the desired vector-feature.

handles.Start = str2double(get(handles.text_Start,'String'));
handles.End = str2double(get(handles.text_End,'String'));

if handles.Start < 0 | handles.End > 100
    error('Input value has to be 0-100')
end

handles = compute(handles, vectorNdx);
guidata(hObject, handles);

% Use UIRESUME instead of delete because the OutputFcn needs
% to get the updated handles structure.
uiresume(handles.figure1);


% --- Executes on button press in buttonCancel.
function buttonCancel_Callback(hObject, eventdata, handles)
% hObject    handle to buttonCancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Use UIRESUME instead of delete because the OutputFcn needs
% to get the updated handles structure.
uiresume(handles.figure1);


% --- Executes on selection change in popupVector.
function popupVector_Callback(hObject, eventdata, handles)
% hObject    handle to popupVector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupVector contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupVector


% --- Executes during object creation, after setting all properties.
function popupVector_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupVector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- imports
function handles = compute(handles, vectorNdx)
try
    if(vectorNdx == 0)
        vects = handles.vcdb.d.v;
        vname = 'vector';
    else
        vects = handles.vcdb.d.vf{vectorNdx};
        L = cellfun(@length,vects);
        Start = round(L.*(handles.Start/100)+1);
        End = round(L.*(handles.End/100)); 
        partial_vects = cell(size(vects));
        for i=1:length(vects)
            partial_vects{i} = vects{i}(Start(i):End(i)); %%
        end
        vname = handles.vcdb.f.vfname{vectorNdx};
    end
    
    handles.sf = cellfun(@mean,partial_vects);
    handles.sfname{1,1} = [num2str(handles.Start) '_' num2str(handles.End) '_mean_',vname];
    handles.sffcn{1,1} = 'vc_cmf_PartialMean';
    handles.sfparam{1,1} = [];
    
    handles.sf(:,2) = cellfun(@std,partial_vects);
    handles.sfname{2,1} = [num2str(handles.Start) '_' num2str(handles.End) '_std_',vname];
    handles.sffcn{2,1} = 'vc_cmf_PartialMean';
    handles.sfparam{2,1} = [];
    
    handles.vf = {};
    handles.vfname = {};
    handles.vffcn = {};
    handles.vfparam = {};
    
    handles.output = 'success';
catch
    handles.output = ['Compute basic statistic failed: ', lasterr];
end


function text_Start_Callback(hObject, eventdata, handles)
% hObject    handle to text_Start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of text_Start as text
%        str2double(get(hObject,'String')) returns contents of text_Start as a double


% --- Executes during object creation, after setting all properties.
function text_Start_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text_Start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function text_End_Callback(hObject, eventdata, handles)
% hObject    handle to text_End (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of text_End as text
%        str2double(get(hObject,'String')) returns contents of text_End as
%        a double

% --- Executes during object creation, after setting all properties.
function text_End_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text_End (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end