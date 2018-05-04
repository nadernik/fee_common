function exper = updateExperDir(exper, rootdir)
%The exper contains a directory folder specifying where the files are
%saved.  This direction needs to be updated if the files are moved.
%Rootdir is the directory in which the bird folder resides.

if(~exist('rootdir'))
    rootdir = pwd;
end

exper.dir = [rootdir,'\',exper.birdname,'\',exper.expername,'\']; 