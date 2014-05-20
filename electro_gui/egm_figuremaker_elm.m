function handles = egm_figuremaker_elm(handles)
shg;
figure; 
h = subplot(2,1,1)
fs = handles.fs;
lims = get(handles.axes_Sonogram, 'xlim');
if lims(1) < 1/fs;
    lims(1) = 1/fs;
end
if lims(2)*fs > numel(handles.sound)
    lims(2) = numel(handles.sound)/fs
end
ind_time = lims(1):1/fs:lims(2);
song = handles.sound(round(ind_time*fs));
units = handles.chan1(round(ind_time*fs));
time = 0:1/fs:(lims(2)-lims(1));

%% using chronux. It is prettier this way. 
% Thres = -95; % threshold for being in black background
% 
% params.Fs = fs;
% params.fpass = [0 8000];
% winsize = .015;
% winstep = winsize/10;
% T = winsize; 
% W = 150; % frequency bandwidth
% K = 1; %number of tapers
% params.tapers = [T*W K];
% movingwin = [winsize winstep]; 
% [S,t,f]=mtspecgramc(song,movingwin,params);
% Pow = 10*log10(S)';
% Pow(Pow<Thres) = Thres;
% cmap = jet; 
% cmap(1,:) = zeros(1,3); % background = black
% colormap(cmap);
% surf(t, f/1000, Pow,'edgecolor','none'); axis tight; 
% view(0,90);
% ylabel('Frequency (kHz)')
% %imagesc(t, f, 10*log10(S)');shg
% %set(gca, 'Ydir', 'normal')
%% using displayspecgramquick
set(gca, 'xtick', [])
displaySpecgramQuick(song,fs); 
temp = get(gca, 'Children'); 
cdata = get(temp, 'Cdata');
fdata = get(temp, 'ydata'); 
tdata = get(temp, 'xdata'); 
Thres = -16.2;
cdata(cdata<Thres) = Thres; 
surf(tdata, fdata, cdata, 'edgecolor', 'none'); axis tight; view(0,90)
ylabel('Frequency (kHz)')
colormap(cmap);
%% using MATLAB spectrogram function

% NFFT = 1025;
% windowSize = round(512/25);
% NoiseFloor = -90; 
% [S,F,T, P] = spectrogram(song, windowSize, windowSize/2, NFFT, fs);
% Pow = 10*log10(P);
% Pow(Pow<NoiseFloor) = NoiseFloor; 
% surf(T,F,Pow,'edgecolor','none'); axis tight; 
% cmap = jet; 
% cmap(1,:) = zeros(1,3); 
% colormap(cmap)
% view(0,90);
% ylabel('Frequency (Hz)');
% ylim([0 8000])
% set(gca, 'xtick', [])
%%
% subplot(3,1,2)
% plot((1:size(handles.sound))/handles.fs, handles.amplitude)
g = subplot(2,1,2)
set(gca, 'box', 'off', 'ColorOrder', [0 0 0], 'NextPlot', 'replacechildren')
plot(time, units)
xlabel('Time(s)'); ylabel('Voltage (mV)')
linkaxes([h g],'x')
%xlim([lims(1) lims(2)])
%% in order to make no space between plots
ShrinkBy = 4; 
p = get(h, 'pos');
q = get(g, 'pos');
m = mean([p(2) q(2)+q(4)])
gap = p(2) - (q(2)+q(4));
p(2) = m + gap/(2*ShrinkBy);
q(4) = m-q(2)-  gap/(2*ShrinkBy);
set(h, 'pos', p)
set(g, 'pos', q)
%%
set(gcf, 'Color', [1 1 1], 'papersize', [5 4], 'paperposition', [0 0 5 4])