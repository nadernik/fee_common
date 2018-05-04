%%
close all; clear all; clc

try
for i = 1:20
    % load songs to play
    [slowed,fs] = wavread('Z:\VocodedSongs\slowed.wav');
    [sped,fs1] = wavread('Z:\VocodedSongs\sped.wav');

    % check they all have the same sampling rates
    fs 
    fs1
    if fs~=fs1
        disp('WARNING: songs have different sampling rates')
    end

    % make a cell array of what songs to to each box, making each song the same
    % length
    song{1,2} = slowed; % cooler 1 song
    song{1,1} = zeros(numel(slowed),1); % cooler 1 silence
    song{2,2} = [sped; zeros(numel(slowed)-numel(sped),1)]; % cooler 2 song
    song{2,1} = zeros(numel(slowed),1); % cooler 2 silence

    % initialize dio and ao
    dio = digitalio('nidaq','Dev1');
    addline(dio,0,'in');
    addline(dio,1,'in');
    pulled = getvalue(dio); 
    ao = analogoutput('nidaq', 'Dev1');
    addchannel(ao, 0);
    set(ao, 'SampleRate', fs)
    set(ao, 'TriggerType', 'Manual');
    addchannel(ao, 1);
    set(ao, 'SampleRate', fs)
    set(ao, 'TriggerType', 'Manual');

    % initialize times of string pulls, and string pull counts
    PullTimes{1} = [];
    PullTimes{2} = [];
    Nplays = [40 40];

    % while it's today
    date = datestr(now);
    today = date;
    % is there a way of doing this with timers or interrupts??
    while issame(today(1:2),date(1:2))
        date = datestr(now);
        % get value of the dio
        pulled = getvalue(dio);
        % check if each is pressed, and
        if sum(pulled) ~= 0
            % keep track of pull times
            if pulled(1)
                PullTimes{1} = [PullTimes{1} now];
            end
            if pulled(2)
                PullTimes{2} = [PullTimes{2} now];
            end
            % check number of previous plays, decrement current play
            if Nplays(1) == 0
                pulled(1) = 0;
            elseif pulled(1)
                Nplays(1) = Nplays(1) - 1
            end
            if Nplays(2) == 0
                pulled(2) = 0; 
            elseif pulled(2)
                Nplays(2) = Nplays(2) - 1
            end
            play = [song{1,pulled(1)+1}, song{2,pulled(2)+1}];
            % play data based on this, if it hasn't reached the maximum
            putdata(ao, play)
            start(ao)
            trigger(ao)
            wait(ao,5)
            stop(ao)
        end
        save(['Z:\PullTimes\PullTimes', num2str(round(now*1000)), '.mat'])

    end
        emailme(['today strings were pulled ', [num2str(40-Nplays(1))], ' and ', [num2str(40-Nplays(2))], ' times'])
end
catch 
    A = lasterror;
    save(['Z:\PullTimes\PullTimes', num2str(round(now*1000)), '.mat'])
    emailme(['Code errored out ' A.message])
    %StringPull
end
                