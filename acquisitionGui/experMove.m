function experMove(birdname1, expername1, rootdir1, birdname2, expername2, rootdir2)
%EXPERMOVE Move acquisitionGui exper to change bird name, exper name, or root directory
%
% This function does three things
% 1. Moves all files in the exper directory to the new exper directory
% 2. Changes names of data files if bird names are different
% 3. Changes exper struct in exper.mat
%
%Example 1, changing birdname:
% rootdir = 'c:\data';
% expername = '2014-09-30';
% experMove('screening034', expername, rootdir, 'microdrive001', expername, rootdir)
%
%Example 2, Changing everything:
% experMove('1324', '2014-09-31', 'c:\data', '1234', '2014-10-01', 'z:\backup')
% % fixed typo in birdname, date, and moved it to backup
% 
%See also EXPERSPLIT, BACKUPEXPER


exper1 = loadExper(birdname1, expername1, rootdir1);
assert(isexper(exper1), 'FeeLab:acquisitionGui:experMove:invalidExper', ...
    'Invalid exper for bird %s exper %s in root directory %s', ...
    birdname1, expername1, rootdir1)
exper2 = exper1;
exper2.dir = [fullfile(rootdir2, birdname2, expername2) filesep]; % exper.dir always ends in filesep
exper2.birdname = birdname2;
exper2.expername = expername2;

% Verify that destination directory does not exist
assert(~exist(exper2.dir, 'dir'), ...
    'FeeLab:acquisitionGui:experMove:invalidDestination', ...
    'Destination directory %s already exists', exper2.dir)

% Move everything in the exper directory
if strcmp(birdname1, birdname2)
    % If the bird name doesn't change, we can just move the whole directory
    % at once.
    movefile(exper1.dir, exper2.dir)
else
    % If the bird name changes, we need to rename each data file
    mkdir(exper2.dir)
    d = dir(exper1.dir);
    % Replace bird name in data file (other file names are unchanged)
    newfilename = regexprep({d.name}, '.+(_d\d{6}_\d{8}T\d{6}chan\d\.dat)', [birdname2 '$1']);
    for ii = 1:length(d)
        if strcmp(d(ii).name, '.') || strcmp(d(ii).name, '..')
            continue
        end
        file1 = fullfile(exper1.dir, d(ii).name);
        file2 = fullfile(exper2.dir, newfilename{ii});
        movefile(file1, file2)
    end
    rmdir(exper1.dir)
end


% Save new exper.mat
exper = exper2;
experfile = fullfile(rootdir2, birdname2, expername2, 'exper.mat');
save(experfile, 'exper')