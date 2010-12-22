function [h] = testtimer

h = figure;
set(h,'Tag', 'word');
setappdata(h,'name',5);
t = timer('TimerFcn','mycallback(t, [], findobj(''Tag'', ''word''))', 'Period', 1);
set(t,'ExecutionMode','fixedDelay');
start(t);
