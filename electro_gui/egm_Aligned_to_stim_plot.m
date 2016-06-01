function handles = egm_Aligned_to_stim_plot(handles)
persistent prevparams

fls = get(handles.list_Files,'string');
found = [];
for c = 1:handles.TotalFileNumber
    if strcmp(fls{c}(19),'F')
        found = [found c];
    end
end
if isempty(found)
    found = 1:handles.TotalFileNumber;
end



str = get(handles.popup_EventList,'string');
str = str(2:end);
mn = [];
for c = 1:length(str)
    mn = [mn ',''' str{c} ''''];
end
indx = eval(['menu(''Choose events''' mn ')']);

nums = [];
for c = 1:length(handles.EventTimes);
    nums(c) = size(handles.EventTimes{c},1);
end
cs = cumsum(nums);

f = length(find(cs<indx))+1;
if f>1
    g = indx-cs(f-1);
else
    g = indx;
end

evtimes = cell(1,handles.TotalFileNumber);
for c = found
    ev = handles.EventTimes{f}{g,c};
    isin = handles.EventSelected{f}{g,c};
    evtimes{c} = ev(find(isin==1));
end


mn = [];
f = [];
for c = 1:length(handles.chan_files)
    if ~isempty(handles.chan_files{c})
        f = [f c];
    end
end
for c = f
    mn = [mn ',''Channel ' num2str(c) ''''];
end
chan = eval(['menu(''Choose channel''' mn ')']);
chan = f(chan);

%% Ask user for parameters
names{1}    = 'Min time (sec)';
defaults{1} = '-0.05';
names{2}    = 'Max time (sec)';
defaults{2} = '0.05';
names{3}    = 'Min value';
defaults{3} = '-0.4';
names{4}    = 'Max value';
defaults{4} = '0.4';
names{5}    = 'Spacing (%)';
defaults{5} = '-25';

% Use parameters from last time as default, if possible
if ~isempty(prevparams)
    defaults = prevparams;
end

answer = inputdlg(names, 'Options', 1, defaults);
if isempty(answer)
    return
end
t1 = round(str2double(answer{1})*handles.fs);
t2 = round(str2double(answer{2})*handles.fs);
mn = str2double(answer{3});
mx = str2double(answer{4});
spc = (1+str2double(answer{5})/100)*(mx-mn);
prevparams = answer; % store current parameters - will use as defaults next time
%% Get all data to plot
rownum = 0;
alldata = [];
for c = 1:handles.TotalFileNumber
    if ~isempty(evtimes{c})
        [data, ~, ~, ~, ~] = eval(['egl_' handles.chan_loader{chan} '([''' handles.path_name '\' handles.chan_files{chan}(c).name '''],1)']);
        for d = 1:1:length(evtimes{c})
            if evtimes{c}(d) + t1 >  0 && ...
               evtimes{c}(d) + t2 <= length(data)
                dt = data(evtimes{c}(d)+t1:evtimes{c}(d)+t2);
                dt(dt < mn) = mn;
                dt(dt > mx) = mx;
                rownum = rownum + 1;
                alldata(rownum, :) = dt';
            end
        end
    end
end


%% Plot data
figure
hold on
x = (t1:t2)/handles.fs*1000;
offs = 0;
for rownum = 1:size(alldata, 1);
    plot(x, alldata(rownum, :) + offs)
    offs = offs + spc;
end
axis tight;
ps = get(gcf,'position');
ps(2) = 400;
ps(4) = range(ylim)*40;
set(gcf,'position',ps);
set(gca,'ytick',[]);