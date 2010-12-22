function displayRecording(exper,num)

sp(1) = subplot(length(exper.sigCh)+2, 1, 1);
audio = loadAudio(exper,num);
displayAudioSpecgram(audio, exper.desiredInSampRate, 0, 6000, [-5 50]);
line(xlim, [3100,3100]); line(xlim, [3500, 3500]);
title([exper.birdname, ' ', exper.expername, ' file:', num2str(num)]);
sp(2) = subplot(length(exper.sigCh)+2, 1, 2);
time = [0:length(audio)-1] / exper.desiredInSampRate;
plot(time, audio);
axis tight;
for(ch = 1:length(exper.sigCh))
    sp(ch+2) = subplot(length(exper.sigCh)+2, 1, ch+2);
    data = loadData(exper,num,exper.sigCh(ch));
    plot(time, data);
    axis tight;
end
linkaxes(sp,'x');
