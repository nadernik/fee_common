function combine_boutfiles(filename)

%%% originally by Lena Veit
%%% Tatsuo Okubo
%%% 2010/09/16

load(filename); % load dbase
pathName = [dbase.PathName filesep];

[dbase.Times ord] = sort(dbase.Times);
dbase.FileLength = dbase.FileLength(ord);
dbase.SoundFiles = dbase.SoundFiles(ord);
for c = 1:length(dbase.ChannelFiles) % for all the channels
    if ~isempty(dbase.ChannelFiles{c})
        dbase.ChannelFiles{c} = dbase.ChannelFiles{c}(ord);
    end
end
dbase.SegmentThresholds = dbase.SegmentThresholds(ord);
dbase.SegmentTimes = dbase.SegmentTimes(ord);
dbase.SegmentTitles = dbase.SegmentTitles(ord);
dbase.SegmentIsSelected = dbase.SegmentIsSelected(ord);

% events don't get reordered because they are all the same

ctr = 1;
while ctr == 1
    ctr = 0;
    for i = 1:length(dbase.Times) % for all the files
        for j = i+1:length(dbase.Times) % for all the files after that file         
            if ctr == 0
                if dbase.Times(j) < dbase.Times(i)+dbase.FileLength(i)/dbase.Fs/60/60/24; % if the next file begins after the current one ends
                    [i j length(dbase.Times)]
                    ctr = 1;
                    load([pathName dbase.SoundFiles(j).name])

                    rec2 = rec;
                    load([pathName dbase.SoundFiles(i).name])
                    rec1 = rec;

                    diffi = round((rec2.Time - rec1.Time)*rec.Fs*60*60*24);
                    rec.Data = [rec1.Data(1:diffi); rec2.Data]; % combine two bouts

                    save([pathName dbase.SoundFiles(i).name],'rec'); % save the new rec
                    delete([pathName dbase.SoundFiles(j).name]); % delete the second bout
                    
                    %%% TO
                    if length(dbase.ChannelFiles)>0
                        Temp = cellfun(@isempty,dbase.ChannelFiles);
                        dchan = find(~Temp); % index of channels that are not empty
                        for b = 1:length(dchan) % for all the channels
                            c = dchan(b);
                            load([pathName dbase.ChannelFiles{c}(j).name])
                            ch2 = ch;
                            load([pathName dbase.ChannelFiles{c}(i).name])
                            ch1 = ch;
                            ch.Data = [ch1.Data(1:diffi); ch2.Data];
                            save([pathName dbase.ChannelFiles{c}(i).name],'ch');
                            delete([pathName dbase.ChannelFiles{c}(j).name]);
                        end
                    end                    
                    %% end of TO

                    dbase.FileLength(i) = length(rec.Data); % new length
                    dbase.SegmentTimes{j} = dbase.SegmentTimes{j}+diffi;
                    dbase.SegmentTimes{i} = [dbase.SegmentTimes{i}; dbase.SegmentTimes{j}];
                    dbase.SegmentTitles{i}(end+1:end+length(dbase.SegmentTitles{j})) = dbase.SegmentTitles{j};
                    dbase.SegmentIsSelected{i}(end+1:end+length(dbase.SegmentIsSelected{j})) = dbase.SegmentIsSelected{j};

                    [dbase.SegmentTimes{i} ord] = sortrows(dbase.SegmentTimes{i});
                    ord = ord';
                    dbase.SegmentTitles{i} = dbase.SegmentTitles{i}(ord);
                    dbase.SegmentIsSelected{i} = dbase.SegmentIsSelected{i}(ord);

                    ctrs = 1;
                    while ctrs == 1
                        ctrs = 0;
                        for v = 1:size(dbase.SegmentTimes{i},1)
                            for w = v+1:size(dbase.SegmentTimes{i},1)
                                if ctrs == 0
                                    if dbase.SegmentTimes{i}(w,1) < dbase.SegmentTimes{i}(v,2)
                                        ctrs = 1;
                                        dbase.SegmentTimes{i}(v,2) = dbase.SegmentTimes{i}(w,2);
                                        dbase.SegmentIsSelected{i}(v) = sign(dbase.SegmentIsSelected{i}(v)+dbase.SegmentIsSelected{i}(w));
                                        dbase.SegmentTimes{i}(w,:) = [];
                                        dbase.SegmentIsSelected{i}(w) = [];
                                        dbase.SegmentTitles{i}(w) = [];
                                    end
                                end
                            end
                        end
                    end

                    % delete the next file
                    dbase.Times(j) = [];
                    dbase.FileLength(j) = [];
                    dbase.SoundFiles(j) = [];
%                     for b = 1:length(dchan)
%                         c = dchan(b);
%                         if ~isempty(dbase.ChannelFiles{c})
%                             dbase.ChannelFiles{c}(j) = [];
%                         end
%                     end
                    dbase.SegmentThresholds(j) = [];
                    dbase.SegmentTimes(j) = [];
                    dbase.SegmentTitles(j) = [];
                    dbase.SegmentIsSelected(j) = [];

                    dbase.EventThresholds(:,j) = [];
                    if ~isempty(dbase.EventTimes)
                        for b = 1:length(dchan)
                            c = dchan(b);
                            dbase.EventTimes{c}(j) = [];
                            dbase.EventIsSelected{c}(j) = [];
                        end
                    end
                end
            end
        end
    end
end

if strfind(filename, pathName)
    save(filename, 'dbase')
else
    save([pathName filename],'dbase')
end
display('combine_boutfiles done')