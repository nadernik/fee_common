function [dbase rowstr pathname filename] = getDbase_elm(row, XLS, Columns)

% getting the relevant info from NIfUnits spreadsheet
bird = num2str(XLS.data.Sheet1(row,strmatch('bird', Columns)));
day = XLS.textdata.Sheet1{row,strmatch('day', Columns)};
depth = XLS.textdata.Sheet1{row,strmatch('folder', Columns)};
feeboxFolder = XLS.textdata.Sheet1{row,strmatch('which feebox', Columns)};
if strmatch('feebox4',feeboxFolder) % feebox 4 is actually on feebox 6 now
    feeboxFolder = '\\feebox6\shared\emackev\AcqGui\';
end
if strmatch('feebox5',feeboxFolder)
    feeboxFolder = '\\feebox5\emily\AcqGui\';
end
filename = ['analysis' depth(2:end)];

% load analysis file
pathname = fullfile(feeboxFolder, bird, day, depth);
load(fullfile(feeboxFolder, bird, day, depth, filename));
dbase.PathName = pathname;

% make row string
SINGING = XLS.data.Sheet1(:,strmatch('singing?', Columns))==1; 
TUTORING = XLS.data.Sheet1(:,strmatch('tutoring?', Columns))==1;
PUTPROJ = XLS.data.Sheet1(:,strmatch('Put Proj?', Columns))==1;
rowstr = ['row' num2str(row) '_' num2str(bird) '_' day '_' depth ]; 
if SINGING(row)
    rowstr = [rowstr '_singing'];
end
if TUTORING(row)
    rowstr = [rowstr '_tutoring']; 
end
if PUTPROJ(row)
    rowstr = [rowstr '_putproj']; 
end
