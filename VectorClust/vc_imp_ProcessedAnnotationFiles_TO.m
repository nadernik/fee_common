function varargout = vc_imp_ProcessedAnnotationFiles_TO(varargin)
% Usages:
%
% GUI MODE
% [v, sf, vf, c, t, i, sf_names, vf_names, fileName, pathName] = vc_imp_ProcessedAnnotationFiles_TO()
%       v: vectors
%       sf: scalar features
%       vf: vector features
%       c: initial cluster 
%       t: time
%       i: identity 
%       sf_names: names of scalar features
%       vf_names: names of vector features.
%       fileName: name of the dbase file being imported %%% TO
%       pathName: path name of the file %%% TO
%
% PARAMETER QUERY MODE
% parameters = vc_imp_ProcessedAnnotationFiles_TO('parameters')
%   returns structure containing a name field.
%
% BATCH MODE 
% [v, sf, vf, c, t, i, sf_names, vf_names] = vc_imp_ProcessedAnnotationFiles_TO('batch', searchString)

% VC_IMP_PROCESSEDANNOTATIONFILES_TO M-file for vc_imp_ProcessedAnnotationFiles_TO.fig
%      VC_IMP_PROCESSEDANNOTATIONFILES_TO by itself, creates a new VC_IMP_PROCESSEDANNOTATIONFILES_TO or raises the
%      existing singleton*.
%
%      H = VC_IMP_PROCESSEDANNOTATIONFILES_TO returns the handle to a new VC_IMP_PROCESSEDANNOTATIONFILES_TO or the handle to
%      the existing singleton*.
%
%      VC_IMP_PROCESSEDANNOTATIONFILES_TO('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in VC_IMP_PROCESSEDANNOTATIONFILES_TO.M with the given input arguments.
%
%      VC_IMP_PROCESSEDANNOTATIONFILES_TO('Property','Value',...) creates a new VC_IMP_PROCESSEDANNOTATIONFILES_TO or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before vc_imp_ProcessedAnnotationFiles_TO_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to vc_imp_ProcessedAnnotationFiles_TO_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help vc_imp_ProcessedAnnotationFiles_TO

% Last Modified by GUIDE v2.5 02-Jun-2008 18:31:05

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @vc_imp_ProcessedAnnotationFiles_TO_OpeningFcn, ...
                   'gui_OutputFcn',  @vc_imp_ProcessedAnnotationFiles_TO_OutputFcn, ...
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

% --- Executes just before vc_imp_ProcessedAnnotationFiles_TO is made visible.
function vc_imp_ProcessedAnnotationFiles_TO_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to vc_imp_ProcessedAnnotationFiles_TO (see VARARGIN)

% Become true if data successfully imported.
handles.output = 'none';
handles.strs = {'misc','audio','cafProgram','pitch','current'};
%handles.strs = {'misc','pitch'}; % TO

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

% UIWAIT makes vc_imp_ProcessedAnnotationFiles_TO wait for user response (see UIRESUME)
if(~strcmpi(handles.output,'params') && ~(~isempty(varargin) && strcmpi(varargin{1},'batch')))
    uiwait(handles.figure1);
else
    set(handles.figure1,'Visible','off');
end

if(~isempty(varargin) && strcmpi(varargin{1},'batch'))
    handles.pathName = varargin{2};
    handles.fileName = varargin{3};
    handles.searchString = regexprep([handles.pathName,handles.fileName],'misc','*');
    handles = import(handles, varargin{2});   
    guidata(hObject, handles);
end


% --- Outputs from this function are returned to the command line.
function varargout = vc_imp_ProcessedAnnotationFiles_TO_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if(strcmpi(handles.output,'none'))
    for(nOut = 1:nargout)
        varargout{nOut} = [];
    end
elseif(strcmpi(handles.output,'params'))
    params.name = 'Processed Annotation Files';
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


function searchString_Callback(hObject, eventdata, handles)
% hObject    handle to searchString (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of searchString as text
%        str2double(get(hObject,'String')) returns contents of searchString as a double


% --- Executes during object creation, after setting all properties.
function searchString_CreateFcn(hObject, eventdata, handles)
% hObject    handle to searchString (see GCBO)
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
[fn,pn] = uigetfile('*misc*.mat','Selected a process annotation file:',''); %%% only display misc files TO
if(~isempty(fn))
    strs = handles.strs;
    for(i = 1:length(strs))
        [s e] = regexp(fn, strs{i}, 'start', 'end');
        if(~isempty(s))
            fn = regexprep(fn, strs{i},'*');
            break;
        end
    end
    set(handles.searchString, 'String', [pn,fn]);
end
guidata(hObject, handles);

% --- Executes on button press in buttonImport.
function buttonImport_Callback(hObject, eventdata, handles)
% hObject    handle to buttonImport (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = import(handles, get(handles.searchString,'String'));
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

% --- imports
function [handles,bSuccess] = import(handles, searchString)
[pathstr,filename] = fileparts(searchString);
%[pathstr,filename] = fileparts(handles.searchString); %TO
handles.pathName = pathstr; % TO
handles.fileName = filename; % TO
d = dir(searchString);
bSuccess = false; % default

%Load raw audio:
for nFile = 1:length(d)
    [s e] = regexp(d(nFile).name, 'audio', 'start', 'end');
    if(~isempty(s))
        load([pathstr, filesep, d(nFile).name]);
        %handles.vectors = {rawaudio.segs(:).audio};      
        %if(size(handles.vectors,2) > 1)
        %    handles.vectors = handles.vectors';
        %end
        
        annotNdx = find(rawaudio.bRand);
        handles.vectors = cell(length(rawaudio.segs),1);
        sf_amplitude = zeros(length(rawaudio.segs),1);
        for(nVec = 1:length(rawaudio.segs))
            if(get(handles.checkboxDownsampleAudio,'Value'))
                handles.vectors{nVec} = rawaudio.segs(nVec).audio(1:2:end);
            elseif(get(handles.checkboxLoadAudio,'Value'))
                handles.vectors{nVec} = rawaudio.segs(nVec).audio;
            else
                handles.vectors{nVec} = [];
            end
            
            %correct orientation
            if(size(handles.vectors{nVec},2)>1)
                handles.vectors{nVec} = handles.vectors{nVec}';       
            end
            if(size(handles.vectors{nVec},2)>1)
                h = warndlg('Audio not appropriate for import.', 'Import Failed', 'modal'); 
                return; 
            end       

            sf_amplitude(nVec,1) = std(rawaudio.segs(nVec).audio);
            handles.identity{nVec,1}.annotndx = annotNdx(nVec);
            handles.identity{nVec,1}.annotkey = rawaudio.segs(nVec).key;
            handles.identity{nVec,1}.absStart = rawaudio.segs(nVec).absStart;            
        end
        
        %handles.scalar_features(:,1) = [rawaudio.segs(:).absStart]';
        %handles.scalar_feature_names{1} = 'time';      
        handles.time = [rawaudio.segs(:).absStart]'; 
        clear rawaudio;
        break;
    else
        %if not audio set then import failed and return.
        return;
    end
end

%if(nargout>1) varargout{2} = handles.scalar_features; end
%if(nargout>2) varargout{3} = handles.vector_features; end
%if(nargout>3) varargout{4} = handles.cluster; end
%if(nargout>6) varargout{7} = handles.scalar_feature_names; end
%if(nargout>7) varargout{8} = handles.vector_feature_names; end

%Load misc:
for nFile = 1:length(d)
    [s e] = regexp(d(nFile).name, 'misc', 'start', 'end');
    if(~isempty(s))
        load([pathstr, filesep, d(nFile).name])
        handles.scalar_features(:,1) = [misc.segs(:).duration]';        
        handles.scalar_feature_names{1,1} = 'duration';      
        handles.cluster = [misc.segs(:).segType]';
        
        %% added for stim amd masking exp (TO)
        if isfield(misc.segs(:),'IsMask')
            temp = {misc.segs(:).IsMask};
            handles.scalar_features(:,13) = (cell2mat(temp))';
            handles.scalar_feature_names{13,1} = 'IsMask';
        end

        if isfield(misc.segs(:),'IsStim')
            temp = {misc.segs(:).IsStim};
            handles.scalar_features(:,14) = (cell2mat(temp))';
            handles.scalar_feature_names{14,1} = 'IsStim';
        end

        if isfield(misc.segs(:),'stimAmp')
            temp = {misc.segs(:).stimAmp};
            handles.scalar_features(:,15) = (cell2mat(temp))';
            handles.scalar_feature_names{15,1} = 'stimAmp';
        end

        if isfield(misc.segs(:),'maskTime')
            temp = {misc.segs(:).maskTime};
            handles.vector_features{4} = temp';
            handles.vector_feature_names{4,1} = 'maskTime';
        end

        if isfield(misc.segs(:),'stimTime')
            temp = {misc.segs(:).stimTime};
            handles.vector_features{5} = temp';
            handles.vector_feature_names{5,1} = 'stimTime';
        end
        break; %?
    end
end
    
%Load pitch
for nFile = 1:length(d)
    [s e] = regexp(d(nFile).name, 'pitch', 'start', 'end');
    if(~isempty(s))
        load([pathstr, filesep, d(nFile).name]);
        if(get(handles.checkboxImportVF,'Value'))            
            handles.vector_features{1} = {pitch.segs(:).pitch}';
            handles.vector_feature_names{1,1} = 'pitch';    
        end
        handles.scalar_features(:,2) = cellfun(@mean, {pitch.segs(:).pitch}');
        handles.scalar_feature_names{2,1} = 'mean_pitch'; 
        handles.scalar_features(:,3) = cellfun(@std, {pitch.segs(:).pitch}');
        handles.scalar_feature_names{3,1} = 'std_pitch'; 
        
        if(get(handles.checkboxImportVF,'Value'))  
            handles.vector_features{2} = {pitch.segs(:).pitchGoodness}';
            handles.vector_feature_names{2,1} = 'pitchGoodness';
        end
        handles.scalar_features(:,4) = cellfun(@mean, {pitch.segs(:).pitchGoodness}');
        handles.scalar_feature_names{4,1} = 'mean_pitchGoodness'; 
        handles.scalar_features(:,5) = cellfun(@std, {pitch.segs(:).pitchGoodness}');
        handles.scalar_feature_names{5,1} = 'std_pitchGoodness';
        
        if(get(handles.checkboxImportVF,'Value'))  
            handles.vector_features{3} = {pitch.segs(:).entropy}';
            handles.vector_feature_names{3,1} = 'entropy';
        end
        handles.scalar_features(:,6) = cellfun(@mean, {pitch.segs(:).entropy}');
        handles.scalar_feature_names{6,1} = 'mean_entropy'; 
        handles.scalar_features(:,7) = cellfun(@std, {pitch.segs(:).entropy}');
        handles.scalar_feature_names{7,1} = 'std_entropy';        
    end
end

if(length(handles.vectors) > 1)
    startTimes = handles.time';
    endTimes = startTimes + (handles.scalar_features(:,1)/(24*60*60))';
    handles.scalar_features(:,8) = [nan, diff(startTimes)]*24*60*60;
    handles.scalar_feature_names{8,1} = 'prev_interval';
    handles.scalar_features(:,9) = [diff(startTimes),nan]*24*60*60;
    handles.scalar_feature_names{9,1} = 'next_interval';
    handles.scalar_features(:,10) = [nan, (startTimes(2:end) - endTimes(1:end-1))]*24*60*60;
    handles.scalar_feature_names{10,1} = 'prev_gap';
    handles.scalar_features(:,11) = [(startTimes(2:end) - endTimes(1:end-1)),nan]*24*60*60;
    handles.scalar_feature_names{11,1} = 'next_gap';
    handles.scalar_features(:,12) = sf_amplitude;
    handles.scalar_feature_names{12,1} = 'amplitude';
end

bSuccess = true;
handles.output = 'import';


% --- Executes on button press in checkboxImportVF.
function checkboxImportVF_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxImportVF (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkboxImportVF


% --- Executes on button press in checkboxDownsampleAudio.
function checkboxDownsampleAudio_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxDownsampleAudio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkboxDownsampleAudio




% --- Executes on button press in checkboxLoadAudio.
function checkboxLoadAudio_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxLoadAudio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkboxLoadAudio


