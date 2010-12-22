function exper = createExper(rootdir)
%Creates a folder for all files related to this experiment.  Also saves a
%.mat file to this folder containing the experiment description.

if(~exist('rootdir'))
    rootdir = pwd;
end

birdname = input('Enter a bird name: (no spaces or strange characters)','s');
birddesc = input('Enter a description of the bird:','s');
expername = input('Enter a experiment name:','s');
experdesc = input('Enter a description of the exper:','s');

mkdir(rootdir, birdname);
mkdir([rootdir,'/',birdname], expername);

exper.dir = [rootdir,'\',birdname,'\',expername,'\'];
exper.birdname = birdname;
exper.birddesc = birddesc;
exper.expername = expername;
exper.experdesc = experdesc;
exper.datecreated = datestr(now,30);

exper.desiredInSampRate = input('Enter the desired input sampling rate:');
exper.audioCh = input('What hw channel will audio be on: (-1 if no audio)');
exper.sigCh = input('Enter vector of other hw channels to be recorded: ([] if none)');

for(nName = 1:length(exper.sigCh))
    exper.sigName{nName} = input(['Enter name of signal on channel ', num2str(exper.sigCh(nName)), ':'],'s');
    exper.sigDesc{nName} = input(['Enter description of signal on channel ', num2str(exper.sigCh(nName)), ':'],'s');
end

save([rootdir,'\',birdname,'\',expername,'\exper.mat'], 'exper');
