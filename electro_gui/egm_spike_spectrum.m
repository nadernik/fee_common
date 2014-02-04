function handles = spike_spectrum(handles)
% ElectroGui macro
% Plots the syllable distribution of all analyzed files

filenum = str2num(get(handles.edit_FileNumber,'string')); % get current file number
answer = inputdlg({'File','[winsize winstep]', '[minfreq maxfreq]', 'Event Index (order in sorted raster dropdown list)'},'in seconds...',1,{[num2str(filenum)],'[1.5 .1]', '[2 25]', '4'}); % input dialog box
if isempty(answer)
    return
end
file = eval(answer{1}); % array of files to be analyzed, convert from string to number

movingwin = str2num(answer{2}); 
fpass = str2num(answer{3});
EventInd = str2num(answer{4});
fs = handles.fs;
figure; hold all

%smoothing_window = .020; 
spiketimes1 =handles.EventTimes{EventInd}{1, file};
spiketimes = spiketimes1/fs;
spiketrain = zeros(1, numel(handles.sound));
spiketrain(spiketimes1) = 1;
%filter = normpdf(-6*smoothing_window:1/fs:6*smoothing_window, 0, smoothing_window);
%smooth_spiketimes = conv(spiketrain, filter);
%sound(spiketrain, fs);
time = (1:numel(handles.sound))/fs;
%params.tapers = [.1 6];
params.Fs = fs; 
params.fpass = fpass;
%params.pad = -1;
data(1).times = spiketimes;
%winsize = 1;
%winstep = .1;
%movingwin = [winsize winstep];
[S,t,f] = mtspecgrampt(data, movingwin, params);
%[S1,t1,f1] = mtspecgramc(smooth_spiketimes, movingwin, params);
h = subplot(2,1,1)
imagesc((S'), 'Xdata', t, 'Ydata', f)
set(gca, 'ydir', 'normal')
colormap hot
ylabel('frequency (Hz)')
xlabel('time (s)')
% f = subplot(3,1,2)
% imagesc(S1, 'Xdata', t1, 'Ydata', f1)
% colormap hot
% ylabel('frequency (Hz)')
g = subplot(2,1,2)
plot(time,spiketrain, 'k')
linkaxes([h g], 'x')
subplot(g)
xlabel('time (s)')
figure; 
[S,f] = mtspectrumpt(data, params);
plot(f,S)
xlabel('frequency (Hz)')
axis tight



