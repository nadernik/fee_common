function exper = createExperAuto(rootdir, birdname, expername, desiredInSampRate, audioCh, sigCh)
%Creates a folder for all files related to this experiment.  Also saves a
%.mat file to this folder containing the experiment description.

mkdir(rootdir, birdname);
mkdir([rootdir,'/',birdname], expername);

exper.dir = [rootdir,'\',birdname,'\',expername,'\'];
exper.birdname = birdname;
exper.birddesc = '';
exper.expername = expername;
exper.experdesc = '';
exper.datecreated = datestr(now,30);
exper.desiredInSampRate = desiredInSampRate;
exper.audioCh = audioCh;
exper.sigCh = sigCh;
exper.sigName = {};
exper.sigDesc = {};

for nName = 1:length(exper.sigCh)
    exper.sigName{nName} = '';
    exper.sigDesc{nName} = '';
end

save([rootdir,'\',birdname,'\',expername,'\exper.mat'], 'exper');
