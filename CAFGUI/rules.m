function varargout = rules(varargin)
% RULES M-file for rules.fig
%      RULES, by itself, creates a new RULES or raises the existing
%      singleton*.
%
%      H = RULES returns the handle to a new RULES or the handle to
%      the existing singleton*.
%
%      RULES('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in RULES.M with the given input arguments.
%
%      RULES('Property','Value',...) creates a new RULES or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before rules_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to rules_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help rules

% Last Modified by GUIDE v2.5 02-Feb-2011 15:28:39

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @rules_OpeningFcn, ...
                   'gui_OutputFcn',  @rules_OutputFcn, ...
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


% --- Executes just before rules is made visible.
function rules_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to rules (see VARARGIN)

% Choose default command line output for rules
handles.output = hObject;

% a list of all conditions (sound power, pitch, boolean, etc.)
handles.conditions = ruleConditions();
% edit ruleConditions.m to add new conditions

for nc = 1:length(handles.conditions)
    str{nc} = handles.conditions(nc).name;
end
set(handles.popupCondition,'String',str)

set(handles.editRuleName,'Enable','off')
set(handles.popupCondition,'Enable','off')
set(handles.editPartagSuffix,'Enable','off')
set(handles.actionNoise,'Enable','off')
set(handles.buttonCondition,'Enable','off')

handles.testSuffix = get(handles.editTestSuffix,'String');

% Defaults for the dialog box that appears when you click "Test Clustered
% Syllables" button
handles.testSyllablesDefaults = {'1,2','50','60'};

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes rules wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = rules_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in radiobutton4.
function radiobutton4_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton4


% --- Executes on button press in radiobutton5.
function radiobutton5_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton5



function editRuleName_Callback(hObject, eventdata, handles)
% hObject    handle to editRuleName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editRuleName as text
%        str2double(get(hObject,'String')) returns contents of editRuleName as a double
newName = get(hObject,'String');
nSel = get(handles.listRules,'Value');
% set new name in internal list of rules
handles.rules(handles.list2rule(nSel)).name = newName;
guidata(hObject,handles);
% set new name in listRules
rulesList = get(handles.listRules,'String');
rulesList{nSel} = newName;
set(handles.listRules,'String',rulesList);

% --- Executes during object creation, after setting all properties.
function editRuleName_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editRuleName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in buttonCondition.
function buttonCondition_Callback(hObject, eventdata, handles)
% hObject    handle to buttonCondition (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% opens the appropriate condition editor and captures the changes you make
% there
% get the rule
handles.rSel = handles.list2rule(get(handles.listRules,'Value'));
% get the condition
c = handles.rules(handles.rSel).condition;
% open up the editor
handles.rules(handles.rSel).params = handles.conditions(c).editFcn(handles);
% store results
guidata(hObject,handles)


function windowStart_Callback(hObject, eventdata, handles)
% hObject    handle to windowStart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of windowStart as text
%        str2double(get(hObject,'String')) returns contents of windowStart as a double
t = str2double(get(hObject,'String'));
rSel = handles.list2rule(get(handles.listRules,'Value')); % selected rule #
handles.rules(rSel).windowStart = t;
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function windowStart_CreateFcn(hObject, eventdata, handles)
% hObject    handle to windowStart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function windowEnd_Callback(hObject, eventdata, handles)
% hObject    handle to windowEnd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of windowEnd as text
%        str2double(get(hObject,'String')) returns contents of windowEnd as
%        a double
t = str2double(get(hObject,'String'));
rSel = handles.list2rule(get(handles.listRules,'Value')); % selected rule #
handles.rules(rSel).windowEnd = t;
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function windowEnd_CreateFcn(hObject, eventdata, handles)
% hObject    handle to windowEnd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in listRules.
function listRules_Callback(hObject, eventdata, handles)
% hObject    handle to listRules (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns listRules contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listRules

handles.rSel = handles.list2rule(get(handles.listRules,'Value'));
refreshRuleDisplay(handles);
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function listRules_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listRules (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in buttonNewRule.
function buttonNewRule_Callback(hObject, eventdata, handles)
% hObject    handle to buttonNewRule (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% set default properties for new rule
if ~isfield(handles,'rules')
    n = 1;
    handles.list2rule = [];
else
    n = length(handles.rules) + 1;
end
handles.rules(n).name = ['rule' int2str(n)];
handles.rules(n).condition = 1;
handles.rules(n).tdtPartagSuffix = n;
handles.rules(n).tdtTags = makeSuffix(handles.conditions(1).tdtTags,n);
handles.rules(n).actionNoise = 0;
handles.rules(n).visible = true;
% add a new element to the rules list
rulesList = get(handles.listRules,'String');
rulesList{end+1} = handles.rules(n).name;
set(handles.listRules,'String',rulesList);
handles.list2rule(end+1) = n;
% select the new rule
set(handles.listRules,'Value',length(handles.list2rule))
handles.rSel = n;
%
guidata(hObject,handles);
refreshRuleDisplay(handles)


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in buttonTest.
function buttonTest_Callback(hObject, eventdata, handles)
% hObject    handle to buttonTest (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% get audio
Fs_in = handles.exper.desiredInSampRate;
Fs = 24414; %Hz, TDT sampling rate
audio_in = loadAudio(handles.exper, get(handles.listFiles,'Value'));
audio = resample2(audio_in, Fs, Fs_in);
audio = audio - mean(audio);
t = (0:length(audio)-1) * 1/Fs;
% get list of rules to test
toTest = handles.list2rule;%(get(handles.listRules,'Value'));
tested = zeros(size(toTest));
% evaluate each rule
bRuleMet = [];
while ~all(tested)
    evalFlag = 0;
    for r = toTest(~tested)
        rTested = toTest(logical(tested));
        dep = handles.rules(r).params.dependencies;
        if isempty(dep) || ... % if no dependencies
            all(ismember(dep, rTested)) % if all dependencies met
        bRuleMet(:,r) = feval(handles.rules(r).params.filterFunc, audio, handles.rules(r).params, bRuleMet);
        tested(toTest==r) = 1;
        evalFlag = 1;
        end
    end
    if ~evalFlag
        % if there are some rules that can't be evaluated, error
        errordlg('Cannot evaluate rules because dependencies cannot be met.')
        return
    end
end

% use noise-determining rule(s)
noise = zeros(size(t));
for r = toTest
    if handles.rules(r).actionNoise
        noise(logical(bRuleMet(:,r))) = 1;
    end
end

m = length(toTest) + 3; % spectrogram will be triple height
fh = figure; % new figure
axh = zeros(1,length(toTest + 1)); % list of axes handles to link later
% spectrogram with noise marked
axh(1) = subplot(m,1,1:3);
displaySpecgramQuick(audio, Fs)
x = [t t(end) t(1)];
y = [20000*noise 0 0];
% fill(x,y,'r','FaceAlpha',0.5) %%%DEBUG
% a separate subplot for each rule
for n = 1:length(toTest)
    r = toTest(n);
    axh(n+1) = subplot(m,1,n+3);
    plot(t,bRuleMet(:,r))
    axis off
    title(handles.rules(r).name)
end
linkaxes(axh,'x')

% --- Executes on button press in buttonDeleteRule.
function buttonDeleteRule_Callback(hObject, eventdata, handles)
% hObject    handle to buttonDeleteRule (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
nSel = get(handles.listRules,'Value'); % number of selected rule
set(handles.listRules,'Value',1); % select the first rule
% remove from listRules
rulesList = get(handles.listRules,'String');
n = 1:length(rulesList);
if length(rulesList) == 1 % if this is the last rule
    % cannot delete everything from the list because it will give an error
    % so just make the first (and only) entry blank
    rulesList = '';
else % if there are other rules, we can just remove the selected one
    rulesList = rulesList(n ~= nSel);
end
set(handles.listRules,'String',rulesList);
% make it invisible, but do not delete from our internal list of rules
rSel = handles.list2rule(nSel);
handles.rules(rSel).visible = 0;
handles.list2rule = handles.list2rule(n ~= nSel);
guidata(hObject,handles);

% --- Executes on button press in actionSwitch.
function actionSwitch_Callback(hObject, eventdata, handles)
% hObject    handle to actionSwitch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of actionSwitch


% --- Executes on button press in actionNoise.
function actionNoise_Callback(hObject, eventdata, handles)
% hObject    handle to actionNoise (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of actionNoise
rSel = handles.list2rule(get(handles.listRules,'Value')); % selected rule #
handles.rules(rSel).actionNoise = get(hObject,'Value');
guidata(hObject,handles);

function refreshRuleDisplay(handles)
rSel = handles.rules(handles.list2rule(get(handles.listRules,'Value'))); % selected rule
if isempty(rSel) % if there are no rules
    return
end
if length(rSel) == 1
    %enable all the fields. they might be disabled if you had previously
    %selected multiple rules (see the else clause)
    set(handles.editRuleName,'Enable','on')
    set(handles.popupCondition,'Enable','on')
    set(handles.editPartagSuffix,'Enable','on')
    set(handles.actionNoise,'Enable','on')
    set(handles.buttonCondition,'Enable','on')
    % set name
    set(handles.editRuleName,'String',rSel.name);
    % set condition
    set(handles.popupCondition,'Value',rSel.condition);
    % set suffix
    set(handles.editPartagSuffix,'String',num2str(rSel.tdtPartagSuffix))
    % set action
    set(handles.actionNoise,'Value',rSel.actionNoise)
else
    % if more than one rule is selected, gray out editing
    set(handles.editRuleName,'Enable','off')
    set(handles.popupCondition,'Enable','off')
    set(handles.editPartagSuffix,'Enable','off')
    set(handles.actionNoise,'Enable','off')
    set(handles.buttonCondition,'Enable','off')
end

% --- Executes when selected object is changed in panelRule.
function panelRule_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in panelRule 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)
% rSel = handles.list2rule(get(handles.listRules,'Value')); % selected rule #
% cHandle = get(handles.panelRule,'SelectedObject');
% for c = 1:length(handles.conditions) 
%     % find condition by looking for a match of object handles
%     if cHandle == handles.conditions(c).h
%         handles.rules(rSel).condition = c;
%         break
%     end
% end
% guidata(hObject,handles);


% --- Executes on button press in buttonLoadExper.
function buttonLoadExper_Callback(hObject, eventdata, handles)
% hObject    handle to buttonLoadExper (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[FileName,PathName] = uigetfile('*.mat');
temp = load([PathName FileName]);
handles.exper = temp.exper;
% put list of files in box
n = 1:getLatestDatafileNumber(handles.exper);
str = mat2cell(n',ones(size(n)), 1);
set(handles.listFiles,'String',str);
set(handles.listFiles,'Value',1);
guidata(hObject,handles)


% --- Executes on button press in buttonLoadRules.
function buttonLoadRules_Callback(hObject, eventdata, handles)
% hObject    handle to buttonLoadRules (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[FileName,PathName] = uigetfile('*.mat');
temp = load([PathName FileName]);
handles.rules = temp.handles.rules;
handles.list2rule = temp.handles.list2rule;
if isfield(temp.handles, 'tdt')
    % for backwards compatability, checks to see if the field exists. In
    % rules made before 2011-02-03 this field will not exist
    handles.tdt = temp.handles.tdt;
    set(handles.editTdtCircuit, 'String', handles.tdt.rcx);
end
% put list of rules in box
str = cell(length(handles.list2rule),1);
for n = 1:length(handles.list2rule)
    r = handles.list2rule(n);
    str{n} = handles.rules(r).name;
end
set(handles.listRules,'String',str);
if isfield(temp.handles,'testSuffix')
    set(handles.editTestSuffix,'String',temp.handles.testSuffix)
    handles.testSuffix = temp.handles.testSuffix;
end
guidata(hObject,handles)
refreshRuleDisplay(handles)
    


% --- Executes on button press in buttonSaveRules.
function buttonSaveRules_Callback(hObject, eventdata, handles)
% hObject    handle to buttonSaveRules (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[FileName,PathName] = uiputfile('*.mat');
save([PathName FileName], 'handles')


% --- Executes on selection change in listFiles.
function listFiles_Callback(hObject, eventdata, handles)
% hObject    handle to listFiles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns listFiles contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listFiles


% --- Executes during object creation, after setting all properties.
function listFiles_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listFiles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function panelRule_CreateFcn(hObject, eventdata, handles)
% hObject    handle to panelRule (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on selection change in popupCondition.
function popupCondition_Callback(hObject, eventdata, handles)
% hObject    handle to popupCondition (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupCondition contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupCondition
c = get(handles.popupCondition,'Value');
tags = handles.conditions(c).tdtTags;
suff = str2double(get(handles.editPartagSuffix,'String'));
handles.rules(handles.rSel).condition = c;
handles.rules(handles.rSel).tdtTags =  makeSuffix(tags, suff);
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function popupCondition_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupCondition (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in buttonTestSyllable.
function buttonTestSyllable_Callback(hObject, eventdata, handles)
% hObject    handle to buttonTestSyllable (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%% Ask for target syllables and region

% Dialog box to ask for info on testing
prompt = {'Target syllable(s):','Target region start (ms):','Target region end (ms):'};
dlg_title = 'Input';
num_lines = 1;
answer = inputdlg(prompt,dlg_title,num_lines,handles.testSyllablesDefaults);

if isempty(answer)
    return
end

% Update defaults of that dialog box to be the answers we just received
handles.testSyllablesDefaults = answer;
guidata(hObject, handles)

% Call function to do the testing
target_syllable = str2num(answer{1});
target_range = [str2num(answer{2}), str2num(answer{3})];
testRulesBySyllable(handles.rules, handles.exper, ...
    'File', get(handles.listFiles, 'Value'), ...
    'TargetSyllable', target_syllable, ...
    'TargetRange', target_range)

function editPartagSuffix_Callback(hObject, eventdata, handles)
% hObject    handle to editPartagSuffix (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editPartagSuffix as text
%        str2double(get(hObject,'String')) returns contents of editPartagSuffix as a double
suff = str2double(get(hObject,'String'));
tags = handles.rules(handles.rSel).tdtTags;
handles.rules(handles.rSel).tdtPartagSuffix = suff;
handles.rules(handles.rSel).tdtTags =  makeSuffix(tags, suff);
guidata(hObject, handles)

% --- Executes during object creation, after setting all properties.
function editPartagSuffix_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editPartagSuffix (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in buttonTestTDT.
function buttonTestTDT_Callback(hObject, eventdata, handles)
% hObject    handle to buttonTestTDT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.testSuffix = get(handles.editTestSuffix,'String');
handles = exportTDT(handles);
Fs_in = handles.exper.desiredInSampRate;
Fs = 24414; %Hz, TDT sampling rate
audio_in = loadAudio(handles.exper, get(handles.listFiles,'Value'));
audio = resample2(audio_in, Fs, Fs_in);
audio = audio - mean(audio);
noise = testRulesTdt(audio, handles.RP, handles.testSuffix);
figure
axh(1) = subplot(2,1,1);
displaySpecgramQuick(audio, Fs)
axh(2) = subplot(2,1,2);
t = (0:length(noise)-1)*1/Fs;
plot(t,noise)
linkaxes(axh, 'x')
guidata(hObject, handles)

% --- Executes on button press in buttonExportTDT.
function buttonExportTDT_Callback(hObject, eventdata, handles)
% hObject    handle to buttonExportTDT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = exportTDT(handles);
guidata(hObject, handles)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function handles = exportTDT(handles)
loadflag = 1; %determines if new circuit will be loaded. default yes.
if ~isfield(handles,'RP')
    handles.RP = actxcontrol('RPco.x',[5 5 26 26]);
end
handles.RP.ConnectRX8('USB', 1);
status=double(handles.RP.GetStatus); % Get status
if bitget(status,1)==0; % Checks for connection
    disp('Error connecting to RX8');
end

% If we are automatically reloading and circuit has changed since last
% time, reload it. Otherwise, load into existing circuit
reload = get(handles.checkReloadTdt, 'Value');
file = dir(handles.tdt.rcx);
last_modified_time = file.datenum;
try
    circuit_modified = last_modified_time > handles.tdt.rcx_modification_time;
catch
    circuit_modified = true; %when in doubt, just reload the circuit
end
handles.tdt.rcx_modification_time = last_modified_time;
if reload && circuit_modified
    debugdisp('Reloading circuit')
    handles.RP.Halt; % Stops any processing chains running on RP2
    handles.RP.ClearCOF; % Clears all the buffers and circuits on RP2
    handles.RP.LoadCOF(handles.tdt.rcx);
    handles.RP.Run;
    status=double(handles.RP.GetStatus); % Get status
    if bitget(status,1)==0; % Checks for connection
        disp('Error connecting to device');
    elseif bitget(status,2)==0; % Checks for errors in loading circuit
        disp('Error loading circuit');
    elseif bitget(status,3)==0
        disp('Error running circuit');
    else
        disp('Circuit loaded and running');
    end
else
    debugdisp('Loading into existing circuit')
    % User needs to choose the circuit file that is already running.
    % This will NOT reload the circuit on the TDT. We just need the
    % circuit file so that the ActiveX control can access the ParTags.
    % See TDT's ActiveX documentation on ReadCOF for more info.
    handles.RP.ReadCOF(handles.tdt.rcx);
end


for r = 1:length(handles.rules)
    if handles.rules(r).visible
        exportRule2tdt(handles.rules(r),handles.RP)
    end
end
disp('Rules loaded')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function editTestSuffix_Callback(hObject, eventdata, handles)
% hObject    handle to editTestSuffix (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editTestSuffix as text
%        str2double(get(hObject,'String')) returns contents of editTestSuffix as a double
handles.testSuffix = get(hObject,'String');
guidata(hObject, handles)


% --- Executes during object creation, after setting all properties.
function editTestSuffix_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editTestSuffix (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkReloadTDT.
function checkReloadTDT_Callback(hObject, eventdata, handles)
% hObject    handle to checkReloadTDT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkReloadTDT



function editTdtCircuit_Callback(hObject, eventdata, handles)
% hObject    handle to editTdtCircuit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editTdtCircuit as text
%        str2double(get(hObject,'String')) returns contents of editTdtCircuit as a double
handles.tdt.rcx = get(hObject,'String');
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function editTdtCircuit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editTdtCircuit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in buttonBrowseTdt.
function buttonBrowseTdt_Callback(hObject, eventdata, handles)
% hObject    handle to buttonBrowseTdt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[FileName,PathName,FilterIndex] = uigetfile('*.rcx');
if FileName == 0 % if user pushed cancel
    return
end
handles.tdt.rcx = [PathName FileName];
set(handles.editTdtCircuit, 'String', handles.tdt.rcx);
guidata(hObject, handles);


% --- Executes on button press in checkReloadTdt.
function checkReloadTdt_Callback(hObject, eventdata, handles)
% hObject    handle to checkReloadTdt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkReloadTdt


function panelCondition_CreateFcn(hObject, eventdata, handles)

