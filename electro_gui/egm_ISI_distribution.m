function handles = egm_ISI_distribution(handles)
% ElectroGui macro
% Plots the syllable distribution of all analyzed files

filenum = str2num(get(handles.edit_FileNumber,'string')); % get current file number
answer = inputdlg({'Files','Array of bin edges (ms)', 'log xaxis?', 'event ind (order in sorted raster menu)'},'ISI distribution',1,{[num2str(filenum)],'logspace(-3,3.75,100)', '1', '1'}); % input dialog box
if isempty(answer)
    return
end
fls = eval(answer{1}); % array of files to be analyzed, convert from string to number
lst = str2num(answer{2}); % array of histogram bin edges (ms)
logaxis = str2num(answer{3});
EventInd = str2num(answer{4});
ISIs = zeros(0,1);
for c = fls % array of files
    spiketimes = handles.EventTimes{EventInd}{1, c}; % sometimes this indexing is different... handles.EventTimes{1}{1,c}; % change to use input to select which event
    
    ISIs = [ISIs; diff(spiketimes)]; 
end


ISIs = ISIs/handles.fs*1000; % converting duration to miliseconds

figure

y = histc(ISIs,lst);% /length(ISIs); % converting to probability
if ~isempty(ISIs) % duration is not empty
    bar((lst(1:end-1)+lst(2:end))/2,y(1:end-1)); % x-axis is the value in between the edges
end
if logaxis
    set(gca, 'xscale', 'log')
end
xmin = find(y); xmin = xmin(1); xmin = lst(xmin);
xlim([xmin lst(end)]);
ylim([0 max(y)*1.2]);
xlabel('ISI (ms)');
ylabel('Count'); 