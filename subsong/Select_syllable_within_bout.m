function dbase = Select_syllable_within_bout(dbase,MaxInterval,MinBoutDuration,fileNum)
% select syllables within bouts
% Tatsuo Okubo
% 2011/02/20

%% detect bout onset & offset
dbase.BoutTimes = {}; % reset
syll_dur = zeros(0,2);

if nargin==4 % fileNum specified
    C = fileNum;
else
    C = 1:length(dbase.FileLength);
end

for c = C % array of files to be analyzed  
    f = find(dbase.SegmentIsSelected{c} == 1); % indeces of segments that are selected
    
    if isempty(f) % no selected segments
        BoutTimes{c} = [];
        BoutTimes_abs{c} = [];
        continue
    else
        TempBoutTimes = [dbase.SegmentTimes{c}(f(1),1),0]; % bout onset

        for n = 1:length(f)-1
            Interval = (dbase.SegmentTimes{c}(f(n+1),1)-dbase.SegmentTimes{c}(f(n),2))/dbase.Fs; % Inter-syllable interval (ms)
            if Interval > MaxInterval
                TempBoutTimes(end,2) = dbase.SegmentTimes{c}(f(n),2); % bout offset
                TempBoutTimes(end+1,1) = dbase.SegmentTimes{c}(f(n+1),1); % bout onset   
            end
        end
        TempBoutTimes(end,2) = dbase.SegmentTimes{c}(f(end),2);
    end
    BoutDuration = (TempBoutTimes(:,2)-TempBoutTimes(:,1))/dbase.Fs; % 
    BoutDurationNdx = find(BoutDuration>MinBoutDuration); % index of bouts that are longer than MinBoutDuration
    BoutTimes{c} = TempBoutTimes(BoutDurationNdx,:);
    BoutTimes_abs{c} = repmat(dbase.Times(c),size(BoutTimes{c}))+BoutTimes{c}/dbase.Fs/24/60/60;
    BoutDurationFile{c} = BoutDuration;
        
    %% deselect syllables outside bout
    for k = 1:size(dbase.SegmentTimes{c},1)
        SyllableOnset = dbase.SegmentTimes{c}(k,1);
        SyllableOffset = dbase.SegmentTimes{c}(k,2);
        if sum(SyllableOnset>=BoutTimes{c}(:,1) & SyllableOffset <= BoutTimes{c}(:,2))==0 % segment is not within bout
            dbase.SegmentIsSelected{c}(k) = 0;
        end
    end    
end

dbase.BoutTimes = BoutTimes; % add field
dbase.BoutTimes_abs = BoutTimes_abs;