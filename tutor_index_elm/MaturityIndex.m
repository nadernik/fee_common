%% calculate maturity index 
clear all
add_elm_code_paths;
initial_path = PlatformPicker('feebox3', 'emily');
pathname = fullfile(initial_path, 'TI_data_weeded','Songbirds'); 
MI.names = {'3289', '3291', '3403', '3422', '3423', '3426', '3427', '3434', ...
    '3449', '3458'};
%MI.scores = cell(1,numel(MI.names));
for birdi = 1:numel(MI.names)
    birdname = MI.names{birdi}; 
    DIR = dir(fullfile(pathname, birdname, 'bouts', 'extr*.mat'));
    N =  numel(DIR);
    %nPairs = min([10, N]);
    c = 1;
    for i = 1:N
        load(fullfile(pathname, birdname, 'bouts', DIR(i).name));
        bout1 = rec.Data;
        fs = rec.Fs;
        for j = 1:(i-1)
            tic
            load(fullfile(pathname, birdname, 'bouts', DIR(j).name));
            bout2 = rec.Data;
            if fs~=rec.Fs
                disp('WARNING: inconsistent sampling rates')
            end
            MI.scores{birdi}(c) = SpecCrossCorr_YM2(bout1,bout2,fs);
            disp([birdname, ' comparison #', num2str(c), ' score = ', num2str(MI.scores{birdi}(c))]);
            c = c+1;
            toc
        end
    end
end
cd(orig_path)
%%
save MI MI