function varargout = ruleEditor(varargin)
% RULEEDITOR M-file for ruleEditor.fig
%      RULEEDITOR, by itself, creates a new RULEEDITOR or raises the existing
%      singleton*.
%
%      H = RULEEDITOR returns the handle to a new RULEEDITOR or the handle to
%      the existing singleton*.
%
%      RULEEDITOR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in RULEEDITOR.M with the given input arguments.
%
%      RULEEDITOR('Property','Value',...) creates a new RULEEDITOR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ruleEditor_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ruleEditor_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ruleEditor

% Last Modified by GUIDE v2.5 18-Aug-2014 16:54:09

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ruleEditor_OpeningFcn, ...
                   'gui_OutputFcn',  @ruleEditor_OutputFcn, ...
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


% --- Executes just before ruleEditor is made visible.
function ruleEditor_OpeningFcn(hObject, eventdata, handles, varargin)%#ok
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ruleEditor (see VARARGIN)

% Get bird info passed from rules_multiple_birds
handles.birdinfo = varargin{1};
handles.rules = handles.birdinfo.rules;
handles.exper = handles.birdinfo.exper;
handles.targetSyllable = handles.birdinfo.targetSyllable;
handles.targetRegionMs = handles.birdinfo.targetRegion;
if isempty(handles.rules)
    handles.list2rule = [];
else
    handles.list2rule = find([handles.rules.visible]);
end


% Get different rule types and put them in the rule type popup control
handles.conditions = ruleConditions;
set(handles.popupCondition, 'String', {handles.conditions.name})

% Default parameters for testing
handles.testFile = 1; % default file number to analyze when "All rules for one file" button is pushed
handles.statsFiles = 1; % default file numbers to do statistics on when "Hit/escape statistics" button is pushed

% List of file numbers (used for testing dialogues)
filenum = 1:getLatestDatafileNumber(handles.exper);
handles.filestr = arrayfun(@int2str, filenum, 'UniformOutput', false); % cell array of strings

% Template deleted rule.
% When a rule is 'deleted' it really just turns invisible (by setting it
% equal to this template rule). We don't actually remove it because that
% would make it complicated to keep track of dependencies between rules.
% Invisibility is accomplished by setting the 'visible' property to false
% and also removing the corresponding entry in handles.list2rule
handles.DELETED_RULE = struct(handles.rules);
handles.DELETED_RULE = handles.DELETED_RULE([]); % make empty struct with same format as handles.rules
handles.DELETED_RULE(1).name = 'DELETED';
handles.DELETED_RULE(1).visible = false;
handles.DELETED_RULE(1).summary = 'This is a deleted rule. You should never see this text.';
handles.DELETED_RULE(1).tdtPartagSuffix = NaN;

handles.rSel = 1; % selected rule
handles = updateDisplay(handles);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ruleEditor wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ruleEditor_OutputFcn(hObject, eventdata, handles)%#ok
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isempty(handles)
    varargout{1} = [];
else
    handles.birdinfo.rules = handles.rules;
    handles.birdinfo.targetSyllable = handles.targetSyllable;
    handles.birdinfo.targetRegion = handles.targetRegionMs;
    visibleRules = handles.rules([handles.rules.visible]);
    handles.birdinfo.ruleSummary = strjoin({visibleRules.summary}, '\n\n');
    varargout{1} = handles.birdinfo;
    delete(handles.figure1)
end


function editRuleName_Callback(hObject, eventdata, handles)%#ok
% hObject    handle to editRuleName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

newName = get(hObject,'String');
nSel = get(handles.listRules,'Value');
handles.rules(handles.list2rule(nSel)).name = newName;
handles = updateDisplay(handles);
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function editRuleName_CreateFcn(hObject, eventdata, handles)%#ok
% hObject    handle to editRuleName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in buttonCondition.
function buttonCondition_Callback(hObject, eventdata, handles)%#ok
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
handles.rules(handles.rSel).summary = summarizeRule(handles.rules(handles.rSel));
handles = updateDisplay(handles);
guidata(hObject,handles)


% --- Executes on selection change in listRules.
function listRules_Callback(hObject, eventdata, handles)%#ok
% hObject    handle to listRules (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns listRules contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listRules

handles.rSel = handles.list2rule(get(handles.listRules,'Value'));
handles = updateDisplay(handles);
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function listRules_CreateFcn(hObject, eventdata, handles)%#ok
% hObject    handle to listRules (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in buttonNew.
function buttonNew_Callback(hObject, eventdata, handles)%#ok
% hObject    handle to buttonNew (see GCBO)
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
handles.rules(n).params = [];
handles.rules(n).summary = 'This is an empty rule. Choose a type and click the Design button below.';
% add a new element to the ruleEditor list
rulesList = get(handles.listRules,'String');
rulesList{end+1} = handles.rules(n).name;
set(handles.listRules,'String',rulesList);
handles.list2rule(end+1) = n;
% select the new rule
set(handles.listRules,'Value',length(handles.list2rule))
handles.rSel = n;
%
handles = updateDisplay(handles);
guidata(hObject,handles);


% --- Executes on button press in buttonTest.
function buttonTest_Callback(hObject, eventdata, handles)%#ok
% hObject    handle to buttonTest (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Prompt user to select file
[sel, ok] = listdlg('ListString', handles.filestr, ...
                    'SelectionMode', 'single', ...
                    'InitialValue', handles.testFile, ...
                    'Name', 'Test all rules on one file', ...
                    'PromptString', 'Choose one file');
if ~ok
    return
end
handles.testFile = sel;

% get audio
Fs_in = handles.exper.desiredInSampRate;
Fs = 24414; %Hz, TDT sampling rate
audio_in = loadAudio(handles.exper, handles.testFile);
audio = resample2(audio_in, Fs, Fs_in);
audio = audio - mean(audio);
t = (0:length(audio)-1) * 1/Fs;
% get list of ruleEditor to test
toTest = handles.list2rule;
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
        % if there are some ruleEditor that can't be evaluated, error
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
figure; % new figure
axh = zeros(1,length(toTest + 1)); % list of axes handles to link later
% spectrogram with noise marked
axh(1) = subplot(m,1,1:3);
displaySpecgramQuick(audio, Fs)

% a separate subplot for each rule
for n = 1:length(toTest)
    r = toTest(n);
    axh(n+1) = subplot(m,1,n+3);
    plot(t,bRuleMet(:,r))
    axis off
    title(handles.rules(r).name)
end
linkaxes(axh,'x')
guidata(hObject, handles)

% --- Executes on button press in buttonDelete.
function buttonDelete_Callback(hObject, eventdata, handles)%#ok
% hObject    handle to buttonDelete (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% remove selected rule from handles.list2rule
isSelected = handles.list2rule == handles.rSel;
assert(sum(isSelected) == 1)
handles.list2rule = handles.list2rule(~isSelected); 

% set it to the deleted rule template
handles.rules(handles.rSel) = handles.DELETED_RULE;

% select the previous rule
iSel = find(isSelected);
if isempty(handles.list2rule)
    handles.rSel = 1;
elseif iSel > length(handles.list2rule)
    handles.rSel = handles.list2rule(end);
else
    handles.rSel = handles.list2rule(iSel);
end

handles = updateDisplay(handles);
guidata(hObject,handles);


% --- Executes on button press in actionNoise.
function actionNoise_Callback(hObject, eventdata, handles)%#ok
% hObject    handle to actionNoise (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of actionNoise
rSel = handles.list2rule(get(handles.listRules,'Value')); % selected rule #
handles.rules(rSel).actionNoise = get(hObject,'Value');
guidata(hObject,handles);


% --- Executes on selection change in popupCondition.
function popupCondition_Callback(hObject, eventdata, handles)%#ok
% hObject    handle to popupCondition (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupCondition contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupCondition
c = get(handles.popupCondition,'Value');
tags = handles.conditions(c).tdtTags;
suff = handles.rules(handles.rSel).tdtPartagSuffix;
handles.rules(handles.rSel).condition = c;
handles.rules(handles.rSel).tdtTags =  makeSuffix(tags, suff);
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function popupCondition_CreateFcn(hObject, eventdata, handles)%#ok
% hObject    handle to popupCondition (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in buttonTestSyllable.
function buttonTestSyllable_Callback(hObject, eventdata, handles)%#ok
% hObject    handle to buttonTestSyllable (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%% Ask for target syllables and region
dlg_title = 'Hit/escape statistics';
num_lines = 1;
prompt{1} = 'Target syllable(s):';
def{1} = num2str(handles.targetSyllable);
prompt{2} = 'Target region start (ms):';
def{2} = num2str(handles.targetRegionMs(1));
prompt{3} = 'Target region end (ms):';
def{3} = num2str(handles.targetRegionMs(2));
answer = inputdlg(prompt,dlg_title,num_lines,def);

if isempty(answer)
    return
end
handles.targetSyllable = str2num(answer{1});
handles.targetRegionMs = [str2double(answer{2}), str2double(answer{3})];
if isempty(handles.targetSyllable)
    errordlg('Invalid target syllable')
    return
end
if any(isnan(handles.targetRegionMs))
    errordlg('Invalid target range')
    return
end

[sel, ok] = listdlg('ListString', handles.filestr, ...
                    'SelectionMode', 'multiple', ...
                    'InitialValue', handles.statsFiles, ...
                    'Name', 'Hit/escape statistics', ...
                    'PromptString', 'Choose multiple files (hold shift)');
if ~ok
    return
end
handles.statsFiles = sel;

guidata(hObject, handles)

testRulesBySyllable(handles.rules, handles.exper, ...
    'File', handles.statsFiles, ...
    'TargetSyllable', handles.targetSyllable, ...
    'TargetRange', handles.targetRegionMs)

% --- Executes on button press in buttonUp.
function buttonUp_Callback(hObject, eventdata, handles)%#ok
% hObject    handle to buttonUp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
numOld = handles.rules(handles.rSel).tdtPartagSuffix;
if numOld == 1 % already at the top, cannot move up farther
    return
end
numNew = numOld - 1;

% If another rule already has the new number, switch numbers with it!
hasNewNum = [handles.rules.tdtPartagSuffix] == numNew;
if any(hasNewNum)
    handles.rules(hasNewNum).tdtPartagSuffix = numOld;
end

handles.rules(handles.rSel).tdtPartagSuffix = numNew;
handles = updateDisplay(handles);
guidata(hObject, handles)

% --- Executes on button press in buttonDown.
function buttonDown_Callback(hObject, eventdata, handles)%#ok
% hObject    handle to buttonDown (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
numOld = handles.rules(handles.rSel).tdtPartagSuffix;
numNew = numOld + 1;

% If another rule already has the new number, switch numbers with it!
hasNewNum = [handles.rules.tdtPartagSuffix] == numNew;
if any(hasNewNum)
    handles.rules(hasNewNum).tdtPartagSuffix = numOld;
end

handles.rules(handles.rSel).tdtPartagSuffix = numNew;
handles = updateDisplay(handles);
guidata(hObject, handles)

% --- Executes on button press in buttonDone.
function buttonDone_Callback(hObject, eventdata, handles)%#ok
% hObject    handle to buttonDone (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
uiresume(handles.figure1);

function panelCondition_CreateFcn(hObject, eventdata, handles)%#ok
% This function is intentionally left blank (but MATLAB throws an error on 
% GUI creation if it doesn't exist).

function handles = updateDisplay(handles)
if ~isfield(handles, 'rules') || isempty(handles.list2rule) % if there are no visible rules
    % The listbox must have at least one entry in its 'String' property, so
    % set it to an empty string
    set(handles.listRules, 'String', '')
    set(handles.listRules, 'Value', 1)
    
    % disable rule editing controls
    set(handles.editRuleName,'Enable','off')
    set(handles.popupCondition,'Enable','off')
    set(handles.actionNoise,'Enable','off')
    set(handles.buttonCondition,'Enable','off')
    return
end

set(handles.editRuleName,'Enable','on')
set(handles.popupCondition,'Enable','on')
set(handles.actionNoise,'Enable','on')
set(handles.buttonCondition,'Enable','on')

% update the list of rules
[~, ordr] = sort([handles.rules.tdtPartagSuffix]); % display in order by tdtPartagSuffix
handles.list2rule = ordr([handles.rules(ordr).visible]);
displayName = cell(size(handles.list2rule));
for ii = 1:length(handles.list2rule)
    r = handles.rules(handles.list2rule(ii));
    displayName{ii} = sprintf('%g. %s', r.tdtPartagSuffix, r.name);
end
set(handles.listRules, 'String', displayName)
iSel = find(handles.list2rule == handles.rSel);
iSel = max(iSel, 1);                         % make sure iSel is in range
iSel = min(iSel, length(handles.list2rule)); % make sure iSel is in range
set(handles.listRules, 'Value', iSel)
handles.rSel = handles.list2rule(iSel); % update rSel because iSel may have changed above

r = handles.rules(handles.rSel);

% selected rule summary
set(handles.textRuleSummary, 'String', r.summary)
% selected rule type (textbox and panel title)
set(handles.popupCondition, 'Value', r.condition)
% selected rule name 
set(handles.editRuleName, 'String', r.name)
set(handles.panelRule, 'Title', ['Rule: ' r.name])
% selected rule play noise
set(handles.actionNoise, 'Value', r.actionNoise)
