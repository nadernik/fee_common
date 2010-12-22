function bNoised = find_noised_syllables(exper, file, syllStartTimes, syllEndTimes, varargin)
% syllStartTies and syllEndTimes are times relative to start of file

P.ChanAudio = 0; %used to display audio for debugging only
P.ChanNoise = 2; %channel that has noise signal
P.ThresNoise = 0.1; %threshold for rms noise signal
P.bDebug = 0;
P = parseargs(P,varargin{:});
totalSyll = length(syllStartTimes);
bNoised = false(totalSyll,1);
[data, time, HWChannels, startSamp, timeCreated, startTime, names, values, info] = loadData(exper,file,P.ChanNoise);
for syll = 1:length(syllStartTimes)
    sig = data(syllStartTimes(syll):syllEndTimes(syll));
    rootmeansq = sqrt(mean(sig.^2));
    if rootmeansq > P.ThresNoise
        bNoised(syll) = true;
    end
end

if P.bDebug
    figure(3214)
    % spectrogram
    ah(1) = subplot(2,1,1);
    [audio, time, HWChannels, startSamp, timeCreated, startTime, names, values, info] = loadData(exper,file,P.ChanAudio);
    displaySpecgramQuick(audio,info.fs)
    % each syllable is a line segment, blue if normal, red if noised
    ah(2) = subplot(2,1,2);
    hold on
    for syll = 1:totalSyll
        if bNoised(syll)
            c = 'r'; %red segments for noised syllables
        else
            c = 'b'; %blue segments for normal syllables
        end
        plot([syllStartTimes(syll) syllEndTimes(syll)],[0 0],c)
    end
    linkaxes(ah, 'x')
end