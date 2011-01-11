function varargout = vc_imp_MatlabWorkspaceVariable(varargin)
% Usages:
%
% GUI MODE
% [v, sf, vf, c, t, i, sf_names, vf_names] = vc_imp_MatlabWorkspaceVariable()
%       v: vectors
%       sf: scalar features
%       vf: vector features
%       c: initial cluster 
%       t: time
%       i: identity 
%       sf_names: names of scalar features
%       vf_names: names of vector features.
%
% PARAMETER QUERY MODE
% parameters = vc_imp_MatlabWorkspaceVariable('parameters')
%   returns structure containing a name field.
%
% BATCH MODE 
% [v, sf, vf, c, t, i, sf_names, vf_names] = vc_imp_MatlabWorkspaceVariable('batch', variableName)

% VC_IMP_MATLABWORKSPACEVARIABLE M-file for vc_imp_MatlabWorkspaceVariable.fig
%      VC_IMP_MATLABWORKSPACEVARIABLE by itself, creates a new VC_IMP_MATLABWORKSPACEVARIABLE or raises the
%      existing singleton*.
%
%      H = VC_IMP_MATLABWORKSPACEVARIABLE returns the handle to a new VC_IMP_MATLABWORKSPACEVARIABLE or the handle to
%      the existing singleton*.
%
%      VC_IMP_MATLABWORKSPACEVARIABLE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in VC_IMP_MATLABWORKSPACEVARIABLE.M with the given input arguments.
%
%      VC_IMP_MATLABWORKSPACEVARIABLE('Property','Value',...) creates a new VC_IMP_MATLABWORKSPACEVARIABLE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before vc_imp_MatlabWorkspaceVariable_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to vc_imp_MatlabWorkspaceVariable_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help vc_imp_MatlabWorkspaceVariable

% Last Modified by GUIDE v2.5 14-May-2008 00:32:40

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @vc_imp_MatlabWorkspaceVariable_OpeningFcn, ...
                   'gui_OutputFcn',  @vc_imp_MatlabWorkspaceVariable_OutputFcn, ...
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

% --- Executes just before vc_imp_MatlabWorkspaceVariable is made visible.
function vc_imp_MatlabWorkspaceVariable_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to vc_imp_MatlabWorkspaceVariable (see VARARGIN)

% Become true if data successfully imported.
handles.output = 'none';

if(~isempty(varargin) && strcmpi(varargin{1},'parameters'))
    handles.output = 'params';
end

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
if(~strcmpi(handles.output,'params') && ~(~isempty(varargin) && strcmpi(varargin{1},'batch')))
    uiwait(handles.figure1);
else
    set(handles.figure1,'Visible','off');
end

if(~isempty(varargin) && strcmpi(varargin{1},'batch'))
    handles = import(handles, varargin{2});
    guidata(hObject, handles);
end


% --- Outputs from this function are returned to the command line.
function varargout = vc_imp_MatlabWorkspaceVariable_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if(strcmpi(handles.output,'none'))
    for nOut = 1:nargout
        varargout{nOut} = [];
    end
elseif(strcmpi(handles.output,'params'))
    params.name = 'Matlab Workspace Variable';
    if(nargout>0), varargout{1} = params; end
elseif(strcmpi(handles.output,'import'))
    if(nargout>0), varargout{1} = handles.vectors; end
    if(nargout>1), varargout{2} = handles.scalar_features; end
    if(nargout>2), varargout{3} = handles.vector_features; end
    if(nargout>3), varargout{4} = handles.cluster; end
    if(nargout>4), varargout{5} = handles.time; end
    if(nargout>5), varargout{6} = handles.identity; end
    if(nargout>6), varargout{7} = handles.scalar_feature_names; end
    if(nargout>7), varargout{8} = handles.vector_feature_names; end
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


% --- Executes on key press over figure1 with no controls selected.
function figure1_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Check for "enter" or "escape"
if isequal(get(hObject,'CurrentKey'),'escape')
    uiresume(handles.figure1);
end        

% --- Executes on button press in buttonImport.
function buttonImport_Callback(hObject, eventdata, handles)
% hObject    handle to buttonImport (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
val = get(handles.popupVariables, 'Value');
strs = get(handles.popupVariables,'String');
handles = import(handles, strs{val});
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

% --- Executes on selection change in popupVariables.
function popupVariables_Callback(hObject, eventdata, handles)
% hObject    handle to popupVariables (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupVariables contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupVariables


% --- Executes during object creation, after setting all properties.
function popupVariables_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupVariables (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
vars = evalin('base','whos');
vars = {vars(:).name};
set(hObject,'String',vars);
guidata(hObject, handles);

% --- imports
function [handles,bSuccess] = import(handles, variable)
bSuccess = false;

handles.vectors = evalin('base',variable);
if(~iscell(handles.vectors) | ~isvector(handles.vectors))
    h = warndlg('Variable not appropriate for import.', 'Import Failed', 'modal'); 
    return; 
end

if(size(handles.vectors,2) > 1)
    handles.vectors = handles.vectors';
end

%verify all vectors have correct orientation.
for(nVec = 1:length(handles.vectors))
    if(size(handles.vectors{nVec},2)>1)
        handles.vectors{nVec} = handles.vectors{nVec}';       
    end
    if(size(handles.vectors{nVec},2)>1)
        h = warndlg('Variable not appropriate for import.', 'Import Failed', 'modal'); 
        return; 
    end
end

handles.scalar_features = cellfun(@length,handles.vectors); 
handles.vector_features = {};
handles.cluster = nan(size(handles.vectors));
handles.time = nan(size(handles.vectors));
handles.identity = zeros(size(handles.vectors)); 
handles.scalar_feature_names = {'length'};
handles.vector_feature_names = {};

bSuccess = true;
handles.output = 'import';
