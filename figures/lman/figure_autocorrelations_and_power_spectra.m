function figure_autocorrelations_and_power_spectra
%%
fs=1e3;

b(1).name= '1772';
b(2).name= 'black401';
b(3).name= 'blue298';
b(4).name= 'mes003';
b(5).name= 'mes010';
b(6).name= 'mes011';
b(7).name= 'mes013';
b(8).name= 'mes020';
b(9).name= 'mes021';
% b(10).name= 'mes021';

b(1).exper = '2010-08-26';
b(2).exper = '2010-12-20';
b(3).exper = '2010-12-12';
b(4).exper = '2011-02-08';
b(5).exper = '2011-02-26';
b(6).exper = '2011-03-03';
b(7).exper = '2011-03-10';
b(8).exper = '2011-04-09';
b(9).exper = '2011-05-03';
% b(10).exper = '2011-05-03';

b(1).syllable = 1;
b(2).syllable = 1;
b(3).syllable = 1;
b(4).syllable = 2;
b(5).syllable = 2;
b(6).syllable = 2;
b(7).syllable = 1;
b(8).syllable = 2;
b(9).syllable = 1;

c = colormap;
colors = c(round(linspace(1,64,length(b))),:);

%% Load all data
for ii = 1:length(b)

    pitchfluctuations_data_file = sprintf('c:\\stetner\\data\\pitchfluctuations\\long_stacks_for_figure\\%s_yesdc.mat', b(ii).name)
    if ~exist(pitchfluctuations_data_file, 'file')
        warning(['File does not exist: ' pitchfluctuations_data_file])
        continue
    end
    
    load(pitchfluctuations_data_file, 'P')

    % autocorrelation
    debugdisp('Autocorrelation')
    load(pitchfluctuations_data_file, 'acorr', 'lags')
    if ~exist('acorr', 'var')
        acorr = zeros(P.MaxLag * 2 + 1, size(pitches, 2));
        for col = 1:size(pitches, 2)
            [c, lags] = xcorr(pitches(:, col), P.MaxLag, 'unbiased');
            acorr(:, col) = c / max(c);
        end
    end
    b(ii).acorr = mean(acorr, 2);
    b(ii).lags = lags;
    clear acorr c lags P
    
    % power spectrum
    debugdisp('Power spectrum')
    load(pitchfluctuations_data_file, 'freq', 'freqpower')
    b(ii).freq = freq;
    b(ii).freqpower = mean(freqpower,2);

end

% reorder by value of autocorrleation at longest lag
temp = [b.acorr];
[junk, ndx] = sort(temp(1,:));
b = b(ndx);

%% Plot all autocorrelations
figure
set(gca, 'ColorOrder', colors)
hold all
for ii = 1:length(b)
    plot(b(ii).lags, b(ii).acorr, 'LineWidth', 2)
end
set(gca, 'XTick', -10:5:10, 'YLim', [0 1], 'YTick', 0:0.25:1)
xlabel('Lag (ms)')
ylabel('Correlation (normalized)')

%% Plot all power spectra
figure
set(gca, 'ColorOrder', colors)
hold all
for ii = 1:length(b)
    plot(b(ii).freq, b(ii).freqpower, 'LineWidth', 2)
end
set(gca, 'YScale', 'log')
set(gca, 'XTick', 0:100:500)
xlabel('Frequency (Hz)')
ylabel('Power')

%% 
temp = mat2cell(colors, ones(1,length(b)), 3);
[b.color] = deal(temp{:});
save('c:\stetner\data\pitchfluctuations\long_stacks_for_figure\birds.mat', 'b')