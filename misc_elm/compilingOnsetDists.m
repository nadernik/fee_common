clear all; close all; clc
bird = '3646'; 
bday = datenum('2-26-2013'); 
d1 = datenum('04-21-2013'); 
d2 = datenum('05-12-2013'); 


%list of bin edges
lst = 2:2:500; 
curr = pwd; 
cd(fullfile('Z:\emackev\AcqGui\', bird)); 
Ds = dir('*-*'); 
days = [];
c = 1; 
for i = 1:length(Ds)
    try
        d = datenum(Ds(i).name); 
        if d>=d1 & d<=d2 & length(dir([Ds(i).name, '\*chan*']))>100
            days(c) = d;
            c = c + 1; 
        end
    catch exception % some folders have non-date names
        exception
    end
end
cd(curr); 
y = zeros(length(days), length(lst)); 
label = {}; 
for di = 1:length(days)
    label{di} = [datestr(days(di)),' (',num2str(days(di) - bday) , ' dph)'] ; 
    day = datestr(days(di), 'yyyy-mm-dd'); 
    load(fullfile('Z:\emackev\AcqGui\', bird, day, 'analysisAuto'))
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
axis tight
xlabel('Onset-to-onset interval (ms)');
ylabel('Probability');
set(gcf, 'Color', [1 1 1], 'papersize', [6 4], 'paperposition', [0 0 6 4])