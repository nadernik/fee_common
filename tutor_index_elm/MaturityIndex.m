%% calculate maturity index 
clear all
pathname = 'Y:\TI_data_weeded\Songbirds'; 
cd(pathname)
MI.names = {'3289', '3291', '3403', '3422', '3423', '3426', '3427', '3434', ...
    '3449', '3458'};
MI.scores = cell(1,numel(MI.names));
for birdi = 1:numel(MI.names)
    birdname = MI.names{birdi}; 
    DIR = dir(fullfile(pathname, birdname, 'bouts', 'extr*.mat'));
    N =  numel(DIR);
    nPairs = min([10, N]);
    for i = 1:nPairs
        load(fullfile(pathname, birdname, 'bouts', DIR(i).name));
        bout{i} = rec.Data;
        fs = rec.Fs;
    end
    for c = 1:nPairs
        idx = randsample(nPairs,2)
        MI.scores{birdi}(c) = SpecCrossCorr_YM2(bout{idx(1)}, bout{idx(2)}, fs)
        disp(num2str(birdname));
    end
end
%%
save MI MI