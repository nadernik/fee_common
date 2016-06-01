clear all; 
XLS = importdata('C:/Users/emackev/Dropbox (MIT)/MackeviciusLabPresentations/TmpFileTransfer.xlsx'); % edit isolate_inventory
XLS.data.Sheet1 = [NaN*ones(1, size(XLS.data.Sheet1,2)); XLS.data.Sheet1]; % add row corresponding to title row, so indices line up./
Columns = XLS.textdata.Sheet1(1,:);
From = [0; XLS.data.Sheet1(2:end,strmatch('From', Columns))];
To = [0; XLS.data.Sheet1(2:end,strmatch('To', Columns))];
RootDir = XLS.textdata.Sheet1(:,strmatch('RootDir', Columns));
NewFolder = XLS.textdata.Sheet1(:,strmatch('NewFolder', Columns));
%%
for row = 2:length(To) % for each row
    mkdir(fullfile(RootDir{row}, NewFolder{row})); % make new folder
    for fnum = From(row):To(row)% for each filenum
        Fls = dir(fullfile(RootDir{row}, strcat('*', sprintf('%06d',fnum), '*')));
        for fi = 1:length(Fls)
            copyfile(fullfile(RootDir{row}, Fls(fi).name), fullfile(RootDir{row}, NewFolder{row}, Fls(fi).name))
            display(['copied ' Fls(fi).name...% transfer files
                ' to ' NewFolder{row}]); 
        end
    end
    display(['------DONE WITH THIS DEPTH: ' RootDir{row} '\' NewFolder{row} '------'])
end
