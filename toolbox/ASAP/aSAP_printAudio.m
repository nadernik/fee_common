function aSAP_printAudio(wavs,p,prefix)
h = figure;
nPerFig = 15;

fs = 44100;
filtOrder = 200; %suffiencity for 44100Hz of lower
filtwin = hann(filtOrder+1);
freqCutoff = 300; %Hz
hpf = fir1(filtOrder, freqCutoff/(fs/2), 'high', filtwin);
nPage = 1;

for(nWav = 1:length(wavs))
    if(~strcmp(p,''))
        [audio, fs] = wavread([p,filesep,wavs{nWav}]);
    else
        [audio, fs] = wavread(wavs{nWav});
    end
    audio = filter(hpf, 1, audio);
    subplot(nPerFig,1,mod(nWav,nPerFig)+1);
    plot([0:(length(audio)/fs)/(length(audio)-1):length(audio)/fs],audio); axis tight;
    set(gca, 'XTickLabelMode', 'manual');
    set(gca, 'XTickLabel',[]);
    yl = ylim;
    xl = xlim;
    t = text(xl(2),yl(1),num2str(mod(aSAP_extractTimeFromSAPFileName(wavs{nWav}),1)*24));
    set(t,'VerticalAlignment','baseline');
    set(t,'HorizontalAlignment','right');
    if(mod(nWav,nPerFig) == 0)
        print('-djpeg', [prefix,'-page',num2str(nPage)]);
        nPage = nPage + 1;
    end
end
