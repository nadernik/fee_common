% close all
clear all

datadir = 'c:\stetner\data\pitchfluctuations';
datafiles = dir([datadir filesep '*_yesdc.mat']);
figure
axes('FontSize', 16, 'XScale', 'log', 'YScale', 'log')
hold all

for n = 1:length(datafiles)
    disp(datafiles(n).name)
    d = load([datadir filesep datafiles(n).name]);
    loglog(d.freq, mean(d.freqpower, 2))
%     pause
end