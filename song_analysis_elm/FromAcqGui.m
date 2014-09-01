%% Nov 9, 2012, ANALYZING SONGS OF BIRDS WHO HEARD INTRO NOTES

% something isn't working on the mac, so I'm switching to the pc
%%
birdnum = '3284';
date = '2012-11-07';
path = '~/../../Volumes/emily/AcqGUI';
filen = 1; 
chan = 0
Exp = loadExper_mac(birdnum, date, path);
Exp.dir = [path,'/', birdnum, '/', date];
Dat = loadAudio(Exp, filen);
%%
figure; displaySpecgramQuick(Dat, Exp, Exp.desiredInSampRate)
sound(Dat, Exp.desiredInSampRate);