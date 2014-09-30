%% load data, check it looks ok
close all
UpBirds = {'3284','3291', '3288', '3293'};% 3284's still on subsong, so I'm leaving him out.
DownBirds = { '3294','3289', '3292'}; %3294's still on subsong, so I left him out.
AllBirds = union(UpBirds,DownBirds);
Markers = {'.','o','*','^'};
expername = '2012-11-24';
rootdir = 'C:\Documents and Settings\Tim C\My Documents\MATLAB\AcqGUI';
c = 1;
filenums = 1:298;
%%% UP BIRDS

for birdi = 1:numel(AllBirds)
    tic
    [Dur, WE] = SylScatter(AllBirds{birdi}, expername, rootdir, filenums);
    figure(1)
    plot(Dur, WE, '.', 'color', [1 0 0])
    xlabel('duration'); ylabel('weiner entropy')
    figure(2)
    [n,x] = hist(Dur, 0:.002:.5);
    plot(x,n)
    xlabel('duration'); ylabel('count')
    toc
    figure(1)
    set(gcf, 'papersize', [6 4], 'paperposition', [0 0 6 4])
    saveas(gcf, ['sylclust', AllBirds{birdi}, expername,'.pdf'])
    figure(2)
    set(gcf, 'papersize', [6 4], 'paperposition', [0 0 6 4])
    saveas(gcf, ['durdist', AllBirds{birdi}, expername,'.pdf'])
    close all
end
%%
AllInOrder = {'3284','3291', '3288', '3293', '3294','3289', '3292'}
expername = '2012-11-24';
ExSongs = [910 648 1226 455 272 1269 980];
for birdi = 1:numel(AllInOrder)
    birdname = AllInOrder{birdi};
    filenum = ExSongs(birdi);
    Exp = loadExper(birdname, expername, rootdir);
    chan = Exp.audioCh;
    Dat = loadData(Exp, filenum, chan);
    figure(1); displaySpecgramQuick(Dat,Exp.desiredInSampRate)
    set(gcf, 'papersize', [6 3], 'paperposition', [0 0 6 3])
    saveas(gcf, ['specgram', AllInOrder{birdi}, expername,'.pdf'])
    sound(Dat,Exp.desiredInSampRate);
    wavwrite(Dat, Exp.desiredInSampRate, ['audio', AllInOrder{birdi}, expername,'.wav']);
    close all
end
%%


%SongOne
[Dat,fs] = wavread('SongOne.wav');
segs = Syllable_segment_Emily('SongOne.wav',4000);
figure(3); subplot(2,1,1);hold on; 
displaySpecgramQuick(Dat,fs);
title('song one')
for i = 1:size(segs,1)
    w = weinerEntropy(Dat(segs(i,1):segs(i,2)),fs);
    Dur1(i) = segs(i,2)/fs-segs(i,1)/fs;
    WE1(i) = w;
    text(segs(i,1)/fs, 7000, num2str(round(w*100)), 'Color', [1 1 1]);
    plot([segs(i,1)/fs segs(i,2)/fs], [6000 6000], 'r', 'linewidth',6)
end

%SongTwo
[Dat,fs] = wavread('SongTwo.wav');
segs = Syllable_segment_Emily('SongTwo.wav',4000);
subplot(2,1,2); hold on
displaySpecgramQuick(Dat,fs);
title('song two')
for i = 1:size(segs,1)
    w = weinerEntropy(Dat(segs(i,1):segs(i,2)),fs);
    Dur2(i) = segs(i,2)/fs-segs(i,1)/fs;
    WE2(i) = w;
    text(segs(i,1)/fs, 7000, num2str(round(w*100)), 'Color', [1 1 1]);
    plot([segs(i,1)/fs segs(i,2)/fs], [6000 6000], 'r', 'linewidth',6)
end
set(gcf, 'papersize', [6 4], 'paperposition', [0 0 6 4])
saveas(gcf, ['specgramTutors.pdf'])
figure(1); hold on; 
plot(Dur1,WE1,'c.');
plot(Dur2,WE2,'k.')
xlabel('duration (s)')
ylabel('entropy')
legend('song one', 'song two', 'location', 'northwest')
set(gcf, 'papersize', [6 4], 'paperposition', [0 0 6 4])
saveas(gcf, ['sylclustTutors.pdf'])
%set(gca, 'xscale', 'log')
