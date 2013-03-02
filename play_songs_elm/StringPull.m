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

% get value of the dio
pushed = getvalue(dio);

putdata(ao, WhichBox{1})
start(ao)
trigger(ao)
wait(ao,5)
stop(ao)
                