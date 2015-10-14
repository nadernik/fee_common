%% load NIf spreadsheet info
clear all; close all; clc
cd C:\Users\emackev\Documents\MATLAB\code; add_elm_code_paths; cd ..; 
addpath(genpath('Insights')); 
%%
% load NIf spreadsheet 
tic; 
XLS = importdata('C:\Users\emackev\Dropbox (MIT)\MackeviciusLabPresentations\NIfUnits1.xlsx'); 
XLS.data.Sheet1 = [NaN*ones(1, size(XLS.data.Sheet1,2)); XLS.data.Sheet1]; % add row corresponding to title row, so indices line up.
Columns = XLS.textdata.Sheet1(1,:);
toc

% logicals for choosing what rows to run
SINGING = XLS.data.Sheet1(:,strmatch('singing?', Columns))==1; 
TUTORING = XLS.data.Sheet1(:,strmatch('tutoring?', Columns))==1;
ASUBSONG = XLS.data.Sheet1(:,strmatch('art subsong?', Columns))==1;
SINGLEUNIT = XLS.data.Sheet1(:,strmatch('quality (1 = bad multi, 2 = ok, 3 = single, 4 = good single)', Columns))>=3; 
CTEST = XLS.data.Sheet1(:,strmatch('ctest?', Columns))==1;
PUTPROJ = XLS.data.Sheet1(:,strmatch('Put Proj?', Columns))==1;
HASH = XLS.data.Sheet1(:,strmatch('hash? (2  = unit)', Columns))>0;
UNITINHASH = XLS.data.Sheet1(:,strmatch('hash? (2  = unit)', Columns))==2;
hashLat = XLS.data.Sheet1(:,strmatch('latency (ms)', Columns));
hashLatJitt = XLS.data.Sheet1(:,strmatch('LatJitt (us)', Columns));
SYLSEL = XLS.data.Sheet1(:,strmatch('maybe Syl selective?', Columns))==1;

% Age
birthday = [0; cellfun(@(X) datenum(X), XLS.textdata.Sheet1(2:end,strmatch('birthday', Columns)))];
day = [0; cellfun(@(X) datenum(X(1:end-4)), XLS.textdata.Sheet1(2:end,strmatch('day', Columns)))];
Age = day - birthday; 

% Histology
Electrode = XLS.data.Sheet1(:,strmatch('electrode #', Columns));
GoodHistvec = cellfun(@(X) eval(X), XLS.textdata.Sheet1(2:end,strmatch('hist. confidence', Columns)), 'uniformoutput', 0); 
GoodHistvec(2:end+1) = GoodHistvec(1:end); % to make rows line up (first row is section headings)
Dvec = cellfun(@(X) eval(X), XLS.textdata.Sheet1(2:end,strmatch('[D_E1, D_E2, D_E3]', Columns)), 'uniformoutput', 0); 
Dvec(2:end+1) = Dvec(1:end); % to make rows line up (first row is section headings)

for rowi = 2:size(XLS.textdata.Sheet1,1)
    goodHist(rowi) = GoodHistvec{rowi}(Electrode(rowi)); 
    elecPosition(rowi) = Dvec{rowi}(Electrode(rowi)); 
end

% for coloring by bird id
birdID = XLS.data.Sheet1(:,strmatch('bird', Columns)); 
[~,~,birdnum] = unique(birdID); 

SUBSONG = zeros(size(XLS.data.Sheet1,1),1); SUBSONG(strmatch('subsong', XLS.textdata.Sheet1(:,strmatch('song stage', Columns))))=1;
PROTOSYLLABLE = zeros(size(XLS.data.Sheet1,1),1); PROTOSYLLABLE(strmatch('protosyllable', XLS.textdata.Sheet1(:,strmatch('song stage', Columns))))=1;
DIFF = zeros(size(XLS.data.Sheet1,1),1); DIFF(strmatch('diff', XLS.textdata.Sheet1(:,strmatch('song stage', Columns))))=1;
%% choose which row/rows
rs = find((SINGING|TUTORING)&PUTPROJ)';

row = 239; 

% load analysis file
[dbase rowstr pathname filename] = getDbase_elm(row, XLS, Columns)
% newFilename = [filename '_old']; 
% save(fullfile(pathname, newFilename), 'dbase');

fs = dbase.Fs;
nFiles = length(dbase.SegmentTimes); 

% define the letters/colors
LabelNames = {[], [], 'R', 'O', 'Y', 'L', 'G', 'B', 'S', 'C', 'M', 'P'};

% load a t_insights file
load(['Tsne_labels_row' num2str(row) '.mat'])
% create a new dbase with tsne labels
dbase.SegWarning = dbase.SegmentIsSelected; % will make dbase.SegWarning 1/3 for syllables with warning
for syli = 1:length(Results.Labels)
    dbase.SegmentTitles{Results.FileNum(syli)}{Results.SegNum(syli)} = ...
        LabelNames{Results.Labels(syli)}; 
    if Results.Labels(syli) == 2 % label 2 means unselecting
        dbase.SegmentIsSelected{Results.FileNum(syli)}(Results.SegNum(syli)) = 0;
    end
    if Results.Warning(syli) % will make dbase.SegWarning 1/3 for syllables with warning
        dbase.SegWarning{Results.FileNum(syli)}(Results.SegNum(syli)) = 1/3; 
    end
end

%%
close all
% save new dbase analysis file
newFilename = [filename]; 
save(fullfile(pathname, newFilename), 'dbase');
% sorted raster of all syllables 
% p = setSortedRastersParams_elm(row,XLS, Columns); 
% sorted_rasters(dbase, p)
% for each syllable type, make a sorted raster and make an example
clear p
p = struct(); 
p.sylType = 'specified'; % 'tutor' 'song' 'artificialsubsong' or 'specified'
p.PSTHaxisMax = []; % [] to leave automatic
p.alignTo = 'onset'; 
p.sortBy = 'syldur'; % syldur or gapdur
p.XLS = XLS; 
p.Columns = Columns; 
p.rasterRange = [-.5 .5];
p.plotRange = [-.4 .4]; 
p.psthdt = .001; %.001; 
smoothwin = 19; %boxcar smoothing window. smoothwin must be odd. 1 is no smoothing.
p.smoothwin = smoothwin; 
bins = p.rasterRange(1):p.psthdt:p.rasterRange(2); 
p.figNum = 1;
p.papersize = 2*[3.5 2.5]; 
p.fontsize = 6; 
p.makeFig = 1; 
p.MaxToPlot = 200;
p.papersize = [8 6]; 
figure(p.figNum)
set(p.figNum, 'color', [1 1 1])
for row = row
    %row = ROWs(rowi); 
    stypes = unique(Results.Labels); stypes(stypes<3) = [];
    p.sylName = LabelNames(stypes)
    analyzeRow(row, p, 'fourRasters');
    if PUTPROJ(row)
        filestr = fullfile('C:\Users\emackev\Documents\MATLAB\code\RasterPlots', ['SortedRasters', num2str(row), 'PutProj_Age', num2str(Age(row))]); 
    else
        filestr = fullfile('C:\Users\emackev\Documents\MATLAB\code\RasterPlots', ['SortedRasters', num2str(row), '_Age', num2str(Age(row))]); 
    end
    saveas(p.figNum,[filestr '.jpg'])
    
    for stypei = 1:length(stypes)
        clf
        p.sylName = LabelNames(stypes(stypei)); 
        analyzeRow(row, p, 'PSTH'); drawnow; pause(.1)
        saveas(p.figNum,[filestr '_' char(p.sylName) '.jpg'])
    end
end
% to plot just one row
%p.makeFig = 1; p.MaxToPlot = 100; analyzeRow(row, p, 'PSTH'); p.makeFig = 0;



% spectrogram
% ppt exporter?