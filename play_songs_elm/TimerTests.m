clear all; close all; clear t; clear t

startday = '10/08/12 9:30';
StartTime = datenum(startday);
dt = 1;
for day = 1:8
    t{day} = timer('TimerFcn', 'PlaySongs'); 
    startat(t{day},StartTime+(day-1)*dt)
end