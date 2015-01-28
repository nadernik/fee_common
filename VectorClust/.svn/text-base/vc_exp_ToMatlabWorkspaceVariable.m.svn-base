function varargout = vc_exp_ToMatlabWorkspaceVariable(varargin)
% Usages:
%
% GUI MODE
% errstr = vc_exp_ToMatlabWorkspaceVariable(vcdb)
%     errstr: [] if successful, 'cancel' if canceled
%
% PARAMETER QUERY MODE
% parameters = vc_exp_ToMatlabWorkspaceVariable('parameters')
%     returns structure containing a name field.
%
% BATCH MODE 
% errstr = vc_exp_ToMatlabWorkspaceVariable('batch', vcdb, variableNames)
%      variableNames: cell array containing workspace variables to export
%      to.

% VC_EXP_TOMATLABWORKSPACEVARIABLE M-file for vc_exp_ToMatlabWorkspaceVariable.fig
%      VC_EXP_TOMATLABWORKSPACEVARIABLE by itself, creates a new VC_EXP_TOMATLABWORKSPACEVARIABLE or raises the
%      existing singleton*.
%
%      H = VC_EXP_TOMATLABWORKSPACEVARIABLE returns the handle to a new VC_EXP_TOMATLABWORKSPACEVARIABLE or the handle to
%      the existing singleton*.
%
%      VC_EXP_TOMATLABWORKSPACEVARIABLE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in VC_EXP_TOMATLABWORKSPACEVARIABLE.M with the given input arguments.
%
%      VC_EXP_TOMATLABWORKSPACEVARIABLE('Property','Value',...) creates a new VC_EXP_TOMATLABWORKSPACEVARIABLE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before vc_exp_ToMatlabWorkspaceVariable_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to vc_exp_ToMatlabWorkspaceVariable_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help vc_exp_ToMatlabWorkspaceVariable

% Last Modified by GUIDE v2.5 31-May-2008 11:25:13

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @vc_exp_ToMatlabWorkspaceVariable_OpeningFcn, ...
                   'gui_OutputFcn',  @vc_exp_ToMatlabWorkspaceVariable_OutputFcn, ...
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

% --- Executes just before vc_exp_ToMatlabWorkspaceVariable is made visible.
function vc_exp_ToMatlabWorkspaceVariable_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to vc_exp_ToMatlabWorkspaceVariable (see VARARGIN)

% Become true if data successfully exported.
handles.output = 'none';

if(~isempty(varargin) && strcmpi(varargin{1},'parameters'))
    handles.output = 'params';
elseif(~isempty(varargin) && ~strcmpi(varargin{1},'batch'))
    handles.vcdb = varargin{1};
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
    handles.vcdb = varargin{2};
    handles = export(handles, varargin{3:end});   
    guidata(hObject, handles);
end


% --- Outputs from this function are returned to the command line.
function varargout = vc_exp_ToMatlabWorkspaceVariable_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if(strcmpi(handles.output,'none'))
    if(nargout>0), varargout{1} = 'cancel'; end
elseif(strcmpi(handles.output,'params'))
    params.name = 'Export to Matlab Workspace';
    if(nargout>0), varargout{1} = params; end
elseif(strcmpi(handles.output,'export'))
    if(nargout>0), varargout{1} = []; end
else
    if(nargout>0), varargout{1} = handles.output; end
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

% Check for "escape"
if isequal(get(hObject,'CurrentKey'),'escape')
    uiresume(handles.figure1);
end        

% --- Executes on button press in buttonExport.
function buttonExport_Callback(hObject, eventdata, handles)
% hObject    handle to buttonExport (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
strs{1} = get(handles.editClusterNumberVar,'String');
strs{2} = get(handles.editClusterNameVar,'String');
strs{3} = get(handles.editVectIdentityVar,'String');
strs{4} = get(handles.editVectTimeVar,'String');
handles = export(handles, strs{:});
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

% --- export ------------
function [handles,bSuccess] = export(handles, cnumName, cstrName, videnName, vtimeName)
try
    vcdb = handles.vcdb;
    cnum = nan(size(vcdb.d.v));
    cstr = cell(size(vcdb.d.v));
    for(nv = 1:length(vcdb.d.v))
        if(~isnan(vcdb.d.cn(nv)))
            cnum(nv) = vcdb.d.cn(nv);
            cstr{nv} = vcdb.c(vcdb.d.cn(nv)).str;
        end
    end
    if(~isempty(cnumName))
        assignin('base',cnumName, cnum);
    end
    if(~isempty(cstrName))
        assignin('base',cstrName, cstr);
    end
    if(~isempty(videnName))
        assignin('base',videnName, vcdb.d.i);
    end
    if(~isempty(vtimeName))
        assignin('base',vtimeName, vcdb.d.t);
    end
    handles.output = 'export';
catch
    handles.output = lasterr;
end

function editClusterNumberVar_Callback(hObject, eventdata, handles)
% hObject    handle to editClusterNumberVar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editClusterNumberVar as text
%        str2double(get(hObject,'String')) returns contents of editClusterNumberVar as a double


% --- Executes during object creation, after setting all properties.
function editClusterNumberVar_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editClusterNumberVar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editClusterNameVar_Callback(hObject, eventdata, handles)
% hObject    handle to editClusterNameVar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editClusterNameVar as text
%        str2double(get(hObject,'String')) returns contents of editClusterNameVar as a double


% --- Executes during object creation, after setting all properties.
function editClusterNameVar_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editClusterNameVar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editVectIdentityVar_Callback(hObject, eventdata, handles)
% hObject    handle to editVectIdentityVar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editVectIdentityVar as text
%        str2double(get(hObject,'String')) returns contents of editVectIdentityVar as a double


% --- Executes during object creation, after setting all properties.
function editVectIdentityVar_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editVectIdentityVar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editVectTimeVar_Callback(hObject, eventdata, handles)
% hObject    handle to editVectTimeVar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editVectTimeVar as text
%        str2double(get(hObject,'String')) returns contents of editVectTimeVar as a double


% --- Executes during object creation, after setting all properties.
function editVectTimeVar_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editVectTimeVar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


