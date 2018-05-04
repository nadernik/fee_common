d0 = datenum('05-18-2014'); % pre stim
d1 = datenum('05-27-2014'); % first post stim day
%d2 = datenum('06-04-2014'); % last day to plot
% d1 = datenum('06-04-2014'); % last day to plot
d2 = datenum('06-16-2014'); % last day to plot

bird = '4705'; 
%list of bin edges
lst = 2:2:500; 
days = [d0 d1:d2];
y = zeros(length(days), length(lst)); 
label = {}; 
%load(fullfile('Z:\emackev\AcqGui\', bird, day, depth, 'raster'))
for di = 1:length(days)
    label{di} = [datestr(days(di)),' (',num2str(days(di) - datenum('05-27-2014') + 63) , ' dph)'] ; 
    day = datestr(days(di), 'yyyy-mm-dd'); 
    load(fullfile('Z:\emackev\AcqGui\', bird, day, 'analysis'))
    % figure out handles, 
    fls = 1:length(dbase.SegmentTimes); 
    % compile syll on to on for all files
    durs = zeros(0,2);
    for c = fls % array of files
        f = find(dbase.SegmentIsSelected{c} == 1);
        durs = [durs; dbase.SegmentTimes{c}(f,:)]; % gathering all the onsets and offsets
    end
    % make vector of bin edges
    durs = diff(durs(:,1)); %durs(:,2)-durs(:,1); % calculating duration (samples)
    durs = durs/dbase.Fs*1000; % converting duration to miliseconds
    % calculate probability of each dur
    y(di,:) = histc(durs,lst)/sum(histc(durs,lst)); % converting to probability
end
figure(1);clf;hold all; 
Colors = jet(length(days)); 
for di = 1: length(days)
    plot((lst(1:end-1)+lst(2:end))/2,smooth(y(di,1:end-1)), ...
        'color', Colors(di,:), 'linewidth', 2); 
end



legend(label); 
plot([150 150], [0 1.05*max(max(y))], 'k', 'linewidth', 2)
axis tight
xlabel('Onset-to-onset interval (ms)');
ylabel('Probability');
set(gcf, 'Color', [1 1 1], 'papersize', [6 4], 'paperposition', [0 0 6 4])