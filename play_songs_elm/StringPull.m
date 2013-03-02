
% load songs to play
[simple,fs] = wavread('CallIntroFast.wav');

% check they all have the same sampling rates

% make a cell array of what songs to to each box
WhichBox = {[simple zeros(numel(simple),1)] [zeros(numel(simple),1) simple] [simple simple]};

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

% while it's today

% get value of the dio
pushed = getvalue(dio);

% check if each is pressed, and

% play data based on this, if it hasn't reached the maximum
putdata(ao, WhichBox{1})
start(ao)
trigger(ao)
wait(ao,5)
stop(ao)

% keep track of when the button was pressed for each cooler
                