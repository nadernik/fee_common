function varargout = vc_exp_ToProcessedAnnotationFile(varargin)
% Usages:
%
% GUI MODE
% errstr = vc_exp_ToProcessedAnnotationFile(vcdb)
%     errstr: [] if successful, 'cancel' if canceled
%
% PARAMETER QUERY MODE
% parameters = vc_exp_ToProcessedAnnotationFile('parameters')
%     returns structure containing a name field.
%
% BATCH MODE 
% errstr = vc_exp_ToProcessedAnnotationFile('batch', vcdb, variableNames)
%      variableNames: cell array containing workspace variables to export
%      to.

% VC_EXP_TOPROCESSEDANNOTATIONFILE M-file for vc_exp_ToProcessedAnnotationFile.fig
%      VC_EXP_TOPROCESSEDANNOTATIONFILE by itself, creates a new VC_EXP_TOPROCESSEDANNOTATIONFILE or raises the
%      existing singleton*.
%
%      H = VC_EXP_TOPROCESSEDANNOTATIONFILE returns the handle to a new VC_EXP_TOPROCESSEDANNOTATIONFILE or the handle to
%      the existing singleton*.
%
%      VC_EXP_TOPROCESSEDANNOTATIONFILE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in VC_EXP_TOPROCESSEDANNOTATIONFILE.M with the given input arguments.
%
%      VC_EXP_TOPROCESSEDANNOTATIONFILE('Property','Value',...) creates a new VC_EXP_TOPROCESSEDANNOTATIONFILE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before vc_exp_ToProcessedAnnotationFile_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to vc_exp_ToProcessedAnnotationFile_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help vc_exp_ToProcessedAnnotationFile

% Last Modified by GUIDE v2.5 31-May-2008 19:44:40

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @vc_exp_ToProcessedAnnotationFile_OpeningFcn, ...
                   'gui_OutputFcn',  @vc_exp_ToProcessedAnnotationFile_OutputFcn, ...
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

% --- Executes just before vc_exp_ToProcessedAnnotationFile is made visible.
function vc_exp_ToProcessedAnnotationFile_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to vc_exp_ToProcessedAnnotationFile (see VARARGIN)

% Become true if data successfully exported.
handles.output = 'none';

if(~isempty(varargin) && strcmpi(varargin{1},'parameters'))
    handles.output = 'params';
elseif(~isempty(varargin) && ~strcmpi(varargin{1},'batch'))
    handles.vcdb = varargin{1};
else % batch
    handles.vcdb = varargin{2};
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
if isfield(handles.vcdb,'pathName') & isfield(handles.vcdb,'fileName')
    pn = handles.vcdb.pathName;
    fn = handles.vcdb.fileName;
end
if(exist('fn') & ~isempty(fn))   
    %set(handles.editMiscFileName, 'String', [pn,fn]);
    fn = regexprep(fn,'*','misc'); % TO
    set(handles.editMiscFileName, 'String', [pn,filesep,fn]); % TO
end
guidata(hObject, handles);

if(~strcmpi(handles.output,'params') && ~(~isempty(varargin) && strcmpi(varargin{1},'batch')))
    uiwait(handles.figure1);
else
    set(handles.figure1,'Visible','off');
end

if(~isempty(varargin) && strcmpi(varargin{1},'batch'))
    handles.vcdb = varargin{2};
    miscfilename = varargin{3};
    handles = export(handles, miscfilename);   
    guidata(hObject, handles);
end


% --- Outputs from this function are returned to the command line.
function varargout = vc_exp_ToProcessedAnnotationFile_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if(strcmpi(handles.output,'none'))
    if(nargout>0), varargout{1} = 'cancel'; end
elseif(strcmpi(handles.output,'params'))
    params.name = 'Export clusters to processed annotation file.';
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
miscfilename = get(handles.editMiscFileName,'String');
handles = export(handles, miscfilename);
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
function [handles,bSuccess] = export(handles, filename)
try
    vcdb = handles.vcdb;
%     if ~isfield(vcdb,'pathName') | ~isfield(vcdb,'fileName') % either pathName or fileName doesn't exist %%%%%
%         [fileName,pathName] = uigetfile('*.mat','Open misc file');
%     else
%         pathName = vcdb.pathName;
%         fileName = vcdb.fileName;
%     end
%     load([pathName, fileName]);
        
    load(filename);
    if(~exist('misc'))
        error('Selected file was not a misc processed annotation file.');
    end
    if(length(misc.segs)~=length(vcdb.d.v))
        error('Vector clust does not have the same number of segments as the misc file.');
    end
    miscT = [misc.segs.absStart];
    if(size(miscT,2)>size(miscT,1))
        miscT = miscT';
    end
    if(~isequal(miscT,vcdb.d.t))
        error('The vector clust times do not match the segment times in the misc file.');
    end
    
    %Export the cluster numbers
    MaskIdx = find(strcmp(vcdb.f.sfname,'IsMask'));
    StimIdx = find(strcmp(vcdb.f.sfname,'IsStim'));
    MaskTimeIdx = find(strcmp(vcdb.f.vfname,'maskTime'));
    StimTimeIdx = find(strcmp(vcdb.f.vfname,'stimTime'));
    for nv = 1:length(vcdb.d.v)
        if(~isnan(vcdb.d.cn(nv)))
            misc.segs(nv).segType = vcdb.d.cn(nv);
        else
            misc.segs(nv).segType = -1; %the unlabeled indicator for processed annotations..
        end
    end   
    
    %save
    save(filename, 'misc', '-v6');
    msgbox('Export complete!') %%% TO
catch
    handles.output = lasterr;
end

function editMiscFileName_Callback(hObject, eventdata, handles)
% hObject    handle to editMiscFileName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editMiscFileName as text
%        str2double(get(hObject,'String')) returns contents of editMiscFileName as a double


% --- Executes during object creation, after setting all properties.
function editMiscFileName_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editMiscFileName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in buttonBrowse.
function buttonBrowse_Callback(hObject, eventdata, handles)
% hObject    handle to buttonBrowse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[fn,pn] = uigetfile('*misc*.mat','Select the associated misc processed annotation file:',''); %%% TO
if(~isempty(fn))   
    set(handles.editMiscFileName, 'String', [pn,fn]);
end
guidata(hObject, handles);


