clear all
close all
datadir = 'c:\stetner\data\pitchfluctuations\long_stacks_for_figure';
datafiles = dir([datadir filesep '*_yesdc.mat']);
figure
axes('FontSize', 16)
hold all
for n = 1:length(datafiles)
    disp(datafiles(n).name)
    temp = load([datadir filesep datafiles(n).name]);
    plot(temp.lags, mean(temp.acorr, 2))
    
    birdname{n} = temp.birdname;
    acorr(:, n) = mean(temp.acorr, 2); % assume lags are the same for all
    meanpitch(n) = mean(mean(temp.meanpitch));
    duration(n) = temp.timewindow(2) - temp.timewindow(1);
end

legend(birdname{:})

figure
scatter(meanpitch, acorr(1,:))
xlabel('Mean Pitch')
ylabel('Autocorrelation at max lag')

figure
scatter(duration, acorr(1, :))
xlabel('Duration')
ylabel('Autocorrelation at max lag')