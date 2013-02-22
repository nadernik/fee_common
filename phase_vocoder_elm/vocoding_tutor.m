pathname = PlatformPicker('feebox1', fullfile('shared', 'colony', 'tutorsong'));
pathname = fullfile(pathname, '73', 'Purple37(previous)', 'undirected', '2461');
DIR = dir(fullfile(pathname, '*.wav'))
close all
for i = 1:10
    figure
    [a,fs] = wavread(fullfile(pathname, DIR(i).name));
    displaySpecgramQuick(a,fs);
    sound(a,fs)
end

%% 8 looked good
close all
i = 8;
[a,fs] = wavread(fullfile(pathname, DIR(i).name));
b = a(1:fs*1.95);
segs = Syllable_segment_Emily(fullfile(pathname, DIR(i).name), 4000); 
displaySpecgramQuick(b,fs); hold on
ind = [];
for i = 1:size(segs,1)
    ind = [ind segs(i,1):segs(i,2)];
    plot([segs(i,1)/fs segs(i,2)/fs], [6000 6000], 'r', 'linewidth', 6)
    %syl{j}{i} = song(segs(i,1):segs(i,2));
end

sound(b,fs)
%%
close all
hist(diff(segs')'/fs, .02:.01:.14)
xlabel('syllable duration'); ylabel('number of syllables')

%%
figure; h = subplot(2,1,1)
displaySpecgramQuick(b,fs); hold on
Stretched = pvoc(b, 2/3, 200);
g = subplot(2,1,2)
displaySpecgramQuick(Stretched,fs); hold on
linkaxes([h g])
xlim([0 max([numel(b)/fs numel(Stretched)/fs])])
sound(b,fs)
sound(Stretched,fs)

