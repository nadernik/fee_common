function backupExper(varargin)
%BACKUPEXPER Compress and backup acquisitionGui exper
%    Compresses all files in the exper's directory and copies them to
%    specified destination. Files are compressed in a gzipped tarball
%    (.tar.gz)
%
%Usage:
%    BACKUPEXPER(EXPER, DESTINATION)
%        EXPER is an exper struct created by acquisitionGui. Typically,
%        this is stored in exper.mat in the exper's directory.
%        
%        DESTINATION is the directory to which the backup is made. It must
%        exist or the backup will fail.
%
%    BACKUPEXPER(BIRDNAME, EXPERNAME, DESTINATION)
%        Alternate syntax where BIRDNAME and EXPERNAME are strings that are
%        passed to LOADEXPER to load the exper.
%
%    BACKUPEXPER( ... , 'RootDir', 'C:\path\to\data')
%        Used to load exper if the first input is birdname and used to find
%        annotation files if WithAnnotation parameter is true. If the first
%        argument is an exper, this parameter is ignored and the actual
%        RootDir is inferred from the exper. Default = 'c:\stetner\data'
%    BACKUPEXPER( ... , 'WithAnnotation', true)
%        Includes annotation files (created by ANNOTATE_EXPER) in the
%        backup. Default = false
%    BACKUPEXPER( ... , 'DeleteOriginal', true)
%        Deletes original files after they are backed up. Default = false
%    BACKUPEXPER( ... , 'OverwriteDestination', true)
%        Overwrite destination file, if it exists. If this option is not
%        set and the destination file already exists, the backup will fail
%        with an error message.
%
% See also: EXPERMOVE, ANNOMOVE

%% Default parameter values
P.RootDir = 'C:\stetner\data';
P.DeleteOriginal = false;
P.WithAnnotation = false;
P.OverwriteDestination = false;

%% Parse arguments
if isexper(varargin{1})
    exper = varargin{1};
    birdname = exper.birdname;
    expername = exper.expername;
    destination = varargin{2};
    params = varargin(3:end);
    P = parseargs(P, params{:});
    P.RootDir = getExperRootdir(exper);
else
    birdname = varargin{1};
    expername = varargin{2};
    destination = varargin{3};
    params = varargin(4:end);
    P = parseargs(P, params{:});
    exper = loadExper(birdname, expername, P.RootDir);
end

backuptempdir = fullfile(tempdir, 'backupExper');
if exist(backuptempdir, 'dir')
    rmdir(backuptempdir, 's')
end
mkdir(backuptempdir)
fname = [birdname '_' expername '.tar.gz'];
zipfiletemp = fullfile(backuptempdir, fname); % zip file in local temp directory (with path)
zipfiledest = fullfile(destination,   fname); % destination zip file (with path) 
%% Check to make sure destination directory exists
assert(exist(destination, 'dir') == 7, 'Destination does not exist')

%% Check to make sure destination file does NOT exist

if ~P.OverwriteDestination && exist(zipfiledest, 'file')
    error('Destination file %s exists. Set the input parameter OverwriteDestination to true to force an overwrite.', zipfiledest)
end

%%
annofiles = {};
if P.WithAnnotation
    disp('Finding annotation files...')
    types = {'annotation', 'audio', 'misc', 'pitch'};
    for ii = 1:length(types)
        for part = 1:1000
            fname = annofilename(birdname, expername, ...
                'RootDir', P.RootDir, ...
                'Part', part, ...
                'Type', types{ii});
            if exist(fname, 'file')
                annofiles{end + 1} = fname;
            else
                break %out of loop over part number
            end
        end
    end
end

%% Compress (put everything in tarball and gzip it)

disp('Copying to temp directory...')
birddirTemp = fullfile(backuptempdir, birdname);
experdirTemp = fullfile(birddirTemp, expername);
mkdir(birddirTemp)
mkdir(experdirTemp)
copyfile(exper.dir, experdirTemp)
for ii = 1:length(annofiles)
    copyfile(annofiles{ii}, birddirTemp)
end

disp('Compressing...')
tar(zipfiletemp, birddirTemp)



%% Copy to destination
disp('Copying...')
[success, msg, msgid] = copyfile(zipfiletemp, destination);
if ~success
    error(['Backup failed: ' msgid msg])
end
% always delete zipped file and tarball after copying
delete(zipfiletemp)

%% Delete original
if P.DeleteOriginal
    disp('Deleting originals...')
    rmdir(exper.dir, 's')
    if ~isempty(annofiles)
        delete(annofiles{:})
    end
end