function varargout = plotResults(varargin)
% PLOTRESULTS M-file for plotResults.fig
%      PLOTRESULTS, by itself, creates a new PLOTRESULTS or raises the existing
%      singleton*.
%
%      H = PLOTRESULTS returns the handle to a new PLOTRESULTS or the handle to
%      the existing singleton*.
%
%      PLOTRESULTS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PLOTRESULTS.M with the given input arguments.
%
%      PLOTRESULTS('Property','Value',...) creates a new PLOTRESULTS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before plotResults_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to plotResults_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help plotResults

% Last Modified by GUIDE v2.5 26-Aug-2009 11:51:17

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @plotResults_OpeningFcn, ...
                   'gui_OutputFcn',  @plotResults_OutputFcn, ...
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


% --- Executes just before plotResults is made visible.
function plotResults_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to plotResults (see VARARGIN)

% Choose default command line output for plotResults
handles.output = hObject;

% UIWAIT makes plotResults wait for user response (see UIRESUME)
% uiwait(handles.figure1);

handles.vcdb = varargin{1}.vcdb;
handles.vcg = varargin{1}.vcg;

% Update handles structure
guidata(hObject, handles);

handles.ClusterSelect = get(varargin{1}.popupClusterSelect,'Value'); % get which cluster is selected
ClusterNum = handles.vcdb.c(handles.ClusterSelect).number;
handles.sp = handles.vcg.specgram;

handles.Ndx = find(handles.vcdb.d.cn==ClusterNum);
if isempty(handles.Ndx)
    errordlg('No points in the cluster!')
    return
end

%- TO DO: predetermine figure size
% user input ArrayNum
% make the figure clickable to delete it
% be able to go to next page

handles.PageEnd = 0; % 1 if syllable range is out of bound

handles.column = 3;
handles.row = 4;
handles.range = 1:handles.column*handles.row;
guidata(hObject, handles);

refreshResults(handles);
guidata(hObject, handles);

% --- Outputs from this function are returned to the command line.
function varargout = plotResults_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in buttonNext.
function buttonNext_Callback(hObject, eventdata, handles)
% hObject    handle to buttonNext (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if handles.PageEnd==0
    if max(handles.range)+handles.column*handles.row < size(handles.Ndx,1)
        handles.range = handles.range+handles.column*handles.row;
    else % last page
        handles.range = max(handles.range)+1:size(handles.Ndx,1); 
        handles.PageEnd = 1;
        set(handles.buttonNext,'ForegroundColor',[.7 .7 .7]); % set the color of the arrow to gray
    end
    refreshResults(handles);
end

guidata(hObject, handles);

%if max(range)+column*row > vcdb.c.i(handles.ClusterSelect)
%handles.range = 

% --- Executes on button press in buttonPrev.
function buttonPrev_Callback(hObject, eventdata, handles)
% hObject    handle to buttonPrev (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if handles.PageEnd==0
    if max(handles.range)+handles.column*handles.row < size(handles.Ndx,1)
        handles.range = handles.range+handles.column*handles.row;
    else % last page
        handles.range = max(handles.range)+1:size(handles.Ndx,1); 
        handles.PageEnd = 1;
        set(handles.buttonNext,'ForegroundColor',[.7 .7 .7]); % set the color of the arrow to gray
    end
    refreshResults(handles);
end

guidata(hObject, handles);

% ----
function handles = refreshResults(handles)

%L = 0.1; % size of the square
%xspace = (1-handles.column*L)/(handles.column+1);
%yspace = (0.9-handles.row*L)/(handles.row+1);
clf
for i=1:size(handles.range,2)
    subplot(handles.row,handles.column,i)
    %axes('position',
    displaySpecgramQuick(handles.vcdb.d.v{handles.Ndx(handles.range(i))},handles.sp.fs, handles.sp.freqRange, handles.sp.colorRange);
    axis square
    axis off
end
set(handles.textRange,'String',['Syllables ',num2str(min(handles.range)), ':', num2str(max(handles.range)),...
    ' out of ', num2str(size(handles.Ndx,1))]);