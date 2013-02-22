clear all; close all; clear t; clear t

startday = '2/14/13 11:40';
StartTime = datenum(startday);
PlayToday = timer('TimerFcn', 'PlaySongs');
startat(PlayToday, StartTime);

startday = '2/15/13 9:05';
StartTime = datenum(startday);
dt = 1;
for day = 1:7
    t{day} = timer('TimerFcn', 'PlaySongs'); 
    startat(t{day},StartTime+(day-1)*dt)
end