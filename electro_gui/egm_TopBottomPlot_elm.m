function handles = egm_TopBottomPlot_elm(handles)
figure(); 
filenum = str2double(get(handles.edit_FileNumber, 'string')); % get current file number
FS = 8; % labels 
FS_axes = 8; % axis labels
%h = subplot(2,1,1)
fs = handles.fs;
lims = get(handles.axes_Sonogram, 'xlim');
if lims(1) < 1 / fs;
    lims(1) = 1 / fs;
end
if lims(2) * fs > numel(handles.sound)
    lims(2) = numel(handles.sound) / fs;
end
ind_time = lims(1):(1 / fs):lims(2);
% song = handles.sound(round(ind_time * fs));
Top = handles.chan1(round(ind_time * fs));
Bottom = handles.chan2(round(ind_time * fs));
time = 0:(1 / fs):(lims(2) - lims(1));

%%
h = subplot(2, 1, 1);
set(gca, 'box', 'off', 'ColorOrder', [0, 0, 0], 'NextPlot', 'replacechildren')
plot(time, Top, 'linewidth', 1); %mini_max_plot(time, units, 'ax', g)
% ylabel(get(get(handles.axes_Channel1, 'ylabel'), 'string'),'fontsize',FS); 
axis tight
% set(gca, 'ytick', [0, 0.2], 'yticklabel', {'0', '0.2'})
set(gca, 'xtick', [])
box off

set(gca, 'color', 'none', 'tickdir', 'out', 'ticklength', [0.025, 0.025])
set(gca, 'fontsize' ,FS_axes)

%%
% subplot(3,1,2)
% plot((1:size(handles.sound))/handles.fs, handles.amplitude)
g = subplot(2, 1, 2);
set(gca, 'box', 'off', 'ColorOrder', [0, 0, 0], 'NextPlot', 'replacechildren')
plot(time, Bottom, 'linewidth', 1); %mini_max_plot(time, units, 'ax', g)
xlabel('Time(s)','fontsize',FS); 
% ylabel(get(get(handles.axes_Channel1, 'ylabel'), 'string'),'fontsize',FS); 
axis tight
% set(gca, 'ytick', [0, 0.2], 'yticklabel', {'0', '0.2'})
box off

set(gca, 'color', 'none', 'tickdir', 'out', 'ticklength', [0.025, 0.025])
set(gca, 'fontsize' ,FS_axes)

linkaxes([h g],'x')
%% in order to make no space between plots
ShrinkBy = 4; 
p = get(h, 'pos');
q = get(g, 'pos');
m = mean([p(2), q(2) + q(4)]);
gap = p(2) - (q(2) + q(4));
p(2) = m + gap / (2 * ShrinkBy);
q(4) = m - q(2)-  gap / (2 * ShrinkBy);
set(h, 'pos', p)
set(g, 'pos', q)

%%

set(gcf, 'Color', [1, 1, 1], 'papersize', 2 * [4, 2], 'paperposition', 2 * [0, 0, 4, 2]); 
%print fig -dmeta -r300
