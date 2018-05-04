try
    [SONG1,fs] = wavread('SongOne');
    [SONG2,fs] = wavread('SongTwo');
    [INTRO,fs] = wavread('Intro1');
    SONG1 = SONG1*mean(SONG2.^2)/mean(SONG1.^2);
    NOintro = zeros(size(INTRO));
    
    PlayData1 = ...
        [[INTRO; SONG1] [SONG1; NOintro]];
    dur1 = length(PlayData1)/fs;
    PlayData2 = ...
        [[SONG2; NOintro] [INTRO; SONG2]];
    dur2 = length(PlayData2)/fs;
    ao = analogoutput('winsound');
    addchannel(ao,[1 2]);
    set(ao, 'samplerate', fs);
    timeplayed = datestr(now);
    for j = 1:4
        for i = 1:10  
            putdata(ao,PlayData1);
            start(ao); pause(dur1);
            pause(3+rand*2);
            stop(ao);
        end
        pause(3*60);% oops. changed from 3*30 on 9/28
        for i = 1:10
            putdata(ao,PlayData2);
            start(ao); pause(dur2);
            pause(3+rand(2));
            stop(ao);
        end
        pause(3*60)
    end
    message = ['playdata_played', timeplayed];
    stringname = timeplayed; stringname(ismember(stringname,' ,.:;!')) = [];
    save(['playtime', stringname], 'message')
    try
        emailme(message)
    catch
    end
catch
    exception = lasterror;
    stringname = datestr(now);stringname(ismember(stringname,' ,.:;!')) = [];
    save(['ERROR','playtime', stringname], 'exception')
    try 
        emailme(['ERROR','playtime', stringname, exception.message])
    catch 
    end
end