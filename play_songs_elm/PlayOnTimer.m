clear all; close all; clear t; clear t

% startday = '3/29/13 11:06';
% StartTime = datenum(startday);
% PlayToday = timer('TimerFcn', 'PlaySongs');
% startat(PlayToday, StartTime);

startday = '4/24/13 9:05';
StartTime = datenum(startday);
dt = 1;
for day = 1:7
    t{day} = timer('TimerFcn', 'PlaySongs'); 
    startat(t{day},StartTime+(day-1)*dt)
end