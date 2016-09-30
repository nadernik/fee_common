answer = inputdlg({'Old directory',...
    'New directory',...
    'Files to transfer'},'',1,...
    {'OLD','NEW','[1:1]'}); % input dialog box
if isempty(answer)
    return
end
OldDir = answer{1}; % array of files to be analyzed, convert from string to number
NewDir = answer{2}; % array of files to be analyzed, convert from string to number
fnums = eval(answer{3}); % array of files to be analyzed, convert from string to number

mkdir(NewDir); % make new folder
for fnumi = 1:length(fnums)
    fnum = fnums(fnumi);
    Fls = dir(fullfile(OldDir, strcat('*', sprintf('%06d',fnum), '*')));
    for fi = 1:length(Fls)
        copyfile(fullfile(OldDir, Fls(fi).name), fullfile(NewDir, Fls(fi).name))
        display(['copied ' Fls(fi).name...% transfer files
            ' to ' NewDir]); 
    end
end

