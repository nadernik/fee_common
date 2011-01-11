function varargout = vc_cmf_PCA(varargin)
% calculate principal component analysis
% Tatsuo Okubo
% 2009/07/19
%VC_CMF_PCA M-file for vc_cmf_PCA.fig
%      VC_CMF_PCA, by itself, creates a new VC_CMF_PCA or raises the existing
%      singleton*.
%
%      H = VC_CMF_PCA returns the handle to a new VC_CMF_PCA or the handle to
%      the existing singleton*.
%
%      VC_CMF_PCA('Property','Value',...) creates a new VC_CMF_PCA using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to vc_cmf_PCA_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      VC_CMF_PCA('CALLBACK') and VC_CMF_PCA('CALLBACK',hObject,...) call the
%      local function named CALLBACK in VC_CMF_PCA.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help vc_cmf_PCA

% Last Modified by GUIDE v2.5 19-Jul-2009 14:31:40

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @vc_cmf_PCA_OpeningFcn, ...
                   'gui_OutputFcn',  @vc_cmf_PCA_OutputFcn, ...
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


% --- Executes just before vc_cmf_PCA is made visible.
function vc_cmf_PCA_OpeningFcn(hObject, eventdata, handles, varargin)
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
    handles.vcdb = varargin{1}; % load vcdb
end
set(handles.listbox, 'String', [handles.vcdb.f.sfname]);
    
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
function varargout = vc_cmf_PCA_OutputFcn(hObject, eventdata, handles)
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

%scalarNdx = get(handles.popupScalar, 'Value');
%scalarNdx = vectorNdx-1;
%vectorNdx of 0 specified the original vectors,
%otherwise vectorNdx is the index of the desired vector-feature.

handles = compute(handles); % main function
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


%% main function
function handles = compute(handles)
try
    ScalarNdx = get(handles.listbox, 'Value');
    X = handles.vcdb.d.sf(:,ScalarNdx); % use first 7 features
    [COEFF,PC,Latent] = princomp(zscore(X)); % PCA on standalized values

    handles.sf(:,1) = PC(:,1);
    handles.sfname{1,1} = 'PC1';
    handles.sffcn{1,1} = 'vc_cmf_PCA';
    handles.sfparam{1,1} = [];

    handles.sf(:,2) = PC(:,2);
    handles.sfname{2,1} = 'PC2';
    handles.sffcn{2,1} = 'vc_cmf_PCA';
    handles.sfparam{2,1} = [];

    handles.sf(:,3) = PC(:,3);
    handles.sfname{3,1} = 'PC3';
    handles.sffcn{3,1} = 'vc_cmf_PCA';
    handles.sfparam{3,1} = [];
      
    handles.vf = {};
    handles.vfname = {};
    handles.vffcn = {};
    handles.vfparam = {};
    
    handles.output = 'success';
catch
    handles.output = ['Compute PCA failed: ', lasterr];
end


% --- Executes on selection change in listbox.
function listbox_Callback(hObject, eventdata, handles)
% hObject    handle to listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns listbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox


% --- Executes during object creation, after setting all properties.
function listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end