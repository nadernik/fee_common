function exper = loadExper(birdname, expername, rootdir)

if(~exist('rootdir'))
    rootdir = pwd;
end

load([rootdir,'\',birdname,'\',expername,'\','exper.mat']);    