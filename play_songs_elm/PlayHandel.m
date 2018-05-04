try
    file='simple.wav';
    [y,Fs] = wavread(file);
    ao = analogoutput('winsound');
    addchannel(ao,[1 2]);
    data = [y y];
    set(ao, 'samplerate', Fs);
    putdata(ao,data);
    start(ao);
    timeplayed = datestr(now);
    message = [file, 'Played', timeplayed];
    stringname = timeplayed; stringname(ismember(stringname,' ,.:;!')) = [];
    save(['playtime', stringname], 'message')
catch
    exception = lasterror;
    stringname = datestr(now);stringname(ismember(stringname,' ,.:;!')) = [];
    save(['ERROR','playtime', stringname], 'exception')
end