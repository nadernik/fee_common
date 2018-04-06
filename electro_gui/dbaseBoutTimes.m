function BoutTimes = dbaseBoutTimes(dbase, filenums, MaxInterval, ...
    MinBoutDuration)
%DBASEBOUTTIMES Bout start and end samples from dbase
%
% Bouts are periods of singing where all itervals between syllables are
% shorter than MaxInterval. Only selected syllables are used.
%
% Syntax: BoutTimes = dbaseBoutTimes(dbase, filenums, MaxInterval, ...
%                                    MinBoutDration)
%
% Output:
%     BoutTimes is a cell array containing the sample numbers where bouts
%               begin and end. BoutTimes{filenum}(boutnum, 1) is the onset 
%               of the bout number 'boutnum' in file number 'filenum'.
%               Times are given as number of samples from the start of the
%               file.
% Inputs:
%     dbase           is a dbase struct, saved from electro_gui
%     filenums        is a list of file numbers from which bout times are
%                     calculated. If omitted, bout times are calculated for
%                     all files.
%     MaxInterval     is the maximum interval between syllables in a bout, 
%                     in seconds. If omitted, MaxInterval is set to 2 
%                     seconds.
%     MinBoutDuration is the minimum duration for a bout, in seconds. If
%                     omitted, MinBoutDuration is set to 0.2 seconds.
% 

% This code was modified from egm_Bout_aligned_MUA_TO.

% If no file numbers provided, do all the files
if nargin < 2
    filenums = 1:length(dbase.SoundFiles);
end

% If no MaxInterval, set it to a default of 2 seconds
if nargin < 3
    MaxInterval = 2;
end

% If no MinBoutDuration, set it to a default of 0.2 seconds
if nargin < 4
    MinBoutDuration = 0.2;
end

BoutTimes = cell(max(filenums), 1);

% For each file, detect bouts
for n = 1:length(filenums)
    c = filenums(n);
    
    f = find(dbase.SegmentIsSelected{c} == 1);
    % segment numbers that are selected
    
    % Skip this file if it contains no syllables
    if isempty(f)
        BoutTimes{c} = [];
        continue
    end
    
    % First bout onset is at the onset of the first syllable
    TempBoutTimes = [dbase.SegmentTimes{c}(f(1),1),0];
    
    % For each syllable, end the bout on this syllable if the gap between
    % this syllable and the next is greater than MaxInterval. When a bout
    % is ended, begin a new bout at the onset of the next syllable. 
    for jj = 1:length(f)-1
        thisSyllOffset = dbase.SegmentTimes{c}(f(jj    ), 2);
        nextSyllOnset  = dbase.SegmentTimes{c}(f(jj + 1), 1);
        Interval = (nextSyllOnset - thisSyllOffset) / dbase.Fs; % seconds
        if Interval > MaxInterval
            TempBoutTimes(end    , 2) = thisSyllOffset; % bout offset
            TempBoutTimes(end + 1, 1) = nextSyllOnset;  % bout onset
        end
    end

    % Last bout offset is at the end of the last syllable
    TempBoutTimes(end,2) = dbase.SegmentTimes{c}(f(end),2);
    
    % Remove bouts that are shorter than MinBoutDuration
    BoutDuration = (TempBoutTimes(:, 2) - TempBoutTimes(:, 1)) / dbase.Fs;
    isLongEnough = BoutDuration > MinBoutDuration;
    BoutTimes{c} = TempBoutTimes(isLongEnough,:);
end

end
