%% How much data do I have? 
% load NIf spreadsheet
[XLS, Columns] = loadNIfSpreadsheet_elm();

% define a new path to save neurons in
newrootdir = 'E:\NIfData';
%% check and transfer data row by row
rows = 2:size(XLS.data.Sheet1,1); 
ChanNums = XLS.data.Sheet1(:,strmatch('electrode #', Columns))+1; 
BytesByRow = zeros(length(rows)+1,1); 

for row = 2:max(rows)
    row
    
    % getting the relevant info from NIfUnits spreadsheet
    bird = num2str(XLS.data.Sheet1(row,strmatch('bird', Columns)));
    day = XLS.textdata.Sheet1{row,strmatch('day', Columns)};
    depth = XLS.textdata.Sheet1{row,strmatch('folder', Columns)};
    
    % get dbase
    [dbase rowstr path filename] = getDbase_elm(row, XLS, Columns);
    
    % add bytes for analysis file
    tmp = dir([fullfile(path,filename), '.mat*']); 
    BytesByRow(row) = BytesByRow(row) + tmp.bytes; 
    
    % figure out new path name, make directories
    mkdir(newrootdir, bird); 
    mkdir(fullfile(newrootdir, bird), day); 
    mkdir(fullfile(newrootdir, bird, day), depth); 
    newPathname = fullfile(newrootdir, bird, day, depth); 
    dbase.PathName = newPathname; 
    
    % save the analysis file in the new location
    save([fullfile(newPathname,filename), '.mat'], 'dbase'); 
    
    % go through all the data files
    nFiles = length(dbase.SoundFiles);
    chanN = ChanNums(row); 
    for file = 1:nFiles
        dbase.SoundFiles(file).bytes; 
        BytesByRow(row) = BytesByRow(row) + ...
            dbase.SoundFiles(file).bytes + ... % add sound file bytes
            dbase.ChannelFiles{chanN}(file).bytes; % add chan file bytes
        
        % save the sound file in the new location
        copyfile(fullfile(path,dbase.SoundFiles(file).name), fullfile(newPathname,dbase.SoundFiles(file).name)); 
        
        % save the neural file in the new location
        copyfile(fullfile(path,dbase.ChannelFiles{chanN}(file).name), fullfile(newPathname,dbase.ChannelFiles{chanN}(file).name)); 
    end
end

%%

figure; plot(cumsum(BytesByRow/1e9)); ylabel('amount of data (GB)')

 
 
 
 
