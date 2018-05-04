function saveExper(exper, filename)
%The exper contains a directory folder specifying where the files are
%saved.  This direction needs to be updated if the files are moved.
%Rootdir is the directory in which the bird folder resides.

if(~exist('filename'))
    filename = 'exper.mat';
end

save([exper.dir,filename],'exper'); 