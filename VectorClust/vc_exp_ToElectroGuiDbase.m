function varargout = vc_exp_ToElectroGuiDbase(vcdb)

%%% export from vectorClust to ElectroGui
%%% Tatsuo Okubo
%%% 2009/07/09

%%% Str: open dbase and cluster.mat files
%%% write down cluster number to SyllableTitles
%%% make batch mode as well

% hold onto imported file name

%% input
global ClusterNumber

if ~isfield(vcdb,'pathName') | ~isfield(vcdb,'fileName') % either pathName or fileName doesn't exist %%%%%    
    [fileName,pathName] = uigetfile('*.mat','Open dbase file');
elseif isempty(vcdb.pathName) | isempty(vcdb.fileName) % fixed 10/02/2009
    [fileName,pathName] = uigetfile('*.mat','Open dbase file');
else
    pathName = vcdb.pathName;
    fileName = vcdb.fileName;
end
load([pathName, fileName],'dbase'); % load dbase

SyllableNumber = length(vcdb.d.cn); % number of syllables
ClusterNumber = length(vcdb.c); % number of clusters
if ClusterNumber==0
    error('No clusters defined.')
end

%%
for n=1:SyllableNumber % for all syllbles
    FileNdx= vcdb.d.i{n}.dbaseFileNdx; % file index of dbase
    EventNdx = vcdb.d.i{n}.dbaseEventNdx; % event index of dbase
    Num = vcdb.d.cn(n); % syllable number
    SyllableTitle = ConvertNum2Str(Num,vcdb);
    dbase.SegmentTitles{FileNdx}{EventNdx} = SyllableTitle;
end

[fn pn] = uiputfile('*.mat','Save file name',[pathName,fileName,'_labeled']); % fix  %%%%%%
if isequal(fn,0) | isequal(pn,0)
    error('Not existing file.')
else
    save([pn fn],'dbase')
end
varargout{1} = 'cancel'; %% ??
msgbox('Export succeeded!')
return

%%
function Str = ConvertNum2Str(Num,vcdb)
% convert cluster number to string
% (vectorClust mainly uses numbers whereas electro_gui mainly uses strings)
global ClusterNumber
for i=1:ClusterNumber
    LookupNumber(i) = vcdb.c(i).number; % array
    LookupString{i} = vcdb.c(i).str; % cell array
end

if isnan(Num) % point that doesn't belong to any clusters
    Str = [];
else
    Ndx = find(Num==LookupNumber);
    if length(Ndx)>1
        error('Conflicting cluster name.')
    elseif isempty(Ndx)
        error(['Cluster number ', num2str(Num),' is not being used.']);
    else
        Str = LookupString{Ndx};
    end
end