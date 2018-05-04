function vc_loader_helper(birdname,datestr,varargin)

P.rootdir = 'c:\stetner\data';
P.prefix = 'all';
P = parseargs(P,varargin{:});
keyboard %%%DEBUG
%Get all the relevant files.
fileSearch = [P.rootdir, filesep, birdname, filesep, birdname, '_',P.prefix,'_misc_', datestr, '*'];
dFiles = dir(fileSearch);

for(nFile = 1:length(dFiles))
    searchString = [P.rootdir, filesep, birdname, filesep, strrep(dFiles(nFile).name, '_misc_', '_*_')];
    
    %load data.
    [v, sf, vf, icn, t, i, sfname, vfname] = vc_imp_ProcessedAnnotationFiles('batch', searchString, false, false, false);
    
    %add basic features to the scalar feature list.
    sf(:,end+1) = cellfun(@length,v);  
    sfname{end+1} = 'length';               
    sf(:,end+1) = t;
    sfname{end+1} = 'time';
    sf(:,end+1) = (t - floor(t))*24;
    sfname{end+1} = 'hourOfDay';
    sf(:,end+1) = icn;
    sfname{end+1} = 'imported cluster';   
end
