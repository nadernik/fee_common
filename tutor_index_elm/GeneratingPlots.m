%% generates .jpg and .wav files for each bout
pathname = 'Y:\TI_data_weeded\Songbirds'; 
x = 8; y = 3; 
birds = {'3289', '3291', '3403', '3422', '3423', '3426', '3427', '3434', ...
    '3449', '3458'};

for birdi = 1:numel(birds)
    birdname = birds{birdi}; 
    DIR = dir(fullfile(pathname, birdname, 'bouts', 'extr*.mat'));

    for i = 1:size(DIR)
        load(fullfile(pathname, birdname, 'bouts', DIR(i).name))
        figure; displaySpecgramQuick(rec.Data, rec.Fs);
        set(gcf, 'papersize', [x y], 'paperposition', [0 0 x y])
        saveas(gcf, [fullfile(pathname, birdname, 'bouts', DIR(i).name(1:end-4)), '_', birdname, '.jpg'], 'jpg')
        wavwrite(rec.Data,rec.Fs, [fullfile(pathname, birdname, 'bouts', DIR(i).name(1:end-4)), '_', birdname, '.wav'])
        close all
    end
end

%% plots of scores
close all
clear all
clc
load elm
pathname = 'Y:\TI_data_weeded\Songbirds'; 
picformat = 'png';
x = 8; y = 6; 
for j = 1:numel(Scores)% just imit., for all scores, run: numel(Scores)
    % scatter plot w identity line 
    figure; hold on; 
    lim = .2;
    plot(-10,10,'b.')
    plot(-10,10,'r.')
    xlim([-lim,lim]); ylim([-lim,lim]); 
    legend('intro + song one', 'intro + song two', 'location', 'Northwest')
    plot([-lim lim], [-lim lim], 'k')
    errorbarxy(elm.(Scores{j}).IMeanSubtract, elm.(Scores{j}).noIMeanSubtract, ...
        elm.(Scores{j}).STDI, elm.(Scores{j}).STDnoI, ...
        'Color','k','LineStyle','none','Marker','none')
    scatter(elm.(Scores{j}).IMeanSubtract, elm.(Scores{j}).noIMeanSubtract, ...
        300, elm.Colors, '.')
    text(elm.(Scores{j}).IMeanSubtract+.01, elm.(Scores{j}).noIMeanSubtract,elm.Names)
    xlabel([(Scores{j}),  ' score intro'])
    ylabel([(Scores{j}),  ' score no intro'])
    set(gcf, 'papersize', [x y], 'paperposition', [0 0 x y])
    saveas(gcf, fullfile(pathname, 'figures', [Scores{j} 'ScatterIvsNoI']), picformat)
    
    % w vs wout intros, connected w a line
    figure; hold on; 
    plot(-10,10,'b.')
    plot(-10,10,'r.')
    xlim([-.5,1.5]); ylim([-.25,.3]); 
    legend('intro + song one', 'intro + song two', 'location', 'Northwest')
    jitters = rand(numel(elm.Names),1)*.1-.05;
    for i = 1:numel(elm.Names)
        errorbar([0 1]-jitters(i), [elm.(Scores{j}).IMeanSubtract(i) elm.(Scores{j}).noIMeanSubtract(i)], ...
            [elm.(Scores{j}).STDI(i) elm.(Scores{j}).STDnoI(i)], 'k')
        scatter([0 1]-jitters(i), [elm.(Scores{j}).IMeanSubtract(i) elm.(Scores{j}).noIMeanSubtract(i)], ...
            300, elm.Colors(i,:), '.')
        text(1-jitters(i), elm.(Scores{j}).noIMeanSubtract(i), ['  ', num2str(elm.Names{i})])
    end
    set(gca, 'xtick', [0 1], 'xticklabel', {'intro' 'no intro'})
    ylabel([Scores{j}, ' minus mean'])
    set(gcf, 'papersize', [x/2 y], 'paperposition', [0 0 x/2 y])
    saveas(gcf, fullfile(pathname, 'figures', [Scores{j} 'ColumnsIvsNoI']), picformat)
    
    % song1 vs song2 intros, connected w a line
    figure; hold on; 
    plot(-10,10,'b.')
    plot(-10,10,'r.')
    xlim([-.5,1.5]); ylim([0,.75]); 
    legend('intro + song one', 'intro + song two', 'location', 'Northwest')
    jitters = rand(numel(elm.Names),1)*.1-.05;
    for i = 1:numel(elm.Names)
        errorbar([0 1]-jitters(i), [elm.(Scores{j}).SongOne(i) elm.(Scores{j}).SongTwo(i)], ...
            [elm.(Scores{j}).STDSongOne(i) elm.(Scores{j}).STDSongTwo(i)], 'k')
        scatter([0 1]-jitters(i), [elm.(Scores{j}).SongOne(i) elm.(Scores{j}).SongTwo(i)], ...
            300, elm.Colors(i,:), '.')
        text(1-jitters(i), elm.(Scores{j}).SongTwo(i), ['  ', num2str(elm.Names{i})])
    end
    set(gca, 'xtick', [0 1], 'xticklabel', {'song one' 'song two'})
    ylabel([Scores{j}])
    set(gcf, 'papersize', [x/2 y], 'paperposition', [0 0 x/2 y])
    saveas(gcf, fullfile(pathname, 'figures', [Scores{j} 'ColumnsSongOnevsTwo']), picformat)
    
    % scores vs maturity index
    figure; hold on; 
    errorbarxy(elm.meanMI, elm.(Scores{j}).IMeanSubtract, ...
        elm.stdMI, elm.(Scores{j}).STDI, ...
        'Color','b','LineStyle','none','Marker','none')
    errorbarxy(elm.meanMI+.005, elm.(Scores{j}).noIMeanSubtract, ...
        elm.stdMI, elm.(Scores{j}).STDnoI, ...
        'Color','r','LineStyle','none','Marker','none')
    xlabel('maturity index'); ylabel([Scores{j}, ' minus mean']);
    legend('intro', '','no intro')
    set(gcf, 'papersize', [x y], 'paperposition', [0 0 x y])
    saveas(gcf, fullfile(pathname, 'figures', [Scores{j} 'ScoresvsMaturity']), picformat)
    
    % non mean subtracted scores vs maturity index
    figure; hold on; 
    plot(-10,10,'b.')
    plot(-10,10,'r.')
    xlim([0,.5]); ylim([0,.75]); 
    errorbarxy(elm.meanMI, elm.(Scores{j}).SongOne, ...
        elm.stdMI, elm.(Scores{j}).STDSongOne, ...
        'Color','g','LineStyle','none','Marker','none')
    errorbarxy(elm.meanMI+.005, elm.(Scores{j}).SongTwo, ...
        elm.stdMI, elm.(Scores{j}).STDSongTwo, ...
        'Color','c','LineStyle','none','Marker','none')
    scatter(elm.meanMI, elm.(Scores{j}).SongOne, ...
            300, elm.Colors, '.')
    scatter(elm.meanMI, elm.(Scores{j}).SongTwo, ...
            300, elm.Colors, '.')    
    xlabel('maturity index'); ylabel([Scores{j}, ' minus mean']);
    legend('intro + song one', 'intro + song two', 'song one', '','song two', 'location', 'Northeast')
    set(gcf, 'papersize', [x y], 'paperposition', [0 0 x y])
    saveas(gcf, fullfile(pathname, 'figures', [Scores{j} 'rawScoresvsMaturity']), picformat)
    
    % difference in scores vs maturity index
    figure; hold on; 
    plot(-10,10,'b.')
    plot(-10,10,'r.')
    xlim([0,.5]); ylim([-.2,.2]); 
    legend('intro + song one', 'intro + song two', 'location', 'Southeast')
    errorbarxy(elm.meanMI, elm.(Scores{j}).IMeanSubtract-elm.(Scores{j}).noIMeanSubtract, ...
        elm.stdMI, elm.(Scores{j}).STDI+elm.(Scores{j}).STDnoI, ...
        'Color','k','LineStyle','none','Marker','none')
    text(elm.meanMI+.01, elm.(Scores{j}).IMeanSubtract-elm.(Scores{j}).noIMeanSubtract, ...
        elm.Names)
    scatter(elm.meanMI, elm.(Scores{j}).IMeanSubtract-elm.(Scores{j}).noIMeanSubtract, ...
            300, elm.Colors, '.')
    xlabel('maturity index'); ylabel(['mean-subtracted ',Scores{j}, ', intro minus no intro']);
    set(gcf, 'papersize', [x y], 'paperposition', [0 0 x y])
    saveas(gcf, fullfile(pathname, 'figures', [Scores{j} 'diffscorevsMaturity']), picformat)
end
