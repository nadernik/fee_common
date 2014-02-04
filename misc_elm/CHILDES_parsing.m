path = 'C:\Users\emackev\Downloads\Davis_Babbling\';
ChildName = 'Aaron';
DIR = dir(fullfile(path, ChildName, '*.wav'));
filesize = [];
fullname = {};
for i = 1:numel(DIR)
    filesize(i) = DIR(i).bytes;
    fullname{i} = fullfile(path, ChildName, (DIR(i).name));
end

[~,i] = min(filesize);

%loading file
cd(fullfile(path, ChildName));
D = wavread(fullname{i});
D = mean(D,2);
cd C:\Users\emackev\Documents\MATLAB\code
%%
