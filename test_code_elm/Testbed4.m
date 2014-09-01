% labeling intro notes for tutor songs from Liora's database
clear all; close all; 
cd ~/../../Volumes/emackev
pathname = 'MI_newTutor/c*';
DIR1 = dir(pathname); 

bird = DIR1(3).name;
fullPathname = [pathname(1:end-1), num2str(bird(2:end)), '/',...
    '*.wav'];
DIR = dir(fullPathname)
DIR = DIR(3:end);

syli = 1;
Length = [];
Entropy = [];

for i = 1:2:size(DIR,1) % 2648 intro note clips: [414 421 435 442 449 450 464 492 503 505 510 517]
    figure; hold on
    [song,fs] = wavread([fullPathname(1:end-5), DIR(i).name]);
    displaySpecgramQuick(song, fs); title(DIR(i).name);
    segs{i} = Syllable_segment_Emily([fullPathname(1:end-5), DIR(i).name], 4000);
    for segi = 1:size(segs{i},1)
        Length(syli) = (segs{i}(segi,2)-segs{i}(segi,1))/fs*1000;
        syl = song(segs{i}(segi,1):segs{i}(segi,2));
        Entropy(syli) = weinerEntropy(syl,fs);
        % calculate fourier spectrum
        % normalize so it sums to one
        if Length(syli)>80 & Length(syli)<101 % bird 1: 30; bird 2: 100; 
            plot([segs{i}(segi,1)/fs segs{i}(segi,2)/fs], [6000 6000], 'y', 'linewidth', 6)
        else
            plot([segs{i}(segi,1)/fs segs{i}(segi,2)/fs], [6000 6000], 'r', 'linewidth', 6)
        end
        syli = syli+1;
    end
    sound(song, fs);
end

figure; 
plot(Length, Entropy, 'k.')
xlabel('length (ms)')
ylabel('weiner entropy'); 
% set(gcf, 'papersize', [4 3], 'paperposition', [0 0 4 3]);
% saveas(gcf, 'temp.pdf')

%%
figure; hold on
set(gcf, 'papersize', [10 3], 'paperposition', [0 0 10 3]);
[song,fs] = wavread([fullPathname(1:end-5), DIR(i).name]);
displaySpecgramQuick(song, fs); 
segs{i} = Syllable_segment_Emily([fullPathname(1:end-5), DIR(i).name], 4000);
for segi = 1:size(segs{i},1)
    Length(syli) = (segs{i}(segi,2)-segs{i}(segi,1))/fs*1000;
    syl = song(segs{i}(segi,1):segs{i}(segi,2));
    Entropy(syli) = weinerEntropy(syl,fs);
    % calculate fourier spectrum
    % normalize so it sums to one
    if Length(syli)>80 & Length(syli)<101 % bird 1: 30; bird 2: 100; 
        plot([segs{i}(segi,1)/fs segs{i}(segi,2)/fs], [6000 6000], 'y', 'linewidth', 6)
    else
        plot([segs{i}(segi,1)/fs segs{i}(segi,2)/fs], [6000 6000], 'r', 'linewidth', 6)
    end
    syli = syli+1;
end
saveas(gcf, 'temp.pdf')
wavwrite(song,fs, 'temp.wav')
sound(song, fs);