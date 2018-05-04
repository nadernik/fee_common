% Do higher pitch syllables have more variability?

clear all
close all
datadir = 'c:\stetner\data\pitchfluctuations\long_stacks_for_figure';
datafiles = dir([datadir filesep '*_yesdc.mat']);

for n = 1:length(datafiles)
    disp(datafiles(n).name)
    temp = load([datadir filesep datafiles(n).name]);
    
    birdname{n}  = temp.birdname;
    meanpitch(n) = mean(mean(temp.meanpitch));
    pitch_mean_subtracted{n} = temp.pitches / 100 .* temp.meanpitch;
    stdpitch(n)  = std(pitch_mean_subtracted{n}(:));
end


% plot histograms color coded by mean pitch
figure
hold all
bins = -80:2:80; % Hz pitch difference from mean
[junk, ord] = sort(meanpitch);
c = colormap;
colors = c(round(linspace(1,64,length(datafiles))),:);
for n = 1:length(datafiles)
    counts = hist(pitch_mean_subtracted{ord(n)}(:), bins);
    stairs(bins, counts/sum(counts), 'Color', colors(n,:));
end

xlabel('Pitch difference from mean (Hz)')
ylabel('Probability')
legend(birdname{ord})

figure
scatter(meanpitch, stdpitch)
xlabel('Mean Pitch')
ylabel('Standard Deviation of Pitch')

figure
cv = stdpitch ./ meanpitch;
scatter(meanpitch, cv)
xlabel('Mean Pitch (Hz)')
ylabel('Coefficient of Variation')