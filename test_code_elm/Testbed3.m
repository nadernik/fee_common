% this file removes gaps, stretches, and flattens a song, and generates
% relevant plots.
%% just start with the third cell...
[bells,fs] = wavread('OferSongs/bells.wav'); 
sound(bells, fs)
A = 10*log(conv(bells.^2, gausswin(100), 'same'));
figure; plot(A);shg
figure; hist(A,100);shg
%% skip this
close all
Thress = [-30:10:0];

figure; subplot(numel(Thress)+1,1,1);
displaySpecgramQuick(bells,fs); 
sound(bells,fs)
title('original')
for Thresi = 1:numel(Thress)
    Thres = Thress(Thresi);
    B = bells;
    NoGaps = B(A>Thres);
    subplot(numel(Thress)+1,1,1+Thresi);
    displaySpecgramQuick(NoGaps,fs);
    title(['Thres=', num2str(Thres)])
    sound(NoGaps,fs)
    set(gcf, 'papersize', [8 3*numel(Thress)], 'paperposition', [0 0 8 3*numel(Thress)]);
    saveas(gcf, 'temp.pdf')
    wavwrite(NoGaps,fs, ['Thres=', num2str(Thres)]);
end

%%
[bells,fs] = wavread('OferSongs/bells.wav'); 
segs = Syllable_segment_Emily('OferSongs/bells.wav', 4000); 

figure; 
subplot(411); 
displaySpecgramQuick(bells,fs); hold on

ind = [];
for i = 1:size(segs,1)
    ind = [ind segs(i,1):segs(i,2)];
    plot([segs(i,1)/fs segs(i,2)/fs], [6000 6000], 'r', 'linewidth', 6)
end
title('original')
xlim([0 .8])
sound(bells,fs)

subplot(412); 
displaySpecgramQuick(bells(ind),fs); 
NoGaps = bells(ind);
sound(NoGaps,fs)
wavwrite(NoGaps,fs, ['BellsNoGaps']);
xlim([0 .8])
title('no gaps')

subplot(413)
StretchedNoGaps = pvoc(NoGaps, numel(NoGaps)/numel(bells), 200);
displaySpecgramQuick(StretchedNoGaps,fs); 
sound(StretchedNoGaps, fs)
wavwrite(StretchedNoGaps,fs, ['BellsNoGapsStretched']);
xlim([0 .8])
title('no gaps stretched with pvoc')

% flatten amplitude
FlatSNG = pvocnormalized(NoGaps, numel(NoGaps)/numel(bells),200);
FlatSNG = FlatSNG/mean(FlatSNG)*mean(StretchedNoGaps);
subplot(414); displaySpecgramQuick(FlatSNG,fs)
wavwrite(FlatSNG,fs, ['BellsNoGapsStretchedFlattened']);
xlim([0 .8])
title('no gaps, stretched, flattened')
sound(FlatSNG,fs)

set(gcf, 'papersize', [8 12], 'paperposition', [0 0 8 12]);
saveas(gcf, 'temp.pdf')

%%
time = 1/fs:1/fs:length(StretchedNoGaps)/fs;
figure; subplot(211)
plot(time,StretchedNoGaps);
title('no gaps, stretched')
subplot(212)
plot(time,FlatSNG);
title('no gaps, stretched, flattened')
set(gcf, 'papersize', [8 6], 'paperposition', [0 0 8 6]);
saveas(gcf, 'temp1.pdf')

figure; 
plot(1/fs:1/fs:length(bells)/fs,bells);
title('original')
set(gcf, 'papersize', [8 3], 'paperposition', [0 0 8 3]);
saveas(gcf, 'temp2.pdf')