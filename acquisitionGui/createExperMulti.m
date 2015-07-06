function varargout = createExperMulti(varargin)
% CREATEEXPERMULTI M-file for createExperMulti.fig
%      CREATEEXPERMULTI, by itself, creates a new CREATEEXPERMULTI or raises the existing
%      singleton*.
%
%      H = CREATEEXPERMULTI returns the handle to a new CREATEEXPERMULTI or the handle to
%      the existing singleton*.
%
%      CREATEEXPERMULTI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CREATEEXPERMULTI.M with the given input arguments.
%
%      CREATEEXPERMULTI('Property','Value',...) creates a new CREATEEXPERMULTI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before createExperMulti_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to createExperMulti_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help createExperMulti

% Last Modified by GUIDE v2.5 07-Jan-2011 14:10:46

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @createExperMulti_OpeningFcn, ...
                   'gui_OutputFcn',  @createExperMulti_OutputFcn, ...
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


% --- Executes just before createExperMulti is made visible.
function createExperMulti_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to createExperMulti (see VARARGIN)

% Choose default command line output for createExperMulti
handles.output = hObject;

% song detection parameters
handles.songDetection_default.songDensity = 0.5;
handles.songDetection_default.powerThres = 2;
handles.songDetection_default.songLength = 1;
handles.songDetection_default.minFreq = 2000;
handles.songDetection_default.maxFreq = 6000;

handles.fieldnames = {'Birdname', 'Expername', 'Sigchan', 'Samprate'};

try
    handles = load_values('createExperMulti_defaults.mat', handles);
catch
    disp('Could not load defaults from file.')
    % use these hard coded defaults
    handles.val.checkSameBirdname = 0;
    handles.val.checkSameExpername = 1;
    handles.val.checkSameSigchan = 0;
    handles.val.checkSameSamprate = 1;
    
    for ch = 0:7
        handles.val.(sprintf('editBirdname%g', ch)) = '';
        handles.val.(sprintf('editExpername%g', ch)) = datestr(today,'yyyy-mm-dd');
        handles.val.(sprintf('editSigchan%g', ch)) = '';
        handles.val.(sprintf('editSamprate%g', ch)) = '40000';
    end
    
    handles.val.editRootdir = 'C:\Users\emackev\Documents\MATLAB\AcqGui2';
end

update_display(handles)

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes createExperMulti wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = createExperMulti_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function editBirdname0_Callback(hObject, eventdata, handles)
% hObject    handle to editBirdname0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.val.editBirdname0 = get(hObject,'String');
handles = same_for_all('Birdname', 0, handles);
update_display(handles);
guidata(hObject, handles)


% --- Executes during object creation, after setting all properties.
function editBirdname0_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editBirdname0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editBirdname1_Callback(hObject, eventdata, handles)
% hObject    handle to editBirdname1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.val.editBirdname1 = get(hObject,'String');
handles = same_for_all('Birdname', 1, handles);
update_display(handles);
guidata(hObject, handles)


% --- Executes during object creation, after setting all properties.
function editBirdname1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editBirdname1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editBirdname2_Callback(hObject, eventdata, handles)
% hObject    handle to editBirdname2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.val.editBirdname2 = get(hObject,'String');
handles = same_for_all('Birdname', 2, handles);
update_display(handles);
guidata(hObject, handles)


% --- Executes during object creation, after setting all properties.
function editBirdname2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editBirdname2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editBirdname3_Callback(hObject, eventdata, handles)
% hObject    handle to editBirdname3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.val.editBirdname3 = get(hObject,'String');
handles = same_for_all('Birdname', 3, handles);
update_display(handles);
guidata(hObject, handles)

% --- Executes during object creation, after setting all properties.
function editBirdname3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editBirdname3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editBirdname4_Callback(hObject, eventdata, handles)
% hObject    handle to editBirdname4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.val.editBirdname4 = get(hObject,'String');
handles = same_for_all('Birdname', 4, handles);
update_display(handles);
guidata(hObject, handles)

% --- Executes during object creation, after setting all properties.
function editBirdname4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editBirdname4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editBirdname5_Callback(hObject, eventdata, handles)
% hObject    handle to editBirdname5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.val.editBirdname5 = get(hObject,'String');
handles = same_for_all('Birdname', 5, handles);
update_display(handles);
guidata(hObject, handles)

% --- Executes during object creation, after setting all properties.
function editBirdname5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editBirdname5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editBirdname6_Callback(hObject, eventdata, handles)
% hObject    handle to editBirdname6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.val.editBirdname6 = get(hObject,'String');
handles = same_for_all('Birdname', 6, handles);
update_display(handles);
guidata(hObject, handles)

% --- Executes during object creation, after setting all properties.
function editBirdname6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editBirdname6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editBirdname7_Callback(hObject, eventdata, handles)
% hObject    handle to editBirdname7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.val.editBirdname7 = get(hObject,'String');
handles = same_for_all('Birdname', 7, handles);
update_display(handles);
guidata(hObject, handles)

% --- Executes during object creation, after setting all properties.
function editBirdname7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editBirdname7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editExpername0_Callback(hObject, eventdata, handles)
% hObject    handle to editExpername0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.val.editExpername0 = get(hObject,'String');
handles = same_for_all('Expername', 0, handles);
update_display(handles);
guidata(hObject, handles)

% --- Executes during object creation, after setting all properties.
function editExpername0_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editExpername0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editExpername1_Callback(hObject, eventdata, handles)
% hObject    handle to editExpername1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.val.editExpername1 = get(hObject,'String');
handles = same_for_all('Expername', 1, handles);
update_display(handles);
guidata(hObject, handles)

% --- Executes during object creation, after setting all properties.
function editExpername1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editExpername1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editExpername2_Callback(hObject, eventdata, handles)
% hObject    handle to editExpername2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.val.editExpername2 = get(hObject,'String');
handles = same_for_all('Expername', 2, handles);
update_display(handles);
guidata(hObject, handles)

% --- Executes during object creation, after setting all properties.
function editExpername2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editExpername2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editExpername3_Callback(hObject, eventdata, handles)
% hObject    handle to editExpername3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.val.editExpername3 = get(hObject,'String');
handles = same_for_all('Expername', 3, handles);
update_display(handles);
guidata(hObject, handles)

% --- Executes during object creation, after setting all properties.
function editExpername3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editExpername3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editExpername4_Callback(hObject, eventdata, handles)
% hObject    handle to editExpername4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.val.editExpername4 = get(hObject,'String');
handles = same_for_all('Expername', 4, handles);
update_display(handles);
guidata(hObject, handles)

% --- Executes during object creation, after setting all properties.
function editExpername4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editExpername4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editExpername5_Callback(hObject, eventdata, handles)
% hObject    handle to editExpername5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.val.editExpername5 = get(hObject,'String');
handles = same_for_all('Expername', 5, handles);
update_display(handles);
guidata(hObject, handles)

% --- Executes during object creation, after setting all properties.
function editExpername5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editExpername5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editExpername6_Callback(hObject, eventdata, handles)
% hObject    handle to editExpername6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.val.editExpername6 = get(hObject,'String');
handles = same_for_all('Expername', 6, handles);
update_display(handles);
guidata(hObject, handles)

% --- Executes during object creation, after setting all properties.
function editExpername6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editExpername6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editExpername7_Callback(hObject, eventdata, handles)
% hObject    handle to editExpername7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.val.editExpername7 = get(hObject,'String');
handles = same_for_all('Expername', 7, handles);
update_display(handles);
guidata(hObject, handles)

% --- Executes during object creation, after setting all properties.
function editExpername7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editExpername7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in buttonCreate.
function buttonCreate_Callback(hObject, eventdata, handles)
% hObject    handle to buttonCreate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
for ch = 0:7
    if is_valid(ch, handles)
        if exist('expers','var')
            expers(end+1) = create_exper_by_ch(ch, handles);
            songDetection(end+1) = handles.songDetection_default;
        else
            expers = create_exper_by_ch(ch, handles);
            songDetection = handles.songDetection_default;
        end
    end
end
save_values('createExperMulti_defaults.mat', handles)
acquisitionGui('expers', expers, 'songDetection', songDetection, 'bTrigOnSong', ones(size(expers)))

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ok = is_valid(ch, handles)
ok = true;
% birdname cannot be blank
tag = sprintf('editBirdname%g',ch);
if isempty(handles.val.(tag))
    ok = false;
    debugdisp([int2str(ch) ' empty birdname']);
end
% birdname cannot contain spaces
if ~isempty(strfind(handles.val.(tag), ' '))
    ok = false;
    debugdisp([int2str(ch) ' birdname has space']);
end
% expername cannot be blank
tag = sprintf('editExpername%g',ch);
if isempty(handles.val.(tag))
    ok = false;
    debugdisp([int2str(ch) ' empty expername']);
end
% expername cannot contain spaces
if ~isempty(strfind(handles.val.(tag), ' '))
    ok = false;
    debugdisp([int2str(ch) ' expername has space']);
end
% sigchan must evaluate to a vector (or be empty)
tag = sprintf('editSigchan%g', ch);
val = str2num(handles.val.(tag));
if ~isempty(val) && ~isvector(val)
    ok = false;
    debugdisp([int2str(ch) ' sigchan must be vector or empty']);
end
% samprate must be a scalar number (and cannot be blank)
tag = sprintf('editSamprate%g', ch);
val = str2num(handles.val.(tag));
if ~isscalar(val)
    ok = false;
    debugdisp([int2str(ch) ' samprate must be a scalar number']);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function exper = create_exper_by_ch(ch, handles)
exper = createExperAuto( ... 
    handles.val.editRootdir, ...
    handles.val.(sprintf('editBirdname%g', ch)), ...
    handles.val.(sprintf('editExpername%g', ch)), ...
    str2num(handles.val.(sprintf('editSamprate%g', ch))), ...
    ch, ...
    str2num(handles.val.(sprintf('editSigchan%g', ch))));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function editRootdir_Callback(hObject, eventdata, handles)
% hObject    handle to editRootdir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editRootdir as text
%        str2double(get(hObject,'String')) returns contents of editRootdir as a double
handles.val.editRootdir = get(hObject,'String');
update_display(handles);
guidata(hObject, handles)

% --- Executes during object creation, after setting all properties.
function editRootdir_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editRootdir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in buttonBrowseRootdir.
function buttonBrowseRootdir_Callback(hObject, eventdata, handles)
% hObject    handle to buttonBrowseRootdir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.val.editRootdir = uigetdir;
update_display(handles);
guidata(hObject, handles)


function editSigchan0_Callback(hObject, eventdata, handles)
% hObject    handle to editSigchan0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.val.editSigchan0 = get(hObject,'String');
handles = same_for_all('Sigchan', 0, handles);
update_display(handles);
guidata(hObject, handles)

% --- Executes during object creation, after setting all properties.
function editSigchan0_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editSigchan0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editSigchan1_Callback(hObject, eventdata, handles)
% hObject    handle to editSigchan1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.val.editSigchan1 = get(hObject,'String');
handles = same_for_all('Sigchan', 1, handles);
update_display(handles);
guidata(hObject, handles)

% --- Executes during object creation, after setting all properties.
function editSigchan1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editSigchan1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editSigchan2_Callback(hObject, eventdata, handles)
% hObject    handle to editSigchan2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.val.editSigchan2 = get(hObject,'String');
handles = same_for_all('Sigchan', 2, handles);
update_display(handles);
guidata(hObject, handles)

% --- Executes during object creation, after setting all properties.
function editSigchan2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editSigchan2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editSigchan3_Callback(hObject, eventdata, handles)
% hObject    handle to editSigchan3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.val.editSigchan3 = get(hObject,'String');
handles = same_for_all('Sigchan', 3, handles);
update_display(handles);
guidata(hObject, handles)

% --- Executes during object creation, after setting all properties.
function editSigchan3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editSigchan3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editSigchan4_Callback(hObject, eventdata, handles)
% hObject    handle to editSigchan4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.val.editSigchan4 = get(hObject,'String');
handles = same_for_all('Sigchan', 4, handles);
update_display(handles);
guidata(hObject, handles)

% --- Executes during object creation, after setting all properties.
function editSigchan4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editSigchan4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editSigchan5_Callback(hObject, eventdata, handles)
% hObject    handle to editSigchan5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.val.editSigchan5 = get(hObject,'String');
handles = same_for_all('Sigchan', 5, handles);
update_display(handles);
guidata(hObject, handles)

% --- Executes during object creation, after setting all properties.
function editSigchan5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editSigchan5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editSigchan6_Callback(hObject, eventdata, handles)
% hObject    handle to editSigchan6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.val.editSigchan6 = get(hObject,'String');
handles = same_for_all('Sigchan', 6, handles);
update_display(handles);
guidata(hObject, handles)

% --- Executes during object creation, after setting all properties.
function editSigchan6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editSigchan6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editSigchan7_Callback(hObject, eventdata, handles)
% hObject    handle to editSigchan7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.val.editSigchan7 = get(hObject,'String');
handles = same_for_all('Sigchan', 7, handles);
update_display(handles);
guidata(hObject, handles)

% --- Executes during object creation, after setting all properties.
function editSigchan7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editSigchan7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editSamprate0_Callback(hObject, eventdata, handles)
% hObject    handle to editSamprate0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.val.editSamprate0 = get(hObject,'String');
handles = same_for_all('Samprate', 0, handles);
update_display(handles);
guidata(hObject, handles)

% --- Executes during object creation, after setting all properties.
function editSamprate0_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editSamprate0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editSamprate1_Callback(hObject, eventdata, handles)
% hObject    handle to editSamprate1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.val.editSamprate1 = get(hObject,'String');
handles = same_for_all('Samprate', 1, handles);
update_display(handles);
guidata(hObject, handles)

% --- Executes during object creation, after setting all properties.
function editSamprate1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editSamprate1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editSamprate2_Callback(hObject, eventdata, handles)
% hObject    handle to editSamprate2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.val.editSamprate2 = get(hObject,'String');
handles = same_for_all('Samprate', 2, handles);
update_display(handles);
guidata(hObject, handles)

% --- Executes during object creation, after setting all properties.
function editSamprate2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editSamprate2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editSamprate3_Callback(hObject, eventdata, handles)
% hObject    handle to editSamprate3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.val.editSamprate3 = get(hObject,'String');
handles = same_for_all('Samprate', 3, handles);
update_display(handles);
guidata(hObject, handles)

% --- Executes during object creation, after setting all properties.
function editSamprate3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editSamprate3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editSamprate4_Callback(hObject, eventdata, handles)
% hObject    handle to editSamprate4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.val.editSamprate4 = get(hObject,'String');
handles = same_for_all('Samprate', 4, handles);
update_display(handles);
guidata(hObject, handles)

% --- Executes during object creation, after setting all properties.
function editSamprate4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editSamprate4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editSamprate5_Callback(hObject, eventdata, handles)
% hObject    handle to editSamprate5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.val.editSamprate5 = get(hObject,'String');
handles = same_for_all('Samprate', 5, handles);
update_display(handles);
guidata(hObject, handles)

% --- Executes during object creation, after setting all properties.
function editSamprate5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editSamprate5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editSamprate6_Callback(hObject, eventdata, handles)
% hObject    handle to editSamprate6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.val.editSamprate6 = get(hObject,'String');
handles = same_for_all('Samprate', 6, handles);
update_display(handles);
guidata(hObject, handles)

% --- Executes during object creation, after setting all properties.
function editSamprate6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editSamprate6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editSamprate7_Callback(hObject, eventdata, handles)
% hObject    handle to editSamprate7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.val.editSamprate7 = get(hObject,'String');
handles = same_for_all('Samprate', 7, handles);
update_display(handles);
guidata(hObject, handles)

% --- Executes during object creation, after setting all properties.
function editSamprate7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editSamprate7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkSameBirdname.
function checkSameBirdname_Callback(hObject, eventdata, handles)
% hObject    handle to checkSameBirdname (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.val.checkSameBirdname = get(hObject,'Value');
guidata(hObject, handles)


% --- Executes on button press in checkSameExpername.
function checkSameExpername_Callback(hObject, eventdata, handles)
% hObject    handle to checkSameExpername (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkSameExpername


% --- Executes on button press in checkSameSigchan.
function checkSameSigchan_Callback(hObject, eventdata, handles)
% hObject    handle to checkSameSigchan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkSameSigchan


% --- Executes on button press in checkSameSamprate.
function checkSameSamprate_Callback(hObject, eventdata, handles)
% hObject    handle to checkSameSamprate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkSameSamprate


% --- Executes on button press in buttonReset0.
function buttonReset0_Callback(hObject, eventdata, handles)
% hObject    handle to buttonReset0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = reset_row(0, handles);
update_display(handles);
guidata(hObject, handles);

% --- Executes on button press in buttonReset1.
function buttonReset1_Callback(hObject, eventdata, handles)
% hObject    handle to buttonReset1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = reset_row(1, handles);
update_display(handles);
guidata(hObject, handles);

% --- Executes on button press in buttonReset2.
function buttonReset2_Callback(hObject, eventdata, handles)
% hObject    handle to buttonReset2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = reset_row(2, handles);
update_display(handles);
guidata(hObject, handles);

% --- Executes on button press in buttonReset3.
function buttonReset3_Callback(hObject, eventdata, handles)
% hObject    handle to buttonReset3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = reset_row(3, handles);
update_display(handles);
guidata(hObject, handles);

% --- Executes on button press in buttonReset4.
function buttonReset4_Callback(hObject, eventdata, handles)
% hObject    handle to buttonReset4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = reset_row(4, handles);
update_display(handles);
guidata(hObject, handles);

% --- Executes on button press in buttonReset5.
function buttonReset5_Callback(hObject, eventdata, handles)
% hObject    handle to buttonReset5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = reset_row(5, handles);
update_display(handles);
guidata(hObject, handles);

% --- Executes on button press in buttonReset6.
function buttonReset6_Callback(hObject, eventdata, handles)
% hObject    handle to buttonReset6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = reset_row(6, handles);
update_display(handles);
guidata(hObject, handles);

% --- Executes on button press in buttonReset7.
function buttonReset7_Callback(hObject, eventdata, handles)
% hObject    handle to buttonReset7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = reset_row(7, handles);
update_display(handles);
guidata(hObject, handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function handles = reset_row(r, handles)
for n = 1:length(handles.fieldnames)
    tag = sprintf('edit%s%g', handles.fieldnames{n}, r);
    handles.val.(tag) = '';
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function update_display(handles)
set(handles.editRootdir, 'String', handles.val.editRootdir);
for n = 1:length(handles.fieldnames)
    tag = sprintf('checkSame%s', handles.fieldnames{n});
    set(handles.(tag),'Value',handles.val.(tag))
    for ch = 0:7
        tag = sprintf('edit%s%g', handles.fieldnames{n}, ch);
        set(handles.(tag), 'String', handles.val.(tag));
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function handles = same_for_all(fieldname, source_channel, handles)
tag = sprintf('checkSame%s', fieldname);
if handles.val.(tag) % if checkSame box is checked for this column
    % get the value we are copying
    tag = sprintf('edit%s%g', fieldname, source_channel);
    val = handles.val.(tag);
    % copy it into every channel
    for ch = 0:7
        tag = sprintf('edit%s%g', fieldname, ch);
        handles.val.(tag) = val;
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function handles = load_values(filename, handles)
temp = load(filename);
handles.val = temp.handles.val;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function save_values(filename, handles)
save(filename,'handles')