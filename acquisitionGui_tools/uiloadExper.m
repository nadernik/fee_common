function exper = uiloadExper(rootdir)

if(~exist('rootdir'))
    rootdir = 'c:\aadata';
end

a = pwd;
cd(rootdir);
[file,path] = uigetfile('*.mat', 'Experiment file:');
cd(a);

if isequal(file,0) || isequal(path,0)
    exper = [];
else
    load([path,filesep,file]);
    if(~exist('exper'))
        exper = uiloadExper(rootdir);
    else
        if(~strcmp(exper.dir, path))
            exper.dir = path;
            saveExper(exper,file);
        end
    end
end   