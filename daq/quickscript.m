%script quick data test
daqreset;
sampRate = 40000;
chan = [1,2];
[ai, ao, actInSampleRate, actOutSampleRate, actUpdateFreq] = daq_Init(chan, sampRate, [], sampRate, 20, 1);
daq_Start;
pause(3);
daq_recordStart(daq_getCurrSampNum, 'aa130_multiunit_RA_20060503_postop_', chan);
disp('press a key when finished recording');
pause;
daq_recordStop(daq_getCurrSampNum, chan);
%file won't be completed if you quit too quickly.
pause(2);
daq_Quit;
% [t, data] = daq_readDatafile(['test7chan',num2str(chan),'.dat']);
% figure; 
% subplot(2,1,1);
% data = data - mean(data);
% %plot([0:length(data)-1]/(length(data)/sampRate), log(abs(fft(data)).^2));
% periodogram(data, hanning(length(data)), length(data), sampRate);
% subplot(2,1,2);
% plot(data);
% 
% fclose('all');
% delete 'test7chan2.dat'