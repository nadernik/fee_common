clear all
close all
datadir = 'c:\stetner\data\pitchfluctuations';
datafiles = dir([datadir filesep '*.mat']);
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
       
    %pause
end

figure
scatter(meanpitch, acorr(1,:))
xlabel('Mean Pitch')
ylabel('Autocorrelation at max lag')

figure
scatter(duration, acorr(1, :))
xlabel('Duration')
ylabel('Autocorrelation at max lag')