function acqgui_overnightBatch(expers)
% expers is a cell array of exper structures

for ii = 1:length(expers)
    birdname = expers{ii}.birdname;
    expername = expers{ii}.expername;
    switch birdname
        case '2365'
            if mod(floor(now), 5) == 1 % only do analysis every 5 days
                Bout_detect_TO(expers{ii}.dir, expers{ii}.audioCh, [])
                combine_boutfiles([expers{ii}.dir filesep 'bouts\analysis_bout.mat'])
                fprintf(1, 'Detected bouts in exper %s for bird %s\n', expername, birdname)
            else
                fprintf(1, 'Skipping exper %s for bird %s because today is an off day\n', expername, birdname)
            end
        case '2423'
            Bout_detect_TO(expers{ii}.dir, expers{ii}.audioCh, [])
            combine_boutfiles([expers{ii}.dir filesep 'bouts\analysis_bout.mat'])
            fprintf(1, 'Detected bouts in exper %s for bird %s\n', expername, birdname)
        case '2428'
            Bout_detect_TO(expers{ii}.dir, expers{ii}.audioCh, [])
            combine_boutfiles([expers{ii}.dir filesep 'bouts\analysis_bout.mat'])
            fprintf(1, 'Detected bouts in exper %s for bird %s\n', expername, birdname)
        otherwise
            fprintf(1, 'Skipping exper %s for bird %s\n', expername, birdname)
    end
end