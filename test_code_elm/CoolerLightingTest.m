birdnames = {'3284', '3294', '3423', '3458', ...
    '3288', '3292', '3403', '3426', '3427', ...
    '3289', '3291', '3293', '3422', '3434', '3449'};
Cooler = [0 4 3 0 2 6 7 1 4 5 1 3 5 2 6]; 
SongQuality = [0 0 0 0 1 1 1 1 1 2 2 2 2 2 2];
CoolerQuality = [0 2 2 0 0 1 2 1 2 1 1 2 1 0 1];
jitters = rand(1,numel(birdnames))*.25-.5;
figure
plot(SongQuality-jitters, CoolerQuality, '.');
[h,p] = ttest(SongQuality,CoolerQuality)