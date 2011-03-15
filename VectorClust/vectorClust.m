function varargout = vectorClust(varargin)
% VECTORCLUST M-file for vectorClust.fig
%      VECTORCLUST, by itself, creates a new VECTORCLUST or raises the
%      existing
%      singleton*.
%
%      H = VECTORCLUST returns the handle to a new VECTORCLUST or the handle to
%      the existing singleton*.
%
%      VECTORCLUST('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in VECTORCLUST.M with the given input arguments.
%
%      VECTORCLUST('Property','Value',...) creates a new VECTORCLUST or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before vectorClust_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to vectorClust_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help vectorClust

% Last Modified by GUIDE v2.5 27-May-2010 15:51:03

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @vectorClust_OpeningFcn, ...
                   'gui_OutputFcn',  @vectorClust_OutputFcn, ...
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

% --- Executes just before vectorClust is made visible.
function vectorClust_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to vectorClust (see VARARGIN)

% Choose default command line output for vectorClust
handles.output = hObject;

%Vector Cluster DB (the saved object)
%data
vcdb.d.v = {};
vcdb.d.sf = [];
vcdb.d.vf = {};
vcdb.d.cn = [];
vcdb.d.icn = [];
vcdb.d.t = [];
vcdb.d.i = {};
%feature descriptions
vcdb.f.sfname = {};
vcdb.f.sffcn = {};
vcdb.f.sfparam = {};
vcdb.f.vfname = {};
vcdb.f.vffcn = {};
vcdb.f.vfparam = {};
%cluster definitions
vcdb.c = []; %no clusters yet.

%Vector Cluster Gui Variables
f = functions(@vectorClust);
vcg.vcdir = fileparts(f.file);
vcg.vcdbFilename = [];
vcg.bSel = [];
vcg.bDraw = [];
vcg.bFilt = [];
vcg.hScat = [];
vcg.hVect = [];
vcg.mVectMat = [];
vcg.feat2colorMap = jet(256);
vcg.feat2colorFeat = 1;
vcg.feat2colorRange = [0,1];
vcg.subsamp.p = 1;
vcg.subsamp.q = 10;
vcg.subsamp.bFast = true;
vcg.stretch.n = 100;
vcg.stretch.bFast = true;
vcg.vectRange = [-Inf,Inf];
vcg.specgram.fs = 40000;
vcg.specgram.freqRange = [0,8001]; %%% changed from [0 10000] TO
vcg.specgram.colorRange = [];
vcg.options.largeSetThreshold = 3000;
vcg.options.unclusteredColor = [0,0,0];
vcg.options.unclusteredMarker = 'o';
vcg.options.unclusteredSize = 20;
vcg.options.maxSets = 20;

handles.vcdb = vcdb;
handles.vcg = vcg;

%Vector Cluster 
d = dir([handles.vcg.vcdir,filesep,'vc_cmf_*.m']);
name = cell(size(d));
for nD = 1:length(d)
    name{nD} = d(nD).name(8:end-2);
end
set(handles.popupComputeFeature,'String',name);

% load path and file names automatically (TO)
P.pathName = [];
P.fileName = [];
P = parseargs(P, varargin{:});
handles.pathName = P.pathName;
handles.fileName = P.fileName;
% if ~(exist([handles.pathName,handles.fileName])==0)
%     buttonImport_Callback(hObject, eventdata, handles);
% end

% Update handles structure
guidata(hObject, handles);
% UIWAIT makes vectorClust wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = vectorClust_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in buttonSave.
function buttonSave_Callback(hObject, eventdata, handles)
% hObject    handle to buttonSave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = saveVCDB(handles);
guidata(hObject, handles);

% --- Executes on button press in buttonSaveAs.
function buttonSaveAs_Callback(hObject, eventdata, handles)
% hObject    handle to buttonSaveAs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[f,p] = uiputfile('*.mat','Save vectorClust Data:');
if(isequal(f,0))
    return;
end
handles.vcg.vcdbFilename = [p,filesep,f];
handles = saveVCDB(handles);
guidata(hObject, handles);

% --- Save the VCDB data.
function handles = saveVCDB(handles)
if(isempty(handles.vcg.vcdbFilename)) % no preexisting file
    [f,p] = uiputfile('*cluster*.mat','Save vectorClust Data:'); %%% TO
    if(isequal(f,0))
        return;
    end
    handles.vcg.vcdbFilename = [p,filesep,f];
end
save(handles.vcg.vcdbFilename, '-struct','handles','vcdb'); % save only handles.vcdb
msgbox(['Saved to ',handles.vcg.vcdbFilename]); % TO DO remove two fileseps

% --- Executes on button press in buttonImport.
function buttonImport_Callback(hObject, eventdata, handles)
% hObject    handle to buttonImport (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%%Ask whether old data should be removed.
[handles, bClosed] = closeVectorClustData(handles);
d = dir([handles.vcg.vcdir,filesep,'vc_imp_*.m']);
func = cell(size(d));
name = cell(size(d));
for nD = 1:length(d)
    name{nD} = d(nD).name(8:end-2);
    func{nD} = str2func(d(nD).name(1:end-2));
end
[sel, ok] = listdlg('ListString', name, 'Name', 'Select an import function:', 'OKString', 'Import','SelectionMode','single');
if(ok)
    %Invoke the import function
    if strcmp(name{sel},'ElectroGuiDbase') %%% TO
        [v, sf, vf, icn, t, i, sfname, vfname, fileName, pathName, Fs] = feval(func{sel}); %%% TO
        set(handles.text_FileName,'string',fileName); %%% TO
        handles.vcdb.fileName = fileName; %%% TO
        handles.vcdb.pathName = pathName; %%% TO
        handles.vcg.specgram.fs = round(Fs); %%% TO
    elseif strcmp(name{sel},'ProcessedAnnotationFiles')
        [v, sf, vf, icn, t, i, sfname, vfname, fileName, pathName] = feval(func{sel}); %%% TO
        handles.vcdb.fileName = fileName; %%% TO
        handles.vcdb.pathName = pathName; %%% TO
        set(handles.text_FileName,'string',fileName); %%% TO
    elseif strcmp(name{sel},'ProcessedAnnotationFiles_TO'); %%% TO        
        %if isempty(handles.pathName) | isempty(handles.fileName)
            [v, sf, vf, icn, t, i, sfname, vfname, fileName, pathName] = feval(func{sel}); %%% TO
        %else
        %    [v, sf, vf, icn, t, i, sfname, vfname, fileName, pathName] = feval(func{sel},...
        %        'batch',handles.pathName,handles.fileName);
        %end
        handles.vcdb.fileName = fileName; %%% TO
        handles.vcdb.pathName = pathName; %%% TO
        set(handles.text_FileName,'string',fileName); %%% TO
    else %%% TO
        [v, sf, vf, icn, t, i, sfname, vfname] = feval(func{sel});    
    end %%% TO
    guidata(hObject, handles);
    
    %If import successful
    if(~isempty(v))
        
        if(bClosed)           
            %add basic features to the scalar feature list.
            sf(:,end+1) = cellfun(@length,v);  
            sfname{end+1} = 'length';               
            sf(:,end+1) = t;
            sfname{end+1} = 'time';
            sf(:,end+1) = (t - floor(t))*24;
            sfname{end+1} = 'hourOfDay';
            sf(:,end+1) = icn;
            sfname{end+1} = 'imported cluster';      
            
            %import the data.
            handles.vcdb.d.v = v;
            handles.vcdb.d.sf = sf;
            handles.vcdb.d.vf = vf;
            handles.vcdb.d.cn = nan(length(v),1);
            handles.vcdb.d.icn = icn;
            handles.vcdb.d.t = t;
            handles.vcdb.d.i = i;
            handles.vcdb.f.sfname = sfname;
            handles.vcdb.f.sffcn = repmat({func2str(func{sel})}, length(sfname), 1);
            handles.vcdb.f.sfparam = cell(length(sfname),1);
            handles.vcdb.f.vfname = vfname;
            handles.vcdb.f.vffcn = repmat({func2str(func{sel})}, length(vfname), 1);
            handles.vcdb.f.vfparam = cell(length(vfname),1);
            handles.vcdb.c = [];
            handles.vcg.bSel = false(size(v));
            handles.vcg.bDraw = true(size(v));
            handles.vcg.bFilt = true(size(v));
            handles.vcg.hScat = [];
            handles.vcg.hVect = [];
            handles.vcg.mVectMat = [];
            handles = refreshAll(handles);
        end
    end
end
buttonHistogram_Callback(hObject, eventdata, handles); % update histogram
guidata(hObject, handles);

% --- Executes on button press in buttonLoad.
function buttonLoad_Callback(hObject, eventdata, handles)
% hObject    handle to buttonLoad (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[f,p] = uigetfile('*cluster*.mat','Load vectorClust data:');
if(isequal(f,0))
    return;
end
%load([p,filesep,f]);
load([p,f]);
if(~exist('vcdb'))
    warndlg('Specifed file is not a vectorClust data file.');
    return;
end
[handles, bClosed] = closeVectorClustData(handles);
if(bClosed)
    if(size(vcdb.f.sfname,2) > size(vcdb.f.sfname,1))
        vcdb.f.sfname = vcdb.f.sfname';
    end
    if(size(vcdb.f.vfname,2) > size(vcdb.f.vfname,1))
        vcdb.f.vfname = vcdb.f.vfname';
    end
    handles.vcdb = vcdb;
    handles.vcg.vcdbFilename = [p,filesep,f];
    handles.vcg.bSel = false(size(handles.vcdb.d.v));
    handles.vcg.bDraw = true(size(handles.vcdb.d.v));
    handles.vcg.bFilt = true(size(handles.vcdb.d.v));
    handles = refreshAll(handles);
end
set(handles.text_FileName,'string',f); %%% TO
buttonHistogram_Callback(hObject, eventdata, handles); % update histogram
guidata(hObject, handles);

% --- Close current data.  Ask first.
function [handles, bClosed] = closeVectorClustData(handles)
% handles    structure with handles and user data (see GUIDATA)
bClosed = true;
if(~isempty(handles.vcdb.d.v))
    bClosed = false;
    button = questdlg('vectorClust data is already open.  Would you like to save before loading different data?','');
    if(strcmp(button,'Yes'))
        handles = saveVCDB(handles);
    end
    if(strcmp(button,'Yes') | strcmp(button,'No'))
        bClosed = true;
        
        %blank data and data descriptions.
        handles.vcdb.d.v = {};
        handles.vcdb.d.sf = [];
        handles.vcdb.d.vf = {};
        handles.vcdb.d.cn = [];
        handles.vcdb.d.icn = [];
        handles.vcdb.d.t = [];
        handles.vcdb.d.i = {};
        handles.vcdb.f.sfname = {};
        handles.vcdb.f.sffcn = {};
        handles.vcdb.f.sfparam = {};
        handles.vcdb.f.vfname = {};
        handles.vcdb.f.vffcn = {};
        handles.vcdb.f.vfparam = {};
        handles.vcdb.fileName = []; %%% TO
        handles.vcdb.pathName = []; %%% TO
        %remove any manual cluster definitions.
        for nc = 1:length(handles.vcdb.c)
            handles.vcdb.c(nc).incs = {};
            handles.vcdb.c(nc).excs = {};
        end      
        %blank vcdb filename.
        handles.vcg.vcdbFilename = [];
        handles.vcg.bSel = [];
        handles.vcg.bDraw = [];
        handles.vcg.bFilt = [];
        handles.vcg.hScat = [];
        handles.vcg.hVect = [];
        handles.vcg.mVectMat = [];
    end
end 

% --- Executes on button press in buttonExport.
function buttonExport_Callback(hObject, eventdata, handles)
% hObject    handle to buttonExport (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
d = dir([handles.vcg.vcdir,filesep,'vc_exp_*.m']);
func = cell(size(d));
name = cell(size(d));
for nD = 1:length(d)
    name{nD} = d(nD).name(8:end-2);
    func{nD} = str2func(d(nD).name(1:end-2));
end
[sel, ok] = listdlg('ListString', name, 'Name', 'Select an export function:', 'OKString', 'Export','SelectionMode','single');
if(ok)
    errString = feval(func{sel}, handles.vcdb);
   
    if(~isempty(errString) && ~strcmpi(errString,'cancel'))
        warndlg(['Export did not complete successfully: ',errString]);
    end
end
guidata(hObject, handles);

% --- Executes on selection change in popupComputeFeature.
function popupComputeFeature_Callback(hObject, eventdata, handles)
% hObject    handle to popupComputeFeature (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupComputeFeature contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupComputeFeature


% --- Executes during object creation, after setting all properties.
function popupComputeFeature_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupComputeFeature (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in buttonComputeFeature.
function buttonComputeFeature_Callback(hObject, eventdata, handles)
% hObject    handle to buttonComputeFeature (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if(~isempty(handles.vcdb.d.v))
    nCmpFcn = get(handles.popupComputeFeature,'Value');
    sFcns = get(handles.popupComputeFeature,'String');
    cmpFcn = str2func(['vc_cmf_',sFcns{nCmpFcn}]);
    [vcdb,status] = feval(cmpFcn,handles.vcdb);
    if(strcmp(status,'success'))
        handles.vcdb = vcdb;
        if(get(handles.checkboxAutoSave,'Value'))
            handles = saveVCDB(handles);
        end
        handles = refreshAll(handles);
    elseif(~isempty(status))
        warndlg(status, 'Compute Feature Failed', 'modal');
    end
    guidata(hObject, handles);
end

% --- Executes on button press in checkboxAutoSave.
function checkboxAutoSave_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxAutoSave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkboxAutoSave

% --- Executes on selection change in popupClusterSelect.
function popupClusterSelect_Callback(hObject, eventdata, handles)
% hObject    handle to popupClusterSelect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupClusterSelect contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupClusterSelect
nVal = get(handles.popupClusterSelect,'Value');
sVal = get(handles.popupClusterSelect,'String');
clusterStr = sVal{nVal};
if(strcmpi(clusterStr,'New Cluster'))
    prompt = {'New cluster number:','New cluster name:'};
    dlg_title = 'Create a new cluster:';
    num_lines = 1;
    answer = inputdlg(prompt,dlg_title,num_lines);    
    if(isempty(answer))
        set(handles.popupClusterSelect,'Value',1);
        return;
    end
    cNum = str2num(answer{1});
    cName = answer{2};
    if(isempty(cNum) || isempty(cName))
        set(handles.popupClusterSelect,'Value',1);
        return;
    end
    cColor = uisetcolor('New cluster color:');
    if(isempty(cColor))
        set(handles.popupClusterSelect,'Value',1);
        return;
    end
    c.number = cNum;
    c.str = cName;
    c.color = cColor;
    c.polys = {};
    c.incs = {};
    c.excs = {};
    if(isempty(handles.vcdb.c))
        handles.vcdb.c = c;
    else
        handles.vcdb.c(end+1) = c;
    end
    set(handles.popupClusterSelect,'Value',length(handles.vcdb.c)); %%% TO
    handles = refreshClusters(handles);
else % pre-existing cluster
    handles = refreshSelectedCluster(handles);
end
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function popupClusterSelect_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupClusterSelect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in listboxClusterPolygons.
function listboxClusterPolygons_Callback(hObject, eventdata, handles)
% hObject    handle to listboxClusterPolygons (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns listboxClusterPolygons contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listboxClusterPolygons
hFig = gcbf;
if(strcmp(get(hFig,'SelectionType'),'open'))
    nVal = get(handles.listboxClusterPolygons,'Value');
    if(~isempty(nVal))
        clust = get(handles.popupClusterSelect,'Value');
        if(~isempty('clust') & clust <= length(handles.vcdb.c))
            poly = handles.vcdb.c(clust).polys{nVal};
            setFeaturePopupValue(handles.popupYFeature, handles.vcdb, poly.yfeat);
            setFeaturePopupValue(handles.popupXFeature, handles.vcdb, poly.xfeat);
            handles = refreshScatter(handles);
        end
    end
end
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function listboxClusterPolygons_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listboxClusterPolygons (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in listboxManualMods.
function listboxManualMods_Callback(hObject, eventdata, handles)
% hObject    handle to listboxManualMods (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns listboxManualMods contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listboxManualMods
hFig = gcbf;
if(strcmp(get(hFig,'SelectionType'),'open'))
    nVal = get(handles.listboxManualMods,'Value');
    sVal = get(handles.listboxManualMods,'String');
    if(~isempty(nVal))
        nc = get(handles.popupClusterSelect,'Value');
        if(~isempty(nc) & nc<=length(handles.vcdb.c))
            %The first 4 letters determine whether we are dealing with includes
            %or excludes.
            field = sVal{nVal}(1:4);
            %The first 6 to end is the index.
            ndx = str2num(sVal{nVal}(6:end));
            handles.vcg.bSel = handles.vcdb.c(nc).(field){ndx} & handles.vcg.bDraw & handles.vcg.bFilt;
            handles = refreshScatterSelection(handles);
            handles = refreshVectorSelection(handles);
        end
    end
end
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function listboxManualMods_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listboxManualMods (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in buttonAddPolygon.
function buttonAddPolygon_Callback(hObject, eventdata, handles)
% hObject    handle to buttonAddPolygon (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fig = gcbf;
clust = get(handles.popupClusterSelect,'Value');
clustColor = handles.vcdb.c(clust).color; %%% get color of the current cluster, TO
polylines = [];
if(~isempty(clust) & clust<=length(handles.vcdb.c))
    set(hObject, 'BackgroundColor', clustColor); %%% BG color of the button, TO
    set(handles.axesFeatureScatter, 'ButtonDownFcn', []);
    bCancel = false;
    bComplete = false;
    
    [p1,p2,bKey] = rbline(handles.axesFeatureScatter);
    if(bKey)
        bCancel = true;
    end    
    polyx = [p1(1),p2(1)];
    polyy = [p1(2),p2(2)];
    polylines(end+1) = line(polyx,polyy,'EraseMode','xor');
    tic;
    while(~bCancel & ~bComplete)
        [p1,p2,bKey] = rbline(handles.axesFeatureScatter,polyx(end),polyy(end));
        dt = toc;  
        
        %get state...
        if(bKey)
            key = get(fig, 'CurrentCharacter') + 0;
            if(~(key==13 || key==27))
                continue;
            end
            bDoubleClick = false;
        else
            key = -1;
            if(handles.axesFeatureScatter~=gca)
                continue;
            end
            pause(.001);
            bDoubleClick = strcmp('open', get(fig, 'SelectionType'));
        end    
        
        %take appropriate action.
        bCancel = (key == 27);
        bComplete = (~bKey & bDoubleClick) | (bKey & (key == 13));
        if(~bCancel)
            polylines(end+1) = line([polyx(end),p2(1)],[polyy(end),p2(2)],'EraseMode','xor');
            polyx = [polyx,p2(1)];
            polyy = [polyy,p2(2)];
        end
        tic;
    end
    bCancel = bCancel | (length(polyx)<3);
    if(~bCancel)
        polyx = [polyx, polyx(1)]; % ; added TO
        polyy = [polyy, polyy(1)];
        polylines(end+1) = line([polyx(end-1),polyx(end)],[polyy(end-1),polyy(end)]);

        ndx = length(handles.vcdb.c(clust).polys) + 1;
        handles.vcdb.c(clust).polys{ndx}.xverts = polyx;
        handles.vcdb.c(clust).polys{ndx}.yverts = polyy;
        handles.vcdb.c(clust).polys{ndx}.xfeat = getFeaturePopupValue(handles.popupXFeature, handles.vcdb);
        handles.vcdb.c(clust).polys{ndx}.yfeat = getFeaturePopupValue(handles.popupYFeature, handles.vcdb);
        handles = refreshClusters(handles);
    else
        delete(polylines);
    end
    
    set(hObject, 'BackgroundColor', [236,233,216]./255);
    set(handles.axesFeatureScatter, 'buttonDownFcn', {@axesFeatureScatter_ButtonDownFcn}); 
end
buttonHistogram_Callback(hObject, eventdata, handles); % update histogram
guidata(hObject, handles);

% --- Executes on button press in buttonRemovePolygon.
function buttonRemovePolygon_Callback(hObject, eventdata, handles)
% hObject    handle to buttonRemovePolygon (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
clust = get(handles.popupClusterSelect,'Value');
nVal = get(handles.listboxClusterPolygons,'Value');
if(~isempty(clust) & clust<=length(handles.vcdb.c))
    if(~isempty(nVal))
        handles.vcdb.c(clust).polys(nVal) = [];
        set(handles.listboxClusterPolygons,'Value',[]);
        handles = refreshClusters(handles);
    end
end
guidata(hObject, handles);


% --- Executes on button press in buttonAddSelected.
function buttonAddSelected_Callback(hObject, eventdata, handles)
% hObject    handle to buttonAddSelected (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
clust = get(handles.popupClusterSelect,'Value');
if(~isempty(clust) & clust<=length(handles.vcdb.c))
    handles.vcdb.c(clust).incs{end+1} = handles.vcg.bSel;
    handles = refreshClusters(handles);
end
buttonHistogram_Callback(hObject, eventdata, handles); % update histogram
guidata(hObject, handles);

% --- Executes on button press in buttonRemoveSelected.
function buttonRemoveSelected_Callback(hObject, eventdata, handles)
% hObject    handle to buttonRemoveSelected (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
clust = get(handles.popupClusterSelect,'Value');
if(~isempty(clust) & clust<=length(handles.vcdb.c))
    handles.vcdb.c(clust).excs{end+1} = handles.vcg.bSel;
    handles = refreshClusters(handles);
end
buttonHistogram_Callback(hObject, eventdata, handles); % update histogram
guidata(hObject, handles);

% --- Executes on button press in buttonDeleteManual.
function buttonDeleteManual_Callback(hObject, eventdata, handles)
% hObject    handle to buttonDeleteManual (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
nc = get(handles.popupClusterSelect,'Value');
nVal = get(handles.listboxManualMods,'Value');
sVal = get(handles.listboxManualMods,'String');
if(~isempty(nc) & nc<=length(handles.vcdb.c))
    if(~isempty(nVal))
        %The first 4 letters determine whether we are dealing with includes
        %or excludes.
        field = sVal{nVal}(1:4);
        %The first 6 to end is the index.
        ndx = str2num(sVal{nVal}(6:end));
        handles.vcdb.c(nc).(field)(ndx) = [];
        handles = refreshClusters(handles);
    end
end
buttonHistogram_Callback(hObject, eventdata, handles); % update histogram
guidata(hObject, handles);


% --- Executes on button press in buttonClusterProperties.
function buttonClusterProperties_Callback(hObject, eventdata, handles)
% hObject    handle to buttonClusterProperties (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
nc = get(handles.popupClusterSelect,'Value');
if(~isempty(nc) & nc<=length(handles.vcdb.c))
    prompt = {'Cluster number:','Cluster name:'};
    dlg_title = 'Cluster Properties:';
    num_lines = 1;
    defaults = {num2str(handles.vcdb.c(nc).number),handles.vcdb.c(nc).str};
    answer = inputdlg(prompt,dlg_title,num_lines);
    if(isempty(answer)), return; end
    cNum = str2num(answer{1});
    cName = answer{2};
    if(isempty(cNum) || isempty(cName)), return; end
    handles.vcdb.c(nc).number = cNum;
    handles.vcdb.c(nc).str = cName;
    handles = refreshClusters(handles);
end
buttonHistogram_Callback(hObject, eventdata, handles); % update histogram
guidata(hObject, handles);


% --- Executes on button press in buttonClusterColor.
function buttonClusterColor_Callback(hObject, eventdata, handles)
% hObject    handle to buttonClusterColor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
nc = get(handles.popupClusterSelect,'Value');
if(~isempty(nc) & nc<=length(handles.vcdb.c))
    cColor = uisetcolor('New cluster color:');
    if(isempty(cColor)), return; end
    handles.vcdb.c(nc).color = cColor;
    handles = refreshClusters(handles);
end
buttonHistogram_Callback(hObject, eventdata, handles); % update histogram
guidata(hObject, handles);

function editFilterSetNum_Callback(hObject, eventdata, handles)
% hObject    handle to editFilterSetNum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editFilterSetNum as text
%        str2double(get(hObject,'String')) returns contents of
%        editFilterSetNum as a double
bPerc = (get(handles.popupFilterSetType,'Value')==1);
[num, bOK] = str2num(get(handles.editFilterSetNum, 'String'));
if(~bOK)
    %non-number entered... so reset values.
    if(bPerc)
        set(handles.editFilterSetNum, 'String', '100');
        set(handles.popupFilterSet, 'Value', 1);
        set(handles.popupFilterSet, 'String', {'1'});
    else
        set(handles.editFilterSetNum, 'String', num2str(length(handles.vcdb.d.v)));
        set(handles.popupFilterSet, 'Value', 1);
        set(handles.popupFilterSet, 'String', {'1'});
    end
else
    %valid number entered, adjust number of sets.
    if(bPerc)  
        numer = 100;
    else
        numer = length(handles.vcdb.d.v);
    end
    numSets = min(max(ceil(numer/num),1),handles.vcg.options.maxSets);
    for(nSet = 1:numSets)
        strs{nSet} = num2str(nSet);
    end
    set(handles.popupFilterSet, 'Value', 1);
    set(handles.popupFilterSet, 'String',strs);
end
handles.vcg.bSel = false(size(handles.vcdb.d.v));
handles = refreshScatter(handles);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function editFilterSetNum_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editFilterSetNum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in popupFilterSet.
function popupFilterSet_Callback(hObject, eventdata, handles)
% hObject    handle to popupFilterSet (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupFilterSet contents as cell array
%        contents{get(hObject,'Value')} returns selected item from
%        popupFilterSet
handles.vcg.bSel = false(size(handles.vcdb.d.v));
handles = refreshScatter(handles);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function popupFilterSet_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupFilterSet (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in popupFilterSetType.
function popupFilterSetType_Callback(hObject, eventdata, handles)
% hObject    handle to popupFilterSetType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupFilterSetType contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupFilterSetType
bPerc = (get(handles.popupFilterSetType,'Value')==1);
if(bPerc)
    set(handles.editFilterSetNum, 'String', '100');
    set(handles.popupFilterSet, 'Value', 1);
    set(handles.popupFilterSet, 'String', {'1'});
else
    set(handles.editFilterSetNum, 'String', num2str(length(handles.vcdb.d.v)));
    set(handles.popupFilterSet, 'Value', 1);
    set(handles.popupFilterSet, 'String', {'1'});
end
handles.vcg.bSel = false(size(handles.vcdb.d.v));
handles = refreshScatter(handles);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function popupFilterSetType_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupFilterSetType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in buttonRandomize.
function buttonRandomize_Callback(hObject, eventdata, handles)
% hObject    handle to buttonRandomize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.vcg.bRand = randperm(length(handles.vcdb.d.v))';
handles.vcg.bSel = false(size(handles.vcdb.d.v));
handles = refreshScatter(handles);
guidata(hObject, handles);

% --- Executes on selection change in popupFilterSetFeature.
function popupFilterSetFeature_Callback(hObject, eventdata, handles)
% hObject    handle to popupFilterSetFeature (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupFilterSetFeature contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupFilterSetFeature
if(get(handles.radioFilterOrdered,'Value'))
    handles.vcg.bSel = false(size(handles.vcdb.d.v));
    handles = refreshScatter(handles);
    guidata(hObject, handles);
end

% --- Executes during object creation, after setting all properties.
function popupFilterSetFeature_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupFilterSetFeature (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in radioFilterOrdered.
function radioFilterOrdered_Callback(hObject, eventdata, handles)
% hObject    handle to radioFilterOrdered (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of radioFilterOrdered
handles.vcg.bSel = false(size(handles.vcdb.d.v));
handles = refreshScatter(handles);
guidata(hObject, handles);

% --- Executes on button press in radioFilterRandom.
function radioFilterRandom_Callback(hObject, eventdata, handles)
% hObject    handle to radioFilterRandom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of radioFilterRandom
handles.vcg.bSel = false(size(handles.vcdb.d.v));
handles = refreshScatter(handles);
guidata(hObject, handles);

% --- Executes on button press in buttonDeleteCluster.
function buttonDeleteCluster_Callback(hObject, eventdata, handles)
% hObject    handle to buttonDeleteCluster (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
nc = get(handles.popupClusterSelect,'Value');
if(~isempty(nc) & nc<=length(handles.vcdb.c))
    handles.vcdb.c(nc) = [];
    handles = refreshClusters(handles);
end
buttonHistogram_Callback(hObject, eventdata, handles); % update histogram
guidata(hObject, handles);

% --- Executes on selection change in popupYFeature.
function popupYFeature_Callback(hObject, eventdata, handles)
% hObject    handle to popupYFeature (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupYFeature contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupYFeature
handles.keepLimits = false; %%% TO
handles = refreshScatter(handles);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function popupYFeature_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupYFeature (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in popupXFeature.
function popupXFeature_Callback(hObject, eventdata, handles)
% hObject    handle to popupXFeature (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupXFeature contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupXFeature
handles.keepLimits = false; %%% TO
handles = refreshScatter(handles);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function popupXFeature_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupXFeature (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in popupVectorFeature.
function popupVectorFeature_Callback(hObject, eventdata, handles)
% hObject    handle to popupVectorFeature (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupVectorFeature contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupVectorFeature
handles = refreshVectorPlot(handles);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function popupVectorFeature_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupVectorFeature (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in popupScatterType.
function popupScatterType_Callback(hObject, eventdata, handles)
% hObject    handle to popupScatterType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupScatterType contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupScatterType
handles.vcg.bSel = false(size(handles.vcdb.d.v));
handles = refreshScatter(handles);
handles = refreshVectorPlot(handles);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function popupScatterType_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupScatterType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in popupScatterStyle.
function popupScatterStyle_Callback(hObject, eventdata, handles)
% hObject    handle to popupScatterStyle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupScatterStyle contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupScatterStyle
styleType = get(handles.popupScatterStyle, 'Value');
if(styleType == 4 || styleType == 5)
    [sel, ok] = listdlg('ListString', getAllSFNames(handles.vcdb), 'Name', 'Select a feature to map to color:', 'SelectionMode','single');
    if(ok)
        handles.vcg.feat2colorFeat  = ndx2feature(sel, size(handles.vcdb.d.sf,2));
    else
        handles.vcg.feat2colorFeat  = 1;
    end
end
if(styleType == 4 || styleType == 5)
    cmaps = {'jet','hsv','hot','cool','bone','gray','spring','summer','autumn','winter'};
    [sel, ok] = listdlg('ListString', cmaps , 'Name', 'Select a color map:', 'SelectionMode','single');
    if(ok)
        handles.vcg.feat2colorMap  = eval([cmaps{sel},'(256);']);
    else
        handles.vcg.feat2colorMap  = jet;
    end
end
if(styleType == 4)
    minF = min(getSF(handles.vcdb, handles.vcg.feat2colorFeat));
    maxF = max(getSF(handles.vcdb, handles.vcg.feat2colorFeat));
    prompt = {['What is minimum mapped feature value (',num2str(minF),'):'], ['What is maximum mapped feature value (',num2str(maxF),'):']};    
    dlg_title = 'Choose the color range';
    num_lines = 1;
    default = {num2str(minF),num2str(maxF)};
    answer = inputdlg(prompt,dlg_title,num_lines,default);    
    if(isempty(answer))
        handles.vcg.feat2colorRange = [minF,maxF];
    else
        handles.vcg.feat2colorRange = [str2num(answer{1}),str2num(answer{2})];
        if(length(handles.vcg.feat2colorRange)~=2)
            handles.vcg.feat2colorRange = [minF,maxF];
        end
    end
end
%handles.vcg.bSel = false(size(handles.vcdb.d.v));
handles = refreshScatter(handles);
handles = refreshVectorPlot(handles);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function popupScatterStyle_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupScatterStyle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in popupVectorType.
function popupVectorType_Callback(hObject, eventdata, handles)
% hObject    handle to popupVectorType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupVectorType contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupVectorType
handles = refreshVectorPlot(handles);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function popupVectorType_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupVectorType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in buttonPrev.
function buttonPrev_Callback(hObject, eventdata, handles)
% hObject    handle to buttonPrev (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%NOT SURE ABOUT CURRENT FUNCATIONALITY:
% FLIP THROUGH ITEMS IN SELECTION?
% OR MAKE SELECTION EQUAL TO NEXT VISABLE AND DRAWABLE ITEM
% OR ??
% ndx = min(find(handles.vcg.bSel));
% if(ndx-1>=1)
%     bSel = false(size(handles.vcg.bSel));
%     bSel(ndx-1) = true;    
%     handles = refreshScatterSelection(handles);
%     handles = refreshVectorSelection(handles);
%     guidata(hObject, handles);
% end

% --- Executes on button press in buttonNext.
function buttonNext_Callback(hObject, eventdata, handles)
% hObject    handle to buttonNext (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%NOT SURE ABOUT CURRENT FUNCATIONALITY:
% FLIP THROUGH ITEMS IN SELECTION?
% OR MAKE SELECTION EQUAL TO NEXT VISABLE AND DRAWABLE ITEM
% OR ??
% ndx = max(find(handles.vcg.bSel));
% if(ndx+1<=length(handles.vcg.bSel))
%     bSel = false(size(handles.vcg.bSel));
%     bSel(ndx+1) = true;
%     handles = refreshScatterSelection(handles);
%     handles = refreshVectorSelection(handles);
%     guidata(hObject, handles);
% end

% --- Executes on button press in buttonSaveClusters.
function buttonSaveClusters_Callback(hObject, eventdata, handles)
% hObject    handle to buttonSaveClusters (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%get a filename
[file,path] = uiputfile('*.mat',' cluster polygons:');
if(isequal(file,0))
    return;
end
%Prepare clusters for export.
c = handles.vcdb.c;
f = handles.vcdb.f; % will be saved to file
for nc = 1:length(c)
    %Manual includes and excludes are not exportable.
    c(nc).incs = {};
    c(nc).excs = {};
    %Add feature names to the cluster definition.
    for np = 1:length(c(nc).polys)
        c(nc).polys{np}.xfeatName = getsfname(handles.vcdb, c(nc).polys{np}.xfeat);
        c(nc).polys{np}.yfeatName = getsfname(handles.vcdb, c(nc).polys{np}.yfeat);
    end
end
save([path,filesep,file], 'c', 'f');
guidata(hObject, handles);


% --- Executes on button press in buttonLoadClusters.
function buttonLoadClusters_Callback(hObject, eventdata, handles)
% hObject    handle to buttonLoadClusters (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if(isempty(handles.vcdb.d.v))
    warndlg('Vector data must be loaded/imported before cluster polygons.');
    return;   
end

button = 'Overwrite';
if(~isempty(handles.vcdb.c))
    button = questdlg('Clusters have already been defined.  Would you like to:','Cluster Import','Overwrite','Augment','Cancel','Cancel');
    if(strcmpi(button,'Cancel') || strcmpi(button,''))
        return;
    end
end

[file,path] = uigetfile('*.mat','Import cluster polygons:');
if(isequal(file,0))
    return;
end

handles.vcdb = vcdbloadpolys(handles.vcdb, [path filesep file]);

handles = refreshAll(handles);
guidata(hObject, handles);



% --- Executes on mouse press over axes background.
function axesFeatureScatter_ButtonDownFcn(hObject, eventdata)
% hObject    handle to axesFeatureScatter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = guidata(hObject);
mouseMode = get(gcbf, 'SelectionType');
p1 = get(handles.axesFeatureScatter, 'CurrentPoint');
p1 = p1(1,1:2);
axes(handles.axesFeatureScatter);

if(strcmp(mouseMode,'normal')) % drag
    rect = rbbox;
    p2 = get(gca,'CurrentPoint'); 
    p2 = p2(1,1:2);
    ll = min(p1,p2);             
    ur = max(p1,p2);
    offset = abs(ur-ll); 
    if(ur(1)>ll(1) && ur(2)>ll(2))
        xlim([ll(1),ur(1)]); 
        ylim([ll(2),ur(2)]); 
    end
elseif(strcmp(mouseMode,'open')) % double click
    axis tight; % zoom out
elseif(strcmp(mouseMode,'alt')) % right click (Ctrl + click)
    %get the rectangle
    rect = rbbox;
    p2 = get(gca,'CurrentPoint'); 
    p2 = p2(1,1:2);
    ll = min(p1,p2);             
    ur = max(p1,p2);

    %find points in rectangle
    d = handles.vcdb.d;
    xfeat = getFeaturePopupValue(handles.popupXFeature, handles.vcdb);
    yfeat = getFeaturePopupValue(handles.popupYFeature, handles.vcdb);
    bSel = getSF(handles.vcdb, xfeat)>ll(1) & getSF(handles.vcdb, xfeat)<ur(1) & getSF(handles.vcdb, yfeat)>ll(2) & getSF(handles.vcdb, yfeat)<ur(2);
    handles.vcg.bSel = bSel & handles.vcg.bDraw & handles.vcg.bFilt;
    handles = refreshScatterSelection(handles);
    handles = refreshVectorSelection(handles);
end
guidata(hObject, handles);

% --- Executes on mouse press over axes background.
function scatterPoint_ButtonDownFcn(hObject, eventdata)
% hObject    handle to axesFeatureScatter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = guidata(hObject);
ndx = get(hObject, 'UserData');
%handles.vcg.bSel(ndx) = ~handles.vcg.bSel(ndx); % reverse selection
cla(handles.axesVector); %%% TO
handles.vcg.bSel = false(size(handles.vcg.bDraw)); %%% TO
handles.vcg.bSel(ndx) = true; % cursrently selected
handles = refreshScatterSelection(handles);
handles = refreshVectorSelection(handles);
guidata(handles.axesVector, handles);

% --- Executes on mouse press over axes background.
function axesVector_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to axesVector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = guidata(hObject);
mouseMode = get(gcbf, 'SelectionType');
p1 = get(handles.axesVector, 'CurrentPoint');
p1 = p1(1,1:2);
axes(handles.axesVector);

if(strcmp(mouseMode,'normal')) % left click
    rect = rbbox;
    p2 = get(gca,'CurrentPoint'); 
    p2 = p2(1,1:2);
    ll = min(p1,p2);             
    ur = max(p1,p2);
    offset = abs(ur-ll); 
    if(ur(1)>ll(1) && ur(2)>ll(2))
        xlim([ll(1),ur(1)]); 
        ylim([ll(2),ur(2)]); 
    end
elseif(strcmp(mouseMode,'open')) % double click
    axis tight;
elseif(strcmp(mouseMode,'alt')) % right click
    if(~isempty(handles.vcg.hVect)) %&& strcmp(get(handles.menuDisplayOnlySelectedVectors,'Checked'),'off')
        %get the rectangle
        rect = rbbox;
        p2 = get(gca,'CurrentPoint'); 
        p2 = p2(1,1:2);
        ll = min(p1,p2);             
        ur = max(p1,p2);

        %get the currently visible vectors
        bVis = handles.vcg.bDraw & handles.vcg.bFilt;
        if(strcmp(get(handles.menuDisplayOnlySelectedVectors,'Checked'),'on'))
            bVis = handles.vcg.bSel & bVis;
        end
        
        %find which visible vectors are in the rectangle.
        vm = handles.vcg.mVectMat;
        vm = vm(floor(ll(1)):ceil(ur(1)), :);
        bVisSel = any(vm>ll(2) & vm<ur(2), 1); %has length of bVis.
        
        if(strcmp(get(handles.menuDisplayOnlySelectedVectors,'Checked'),'on'))
            handles.vcg.bSel(bVis) = ~bVisSel;
        else
            handles.vcg.bSel(bVis) = bVisSel;
        end
        handles = refreshScatterSelection(handles);
        handles = refreshVectorSelection(handles);
    end
end
guidata(hObject, handles);


% --- Update the entire gui based on new clusters and vectors.
function handles = refreshAll(handles)
if(~isempty(handles.vcdb.d.v))
    %Set up feature popups:
    featureNames = allsfnames(handles.vcdb);
    set(handles.popupXFeature,'String', featureNames);
    if(get(handles.popupXFeature,'Value')>length(featureNames))
        set(handles.popupXFeature,'Value',1);
    end
    set(handles.popupYFeature,'String', featureNames);
    if(get(handles.popupYFeature,'Value')>length(featureNames))
        set(handles.popupYFeature,'Value',1); %%% change?
    end
    set(handles.popupFilterSetFeature,'String',[{'none'}; handles.vcdb.f.sfname]);
    if(get(handles.popupFilterSetFeature,'Value')>length(handles.vcdb.f.sfname)+1)
        set(handles.popupFilterSetFeature,'Value',1);
    end    
    set(handles.popupVectorFeature, 'String', [{'vectors'}; handles.vcdb.f.vfname]);
    if(get(handles.popupVectorFeature,'Value')>length(handles.vcdb.f.vfname))
        set(handles.popupVectorFeature,'Value',1);
    end
    
    %Set up cluster related popups:
    clustStrs = cell(length(handles.vcdb.c) + 1,1);
    for nc = 1:length(handles.vcdb.c)
        c = handles.vcdb.c(nc);
        clustStrs{nc} = ['<HTML><FONT bgCOLOR=#', rgbconv(c.color),'>',num2str(c.number),':',c.str,'</FONT></HTML>'];
    end
    clustStrs{end} = 'New Cluster';
    set(handles.popupClusterSelect,'String',clustStrs);
    set(handles.popupClusterSelect,'Value',1);
    handles = refreshClusters(handles);
end

% --- Refresh clusters.
function handles = refreshClusters(handles)
if(~isempty(handles.vcdb.d.v))
    d = handles.vcdb.d;
    c = handles.vcdb.c;
    
    %construct cluster popup
    sVal = {};
    for nc = 1:length(c)
        sVal{nc} = ['<HTML><FONT bgCOLOR=#', rgbconv(c(nc).color),'>',num2str(c(nc).number),':',c(nc).str,'</FONT></HTML>'];    
    end
    sVal{end+1} = 'New Cluster';
    set(handles.popupClusterSelect,'String',sVal);
    nc = get(handles.popupClusterSelect,'Value');
    if(nc>length(c))
        set(handles.popupClusterSelect,'Value',1);
    end
        
    
    %Assign vectors to clusters
    handles.vcdb = vcdbcluster(handles.vcdb);
    
    handles = refreshSelectedCluster(handles);
end

% --- Update the selected cluster.
function handles = refreshSelectedCluster(handles)
nc = get(handles.popupClusterSelect,'Value');
if(nc <= length(handles.vcdb.c))
    %set up polygon listbox.
    polyStrs = cell(length(handles.vcdb.c(nc).polys),1);
    for(nPoly = 1:length(handles.vcdb.c(nc).polys))
        poly = handles.vcdb.c(nc).polys{nPoly};
        polyStrs{nPoly} = [num2str(nPoly),' : ', getsfname(handles.vcdb, poly.xfeat),' x ', getsfname(handles.vcdb, poly.yfeat)];        
    end
    set(handles.listboxClusterPolygons, 'Value',1);
    set(handles.listboxClusterPolygons, 'String',polyStrs);
    
    %set up manual modification listbox
    modsStrs = {};
    for(nIncs = 1:length(handles.vcdb.c(nc).incs))
        modsStrs{end+1} = ['incs_', num2str(nIncs)];        
    end
    for(nExcs = 1:length(handles.vcdb.c(nc).excs))
        modsStrs{end+1} = ['excs_', num2str(nExcs)];        
    end
    set(handles.listboxManualMods, 'Value',1);
    set(handles.listboxManualMods, 'String',modsStrs);
else
    set(handles.listboxClusterPolygons, 'Value',[]);
    set(handles.listboxClusterPolygons, 'String',{});    
    set(handles.listboxManualMods, 'Value',[]);
    set(handles.listboxManualMods, 'String',{});
end

%%% avoid pan out
axes(handles.axesFeatureScatter);
handles.xlim = xlim;
handles.ylim = ylim;
handles.keepLimits = true;

handles = refreshScatter(handles);
handles = refreshVectorPlot(handles);


% --- Update the scatter axes.
function handles = refreshScatter(handles)
set(gcf,'Renderer','OpenGL'); % optimaze speed. Try painters or zbuffer for more accurate image (TO)

d = handles.vcdb.d;
c = handles.vcdb.c;
xfeat = getFeaturePopupValue(handles.popupXFeature, handles.vcdb);
yfeat = getFeaturePopupValue(handles.popupYFeature, handles.vcdb);

%Apply subset / filter
handles.vcg.bFilt = computeFilterVector(handles);
    
%Determine which vectors should be drawn (independant of filter/subset)
handles.vcg.bDraw = computeDrawVector(handles);

%Determine the current color and size and marker type of each vector
[mcolor, msize, mstyle] = computeScatterStyle(handles);

%draw the markers
bVis = handles.vcg.bDraw & handles.vcg.bFilt & ~isnan(getSF(handles.vcdb,xfeat)) & ~isnan(getSF(handles.vcdb,yfeat));
axes(handles.axesFeatureScatter);
hold off;
% screenImage = zeros(xPix, yPix, 3) color code
% N = size(handles.vcdb.d.cn,1); % number of points
% for n=1:N
%   handles.vcdb.d(n).cn    
% end
%codes which changes the pixeles in the screen image.
%image(screenImage);
handles.vcg.hScat = scatter(getSF(handles.vcdb,xfeat,bVis), getSF(handles.vcdb,yfeat,bVis), msize(bVis), mcolor(bVis,:));

xl = xlim; % expand the axis TO
yl = ylim; % expand the axis TO
xlim([xl(1)*0.9 xl(2)*1.1]); % expand the axis TO
ylim([yl(1)*0.9 yl(2)*1.1]); % expand the axis TO

if isfield(handles,'keepLimits') && handles.keepLimits
    xlim(handles.xlim); %%% TO
    ylim(handles.ylim); %%% TO
end
scatChildren = get(handles.vcg.hScat,'Children');
scatChildren = scatChildren(end:-1:1);
set(scatChildren, {'Marker'}, mstyle(bVis));

%Configure markers to be clickable.
set(scatChildren,{'UserData'},mat2cell(find(bVis),ones(sum(bVis),1)));
set(scatChildren,'buttonDownFcn', {@scatterPoint_ButtonDownFcn});
set(scatChildren,'HitTest','on');

%draw any polygon in view
cc = get(handles.popupClusterSelect,'Value');
np = get(handles.listboxClusterPolygons,'Value');
for(nc = 1:length(handles.vcdb.c))
    for(nPoly = 1:length(handles.vcdb.c(nc).polys))
        poly = handles.vcdb.c(nc).polys{nPoly};
        if((poly.xfeat==xfeat) && (poly.yfeat==yfeat))
            hp = patch(poly.xverts,poly.yverts,'black','FaceColor','none','EdgeColor',handles.vcdb.c(nc).color); 
        elseif((poly.xfeat==yfeat) && (poly.yfeat==xfeat))
            hp = patch(poly.yverts,poly.xverts,'black','FaceColor','none','EdgeColor',handles.vcdb.c(nc).color);
        else
            hp = [];
        end
        if(~isempty(hp)) 
            set(hp,'HitTest','off');
            if(nc==cc && np==nPoly)
                set(hp,'LineWidth',2);
            end
        end
    end
end

handles = refreshScatterSelection(handles);
set(handles.axesFeatureScatter, 'buttonDownFcn', {@axesFeatureScatter_ButtonDownFcn}); 

% --- Compute bFilt based on subsetting and filtering
function bFilt = computeFilterVector(handles)
d = handles.vcdb.d;
c = handles.vcdb.c;
bFilt = false(size(d.v));
ndxPerm = [1:length(d.v)]';
ndxSet = ndxPerm;
[nSetSize,bOk] = str2num(get(handles.editFilterSetNum,'String'));
%Check if valid set size
if(bOk & (nSetSize > 0))
    %First get the order from which sets will be divided.
    if(get(handles.radioFilterOrdered,'Value'))
        nFeat = get(handles.popupFilterSetFeature, 'Value') - 1;
        if(nFeat > 0)
            [junk, ndxPerm] = sort(getSF(handles.vcdb,nFeat));
        end
    elseif(get(handles.radioFilterRandom,'Value'))
        if(~isfield(handles.vcg, 'bRand') || (length(handles.vcg.bRand)~=length(d.v)))
            handles.vcg.bRand = randperm(length(d.v))';
        end
        ndxPerm = handles.vcg.bRand;
    end
    %Next get the selected set
    nSet = get(handles.popupFilterSet, 'Value');
    bPerc = (get(handles.popupFilterSetType,'Value')==1);
    if(bPerc)        
        numPerSet = ceil(length(d.v) * (nSetSize/100));
    else
        numPerSet = ceil(nSetSize);
    end
    if(length(d.v)>0)
        ndxStart = min(length(d.v), (nSet-1)*numPerSet + 1);
        ndxEnd = min(length(d.v), nSet*numPerSet);
        ndxSet = ndxPerm(ndxStart:ndxEnd);
    else
        ndxSet = [];
    end
end
bFilt(ndxSet) = true;

% --- Compute bDraw based on the "WHICH" popup ---------------------
function bDraw = computeDrawVector(handles)
d = handles.vcdb.d;
c = handles.vcdb.c;
scatType = get(handles.popupScatterType, 'Value');
bDraw = false(size(d.v));
switch scatType
    case 1 %all
        bDraw = true(size(d.v));
    case 2 %clustered
        bDraw = ~isnan(d.cn);
    case 3 %unclustered
        bDraw = isnan(d.cn);
    case 4 %only selected clustered
        nc = get(handles.popupClusterSelect,'Value');
        %nc=1; %% TO
        bDraw = (d.cn==c(nc).number);
%     case 5 % IsMask TO
%         temp1 = strcmp(handles.vcdb.f.sfname(:),'IsMask');
%         if ~isempty(temp1)
%             featureNum1 = find(temp1);
%         else
%             error('No IsMask feature')
%         end
%         bDraw1 = d.sf(:,featureNum1);
%         temp2 = strcmp(handles.vcdb.f.sfname(:),'IsStim');
%         if ~isempty(temp2)
%             featureNum2 = find(temp2);
%         else
%             error('No IsStim feature')
%         end
%         bDraw2 = d.sf(:,featureNum2);
%         bDraw = bDraw1 | bDraw2;
    otherwise
end

% --- Compute the color size and shape of each vector on the scatter plot -
function [mcolor,msize,mstyle] = computeScatterStyle(handles)
d = handles.vcdb.d;
c = handles.vcdb.c;
styleType = get(handles.popupScatterStyle, 'Value');
mcolor = repmat(handles.vcg.options.unclusteredColor,size(d.v));
msize = repmat(handles.vcg.options.unclusteredSize,length(d.v),1);
mstyle = repmat({handles.vcg.options.unclusteredMarker}, length(d.v),1);
switch styleType
    case 1 % style by cluster
        for(nc = 1:length(c))
            bIN = d.cn==c(nc).number;
            mcolor(bIN,:) = repmat(c(nc).color,sum(bIN),1);
            msize(bIN,:) = repmat(handles.vcg.options.unclusteredSize, sum(bIN),1); %clusters don't yet have a size
            mstyle(bIN,:) = repmat({handles.vcg.options.unclusteredMarker},sum(bIN),1); %clusters don't yet have a style
        end     
    case 2 % unstyled       
    case 3 % style selected cluster only
        nc = get(handles.popupClusterSelect,'Value');
        bIN = d.cn==c(nc).number;
        mcolor(bIN,:) = repmat(c(nc).color,sum(bIN),1);
        msize(bIN,:) = repmat(handles.vcg.options.unclusteredSize, sum(bIN),1); %clusters don't yet have a size
        mstyle(bIN,:) = repmat({handles.vcg.options.unclusteredMarker},sum(bIN),1); %clusters don't yet have a style    
    case 4 % color by feature value
        f2cF = handles.vcg.feat2colorFeat;
        f2cM = handles.vcg.feat2colorMap;
        f2cR = handles.vcg.feat2colorRange;
        colorVal = getSF(handles.vcdb,f2cF);
        colorVal = (colorVal - f2cR(1)) ./ (f2cR(2)-f2cR(1));
        colorVal(colorVal<0) = 0;
        colorVal(colorVal>1) = 1;
        colorVal = round(colorVal*(length(f2cM)-1) + 1);
        colorVal(isnan(colorVal)) = 256;
        mcolor = f2cM(colorVal,:);
    case 5 % color by feature sort order
        f2cF = handles.vcg.feat2colorFeat;
        f2cM = handles.vcg.feat2colorMap;
        [junk, colorVal] = sort(getSF(handles.vcdb,f2cF));
        colorVal = (colorVal-1) ./ (length(colorVal)-1);
        colorVal = round(colorVal*(length(f2cM)-1) + 1);
        mcolor = f2cM(colorVal,:);
    case 6 % mask (blue), stim (red)
        %nc = get(handles.popupClusterSelect,'Value');
        %bIN = d.cn==c(nc).number;
        temp1 = strcmp(handles.vcdb.f.sfname(:),'IsMask');
        if ~isempty(temp1)
            featureNum1 = find(temp1);
        else
            error('No IsMask feature')
        end
        IsMask = logical(d.sf(:,featureNum1));
        %IsMask = logical(d.sf(:,featureNum1)) & bIN;
        temp2 = strcmp(handles.vcdb.f.sfname(:),'IsStim');
        if ~isempty(temp2)
            featureNum2 = find(temp2);
        else
            error('No IsStim feature')
        end
        IsStim = logical(d.sf(:,featureNum2));
        %IsStim = logical(d.sf(:,featureNum2)) & bIN;
        mcolor(IsMask,:) = repmat([0,0,1],sum(IsMask),1); % mask in blue
        mcolor(IsStim,:) = repmat([1,0,0],sum(IsStim),1); % stim in red
    otherwise
end

% --- Update the vector axes.
function handles = refreshVectorPlot(handles)
d = handles.vcdb.d;
xfeat = getFeaturePopupValue(handles.popupXFeature, handles.vcdb);
yfeat = getFeaturePopupValue(handles.popupYFeature, handles.vcdb);

%Get the appropriate vectors
vfeat = get(handles.popupVectorFeature,'Value');
if(vfeat == 1)
    vects = d.v; % vector itself
else % other vector features
    vects = d.vf{vfeat-1};
end

%Apply subset / filter
handles.vcg.bFilt = computeFilterVector(handles); 
%Determine which vectors should be drawn (independant of filter/subset)
handles.vcg.bDraw = computeDrawVector(handles);
%Determine the current color and size and marker type of each vector
[mcolor, msize, mstyle] = computeScatterStyle(handles);
ccolor = mat2cell(mcolor,ones(length(mcolor),1), 3);

bVis = handles.vcg.bDraw & handles.vcg.bFilt  & ~isnan(getSF(handles.vcdb,xfeat)) & ~isnan(getSF(handles.vcdb,yfeat));
%If only show selected:
if(strcmp(get(handles.menuDisplayOnlySelectedVectors,'Checked'),'on'))
    bVis = bVis & handles.vcg.bSel;
end

%Preprocess and align visible vectors:
[vectMat, status] = preprocessAndAlignVectors(vects(bVis),handles);
if(strcmp(status,'OutOfMemory'))
    axes(handles.axesVector);
    text(mean(xlim),mean(ylim),'Too Much To Plot','HorizontalAlignment','center','Color','red','FontSize',20);
    return;
end

if(~isempty(vectMat))  
    nVectorPlotType = get(handles.popupVectorType,'Value');
    axes(handles.axesVector);
    hold off;
    
    %vectMat = OutlierRemoval(vectMat,100,false); % TO
    
    vectMat = vectMat';
    %%% stop here
    switch nVectorPlotType
        case {1,8,9,10} % raw          
            if(nVectorPlotType == 8) % residuals from mean
                vectMat = vectMat - repmat(nanmean(vectMat,2), 1, size(vectMat,2));               
            elseif(nVectorPlotType == 9) % residuals from median
                vectMat = vectMat - repmat(nanmedian(vectMat,2), 1, size(vectMat,2));
            elseif(nVectorPlotType == 10) % diff
                vectMat = diff(vectMat);
            end
            
            handles.vcg.hVect = plot(vectMat);
            handles.vcg.mVectMat = vectMat;
            set(handles.vcg.hVect, {'Color'}, ccolor(bVis));

            %Configure markers to be clickable.
            set(handles.vcg.hVect,{'UserData'},mat2cell(find(bVis),ones(sum(bVis),1)));
            set(handles.vcg.hVect,'buttonDownFcn', {@scatterPoint_ButtonDownFcn});
            set(handles.vcg.hVect,'HitTest','on');

            if(~strcmp(get(handles.menuDisplayOnlySelectedVectors,'Checked'),'on'))
                handles = refreshVectorSelection(handles);
            end
        case 2 % Specgram of mean
            mu = nanmean(vectMat,2);
            mu = mu(~isnan(mu));
            sp = handles.vcg.specgram;
            displaySpecgramQuick(mu, sp.fs, sp.freqRange, sp.colorRange);
            handles.vcg.hVect = [];
        case 3 % mean
            mu = nanmean(vectMat,2);
            plot(mu,'LineWidth', 3, 'Color', 'black');
            handles.vcg.hVect = [];
            
            if get(handles.popupScatterStyle, 'Value') == 6; % mask and stim
                nc = get(handles.popupClusterSelect,'Value');
                bIN = d.cn==handles.vcdb.c(nc).number;
                temp1 = strcmp(handles.vcdb.f.sfname(:),'IsMask');
                if ~isempty(temp1)
                    featureNum1 = find(temp1);
                else
                    error('No IsMask feature')
                end
                IsMask = logical(d.sf(:,featureNum1)) & bIN;
                temp2 = strcmp(handles.vcdb.f.sfname(:),'IsStim');
                if ~isempty(temp2)
                    featureNum2 = find(temp2);
                else
                    error('No IsStim feature')
                end
                IsStim = logical(d.sf(:,featureNum2)) & bIN;
                
                % for control
                %IsMask = ~logical(d.sf(:,featureNum2)) & bIN;
                
                MaskNum = find(IsMask); % index of IsMask
                StimNum = find(IsStim); % index of IsStim
                vectMatMask = vectMat(:,MaskNum);
                vectMatStim = vectMat(:,StimNum);
                muMask = nanmean(vectMatMask,2);
                muStim = nanmean(vectMatStim,2);
                axes(handles.axesVector);
                hold on
                plot(muMask,'Linewidth',3,'color','b');
                plot(muStim,'Linewidth',3,'color','r');
                hold off
%                 MaskL = floor(length(MaskNum)/2); % divide data into first and second half
%                 StimL = floor(length(StimNum)/2); % divide data into first and second half
%                 FirstMask = MaskNum(1:MaskL);
%                 SecondMask = MaskNum(MaskL+1:end);
%                 FirstStim = StimNum(1:StimL);
%                 SecondStim = StimNum(StimL+1:end);
% 
%                 vectMatFirstMask = vectMat(:,FirstMask);
%                 vectMatSecondMask = vectMat(:,SecondMask);
%                 vectMatFirstStim = vectMat(:,FirstStim);
%                 vectMatSecondStim = vectMat(:,SecondStim);
%                 
%                 muFirstMask = nanmean(vectMatFirstMask,2);
%                 muSecondMask = nanmean(vectMatSecondMask,2);
%                 muFirstStim = nanmean(vectMatFirstStim,2);
%                 muSecondStim = nanmean(vectMatSecondStim,2);
%                 hold on
%                 plot(muFirstMask,'Linewidth',3,'color','b','linestyle',':');
%                 plot(muSecondMask,'Linewidth',3,'color','b','linestyle','-');
%                 plot(muFirstStim,'Linewidth',3,'color','r','linestyle',':');
%                 plot(muSecondStim,'Linewidth',3,'color','r','linestyle','-');
%                 hold off
            end
            
        case 4 % median
            med = nanmedian(vectMat,2);
            plot(med,'LineWidth', 3, 'Color', 'black');
            handles.vcg.hVect = []; 
        case 5  % mean with std error
            mu = nanmean(vectMat,2);
            std = nanstd(vectMat,0,2);
            cnt = nansum(~isnan(vectMat),2);
            ste = std ./ sqrt(cnt);
            errorbar(mu,ste,'LineWidth', 1, 'Color', 'blue');            
            hold on;
            plot(mu,'LineWidth', 3, 'Color', 'black');
            handles.vcg.hVect = []; 
        case 6 % mean with std dev
            mu = nanmean(vectMat,2);
            std = nanstd(vectMat,0,2);            
            errorbar(mu,std,'LineWidth', 1, 'Color', 'blue');
            hold on;
            plot(mu,'LineWidth', 3, 'Color', 'black');                     
            handles.vcg.hVect = []; 
        case 7 % standard deviation
            std = nanstd(vectMat,0,2);            
            plot(std,'LineWidth', 3, 'Color', 'black');
            handles.vcg.hVect = [];
        case 11 % value overlayed on top of spectrogram (TO)
            %%% TO DO: have two y-axes, don't take the mean
            SyllNum = find(handles.vcg.bSel);
            FeatureList = get(handles.popupVectorFeature,'String');
            if ~strcmp(FeatureList(vfeat),'vectors') % not amplitude
                %axes(handles.axesVector);
                sp = handles.vcg.specgram; 
                SyllAudio = handles.vcdb.d.v{SyllNum(1)};                
                if ~strcmp(FeatureList(vfeat),'pitch') % rescale value for features other than pitch
                    lm(1) = floor(min(vectMat));
                    lm(2) = ceil(max(vectMat));
                    yl = ylim;
                    vectMat = (vectMat-lm(1))/(lm(2)-lm(1)); % change y-scale to match that of the sonogram
                    vectMat = vectMat*(yl(2)-yl(1))+yl(1);
                end
                [Pitch,PG,HP,Time,Entropy] = estimatePitch(SyllAudio,sp.fs); % just to get the time vector for vector features TO
                hold on
                displaySpecgramQuick(SyllAudio, sp.fs, sp.freqRange, sp.colorRange);
                plot(Time,vectMat,'r','linewidth',4);
                hold off   
            end
         
            handles.vcg.hVect = [];
    end
else
    axes(handles.axesVector);
    cla;
end
set(handles.axesVector, 'buttonDownFcn', {@axesVector_ButtonDownFcn});  

% ----Preprocess and align vectors ---
function [vectMat, status] = preprocessAndAlignVectors(vects, handles)
status = '';

%Stretch or resample.
if(strcmp(get(handles.menuStretchAlignVectors,'Checked'),'on'))
    %Stretch vectors
    if(~handles.vcg.stretch.bFast)
        len = cellfun(@length,vects,'UniformOutput',false);
        vects = cellfun(@resample,vects,repmat({handles.vcg.stretch.n}, size(vects)),len,'UniformOutput',false);
    else
        len = cellfun(@length,vects);
        for nVect = 1:length(vects)
            rendx = round(linspace(1,len(nVect),handles.vcg.stretch.n));
            vects{nVect} = vects{nVect}(rendx);
        end
    end
elseif(strcmp(get(handles.menuSubsampleVectors,'Checked'),'on'))
    %Resample the vectors
    if(~handles.vcg.subsamp.bFast)
        vects = cellfun(@resample,vects,repmat({handles.vcg.subsamp.p}, size(vects)),repmat({handles.vcg.subsamp.q}, size(vects)),'UniformOutput',false);
    else
        len = cellfun(@length,vects);
        newlen = ceil(len.*(handles.vcg.subsamp.p/handles.vcg.subsamp.q));
        for nVect = 1:length(vects)
            rendx = round(linspace(1,len(nVect),newlen(nVect)));
            vects{nVect} = vects{nVect}(rendx);
        end
    end
end

%Get alignment
align = -1;
if(strcmp(get(handles.menuCenterAlignVectors,'Checked'),'on'))
    align = 0;
elseif(strcmp(get(handles.menuRightAlignVectors,'Checked'),'on'))
    align = 1;
end

%construct vector matrix
len = cellfun(@length,vects);
mlen = max(len);
try
    vectMat = nan(length(vects),mlen);
catch
    status = 'OutOfMemory';
end
for nVect = 1:length(vects)
    if(align==-1) %left
        vectMat(nVect,1:len(nVect)) = vects{nVect};
    elseif(align==0) %center
        sndx = floor((mlen - len(nVect))/2)+1;
        vectMat(nVect,sndx:sndx+len(nVect)-1) = vects{nVect};        
    elseif(align==1) %right
        vectMat(nVect,mlen-len(nVect)+1:mlen) = vects{nVect};
    end
end

%Eliminate Outliers
if(strcmp(get(handles.menuVectorOutlierRange,'Checked'),'on'))
    vectMat(vectMat<handles.vcg.vectRange(1) & vectMat>handles.vcg.vectRange(2)) = nan;
end

% --- Refresh the selection
function handles = refreshScatterSelection(handles)
%If, in the future, selection involves chaniging color or size...
%[mcolor, msize] = computeScatterStyle(handles);
%msize(handles.vcg.bSel,:) = msize(handles.vcg.bSel,:) * 2;
%mcolor(handles.vcg.bSel,:) = 1 - ((1 - mcolor(handles.vcg.bSel,:))./2);
%WARNING IF YOU CHANGE A PROPERTY ON THE SCATTERGROUP, the Children
%handles change and individual properties are lost.  have to change children properies. 
%hc = get(handles.vcg.hScat,'Children');
%[junk,ndx] = sort([get(hc,'UserData')]);
%hc = hc(ndx);
%set(hc, {'MarkerEdgeColor'}, mat2cell(mcolor(bVis,:));
%set(hc, {'MarkerEdgeColor'}, mat2cell(mcolor(bVis,:));
d = handles.vcdb.d;
xfeat = getFeaturePopupValue(handles.popupXFeature, handles.vcdb);
yfeat = getFeaturePopupValue(handles.popupYFeature, handles.vcdb);

hc = get(handles.vcg.hScat,'Children');
if(~isempty(hc))
    if(length(hc)>1)
        [junk,ndx] = sort(cell2mat(get(hc,'UserData')));
        hc = hc(ndx);
    end
    bVis = handles.vcg.bDraw & handles.vcg.bFilt & ~isnan(getSF(handles.vcdb,xfeat)) & ~isnan(getSF(handles.vcdb,yfeat));
    oldface = get(hc,'MarkerFaceColor');
    if(length(hc)==1)
        oldface = {oldface};
    end
    newface = repmat({'none'},size(handles.vcdb.d.v));
    newface(handles.vcg.bSel) = repmat({'flat'},sum(handles.vcg.bSel),1);
    newface = newface(bVis);
    bDelta = ~cellfun(@isequal, oldface, newface);
    set(hc(bDelta), {'MarkerFaceColor'}, newface(bDelta));
end

% --- Refresh the selection
function handles = refreshVectorSelection(handles)
d = handles.vcdb.d;
xfeat = getFeaturePopupValue(handles.popupXFeature, handles.vcdb);
yfeat = getFeaturePopupValue(handles.popupYFeature, handles.vcdb);

if(strcmp(get(handles.menuDisplayOnlySelectedVectors,'Checked'),'on'))
    handles = refreshVectorPlot(handles);
elseif(~isempty(handles.vcg.hVect))
    %Update vector selection
    hc = handles.vcg.hVect;
    bVis = handles.vcg.bDraw & handles.vcg.bFilt & ~isnan(getSF(handles.vcdb,xfeat)) & ~isnan(getSF(handles.vcdb,yfeat));
    oldwidth = get(hc,'LineWidth');
    if(length(hc)==1)
        oldwidth = {oldwidth};
    end
    newwidth = repmat({1},size(handles.vcdb.d.v));
    newwidth(handles.vcg.bSel) = repmat({2},sum(handles.vcg.bSel),1);
    newwidth = newwidth(bVis);
    bDelta = ~cellfun(@isequal, oldwidth, newwidth);
    set(hc(bDelta), {'LineWidth'}, newwidth(bDelta));
end


% --------------------------------------------------------------------
function axesVectorMenu_Callback(hObject, eventdata, handles)
% hObject    handle to axesVectorMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function menuLeftAlignVectors_Callback(hObject, eventdata, handles)
% hObject    handle to menuLeftAlignVectors (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.menuLeftAlignVectors, 'Checked', 'on');
set(handles.menuRightAlignVectors, 'Checked', 'off');
set(handles.menuCenterAlignVectors, 'Checked', 'off');
set(handles.menuStretchAlignVectors, 'Checked', 'off');
handles = refreshVectorPlot(handles);
guidata(hObject, handles);

% --------------------------------------------------------------------
function menuRightAlignVectors_Callback(hObject, eventdata, handles)
% hObject    handle to menuRightAlignVectors (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.menuLeftAlignVectors, 'Checked', 'off');
set(handles.menuRightAlignVectors, 'Checked', 'on');
set(handles.menuCenterAlignVectors, 'Checked', 'off');
set(handles.menuStretchAlignVectors, 'Checked', 'off');
handles = refreshVectorPlot(handles);
guidata(hObject, handles);

% --------------------------------------------------------------------
function menuCenterAlignVectors_Callback(hObject, eventdata, handles)
% hObject    handle to menuCenterAlignVectors (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.menuLeftAlignVectors, 'Checked', 'off');
set(handles.menuRightAlignVectors, 'Checked', 'off');
set(handles.menuCenterAlignVectors, 'Checked', 'on');
set(handles.menuStretchAlignVectors, 'Checked', 'off');
handles = refreshVectorPlot(handles);
guidata(hObject, handles);

% --------------------------------------------------------------------
function menuStretchAlignVectors_Callback(hObject, eventdata, handles)
% hObject    handle to menuStretchAlignVectors (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.menuLeftAlignVectors, 'Checked', 'off');
set(handles.menuRightAlignVectors, 'Checked', 'off');
set(handles.menuCenterAlignVectors, 'Checked', 'off');
set(handles.menuStretchAlignVectors, 'Checked', 'on');
prompt = {'Number of samples to stretch to:'};
dlg_title = 'Stretch Alignment';
num_lines = 1;
answer = inputdlg(prompt,dlg_title,num_lines,{num2str(handles.vcg.stretch.n)});    
if(isempty(answer) || isempty(str2num(answer{1})))
    
else
    handles.vcg.stretch.n = str2num(answer{1});
end
handles.vcg.stretch.bFast = true;
handles = refreshVectorPlot(handles);
guidata(hObject, handles);

% --------------------------------------------------------------------
function menuSubsampleVectors_Callback(hObject, eventdata, handles)
% hObject    handle to menuSubsampleVectors (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if(strcmp(get(handles.menuSubsampleVectors, 'Checked'),'on'))
    set(handles.menuSubsampleVectors, 'Checked', 'off');
else
    set(handles.menuSubsampleVectors, 'Checked', 'on');
    prompt = {'This many samples:', 'For every:'};
    dlg_title = 'Subsampling';
    num_lines = 1;
    answer = inputdlg(prompt,dlg_title,num_lines,{num2str(handles.vcg.subsamp.p),num2str(handles.vcg.subsamp.q)});    
    if(isempty(answer) || isempty(str2num(answer{1})) || isempty(str2num(answer{2})))
    else
        handles.vcg.subsamp.p = str2num(answer{1});
        handles.vcg.subsamp.q = str2num(answer{2});
    end
    handles.vcg.subsamp.bFast = true;
end
handles = refreshVectorPlot(handles);
guidata(hObject, handles);

% --------------------------------------------------------------------
function menuVectorOutlierRange_Callback(hObject, eventdata, handles)
% hObject    handle to menuVectorOutlierRange (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if(strcmp(get(handles.menuVectorOutlierRange, 'Checked'),'on'))
    set(handles.menuVectorOutlierRange, 'Checked', 'off');
else
    set(handles.menuVectorOutlierRange, 'Checked', 'on');
    prompt = {'The minimum acceptable value:', 'The  maximum acceptable value:'};
    dlg_title = 'Set vector outlier range';
    num_lines = 1;
    answer = inputdlg(prompt,dlg_title,num_lines,{num2str(handles.vcg.vectRange(1)),num2str(handles.vcg.vectRange(2))});    
    if(isempty(answer) || isempty(str2num(answer{1})) || isempty(str2num(answer{2})))
    else
        handles.vcg.vectRange(1) = str2num(answer{1});
        handles.vcg.vectRange(2) = str2num(answer{2});
    end
end
handles = refreshVectorPlot(handles);
guidata(hObject, handles);

% --------------------------------------------------------------------
% right click on axesVector
function menuDisplayOnlySelectedVectors_Callback(hObject, eventdata, handles)
% hObject    handle to menuDisplayOnlySelectedVectors (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if(strcmp(get(handles.menuDisplayOnlySelectedVectors, 'Checked'),'on'))
    set(handles.menuDisplayOnlySelectedVectors, 'Checked', 'off');
else
    set(handles.menuDisplayOnlySelectedVectors, 'Checked', 'on');
end
handles = refreshVectorPlot(handles);
guidata(hObject, handles);

% --------------------------------------------------------------------
function menuSetSpecgramFs_Callback(hObject, eventdata, handles)
% hObject    handle to menuSetSpecgramFs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
prompt = {'What is the sampling rate:'};
dlg_title = 'Specgram Properties';
num_lines = 1;
default = {num2str(handles.vcg.specgram.fs)};
answer = inputdlg(prompt,dlg_title,num_lines,default);    
if(isempty(answer) || isempty(str2num(answer{1})))
else
    handles.vcg.specgram.fs = str2num(answer{1});
end
guidata(hObject, handles);

% --------------------------------------------------------------------
function menuSetSpecgramFreqRange_Callback(hObject, eventdata, handles)
% hObject    handle to menuSetSpecgramFreqRange (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
prompt = {'What is the minimum frequency:','What is the maximum frequency:'};
dlg_title = 'Specgram Properties';
num_lines = 1;
default = {num2str(handles.vcg.specgram.freqRange(1)), num2str(handles.vcg.specgram.freqRange(2))};
answer = inputdlg(prompt,dlg_title,num_lines,default);    
if(isempty(answer) || isempty(str2num(answer{1})) || isempty(str2num(answer{2})))
else
    handles.vcg.specgram.freqRange(1) = str2num(answer{1});
    handles.vcg.specgram.freqRange(2) = str2num(answer{2});
end
guidata(hObject, handles);

% --------------------------------------------------------------------
function menuSetSpecgramColorRange_Callback(hObject, eventdata, handles)
% hObject    handle to menuSetSpecgramColorRange (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
prompt = {'Color range floor ([] to autoscale):','Color range ceiling ([] to autoscale):'};
dlg_title = 'Specgram Properties';
num_lines = 1;
default = {'[]'};
if(isempty(handles.vcg.specgram.colorRange))
    default = {num2str(handles.vcg.specgram.colorRange(1)), num2str(handles.vcg.specgram.colorRange(2))};
end
answer = inputdlg(prompt,dlg_title,num_lines,default);    
if(isempty(answer) || isempty(str2num(answer{1})) || isempty(str2num(answer{2})))
    handles.vcg.specgram.colorRange = [];
else
    handles.vcg.specgram.colorRange(1) = str2num(answer{1});
    handles.vcg.specgram.colorRange(2) = str2num(answer{2});
end
guidata(hObject, handles);

% --------------------------------------------------------------------
function nFeat = getFeaturePopupValue(popupHandle, vcdb)
ndx = get(popupHandle,'Value');
nFeat = ndx2feature(ndx, size(vcdb.d.sf,2));

% --------------------------------------------------------------------
function setFeaturePopupValue(popupHandle, vcdb, nFeat)
ndx = feature2ndx(nFeat, size(vcdb.d.sf,2));
set(popupHandle,'Value',ndx);

% --------------------------------------------------------------------
function ndx = feature2ndx(nFeat, numFeats)
ndx = nFeat;
if(isempty(nFeat)), ndx = []; return; end;
if(nFeat < 1)
    ndx = numFeats - nFeat;
end

% --------------------------------------------------------------------
function nFeat = ndx2feature(ndx, numFeats)
nFeat = ndx;
if(isempty(ndx)), nFeat = []; return; end;
if(ndx > numFeats)
    nFeat = numFeats - ndx;
end


% --- Executes on button press in buttonHistogram. %%% TO
function buttonHistogram_Callback(hObject, eventdata, handles)
% hObject    handle to buttonHistogram (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
axes(handles.axesBar);
cla reset; % clear axes and replot

ClusterNum = size(handles.vcdb.c,2); % number of clusters
if ClusterNum==0
    TotalSegment = size(handles.vcdb.d.cn,1); % number of total segments
    h = bar(1,TotalSegment);
    set(h,'facecolor','k','edgecolor','k')
    set(handles.axesBar,'xtick',-1:2:1,'xticklabel',{'',''})
    xlim([-0.5 2.5]); % make the bar thinner
    return
end
ClusterArray = handles.vcdb.d.cn; % array of cluster number

hold on
for n=1:ClusterNum
    Number(n) = handles.vcdb.c(n).number;
    Count(n)=sum(ClusterArray==Number(n));
    
    h = bar(Number(n),Count(n));
    set(h,'facecolor',handles.vcdb.c(n).color,'edgecolor','k')
    text(Number(n)-0.1,30,handles.vcdb.c(n).str,'fontweight','bold','fontsize',12,'color','w')
end
Number(n+1) = max(Number)+1; % use the last number + 1 for non-clustered syllables
Count(n+1) = size(handles.vcdb.d.cn,1)-sum(Count); % non-clustered syllables (NaN)
h = bar(Number(n+1),Count(n+1));
set(h,'facecolor','k','edgecolor','k')
%text(Number(n+1)-0.35,30,'NaN','fontweight','bold','fontsize',10,'color','w')
set(handles.axesBar,'xtick',1:max(Number));
xlim([0,max(Number)+1])
ylim([0,max(Count)+5])
xlabel('Cluster Number')
hold off

% --- Executes on button press in buttonHeliox.
function buttonHeliox_Callback(hObject, eventdata, handles)
% hObject    handle to buttonHeliox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = Heliox(handles);


% --- Executes on button press in buttonResults.
function buttonResults_Callback(hObject, eventdata, handles)
% hObject    handle to buttonResults (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%plotResults(handles)
vcdb = handles.vcdb;
ClusterSelect = get(handles.popupClusterSelect,'Value'); % get which cluster is selected
ClusterNum = vcdb.c(ClusterSelect).number;
sp = handles.vcg.specgram;

Ndx = find(vcdb.d.cn==ClusterNum);
if isempty(Ndx)
    errordlg('No syllables in the cluster!')
    return
end

%- TO DO: predetermine figure size
% user input ArrayNum
% make the figure clickable to delete it
% be able to go to next page

figure(132)
set(132,'KeyPressFcn',@next) % assign key press function
ud.fig = 132;
ud.i = 1; % initialize
ud.Column = 5;
ud.Row = 5;
ud.Chunk = ud.Column*ud.Row;
ud.vcdb = vcdb;
ud.sp = sp;
ud.Ndx = Ndx;
ud.Length = length(Ndx); % number of syllables within the current cluster
ud.hObject = hObject;
set(132,'UserData',ud);
plotResults(ud)

function plotResults(ud)
% keyboard
figure(ud.fig)
clf; % clear
j = 1; % index for subplot
if ud.i+ud.Chunk-1 <= ud.Length
    End = ud.i+ud.Chunk-1;
else
    End = ud.Length;
end

for i=ud.i:End
    subplot(ud.Row,ud.Column,j)
    displaySpecgramQuick(ud.vcdb.d.v{ud.Ndx(i)},ud.sp.fs, ud.sp.freqRange, ud.sp.colorRange);
    axis off
    ud_ax = get(gca, 'UserData');
    ud_ax.syllable = ud.Ndx(i); %FIXME
    ud_ax.hObject = ud.hObject;
    set(gca,'UserData',ud_ax);
%     set(gca,'ButtonDownFcn',@resultsSubplot_Callback)
    if j==1
        title(num2str(ud.i));
    end
    j = j+1;
end
title(num2str(ud.i+ud.Chunk-1));

function next(src,evnt) % key press
ud = get(src,'UserData');
if strcmp(evnt.Character,'n') % next syllable
    if ud.i+ud.Chunk <= ud.Length
        ud.i = ud.i+ud.Chunk; % go to next chunk
    end
elseif strcmp(evnt.Character,'p') % previous syllable
    if ud.i-ud.Chunk>0
        ud.i = ud.i-ud.Chunk
    end
end
set(src,'UserData',ud);
plotResults(ud);


% --- Executes during object creation, after setting all properties.
function axesVector_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axesVector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axesVector




% --- Executes on button press in buttonZoomOn.
function buttonZoomOn_Callback(hObject, eventdata, handles)
% hObject    handle to buttonZoomOn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
axes(handles.axesBar)
zoom yon

% --- Executes on button press in buttonZoomOff.
function buttonZoomOff_Callback(hObject, eventdata, handles)
% hObject    handle to buttonZoomOff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
axes(handles.axesBar)
zoom off
buttonHistogram_Callback(hObject, eventdata, handles); % reset

%
% --- call vectorClust with file name (TO)
function AutomaticImport_Callback(hObject, eventdata, handles)
% hObject    handle to buttonImport (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[v, sf, vf, icn, t, i, sfname, vfname, fileName, pathName] = feval('vc_imp_ProcessedAnnotationFiles'); %%% TO
handles.vcdb.fileName = fileName; %%% TO
handles.vcdb.pathName = pathName; %%% TO
set(handles.text_FileName,'string',fileName); %%% TO
guidata(hObject, handles);

%If import successful
if(~isempty(v))
    if(bClosed)
        %add basic features to the scalar feature list.
        sf(:,end+1) = cellfun(@length,v);
        sfname{end+1} = 'length';
        sf(:,end+1) = t;
        sfname{end+1} = 'time';
        sf(:,end+1) = (t - floor(t))*24;
        sfname{end+1} = 'hourOfDay';
        sf(:,end+1) = icn;
        sfname{end+1} = 'imported cluster';

        %import the data.
        handles.vcdb.d.v = v;
        handles.vcdb.d.sf = sf;
        handles.vcdb.d.vf = vf;
        handles.vcdb.d.cn = nan(length(v),1);
        handles.vcdb.d.icn = icn;
        handles.vcdb.d.t = t;
        handles.vcdb.d.i = i;
        handles.vcdb.f.sfname = sfname;
        handles.vcdb.f.sffcn = repmat({func2str(func{sel})}, length(sfname), 1);
        handles.vcdb.f.sfparam = cell(length(sfname),1);
        handles.vcdb.f.vfname = vfname;
        handles.vcdb.f.vffcn = repmat({func2str(func{sel})}, length(vfname), 1);
        handles.vcdb.f.vfparam = cell(length(vfname),1);
        handles.vcdb.c = [];
        handles.vcg.bSel = false(size(v));
        handles.vcg.bDraw = true(size(v));
        handles.vcg.bFilt = true(size(v));
        handles.vcg.hScat = [];
        handles.vcg.hVect = [];
        handles.vcg.mVectMat = [];
        handles = refreshAll(handles);
    end
end

buttonHistogram_Callback(hObject, eventdata, handles); % update histogram
guidata(hObject, handles);


% --- Executes on button press in buttonSubcluster.
function buttonSubcluster_Callback(hObject, eventdata, handles)
% hObject    handle to buttonSubcluster (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

nc = get(handles.popupClusterSelect,'Value'); % currently selected cluster numbers
if nc==5
    handles.vcdb.c(nc).polys = {handles.vcdb.c(4).polys{1}};
else
    handles.vcdb.c(nc).polys = {handles.vcdb.c(1).polys{1}};
end
%handles = refreshClusters(handles);
guidata(hObject, handles);


% --- Executes on button press in buttonAnalysis.
function buttonAnalysis_Callback(hObject, eventdata, handles)
% hObject    handle to buttonAnalysis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

temp1 = strcmp(handles.vcdb.f.sfname(:),'IsMask');
if ~isempty(temp1)
    featureNum1 = find(temp1);
else
    error('No IsMask feature')
end
IsMask = logical(handles.vcdb.d.sf(:,featureNum1)); % for all the syllables

temp2 = strcmp(handles.vcdb.f.sfname(:),'IsStim');
if ~isempty(temp2)
    featureNum2 = find(temp2);
else
    error('No IsStim feature')
end
IsStim = logical(handles.vcdb.d.sf(:,featureNum2)); % for all the syllables

IsSyll = {};
for SyllNum = 6:8
    IsSyll{SyllNum-5} = (handles.vcdb.d.cn==SyllNum); % Is the syllable we are looking for?
end

%%% for experimetal days to1145
A1mask = IsSyll{1} & IsMask;
A1stim = IsSyll{1} & IsStim;
A2mask = IsSyll{2} & IsMask;
A2stim = IsSyll{2} & IsStim;
A3mask = IsSyll{3} & IsMask;
A3stim = IsSyll{3} & IsStim;
% prepare vectMat
vfeat = get(handles.popupVectorFeature,'Value');
if(vfeat == 1)
    vects = handles.vcdb.d.v; % vector itself
else % other vector features
    vects = handles.vcdb.d.vf{vfeat-1};
end
[vectMatMask{1}, status] = preprocessAndAlignVectors(vects(A1mask),handles);
[vectMatStim{1}, status] = preprocessAndAlignVectors(vects(A1stim),handles);
[vectMatMask{2}, status] = preprocessAndAlignVectors(vects(A2mask),handles);
[vectMatStim{2}, status] = preprocessAndAlignVectors(vects(A2stim),handles);
[vectMatMask{3}, status] = preprocessAndAlignVectors(vects(A3mask),handles);
[vectMatStim{3}, status] = preprocessAndAlignVectors(vects(A3stim),handles);
%cd('Z:\Data\LMANstim\to1145')
%save to1145_vectMat_2009-12-18_pitch vectMatMask vectMatStim

%% picking random 5 syllables
clear IsSyll
IsSyll = (handles.vcdb.d.cn==1)
A1mask = IsSyll & IsMask;
A1stim = IsSyll & IsStim;
tempMask = find(A1mask);
tempStim = find(A1stim);
randMask = randperm(length(tempMask)); % random permutation
randStim = randperm(length(tempStim)); % random permutation
randMask = tempMask(1:5); % just take the first five
randStim = tempStim(randStim(1:5)); % just take the first five

figure(60)
clf
hold on
for n=1:5
    subplot(2,5,n)
    displaySpecgramQuick(handles.vcdb.d.v{randMask(n)},40000);
    xlabel('')
    ylabel('')
    axis off
    subplot(2,5,n+5)
    displaySpecgramQuick(handles.vcdb.d.v{randStim(n)},40000);
    xlabel('')
    ylabel('')
    axis off
end


%% for washout to1145
A1 = IsSyll{1};
A2 = IsSyll{2};
A3 = IsSyll{3};

vfeat = get(handles.popupVectorFeature,'Value');
if(vfeat == 1)
    vects = handles.vcdb.d.v; % vector itself
else % other vector features
    vects = handles.vcdb.d.vf{vfeat-1};
end
[vectMat{1}, status] = preprocessAndAlignVectors(vects(A1),handles);
[vectMat{2}, status] = preprocessAndAlignVectors(vects(A2),handles);
[vectMat{3}, status] = preprocessAndAlignVectors(vects(A3),handles);

%cd('Z:\Data\LMANstim\to1145')
%save to1145_vectMat_2009-12-16_pitchGoodness vectMat


muMask = mean(vectMatMask{2});
muStim = mean(vectMatStim{2});
figure(60)
hold on
plot(muMask,'b')
plot(muStim,'r')
hold off

%%
% --- Executes on button press in buttonStimTime.
function buttonStimTime_Callback(hObject, eventdata, handles)
% hObject    handle to buttonStimTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
nc = get(handles.popupClusterSelect,'Value');
SyllNum = handles.vcdb.c(nc).number;
StimRange = 50; % valid stimulus onset range (ms)

StimIdx = find(strcmp(handles.vcdb.f.vfname,'stimTime'));
DurationIdx = find(strcmp(handles.vcdb.f.sfname,'duration'));
SyllIdx = find(handles.vcdb.d.cn==SyllNum);
duration = handles.vcdb.d.sf(SyllIdx,DurationIdx);
median(duration)*1000;
stimTimes = handles.vcdb.d.vf{StimIdx}(SyllIdx); 
for n=1:length(stimTimes)
    if ~isempty(stimTimes{n})
        stimOnset(n) = stimTimes{n}(1)*1000; % in ms
        stimOffset(n) = stimTimes{n}(end)*1000; % in ms
    else
        stimOnset(n) = NaN;
        stimOffset(n) = NaN;
    end
end

ValidStimOnset = stimOnset(find(stimOnset < StimRange));
ValidStimOffset = stimOffset(find(stimOnset < StimRange));
N = length(ValidStimOnset);
MedianOnset = median(ValidStimOnset);
MedianOffset = median(ValidStimOffset);
Mean = mean(ValidStimOnset);
Std = std(ValidStimOnset);
% plot the histogram
figure(30)
Edges = 0:1:50;
M = histc(ValidStimOnset,Edges)./N;
bar(Edges,M,'histc')
xlim([Edges(1),Edges(end)])
xlabel('Stim onset(ms)','fontsize',16)
ylabel('Probability','fontsize',16)
h=line([nanmedian(stimOnset),nanmedian(stimOnset)],ylim);
set(h,'color','r','linewidth',2)
xl = xlim;
yl = ylim;
text(2,0.9*yl(2),['Count = ',num2str(N)],'fontsize',12);
text(2,0.8*yl(2),['Median onset = ',num2str(MedianOnset,3),' ms'],'fontsize',12);
text(2,0.72*yl(2),['Mean onset = ',num2str(Mean,3),' ms'],'fontsize',12);
text(2,0.64*yl(2),['Std onset= ',num2str(Std,3),' ms'],'fontsize',12);


% --- Executes on button press in playsyllable.
function playsyllable_Callback(hObject, eventdata, handles)
% hObject    handle to playsyllable (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

audio = handles.vcdb.d.v{handles.vcg.bSel};
Fs = handles.vcg.specgram.fs;
sound(audio,Fs);


function resultsSubplot_Callback(src, evn)
% if it is not in the exclusions, add to exclusions
% turn colormap gray so you know it is excluded
% if it is already excluded, include it again by removing from exclusions
ud = get(src,'UserData');
handles = guidata(ud.hObject);
handles.vcdb.c(clust).excs{end+1} = ud.syllable;
colormap gray
handles = refreshClusters(handles);
guidata(ud.hObject, handles);
keyboard