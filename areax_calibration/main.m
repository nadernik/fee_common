%% calib01
figure
calibration_plot('c:\stetner\data\calib01\20100903 ephys','use_file',1:11)
figure
stim_traces_over_time('c:\stetner\data\calib01\20100903 ephys','use_file',{1:2:11})


%% calib03
figure
calibration_plot('c:\stetner\data\calib03','use_file',3:8)
figure
stim_traces_over_time('c:\stetner\data\calib03','use_file',{3:8},'window',[-5 20])
%% calib05
% Location 1
calibration_plot('c:\stetner\data\calib05','use_file',[6:23]) % also 3?
title('5.75A 1.40L 2.85V')
% Location 2
calibration_plot('c:\stetner\data\calib05','use_file',[4 24])
title('5.75A 1.20L 2.85V')
% Location 3
calibration_plot('c:\stetner\data\calib05','use_file',[5 25])
title('5.75A 1.10L 2.60V')

stim_traces_over_time('c:\stetner\data\calib05','use_file',{6:3:23, [4 24], [5 25]})

%% calib10

% Location 1
calibration_plot('C:\stetner\data\calib10\20101103 surgeryrig','use_file',[6:13],'chan',2,'threshold_frac',0.8)

% Location 2
calibration_plot('C:\stetner\data\calib10\20101103 surgeryrig','use_file',[5 14:21],'chan',2,'threshold_frac',0.8)

% Location 3
calibration_plot('C:\stetner\data\calib10\20101103 surgeryrig','use_file',[4 22],'chan',2,'threshold_frac',0.8)

stim_traces_over_time('C:\stetner\data\calib10\20101103 surgeryrig','use_file',{6:13, [5 14:3:21], [4 22]},'chan',2,'threshold_frac',0.8)