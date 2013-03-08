clear all; close all; clear t; clear t

% startday = '2/18/13 9:43';
% StartTime = datenum(startday);
% PlayToday = timer('TimerFcn', 'PlaySongs');
% startat(PlayToday, StartTime);

startday = '3/08/13 9:05';
StartTime = datenum(startday);
dt = 1;
for day = 1:7
    t{day} = timer('TimerFcn', 'PlaySongs'); 
    startat(t{day},StartTime+(day-1)*dt)
end