function handles = egm_BoutsOverTime(handles)

% songs per hour
nFiles = length(handles.dbase.SoundFiles); 
for fi = 1:nFiles
    TIME(fi) = handles.dbase.SoundFiles(fi).datenum; 
end
[n,x] = hist(TIME,50); 
figure; hist(TIME,50); 
ylabel('# bouts')
xlabel('Time')
set(gca, 'xtick', x(round((0:5)*(length(x)-1)/5)+1), ...
    'xticklabel', datestr(x(round((0:5)*(length(x)-1)/5)+1), 'HH:MM'))
