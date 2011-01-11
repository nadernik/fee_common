function varargout = vc_imp_ElectroGuiDbase(varargin)
% Usages:
%
% GUI MODE
% [v, sf, vf, c, t, i, sf_names, vf_names, fileName, pathName] = vc_imp_ElectroGuiDbase()
%   If import fails, empty vectors are returned.
%       v: vectors
%       sf: scalar features
%       vf: vector features
%       c: initial cluster 
%       t: time
%       i: identity 
%       sf_names: names of scalar features
%       vf_names: names of vector features.
%       fileName: name of the dbase file being imported
%       pathName: path name of the file
%
% PARAMETER QUERY MODE
% parameters = vc_imp_ElectroGuiDbase('parameters')
%   returns structure containing a name field.
%
% BATCH MODE 
% [v, sf, vf, c, t, i, sf_names, vf_names] = vc_imp_ElectroGuiDbase('batch', dbase, varargin{:})
%       varargin are name value pairs specifing what events to use and how
%       to extract them.  See 'import' function for different property names.

% VC_IMP_ELECTROGUIDBASE M-file for vc_imp_ElectroGuiDbase.fig
%      VC_IMP_ELECTROGUIDBASE by itself, creates a new VC_IMP_ELECTROGUIDBASE or raises the
%      existing singleton*.
%
%      H = VC_IMP_ELECTROGUIDBASE returns the handle to a new VC_IMP_ELECTROGUIDBASE or the handle to
%      the existing singleton*.
%
%      VC_IMP_ELECTROGUIDBASE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in VC_IMP_ELECTROGUIDBASE.M with the given input arguments.
%
%      VC_IMP_ELECTROGUIDBASE('Property','Value',...) creates a new VC_IMP_ELECTROGUIDBASE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before vc_imp_ElectroGuiDbase_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to vc_imp_ElectroGuiDbase_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help vc_imp_ElectroGuiDbase

% Last Modified by GUIDE v2.5 06-Jun-2008 20:17:13

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @vc_imp_ElectroGuiDbase_OpeningFcn, ...
                   'gui_OutputFcn',  @vc_imp_ElectroGuiDbase_OutputFcn, ...
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

% --- Executes just before vc_imp_ElectroGuiDbase is made visible.
function vc_imp_ElectroGuiDbase_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to vc_imp_ElectroGuiDbase (see VARARGIN)

% Become true if data successfully imported.
handles.output = 'none';
handles.dbase = [];
handles.fileRange = [];

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

% UIWAIT makes vc_imp_ElectroGuiDbase wait for user response (see UIRESUME)
if(~strcmpi(handles.output,'params') && ~(~isempty(varargin) && strcmpi(varargin{1},'batch')))
    uiwait(handles.figure1);
else
    set(handles.figure1,'Visible','off');
end

if(~isempty(varargin) && strcmpi(varargin{1},'batch')) % strcmpi: case insensitive
    %Varargin{2} must be the dbase.
    %Varargin 3:end are name/value pairs.
    handles = import(handles, varargin{2}, varargin{3:end})
    guidata(hObject, handles);
end

%%
% --- Outputs from this function are returned to the command line.
function varargout = vc_imp_ElectroGuiDbase_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if(strcmpi(handles.output,'none'))
    for(nOut = 1:nargout)
        varargout{nOut} = [];
    end
elseif(strcmpi(handles.output,'params'))
    params.name = 'Electro_gui Files (dbase)';
    if(nargout>0) varargout{1} = params; end
elseif(strcmpi(handles.output,'import'))
    if(nargout>0) varargout{1} = handles.vectors; end
    if(nargout>1) varargout{2} = handles.scalar_features; end
    if(nargout>2) varargout{3} = handles.vector_features; end
    if(nargout>3) varargout{4} = handles.cluster; end
    if(nargout>4) varargout{5} = handles.time; end
    if(nargout>5) varargout{6} = handles.identity; end
    if(nargout>6) varargout{7} = handles.scalar_feature_names; end
    if(nargout>7) varargout{8} = handles.vector_feature_names; end
    if(nargout>8) varargout{9} = handles.fileName; end
    if(nargout>9) varargout{10} = handles.pathName; end
    if(nargout>10) varargout{11} = handles.dbase.Fs; end % exporting Fs
end
% The figure can be deleted now
delete(handles.figure1);

%%
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

%%
% --- Executes on button press in buttonOpen.
function buttonOpen_Callback(hObject, eventdata, handles)
% hObject    handle to buttonOpen (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[fn,pn] = uigetfile('*.mat','Select an electro_gui file (dbase):',''); % get filename and pathname
handles.pathName = pn; %%% save the file name for later use (e.g. when exporting) Tatsuo
handles.fileName = fn; %%% Tatsuo

if(~isempty(fn))
    load([pn,fn]);
    if(~exist('dbase'))
        warning('The file selected was not an electro_gui file.');
    end    
    
    %Use the dbase to populate the event pop-ups:
    eventStrs{1} = 'Audio Segments';
    for ne = 1:length(dbase.EventSources)
        eventStrs{ne+1} = [dbase.EventDetectors{ne} ' - ' dbase.EventSources{ne} ' - ' dbase.EventFunctions{ne}];
    end
    set(handles.popupEvent,'String',eventStrs);
    set(handles.popupEvent,'Value',1);
    set(handles.popupMarkerStart,'String',{'Segment Start','Segment End'});
    set(handles.popupMarkerStart,'Value',1);
    set(handles.popupMarkerEnd,'String',{'Segment Start','Segment End'});
    set(handles.popupMarkerEnd,'Value',2);    
    
    %Enable the popups
    set(handles.popupEvent,'Enable','on');
    set(handles.popupMarkerStart,'Enable','on');
    set(handles.popupMarkerEnd,'Enable','on');
    
    handles.dbase = dbase;
    handles.fileRange = [1:length(dbase.SoundFiles)];
end
guidata(hObject, handles);


%%
% --- Executes on selection change in popupEvent.
function popupEvent_Callback(hObject, eventdata, handles)
% hObject    handle to popupEvent (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupEvent contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupEvent

%Update the marker start and stop popups.
eventVal = get(handles.popupEvent,'Value');
dbase = handles.dbase;

if(eventVal==1) %dbbase Audio segments    
    markerStr = {'Segment Start','Segment End'};
else %dbase event
    eventNdx = eventVal - 1;
    numMarkers = size(dbase.EventTimes{eventNdx},1);
       
    try
        %try to retrieve the labels from the event detector function:
        egeFunctionName = ['ege_' dbase.EventDetectors{eventNdx}];
        [junk markerStr] = eval([egeFunctionName '(''params'')']);
        if(length(markerStr) ~= numMarkers)
            error('');
        end
    catch
        %otherwise use generic names
        for nm = 1:numMarkers
            markerStr{nm} = ['EventMarker ',num2str(nm)];
        end
    end
end
set(handles.popupMarkerStart,'String',markerStr);
set(handles.popupMarkerEnd,'String',markerStr);
set(handles.popupMarkerStart,'Value',1);
set(handles.popupMarkerEnd,'Value',length(markerStr));
guidata(hObject, handles);

%%
% --- Executes during object creation, after setting all properties.
function popupEvent_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupEvent (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in popupMarkerStart.
function popupMarkerStart_Callback(hObject, eventdata, handles)
% hObject    handle to popupMarkerStart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupMarkerStart contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupMarkerStart

%%
% --- Executes during object creation, after setting all properties.
function popupMarkerStart_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupMarkerStart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%%
% --- Executes on selection change in popupMarkerEnd.
function popupMarkerEnd_Callback(hObject, eventdata, handles)
% hObject    handle to popupMarkerEnd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupMarkerEnd contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupMarkerEnd

%%
% --- Executes during object creation, after setting all properties.
function popupMarkerEnd_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupMarkerEnd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%%
function editWindowStartDelta_Callback(hObject, eventdata, handles)
% hObject    handle to editWindowStartDelta (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editWindowStartDelta as text
%        str2double(get(hObject,'String')) returns contents of editWindowStartDelta as a double
str = get(hObject,'String');
[num, status] = str2num(str);
if(~status)
    set(hObject, 'String', '0.0');
end

%%
% --- Executes during object creation, after setting all properties.
function editWindowStartDelta_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editWindowStartDelta (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%%
function editWindowEndDelta_Callback(hObject, eventdata, handles)
% hObject    handle to editWindowEndDelta (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editWindowEndDelta as text
%        str2double(get(hObject,'String')) returns contents of editWindowEndDelta as a double
str = get(hObject,'String');
[num, status] = str2num(str);
if(~status)
    set(hObject, 'String', '0.0');
end

%%
% --- Executes during object creation, after setting all properties.
function editWindowEndDelta_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editWindowEndDelta (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%%
% --- Executes on button press in pushSelectFiles.
function pushSelectFiles_Callback(hObject, eventdata, handles)
% hObject    handle to pushSelectFiles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
dbase = handles.dbase;
if(~isempty(dbase))
    str =  {dbase.SoundFiles(:).name}; %%% semi-colon added by Tatsuo
    for c = 1:length(str)
        str{c} = [num2str(c) '. ' str{c}];
    end
    %[indx,ok] = listdlg('ListString',str,'InitialValue',handles.fileRange,'ListSize',[300 450],'Name','Select files','PromptString','Select file range');
    [indx,ok] = listdlg('ListString',str,'InitialValue',1,'ListSize',[300 450],'Name','Select files','PromptString','Select file range');
    % temporary. just select the first file %%% Tatsuo
    if ok == 0
        return
    end
    handles.fileRange = indx;
    guidata(hObject, handles);
end

%%
% --- Executes on button press in checkboxSubsample.
function checkboxSubsample_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxSubsample (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkboxSubsample

function editFS_Callback(hObject, eventdata, handles)
% hObject    handle to editFS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editFS as text
%        str2double(get(hObject,'String')) returns contents of editFS as a double
str = get(hObject,'String');
[num, status] = str2num(str);
if(~status)
    set(hObject, 'String', '');
end

%%
% --- Executes during object creation, after setting all properties.
function editFS_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editFS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in checkboxFilter.
function checkboxFilter_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxFilter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkboxFilter

% --- Executes on button press in checkboxApplyEventFunction.
function checkboxApplyEventFunction_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxApplyEventFunction (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkboxApplyEventFunction

%%
% --- Executes on button press in checkboxIncludeDeselected.
function checkboxIncludeDeselected_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxIncludeDeselected (see GCBO)
% evevntdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkboxIncludeDeselected


% --- Executes on button press in buttonImport.
function buttonImport_Callback(hObject, eventdata, handles)
% hObject    handle to buttonImport (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = import(handles, handles.dbase, ...
                 'FileRange', handles.fileRange', ...
                 'EventNdx', get(handles.popupEvent,'Value')-1, ...
                 'startEventLabelNdx', get(handles.popupMarkerStart,'Value'), ...
                 'endEventLabelNdx', get(handles.popupMarkerEnd,'Value'), ... 
                 'startDelta', str2num(get(handles.editWindowStartDelta,'String')), ... 
                 'endDelta', str2num(get(handles.editWindowEndDelta,'String')), ... %%% fixed by Tatsuo
                 'bSubsample', logical(get(handles.checkboxSubsample,'Value')), ...
                 'bIncludeDeselected', logical(get(handles.checkboxIncludeDeselected,'Value')), ...
                 'bApplyEventFunction', logical(get(handles.checkboxApplyEventFunction,'Value')), ...
                 'newfs', str2num(get(handles.editFS,'String')), ... 
                 'bFilter', logical(get(handles.checkboxFilter,'Value')));
guidata(hObject, handles);

% Use UIRESUME instead of delete because the OutputFcn needs
% to get the updated handles structure.
uiresume(handles.figure1);

%%
% --- Executes on button press in buttonCancel.
function buttonCancel_Callback(hObject, eventdata, handles)
% hObject    handle to buttonCancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Use UIRESUME instead of delete because the OutputFcn needs
% to get the updated handles structure.
uiresume(handles.figure1);

%%
% --- imports
function [handles,bSuccess] = import(handles, dbase, varargin)
try
    %Load the optional name value pairs.
    P.FileRange = []; %if empty use all files.
    P.EventNdx = 0; %0 indicates audio segments.  Otherwise value is index in dbase.EventSources, Detectors, etc.
    P.startEventLabelNdx = 1; %ndx of row to use in dbase.segmentTimes/dbase.EventTimes as start window reference.
    P.endEventLabelNdx = 1; %ndx of row to use in dbase.segmentTimes/dbase.EventTimes as end window reference.
    P.startDelta = 0.0; %time in ms from startEventLabel where vectors/windows begin.
    P.endDelta = 0.0; %time in ms from endEventLabel where vectors/windows end. 
    P.bSubsample = false; %whether to subsample vectors/windows.
    P.bIncludeDeselected = false; %whether include deselected events
    P.bApplyEventFunction = false; %whether to apply the event function to the signal before importing.
    P.newfs = []; %if bSubsample, then resample to this sampling rate.
    P.bFilter = false; %not currently implemented, but should be used to filter the vectors.
    P = parseargs(P, varargin{:});      %%% changed from parseArgs (TO)       

    if(isempty(P.FileRange)) % File range not specified
        P.FileRange = [1:length(dbase.SoundFiles)]; % all the files
    end
    fs = dbase.Fs;    
    sn = round(P.startDelta/1000*fs); %round(P.startDelta*1000*fs);  %%% fixed Tatsuo 
    en = round(P.endDelta/1000*fs); %round(P.endDelta*1000*fs); %%% fixed Tatsuo
    
    nVect = 0;
    h_waitbar = waitbar(0,'Please wait...','Name','Analyzing file...','CreateCancelBtn','setappdata(gcbf,''canceling'',1)'); %%% Tatsuo
    setappdata(h_waitbar,'canceling',0); %%% Tatsuo
    for n = 1:length(P.FileRange)
        nFile = P.FileRange(n); %%% Tasuo
        %Load the signal we need to clip windows from.
        waitbar(n/length(P.FileRange),h_waitbar,[num2str(n), ' / ', num2str(length(P.FileRange))]); %%% Tatsuo
        if getappdata(h_waitbar,'canceling') %%% Tatsuo
           display(['Imported files from 1:' num2str(nFile-1)]);
           break %%% Tatsuo
        end %%% Tatsuo
                
        if(P.EventNdx == 0)
            [sig nfs] = eval(['egl_' dbase.SoundLoader '([''' dbase.PathName '\' dbase.SoundFiles(nFile).name '''],1)']);
        else
            chan = str2num(dbase.EventSources{P.EventNdx}(9:end));
            [sig nfs] = eval(['egl_' dbase.ChannelLoader{chan} '([''' dbase.PathName '\' dbase.ChannelFiles{chan}(nFile).name '''],1)']);
        end
        if(round(nfs) ~= round(fs))
            error('Unexpected sampling rate.');
        end

        %Load the event times within this file that are selected.
        if(P.EventNdx == 0) % audio segment
            if isempty(dbase.SegmentTimes{nFile}) % no events in this file
                continue
            end
            alignS = dbase.SegmentTimes{nFile}(:,P.startEventLabelNdx); % dbase.SegmentTimes{nFile}(P.startEventLabelNdx,:);
            alignS = alignS'; %%% added by Tatsuo    column -> row vector
            alignE = dbase.SegmentTimes{nFile}(:,P.endEventLabelNdx); % dbase.SegmentTimes{nFile}(P.endEventLabelNdx,:);
            alignE = alignE'; %%% added by Tatsuo    column -> row vector
            bSel = find(dbase.SegmentIsSelected{nFile}); %%% Tatsuo
            %convert char to num
            for(ne = 1:length(alignS))
                if(~isempty(dbase.SegmentTitles{nFile}{ne}))
                    clust(ne) = dbase.SegmentTitles{nFile}{ne} + 0; % syllable title
                else
                    clust(ne) = -1; % empty syllable title
                end
            end
        else  % non-audio segment                      
            alignS = dbase.EventTimes{P.EventNdx}{P.startEventLabelNdx,nFile};
            alignS = alignS';
            alignE = dbase.EventTimes{P.EventNdx}{P.endEventLabelNdx,nFile};
            alignE = alignE';
            bSel = dbase.EventIsSelected{P.EventNdx}{P.startEventLabelNdx,nFile} & dbase.EventIsSelected{P.EventNdx}{P.endEventLabelNdx,nFile};
            clust = nan(size(alignS));
        end
        % sn and en are added to give the proper window size
        % startNdx and endNdx is an array of onset and offset of events (in samples)
        startNdx = min(length(sig), max(1,alignS + sn)); % make sure 1 <= startNdx <= length(sig)
        endNdx = min(length(sig), max(1,alignE + en));
        eventNdx = [1:length(startNdx)];        
        if(~P.bIncludeDeselected) % do not include deselected -> use only selected values
            alignS = alignS(bSel);
            alignE = alignE(bSel);
            startNdx = startNdx(bSel);
            endNdx = endNdx(bSel);
            clust = clust(bSel);
            eventNdx = bSel; %%% Tatsuo           
            %bSel = bSel(bSel); %%% Tatsuo
        end
        
%         %Apply the event function if requested.
%         %Not currently working because don't ahve function parameters in
%         %the dbase.
%         if(P.bApplyEventFunction)
%             if(~strcmp(dbase.EventFunctions{P.EventNdx},'(Raw)'))
%                 try
%                     funcName = dbase.EventFunctions{P.EventNdx};
%                     f = findstr(funcName,' - ');
%                     if(~isempty(f))
%                         funcName = str(1:f(1)-1);
%                     end                
%                     [sig lab] = eval(['egf_' funcName '(sig,fs,handles.FunctionParams)']);                            
%                 catch
%                     error('Unable to find event function.');
%                 end
%             end
%         end

        if(P.bSubsample)
            sig = resample(sig,P.newfs,fs);
            startNdx = min(length(sig), max(1,startNdx*P.newfs/fs));
            endNdx = min(length(sig), max(1,endNdx*P.newfs/fs));
        end   
        
        %Compute scalar features
        duration = (alignE-alignS)./fs; %%fs*(alignE-alignS);  event duration [s] %%% Tatsuo
        timeInFile = (alignS-1)./fs; %% fs*(alignS-1); time from file onset [s] %%% Tatsuo
        
        %Compute the interval and isi
        isi = [];
        interval = [];
        if(~isempty(alignS))
            isi = [diff(alignS)./fs,nan]; %[fs*diff(alignS),nan]; %%% Tatsuo  add nan for the last event
            interval = [nan];
            if(length(alignS)>1)
                interval = [(alignS(2:end)-alignE(1:end-1))./fs, nan]; %[fs*(alignS(2:end)-alignE(1:end-1)), nan]; %%% Tatsuo
            end
        end
             
        for(ne = 1:length(startNdx))
            nVect = nVect + 1;
            syllAudio = sig(startNdx(ne):endNdx(ne)); %%% Tatsuo
            handles.vectors{nVect,1} = syllAudio; %%% Tatsuo
            handles.time(nVect,1) = dbase.Times(nFile) + ((fs*(alignS(ne)-1))/(24*60*60));            
            handles.cluster(nVect,1) = clust(ne);
            handles.identity{nVect,1}.dbaseFileNdx = nFile;
            handles.identity{nVect,1}.dbaseEventTypeNdx = P.EventNdx;
            handles.identity{nVect,1}.dbaseLabelNdx = P.startEventLabelNdx;
            handles.identity{nVect,1}.dbaseEventTime = alignS(ne);
            handles.identity{nVect,1}.dbaseEventNdx = eventNdx(ne);
            handles.scalar_features(nVect,1) = duration(ne);
            [pi, pg, hp, pt, ent] = estimatePitch(syllAudio, dbase.Fs); %%% Tatsuo
            handles.scalar_features(nVect,2:7) = [mean(pi), std(pi), mean(pg), std(pg), mean(ent),std(ent)];
            handles.scalar_features(nVect,8:10) =  [timeInFile(ne), isi(ne), interval(ne)];
            Pitch{nVect,1} = pi;
            PitchGoodness{nVect,1} = pg;
            Entropy{nVect,1} = ent; 
            [features labels] = egf_SAPfeatures(syllAudio, dbase.Fs); % written by Sigal Saar  
            FM{nVect,1} = features{2};
            Mean_frequency{nVect,1} = features{9}; % also known as gravity center
        end
    end    
    handles.scalar_feature_names = {'duration';'mean_pitch';'std_pitch';'mean_pitchGoodness';'std_pitchGoodness';...
        'mean_entropy';'std_entropy';'timeInFile';'isi';'interval';}; %%% changed to column vector, Tatsuo
    handles.vector_features = {Pitch,PitchGoodness,Entropy,FM,Mean_frequency}; %%% Tatsuo
    handles.vector_feature_names = {'pitch';'pitchGoodness';'entropy';'FM';'Mean_frequency'};  %%% Tatsuo
    
    delete(h_waitbar) % not close but delete %%% Tatsuo
    bSuccess = true;
    display('Import succeeded!') %%% Tatsuo
    handles.output = 'import';   
catch
    delete(h_waitbar)
    bSuccess = false;
    warndlg(['Import failed: ', lasterr]);
end