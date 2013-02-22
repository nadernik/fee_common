close all 
birdnames = {'3284', '3294', '3423', '3458', ...
    '3288', '3292', '3403', '3426', '3427', ...
    '3289', '3291', '3293', '3422', '3434', '3449'};
Cooler = [0 4 3 0 2 6 7 1 4 5 1 3 5 2 6]; 
SongQuality = [0 0 0 0 1 1 1 1 1 2 2 2 2 2 2];
CoolerQuality = [0 2 2 0 0 1 2 1 2 1 1 2 1 0 1];
LightReadings = [6.99 7 7.02 6.72 6.90 7.01 7.04 6.92;...
    6.98 6.95 6.97 6.75 6.89 6.94 6.95 6.72;...
    6.91 6.9 6.92 6.81 6.91 6.92 6.94 6.82];
MaxReading = (7.66+7.48)/2; % based on battery voltage
LightReadings = MaxReading - LightReadings;
MeanReadings = mean(LightReadings,1);
StdReadings = std(LightReadings,1);
LightPerBird = MeanReadings(Cooler+1);
StdLightPerBird = StdReadings(Cooler+1);
load(fullfile(PlatformPicker('feebox3', 'emily'), 'TI_data_weeded', 'Songbirds', 'MI21-Feb-2013'))
for i = 1:numel(birdnames)
    ind = find(not(cellfun(@isempty, (strfind(MI.names, birdnames{i})))))
    ind = ind(1);
    MeanMat(i) = mean(MI.scores{ind});
    StdMat(i) = std(MI.scores{ind});
    SemMat(i) = sem(MI.scores{ind});
end
jitters = rand(1,numel(birdnames))*.25-.25/2;
jitters2 = rand(1,numel(birdnames))*.25-.25/2;
% figure
% plot(CoolerQuality-jitters, SongQuality-jitters2, '.');
% set(gca, 'ytick', [0 1 2], 'yticklabel', {'subsongy/immature', 'mediocre', 'good'},...
%     'xtick', [0 1 2], 'xticklabel', {'low', 'medium', 'high'});
% ylabel('song maturity'); xlabel('lighting quality')
% set(gcf, 'Papersize', [8 6], 'Paperposition', [0 0 8 6])
for i = 1:numel(birdnames)
    if CoolerQuality(i) == 0
        Light{i} = 'low';
    end
    if CoolerQuality(i) == 1
        Light{i} = 'medium';
    end
    if CoolerQuality(i) == 2
        Light{i} = 'high';
    end
end
%% Check maturity index consistent with by-ear categories
figure; 
plot(MeanMat, SongQuality + jitters2, '.')
text(MeanMat, SongQuality + jitters2, birdnames)
xlabel('Calculated Maturity'); ylabel('by ear')
set(gca, 'ytick', [0 1 2], 'yticklabel', {'subsongy/immature', 'mediocre', 'good'})
% NOT CONSISTENT -- need better measure of maturity.
%% Check lighting measures consistent with by-eye categories
figure
plot(LightPerBird, (CoolerQuality)+jitters2,'.')
text(LightPerBird, (CoolerQuality)+jitters2,birdnames)
xlabel('light reading'); ylabel('by eye')
set(gca, 'ytick', [0 1 2], 'yticklabel', {'low', 'medium', 'high'})
% fairly consistent, some mixing of medium and low categories.
%%
figure; 
plot(LightPerBird,SongQuality+jitters2,'.')
text(LightPerBird,SongQuality+jitters2, birdnames)
ylabel('Song Quality'); xlabel('Brightness (au)')
set(gca, 'ytick', [0 1 2], 'yticklabel', {'subsongy/immature', 'mediocre', 'good'})
ylim([-.5 2.5])
%set(gca, 'xscale', 'log')
% doesn't seem to be an effect.
%%


%%
anova1(SongQuality, Light)
ylabel('song maturity on a scale from 0 to 2')
set(gcf, 'Papersize', [8 6], 'Paperposition', [0 0 8 6])