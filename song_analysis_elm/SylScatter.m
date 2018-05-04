%% load data, check it looks ok
function [Dur, WE] = SylScatter(birdname, expername, rootdir, filenums);
c = 1;
for filenum = filenums;
    Exp = loadExper(birdname, expername, rootdir);
    chan = Exp.audioCh;
    Dat = loadData(Exp, filenum, chan);
    %figure; displaySpecgramQuick(Dat,Exp.desiredInSampRate)
    %sound(Dat,Exp.desiredInSampRate)
    filename = getExperDatafile(Exp,filenum,chan);
    fs = Exp.desiredInSampRate;
    segs = Syllable_segment_Emily_var(Dat,fs,4000);
    hold on; 
    for i = 1:size(segs,1)
        w = weinerEntropy(Dat(segs(i,1):segs(i,2)),fs);
        Dur(c) = segs(i,2)/fs-segs(i,1)/fs;
        WE(c) = w;
        c = c+1;
        %text(segs(i,1)/fs, 7000, num2str(round(w*100)), 'Color', [1 1 1]);
        %plot([segs(i,1)/fs segs(i,2)/fs], [6000 6000], 'r', 'linewidth', 6)
    end
end


