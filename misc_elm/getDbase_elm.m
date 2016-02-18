function [dbase rowstr pathname filename] = getDbase_elm(row, XLS, Columns)

% getting the relevant info from NIfUnits spreadsheet
bird = num2str(XLS.data.Sheet1(row,strmatch('bird', Columns)));
day = XLS.textdata.Sheet1{row,strmatch('day', Columns)};
depth = XLS.textdata.Sheet1{row,strmatch('folder', Columns)};
feeboxFolder = XLS.textdata.Sheet1{row,strmatch('which feebox', Columns)};
% Age
birthday = [0; cellfun(@(X) datenum(X), XLS.textdata.Sheet1(2:end,strmatch('birthday', Columns)))];
Recdays = [0; cellfun(@(X) datenum(X(1:10)), XLS.textdata.Sheet1(2:end,strmatch('day', Columns)))];
Age = Recdays - birthday; 

if sum(strmatch('feebox4',feeboxFolder))||sum(strmatch('feebox6',feeboxFolder)) % feebox 4 is actually on feebox 6 now
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
CTEST = XLS.data.Sheet1(:,strmatch('ctest?', Columns))==1; 
rowstr = ['row' num2str(row) '_' num2str(bird) '_' day '_' depth ];
if length(SINGING)>0
    if SINGING(row)
        rowstr = [rowstr '_s'];
    end
    if TUTORING(row)
        rowstr = [rowstr '_t']; 
    end
    rowstr = [rowstr '_' num2str(Age(row)) 'dph']; 
    if PUTPROJ(row)
        rowstr = [rowstr '_putproj']; 
    end
    if CTEST(row)
        rowstr = [rowstr '_CTEST']; 
    end
end
