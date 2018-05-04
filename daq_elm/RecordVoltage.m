function RecordVoltage(obj, event, filename, durationInSec, SampleRate, ai)
close all
start(ai)
wait(ai, durationInSec+1)
[data,time] = getdata(ai);
stop(ai)
save(['tests/', date,'/timeis', num2str(round(now*1000)), filename, '.mat'],'data', 'time', 'SampleRate');
disp(['just saved ', datestr(now), filename])
figure; 
subplot(2,1,1)
plot(time,data(:,1)/10)
xlabel('time(s)'); ylabel('V_m (V)')
subplot(2,1,2)
plot(time,data(:,2)*10/.01/1000)
xlabel('time(s)'); ylabel('I_m (nA)')