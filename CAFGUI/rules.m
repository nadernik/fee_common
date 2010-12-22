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

% Last Modified by GUIDE v2.5 19-Aug-2010 13:50:45

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
% button group 'panelCondition' and add an entry to variable c above. You
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
rSel = handles.list2rule(get(handles.listRules,'Value'));
% get the condition
c = handles.rules(rSel).condition;
% open up the editor
handles.rules(rSel).params = handles.conditions(c).editFcn(handles);
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

% --- Executes when selected object is changed in panelCondition.
function panelCondition_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in panelCondition 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)
% rSel = handles.list2rule(get(handles.listRules,'Value')); % selected rule #
% cHandle = get(handles.panelCondition,'SelectedObject');
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
function panelCondition_CreateFcn(hObject, eventdata, handles)
% hObject    handle to panelCondition (see GCBO)
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
idx = strfind(handles.exper.dir,filesep);
dirname = handles.exper.dir(1:idx(end-1)); % like c:\data\birdname\
annoTemplate = '%s_annotation_%s%s.mat';
miscTemplate = '%s_all_misc_%s%s.mat';
annoFile = [dirname sprintf(annoTemplate, handles.exper.birdname, handles.exper.expername, '')];
miscFile = [dirname sprintf(miscTemplate, handles.exper.birdname, handles.exper.expername, '')];
part = 1;
elements = {};
keys = {};
misc = struct('segs',[],'bRand',[]);
while exist(annoFile,'file')
    % load this file and add collect elements and keys
    temp = load(annoFile);
    elements = [elements temp.elements];
    keys = [keys temp.keys];
    temp = load(miscFile);
    misc.segs = [misc.segs temp.misc.segs];
    misc.bRand = [misc.bRand; temp.misc.bRand];
    % make the next filename. keep going until file doesn't exist.
    part = part + 1;
    partstr = sprintf('-pt%03.g',part); %like -pt002
    annoFile = [dirname sprintf(annoTemplate, handles.exper.birdname, handles.exper.expername, partstr)];
    miscFile = [dirname sprintf(miscTemplate, handles.exper.birdname, handles.exper.expername, partstr)];
end

%% apply filters to each file
fileList = get(handles.listFiles,'Value');
noiseByCluster = {[] };
sampledFlag = zeros(1000,1);
for nel = 1:length(elements)
    if ismember( elements{nel}.filenum, fileList )
        % for each selected file
        nf = elements{nel}.filenum%%%DEBUG
        % load audio
        Fs_in = handles.exper.desiredInSampRate;
        Fs = 24414; %Hz, TDT sampling rate
        audio_in = loadAudio(handles.exper, nf);
        audio = resample(audio_in, Fs, Fs_in);
        t = (0:length(audio)-1) * 1/Fs;
        % apply rules to determine noise
        bNoise = testRulesOnFile(handles,audio);
        % classify noise into syllables
        tStart = elements{nel}.segFileStartTimes;
        tEnd = elements{nel}.segFileEndTimes;
        clust = getClusterNumber(nel,elements,keys,misc);
        for s = 1:length(tStart) % for each syllable
            % clust = -1 for unclustered syllables
            if clust(s) > 0 % skip unclustered syllables
                % is there noise in this syllable?
                idx = t > tStart(s) & t < tEnd(s);
                syllNoise = bNoise(idx);
                % chop off remainder so we can resample
                L = length(syllNoise);%floor(length(syllNoise)/100)*100;
                if ~sampledFlag(clust(s))
                    sampleaudio{clust(s)} = audio(idx);
                    sampledFlag(clust(s)) = 1;
                end
                
                noiseByCluster{clust(s)}(:,end+1) = resample(syllNoise(1:L),100,L);
                % decimateMinMax(syllNoise,floor(length(syllNoise)/100));
            end
        end
    end
end

%% assemble statistics
for clust = 1:length(noiseByCluster) % for each cluster
    nz = noiseByCluster{clust};
    pct = sum(any(nz))/size(nz,2) * 100;
    str = sprintf('Cluster %g, %.f%% hit',clust,pct);
    figure
    % plot example syllable spectrogram
    axh(1) = subplot(2,1,1);
    displaySpecgramQuick(sampleaudio{clust}, Fs)
    % show where noise is
    axh(2) = subplot(2,1,2);
    xlims = xlim(axh(1));
    x = linspace(xlims(1),xlims(2),size(nz,1));
    y = 1:size(nz,2);
    imagesc(x,y,nz')
    title(str)
    linkaxes(axh,'x')
end



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

handles = exportTDT(handles);
Fs_in = handles.exper.desiredInSampRate;
Fs = 24414; %Hz, TDT sampling rate
audio_in = loadAudio(handles.exper, get(handles.listFiles,'Value'));
audio = resample(audio_in, Fs, Fs_in);
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

% check to see if something is currently running
status=double(handles.RP.GetStatus); % Get status
if bitget(status,3)==1 % if circuit is currently RUNNING
    button = questdlg('There is already a circuit running! Load these rules into the running circuit?');
    if isempty(button) %if user pushed 'Cancel' then stop loading
        return
    elseif strcmpi(button,'yes')
        loadflag = 0;
    end
end
%     cd('C:\Documents and Settings\stetner\Desktop\research\code\tdt\caf')
[FileName,PathName,FilterIndex] = uigetfile('*.rcx','Choose Circuit');
if loadflag
    handles.RP.Halt; % Stops any processing chains running on RP2
    handles.RP.ClearCOF; % Clears all the buffers and circuits on RP2
    handles.RP.LoadCOF([PathName FileName]);
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
    % User needs to choose the circuit file that is already running.
    % This will NOT reload the circuit on the TDT. We just need the
    % circuit file so that the ActiveX control can access the ParTags.
    % See TDT's ActiveX documentation on ReadCOF for more info.
    handles.RP.ReadCOF([PathName FileName]);
end


for r = 1:length(handles.rules)
    if handles.rules(r).visible
        exportRule2tdt(handles.rules(r),handles.RP)
    end
end
disp('Rules loaded')



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


