function exper = createExperAuto(rootdir, birdname, expername, desiredInSampRate, audioCh, sigCh)
%Creates a folder for all files related to this experiment.  Also saves a
%.mat file to this folder containing the experiment description.

birddir = fullfile(rootdir, birdname);
if ~exist(birddir, 'dir')
    mkdir(rootdir, birdname);
end
experdir = fullfile(rootdir, birdname, expername);
if ~exist(experdir, 'dir')
    mkdir(birddir, expername);
end

exper.dir = experdir;
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

experfile = fullfile(experdir, 'exper.mat');
save(experfile, 'exper');
