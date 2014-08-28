function varargout = rules_multiple_birds(varargin)
% RULES_MULTIPLE_BIRDS M-file for rules_multiple_birds.fig
%      RULES_MULTIPLE_BIRDS, by itself, creates a new RULES_MULTIPLE_BIRDS or raises the existing
%      singleton*.
%
%      H = RULES_MULTIPLE_BIRDS returns the handle to a new RULES_MULTIPLE_BIRDS or the handle to
%      the existing singleton*.
%
%      RULES_MULTIPLE_BIRDS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in RULES_MULTIPLE_BIRDS.M with the given input arguments.
%
%      RULES_MULTIPLE_BIRDS('Property','Value',...) creates a new RULES_MULTIPLE_BIRDS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before rules_multiple_birds_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to rules_multiple_birds_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help rules_multiple_birds

% Last Modified by GUIDE v2.5 18-Aug-2014 13:39:58

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @rules_multiple_birds_OpeningFcn, ...
                   'gui_OutputFcn',  @rules_multiple_birds_OutputFcn, ...
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


% --- Executes just before rules_multiple_birds is made visible.
function rules_multiple_birds_OpeningFcn(hObject, eventdata, handles, varargin)%#ok
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to rules_multiple_birds (see VARARGIN)

% Choose default command line output for rules_multiple_birds
handles.output = hObject;

% Initialize data structure
handles.birds = struct('number', {}, 'name', {}, 'rules', {}, 'exper', {}, 'ruleSummary', {});
handles.selectedBird = 1;
handles.tdtCircuit = '';

% Turn debugging on or off (for debugdisp function)
global DEBUG_TEXT
DEBUG_TEXT = 1;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes rules_multiple_birds wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = rules_multiple_birds_OutputFcn(hObject, eventdata, handles)%#ok 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in buttonBirdAdd.
function buttonBirdAdd_Callback(hObject, eventdata, handles)%#ok
% hObject    handle to buttonBirdAdd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Choose exper for the bird
try
    [filename, pathname] = uigetfile('*.mat', 'Choose exper', 'exper.mat');
    temp = load(fullfile(pathname, filename));
    handles.birds(end + 1).exper = temp.exper;
    clear temp
catch e
    warning('CAFGUI:AddBird', 'Could not create new bird because %s', e.message)
    return
end

if length(handles.birds) == 1
    handles.birds(end).number = 1;
else
    handles.birds(end).number = max([handles.birds.number]) + 1;
end
handles.birds(end).name = handles.birds(end).exper.birdname;
handles.birds(end).ruleSummary = '';
handles.selectedBird = length(handles.birds);
handles = update_display(handles);
guidata(hObject, handles)



% --- Executes on button press in buttonBirdRemove.
function buttonBirdRemove_Callback(hObject, eventdata, handles) %#ok
% hObject    handle to buttonBirdRemove (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
iremove = get(handles.listboxBirds, 'Value');
ikeep = (1:length(handles.birds)) ~= iremove;
handles.birds = handles.birds(ikeep);
handles = update_display(handles);
guidata(hObject, handles)


% --- Executes on selection change in listboxBirds.
function listboxBirds_Callback(hObject, eventdata, handles)%#ok
% hObject    handle to listboxBirds (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns listboxBirds contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listboxBirds
handles.selectedBird = get(hObject, 'Value');
handles = update_display(handles);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function listboxBirds_CreateFcn(hObject, eventdata, handles)%#ok
% hObject    handle to listboxBirds (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in buttonSave.
function buttonSave_Callback(hObject, eventdata, handles)%#ok
% hObject    handle to buttonSave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
defaultfile = 'rules';
for ii = 1:length(handles.birds)
    defaultfile = [defaultfile '_' handles.birds(ii).name];
end
[filename, pathname] = uiputfile('*.mat', 'Save file', defaultfile);
save(fullfile(pathname, filename), 'handles')

% --- Executes on button press in buttonLoad.
function buttonLoad_Callback(hObject, eventdata, handles)%#ok
% hObject    handle to buttonLoad (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename, pathname] = uigetfile('*.mat', 'Load file');
x = load(fullfile(pathname, filename));
try
    handles.birds = x.handles.birds;
    handles.selectedBird = x.handles.selectedBird;
    handles.tdtCircuit = x.handles.tdtCircuit;
    handles = update_display(handles);
    guidata(hObject, handles)
catch e
    warning('CAFGUI:LoadRulesMultiple', 'Cannot load rules because %s', e.message)
end

% --- Executes on button press in buttonExport.
function buttonExport_Callback(hObject, eventdata, handles)%#ok
% hObject    handle to buttonExport (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if hasDuplicatePartags([handles.birds.rules])
    errordlg('Cannot export because there are duplicate partag names')
    return
end

% Connect to TDT RX8 with ActiveX control
if ~isfield(handles,'RP')
    handles.RP = actxcontrol('RPco.x',[5 5 26 26]);
end
handles.RP.ConnectRX8('USB', 1);
status=double(handles.RP.GetStatus); % Get status
if bitget(status,1)==0; % Checks for connection
    debugdisp('Error connecting to RX8');
end

% Stop the TDT and load the circuit
handles.RP.Halt; % Stops any processing chains running on RP2
handles.RP.ClearCOF; % Clears all the buffers and circuits on RP2
handles.RP.LoadCOF(handles.tdt.rcx);
handles.RP.Run;
status=double(handles.RP.GetStatus); % Get status
if bitget(status,1)==0; % Checks for connection
    debugdisp('Error connecting to device');
elseif bitget(status,2)==0; % Checks for errors in loading circuit
    debugdisp('Error loading circuit');
elseif bitget(status,3)==0
    debugdisp('Error running circuit');
else
    debugdisp('Circuit loaded and running');
end

% Load each rule
numVisible = @(x) sum([x.rules.visible]);
numRules = sum(arrayfun(numVisible, handles.birds));
numLoaded = 0;
wbh = waitbar(0);
for b = 1:length(handles.birds)
    for r = 1:length(handles.birds(b).rules)
        if handles.birds(b).rules(r).visible
            exportRule2tdt(handles.birds(b).rules(r), handles.RP) %%%DEBUG
            numLoaded = numLoaded + 1;
            loadStatus = sprintf('Bird %s: Loaded rule %s', handles.birds(b).name, handles.birds(b).rules(r).name);
            waitbar(numLoaded / numRules, wbh, loadStatus);
        end
    end
end
close(wbh)
debugdisp('Rules loaded')
guidata(hObject, handles)


function editCircuit_Callback(hObject, eventdata, handles)%#ok
% hObject    handle to editCircuit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editCircuit as text
%        str2double(get(hObject,'String')) returns contents of editCircuit as a double
handles.tdtCircuit = get(hObject, 'String');
guidata(hObject, handles)

% --- Executes during object creation, after setting all properties.
function editCircuit_CreateFcn(hObject, eventdata, handles)%#ok
% hObject    handle to editCircuit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in buttonCircuit.
function buttonCircuit_Callback(hObject, eventdata, handles)%#ok
% hObject    handle to buttonCircuit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename, pathname] = uigetfile('*.rcx', 'Select TDT circuit');
handles.tdtCircuit = fullfile(pathname, filename);
handles = update_display(handles);
guidata(hObject, handles)


% --- Executes on button press in buttonRuleEdit.
function buttonRuleEdit_Callback(hObject, eventdata, handles)%#ok
% hObject    handle to buttonRuleEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
birdinfo = ruleEditor(handles.birds(handles.selectedBird));
if ~isempty(birdinfo)
    handles.birds(handles.selectedBird) = birdinfo;
    handles = update_display(handles);
    guidata(hObject, handles)
end

% --- Executes on button press in buttonBirdUp.
function buttonBirdUp_Callback(hObject, eventdata, handles)%#ok
% hObject    handle to buttonBirdUp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
numOld = handles.birds(handles.selectedBird).number;
if numOld == 1 % already at the top, cannot move up farther
    return
end    
numNew = numOld - 1;

% Switch numbers with another rule if we take its number my moving up
hasNewNum = [handles.birds.number] == numNew;
if any(hasNewNum)
    handles.birds(hasNewNum).number = numOld;
end

handles.birds(handles.selectedBird).number = numNew;
handles = update_display(handles);
guidata(hObject, handles)



% --- Executes on button press in buttonBirdDown.
function buttonBirdDown_Callback(hObject, eventdata, handles)%#ok
% hObject    handle to buttonBirdDown (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
numOld = handles.birds(handles.selectedBird).number;
numNew = numOld + 1;

% Switch numbers with another rule if we take its number my moving down
hasNewNum = [handles.birds.number] == numNew;
if any(hasNewNum)
    handles.birds(hasNewNum).number = numOld;
end

handles.birds(handles.selectedBird).number = numNew;
handles = update_display(handles);
guidata(hObject, handles)

% --- Executes on button press in buttonBirdExper.
function buttonBirdExper_Callback(hObject, eventdata, handles)%#ok
% hObject    handle to buttonBirdExper (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
    [filename, pathname] = uigetfile('*.mat', 'Choose exper', 'exper.mat');
    temp = load(fullfile(pathname, filename));
    
    % If the file doesn't contain a valid exper, show error dialog and
    % don't change anything
    if ~isexper(temp.exper)
        errordlg('Invalid exper')
        return
    end
    
    % If the new exper is from a different bird, check with the user before
    % proceeding. If we proceed, it will change the name of the bird, but
    % the rules will not change.
    if ~strcmp(temp.exper.birdname, handles.birds(handles.selectedBird).name)
        a = questdlg(['New exper has a different bird name than the' ...
            'selected bird! Do you want to use the new exper and change' ...
            'the bird name (rules will remain the same)?'], ...
            'Bird name mismatch', 'Yes, use new exper anyway', 'No', 'No');
        if ~strcmp(a, 'Yes, use new exper anyway')
            return
        end
    end
    handles.birds(handles.selectedBird).exper = temp.exper;
    handles.birds(handles.selectedBird).name = temp.exper.birdname;
    clear temp
    handles = update_display(handles);
    guidata(hObject, handles);
catch e
    warning('CAFGUI:loadExper', 'Error loading new exper: %s', e.message)
    return
end


function handles = update_display(handles)
% Make sure birds are in order by number
[~, ordr] = sort([handles.birds.number]);
handles.birds = handles.birds(ordr);
handles.selectedBird = ordr(handles.selectedBird);

% Make sure selectedBird isn't out-of-bounds
handles.selectedBird = min(handles.selectedBird, length(handles.birds));
handles.selectedBird = max(handles.selectedBird, 0);

% Each bird is displayed as '#. birdname (expername)'
displayName = cell(size(handles.birds));
for ii = 1:length(handles.birds)
    displayName{ii} = sprintf('%g. %s (%s)', ...
        handles.birds(ii).number, ...
        handles.birds(ii).name, ...
        handles.birds(ii).exper.expername);
end
set(handles.listboxBirds, 'String', displayName)
set(handles.listboxBirds, 'Value', handles.selectedBird)

set(handles.panelRule, 'Title', ['Rules for ' handles.birds(handles.selectedBird).name])
set(handles.textRuleSummary, 'String', handles.birds(handles.selectedBird).ruleSummary)

set(handles.editCircuit, 'String', handles.tdtCircuit)
