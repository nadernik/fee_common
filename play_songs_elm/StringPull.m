
% load songs to play
[simple,fs] = wavread('CallIntroFast.wav');

% check they all have the same sampling rates

% make a cell array of what songs to to each box, making each song the same
% length
WhichBox = {[simple zeros(numel(simple),1)] [zeros(numel(simple),1) simple] [simple simple]};
song{1,2} = []; % cooler 1 song
song{1,1} = []; % cooler 1 silence
song{2,2} = []; % cooler 2 song
song{2,1} = []; % cooler 2 silence

% initialize dio and ao
dio = digitalio('nidaq','Dev1');
addline(dio,0,'in');
addline(dio,1,'in');
pushed = getvalue(dio);
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
            Nplays(1) = Nplays(1) - 1;
        end
        if Nplays(2) == 0
            pulled(2) = 0; 
        elseif pulled(2)
            Nplays(2) = Nplays(2) - 1;
        end
        play = [song{1,pulled(1)+1}, song{2,pulled(2)+1}];
        % play data based on this, if it hasn't reached the maximum
        putdata(ao, play)
        start(ao)
        trigger(ao)
        wait(ao,5)
        stop(ao)
    end
    % keep track of when the button was pressed for each cooler
end
                