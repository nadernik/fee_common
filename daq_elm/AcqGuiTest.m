%% start recording 8 audio channels
createExperMulti
%% load data, check it looks ok
Exp = loadExper('3292', '2012-11-09', 'C:\Documents and Settings\Tim C\My Documents\MATLAB\AcqGUI')
Dat = loadAudio(Exp, 3);
figure; displaySpecgramQuick(Dat,Exp.desiredInSampRate)
sound(Dat,Exp.desiredInSampRate)

%%
clear all; close all; clear t; clear t

startday = '09/27/12 9:30';
StartTime = datenum(startday);
dt = 1;
for day = 1:40
    t{day} = timer('TimerFcn', 'PlaySongs'); 
    startat(t{day},StartTime+(day-1)*dt)
end