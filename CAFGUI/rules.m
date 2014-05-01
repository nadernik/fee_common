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

% a list of all conditions
c(1).name = 'Raw Power (Sliding Boxcar)';
c(1).editFcn = @rawPowerGUI;
c(1).tdtTags(1).name = 'rawCoef';
c(1).tdtTags(1).type = 'buffer';
c(1).tdtTags(1).size = 33;
c(1).tdtTags(1).pfield = 'Numerator';
c(1).tdtTags(2).name = 'rawThresh';
c(1).tdtTags(2).type = 'scalar';
c(1).tdtTags(2).pfield = 'threshold';
c(1).tdtTags(3).name = 'rawSteps';
c(1).tdtTags(3).type = 'scalar';
c(1).tdtTags(3).pfield = 'stepsAbove';
c(1).tdtTags(4).name = 'rawStepsMax';
c(1).tdtTags(4).type = 'scalar';
c(1).tdtTags(4).pfield = 'stepsMax';

c(2).name = 'Bandpassed Sound Power';
c(2).editFcn = @bandPowerGUI;
c(2).tdtTags(1).name = 'band1coef';
c(2).tdtTags(1).type = 'buffer';
c(2).tdtTags(1).size = 208;
c(2).tdtTags(1).pfield = 'coefs1';
c(2).tdtTags(2).name = 'band2coef';
c(2).tdtTags(2).type = 'buffer';
c(2).tdtTags(2).size = 208;
c(2).tdtTags(2).pfield = 'coefs2';
c(2).tdtTags(3).name = 'bandLP';
c(2).tdtTags(3).type = 'buffer';
c(2).tdtTags(3).size = 33;
c(2).tdtTags(3).pfield = 'lpcoefs';
c(2).tdtTags(4).name = 'bandThresh';
c(2).tdtTags(4).type = 'scalar';
c(2).tdtTags(4).pfield = 'threshold';
c(2).tdtTags(5).name = 'bandSteps';
c(2).tdtTags(5).type = 'scalar';
c(2).tdtTags(5).pfield = 'stepsAbove';

c(3).name = 'Pitch (CAFGUI)';
c(3).editFcn = @pitchGUI;
c(3).tdtTags(1).name = 'in1pitch';
c(3).tdtTags(1).type = 'buffer';
c(3).tdtTags(1).size = 300;
c(3).tdtTags(1).pfield = 'coefIn1';
c(3).tdtTags(2).name = 'in2pitch';
c(3).tdtTags(2).type = 'buffer';
c(3).tdtTags(2).size = 300;
c(3).tdtTags(2).pfield = 'coefIn2';
c(3).tdtTags(3).name = 'in3pitch';
c(3).tdtTags(3).type = 'buffer';
c(3).tdtTags(3).size = 300;
c(3).tdtTags(3).pfield = 'coefIn3';
c(3).tdtTags(4).name = 'out1pitch';
c(3).tdtTags(4).type = 'buffer';
c(3).tdtTags(4).size = 300;
c(3).tdtTags(4).pfield = 'coefOut1';
c(3).tdtTags(5).name = 'out2pitch';
c(3).tdtTags(5).type = 'buffer';
c(3).tdtTags(5).size = 300;
c(3).tdtTags(5).pfield = 'coefOut2';
c(3).tdtTags(6).name = 'out3pitch';
c(3).tdtTags(6).type = 'buffer';
c(3).tdtTags(6).size = 300;
c(3).tdtTags(6).pfield = 'coefOut3';
c(3).tdtTags(7).name = 'threshPitch';
c(3).tdtTags(7).type = 'scalar';
c(3).tdtTags(7).pfield = 'pitchThreshold';
c(3).tdtTags(8).name = 'lpPitch';
c(3).tdtTags(8).type = 'buffer';
c(3).tdtTags(8).size = 55;
c(3).tdtTags(8).pfield = 'coefLP';

c(4).name = 'Boolean Statement';
c(4).editFcn = @booleanGUI;
c(4).tdtTags(1).name = 'boolSteps';
c(4).tdtTags(1).type = 'scalar';
c(4).tdtTags(1).pfield = 'stepsAbove';
c(4).tdtTags(2).name = 'boolDelay';
c(4).tdtTags(2).type = 'scalar';
c(4).tdtTags(2).pfield = 'timeDelay';
c(4).tdtTags(3).name = 'boolHi';
c(4).tdtTags(3).type = 'scalar';
c(4).tdtTags(3).pfield = 'stepsHigh';

handles.conditions = c;
% to add more conditions, you need to add a radio button to the radio
% button group 'panelRule' and add an entry to variable c above. You
% should always add to the end of c, otherwise you will break compatability
% with old save files.
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
% keyboard %%%DEBUG
% get audio
Fs_in = handles.exper.desiredInSampRate;
Fs = 24414; %Hz, TDT sampling rate
audio_in = loadAudio(handles.exper, get(handles.listFiles,'Value'));
audio = resample(audio_in, Fs, Fs_in);
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
% keyboard %%%DEBUG

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

%% load all annotations
wbh = waitbar(0);
filenum_list = get(handles.listFiles,'Value');
total_files = length(filenum_list);
filename_list = arrayfun(@getExperAudioFilename, repmat(handles.exper, 1, total_files), filenum_list, 'UniformOutput', false);

% infer rootdir from exper dir
idx = strfind(handles.exper.dir,filesep);
rootdir = handles.exper.dir(1:idx(end-2)); % like c:\data\

miscfiles = getProcessedDataFiles(handles.exper.birdname,'experNames',handles.exper.expername, 'rootdir', rootdir);
pitchfiles = getProcessedDataFiles(handles.exper.birdname,'experNames',handles.exper.expername, 'rootdir', rootdir, 'dataType', 'pitch');

all_syll_noise = [];
all_syll_type = [];
all_pitch = [];
files_processed = 0;
for ii = 1:length(miscfiles)
    load([rootdir handles.exper.birdname filesep miscfiles(ii).name])
    pitch_loaded = false;
    for jj = 1:total_files
        key = filename_list(jj);
        % get segs from this file
        idx_seg_file = cellfun(@strcmp, {misc.segs.key}, repmat({key}, size(misc.segs)));
        if any(idx_seg_file)
            files_processed = files_processed + 1;
        end
        idx_seg_file = idx_seg_file & [misc.segs.segType] ~= -1; % skip unclustered syllables
        total_syllables = sum(idx_seg_file);
        if total_syllables > 0 % if we have segs, load audio and apply rules
            % load audio
            audio_in = loadAudio(handles.exper, filenum_list(jj));
            Fs_in = handles.exper.desiredInSampRate;
            Fs_tdt = 24414; %Hz, TDT sampling rate
            audio = resample(audio_in, Fs_tdt, Fs_in);
            audio = audio - mean(audio);
            % apply rules
            file_noise = testRulesOnFile(handles, audio);
            % map noise onto syllables
            t = (0:length(audio)-1) * 1/Fs_tdt;
            t = repmat({t}, total_syllables, 1);
            temp = [[misc.segs(idx_seg_file).fStartTime]' [misc.segs(idx_seg_file).fEndTime]'];
            t_range = mat2cell(temp, ones(1,size(temp,1)), 2);
            syll_noise = cellfun(@extract_time_range, repmat({file_noise}, total_syllables, 1), t, t_range, 'UniformOutput', false);
            all_syll_noise = [all_syll_noise; syll_noise];
            syll_type = [misc.segs(idx_seg_file).segType];
            all_syll_type = [all_syll_type syll_type];
            % load pitch
            if ~pitch_loaded
                load([rootdir handles.exper.birdname filesep pitchfiles(ii).name])
                pitch_loaded = true;
            end
            all_pitch = [all_pitch {pitch.segs(idx_seg_file).pitch}];                
        end
        waitbar(files_processed / total_files)
    end %file
end %miscfile

L = cellfun(@length,all_syll_noise,'UniformOutput',false);
all_syll_noise = cellfun(@resample, all_syll_noise, repmat({100},size(L)), L,'UniformOutput',false);
all_syll_noise = cell2mat(all_syll_noise');

for clust = unique(all_syll_type)
    figure
    % example spectrogram FIXME
    %axh(1) = subplot(3,1,1)
    %displaySpecgramQuick(sampleaudio{clust}, Fs)
    % noise
    axh(2) = subplot(3,1,2);
    imagesc(all_syll_noise(:,all_syll_type == clust)')
    %xlims = xlim(axh(1));
    %nz = all_syll_noise(all_syll_type == clust);
    %x = linspace(xlims(1),xlims(2),size(nz,1));
    %y = 1:size(nz,2);
    %imagesc(x,y,nz')
    % pitch traces
    axh(3) = subplot(3,1,3);
    has_noise = any(all_syll_noise);
    hold on
    idx = has_noise & all_syll_type == clust;
    cellfun(@plot, all_pitch(idx), repmat({'r'},1,sum(idx)))
    hits = sum(idx);
    idx = ~has_noise & all_syll_type == clust;
    cellfun(@plot, all_pitch(idx), repmat({'b'},1,sum(idx)))
    escapes = sum(idx);
    %linkaxes(axh,'x') %FIXME
    N = hits + escapes;
    title(sprintf('Cluster %g N = %g %.0f%% hit',clust,N,hits/N * 100))
end
close(wbh)

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
audio = resample(audio_in, Fs, Fs_in);
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

