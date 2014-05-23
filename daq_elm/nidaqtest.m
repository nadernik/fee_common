dio = digitalio('nidaq','Dev1');
%%
addline(dio,0,'in');
addline(dio,1,'in');
pushed = getvalue(dio)

%%
N = 40; 
nplays0 = 0;
playtimes0 = [];
nplays1 = 0;
playtimes1 = [];

ao = analogoutput('nidaq', 'Dev1');
addchannel(ao, 0);
set(ao, 'SampleRate', fs)
set(ao, 'TriggerType', 'Manual');
addchannel(ao, 1);
set(ao, 'SampleRate', fs)
set(ao, 'TriggerType', 'Manual');
%% Acquiring Temperature
clear all
%see peekdata

ai = analoginput('nidaq','Dev1');
addchannel(ai,0:1);
ai.Channel.InputRange = [-10 10];
SampleRate = 1000;
set(ai,'SampleRate',SampleRate)
durationInSec = 10;
set(ai,'SamplesPerTrigger',durationInSec*SampleRate)
start(ai)
wait(ai, durationInSec+1)
[data,time] = getdata(ai);
stop(ai)
figure; plot(time,data*10)
xlabel('time(s)'); ylabel('temperature (C)')
legend('bath', 'stage')
clear ai

%% Analog Output

ao = analogoutput('nidaq', 'Dev1');
addchannel(ao, 0:1);
ao.Channel.OutputRange = [-10 10];
ao.Channel.UnitsRange = [-10 10];
SampleRate = 10000;
Duration = 5;
set(ao, 'SampleRate', SampleRate)
data1 = 2*sin(300*linspace(0,Duration,SampleRate*Duration));
data2 = 2*sin(100*linspace(0,Duration,SampleRate*Duration));
%plot(data1); hold on; plot(data2)
putdata(ao, [data1' data2'])
start(ao)
wait(ao, Duration+1)
stop(ao)
clear ao

%% Output and input
close all; clear all;

%ao setup
ao = analogoutput('nidaq', 'Dev1');
addchannel(ao, 0);
ao.Channel.OutputRange = [-10 10];
ao.Channel.UnitsRange = [-10 10];
SampleRate = 10000;
Duration = 5;
set(ao, 'SampleRate', SampleRate)
data1 = 2*mod(round(linspace(0,Duration,SampleRate*Duration)*1),2);
plot(data1); shg
putdata(ao, data1')

%ai setup
ai = analoginput('nidaq','Dev1');
addchannel(ai,0);
ai.Channel.InputRange = [-10 10];
set(ai,'SampleRate',SampleRate)
set(ai,'SamplesPerTrigger',Duration*SampleRate)

start([ai,ao])
wait(ao, Duration+1)
wait(ai, Duration+1)
stop(ao)
[data,time] = getdata(ai);
stop(ai)
figure; plot(time,data)
xlabel('time(s)');
clear ao
clear ai


%% acquiring Im and 10Vm

%clear all
%see peekdata
date = datestr(round(now));
mkdir('tests', date)
comment = 'IStepsInBath';

ai = analoginput('nidaq','Dev1');
addchannel(ai,0:1);
ai.Channel.InputRange = [-10 10];
%out = daqhwinfo(ai);
%out.InputRanges        
SampleRate = 40000;
set(ai,'SampleRate',SampleRate)
durationInSec = 10;
set(ai,'SamplesPerTrigger',durationInSec*SampleRate)

start(ai)
wait(ai, durationInSec+1)
[data,time] = getdata(ai);
stop(ai)
save(['tests/', date,'/timeis', num2str(round(now*1000)), comment, '.mat'],'data', 'time', 'SampleRate');
disp(['just saved ', datestr(now), comment])
figure; 
subplot(2,1,1)
plot(time,data(:,1)/10)
xlabel('time(s)'); ylabel('V_m (V)')
subplot(2,1,2)
plot(time,data(:,2)*10/.01/1000)
xlabel('time(s)'); ylabel('I_m (nA)')


clear ai
