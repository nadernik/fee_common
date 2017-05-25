function analysis2compiled(dbasepath, savepath, moat)
% maybe add automatic analysis file creation
load(fullfile(dbasepath, 'analysis.mat')); 

Y = [];
CompSoundSONG = [];
segs = []; 
FnumBnum = []; 
Labels = {};
almostnothing = []; 
save(fullfile(savepath, ...
   ['justtestingitllevenletmewriteanything']), ...
   'almostnothing'); 
save(fullfile(savepath, 'compiled'), 'Y', 'CompSoundSONG', ...
   '-v7.3')
for filei = 1:length(dbase.SegmentTimes)
    segtimes = dbase.SegmentTimes{filei}(dbase.SegmentIsSelected{filei}==1,:); 
    seglabels = dbase.SegmentTitles{filei}(dbase.SegmentIsSelected{filei}==1);
    load(fullfile(dbasepath, dbase.SoundFiles(filei).name), 'VIDEO', 'VIDEOfs', ...
        'SOUND', 'SOUNDfs', 'nFrames', ...
        'tSound','AudBinWhenFrameEnds', 'AudBinWhenFrameStarts');%,'VIDEO'); 
    
    
    % SONG
    if sum(dbase.SegmentIsSelected{filei}==1)>0
        bouts = SegsToBouts(segtimes, moat*SOUNDfs, length(SOUND)); 
        for bi = 1:size(bouts,1)
            useframes = round(bouts(bi,1)/SOUNDfs*VIDEOfs):...
                round(bouts(bi,2)/SOUNDfs*VIDEOfs); % which movie frames we're using
            useframes(useframes<=0) = []; useframes(useframes>nFrames) = []; 
            usebins = (1:floor(length(useframes)*SOUNDfs/VIDEOfs))+AudBinWhenFrameStarts(useframes(1)); usebins(usebins>length(SOUND)) = []; % which audio bins we're using... 40000/30 has slight rounding error..
            if length(useframes)>0
                Y1 = permute(VIDEO(useframes,:,:),[2 3 1]); 
                Y = cat(3,Y,Y1); 
                segind = (segtimes(:,1)>=usebins(1))&(segtimes(:,2)<=usebins(end));
                segs = [segs; ...
                    (segtimes(segind,:) ...
                    -usebins(1) + length(CompSoundSONG))];
                Labels = [Labels seglabels(segind)];
                CompSoundSONG = [CompSoundSONG; SOUND(usebins)];
%                 CompSpecSONG = cat(1,CompSpecSONG,SPEC(useframes,:,:));
                FnumBnum = [FnumBnum; repmat([filei bi],length(useframes),1)];
                display(['SONG file ' num2str(filei) ' bout ' num2str(bi) ' VIDEOfs=' num2str(VIDEOfs)])
                if length(Labels)~= size(segs,1)
                    display('eek') 
                    length(Labels)
                    size(segs,1)
                end
            end
        end
    end
%     save(fullfile(dbasepath, 'compiled'), 'Y', 'CompSoundSONG', ...
%         'FnumBnum', 'segs', 'Labels', 'VIDEOfs','SOUNDfs',...
%        '-v7.3');
   save(fullfile(savepath, ...
       ['WorkingOnFILE' num2str(filei) 'of' num2str(length(dbase.SegmentTimes)) ...
       'bout' num2str(bi) 'stamp.mat']), ...
       'almostnothing'); 
   clear Y1
   pack
end
save(fullfile(savepath, 'compiled'), 'Y', 'CompSoundSONG', ...
    'FnumBnum', 'segs', 'Labels', 'VIDEOfs','SOUNDfs', 'dbase', ...
    '-v7.3');
save(fullfile(savepath, ...
    ['phewwwDONEsavingMostly']), ...
    'almostnothing'); 
% tic; [SongSpec,SpecTime,SpecF] = spectrogramELM(CompSoundSONG,SOUNDfs,.005, 0); toc
% SongSpec = 10*log10(SongSpec+eps); 
% save(fullfile(dbasepath, 'compiled.mat'), 'SongSpec', 'SpecTime', 'SpecF', ...
%     '-append');
% save(fullfile(dbasepath, ...
%     ['DONEDONEDONE']), ...
%     'almostnothing'); 

