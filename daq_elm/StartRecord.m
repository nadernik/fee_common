function t = StartRecord;
SampleRate = 40000;

filename = input('filename? (no spaces!)', 's');
durationInSec = input('Duration of each file?');
Nfiles = input('How many files total? (Note: change later with set(t,''TasksToExecute'',____)');
if isempty(filename)
    filename = '';
end
if isempty(durationInSec)
    durationInSec = 10;
end
if isempty(Nfiles)
    Nfiles = 1;
end
clear ai t
t = timer;
date = datestr(round(now));
mkdir('tests', date);
ai = analoginput('nidaq','Dev1');
addchannel(ai,0:1);
ai.Channel.InputRange = [-10 10];

set(ai,'SampleRate',SampleRate);
set(ai,'SamplesPerTrigger',durationInSec*SampleRate);

t.Period = durationInSec;
t.TasksToExecute = Nfiles;
t.ExecutionMode = 'FixedDelay';
t.TimerFcn = {@RecordVoltage, filename, durationInSec, SampleRate, ai};

start(t);
for i = 1:5
    if isequal(t.Running, 'on')
        N = 0;
        N = input('To add N more files, type N-Return');
        Nfiles = Nfiles + N;
        t.TasksToExecute = Nfiles;
    end
end
        
