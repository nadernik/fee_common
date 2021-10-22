function [data, fs, dateandtime, label, props] = egl_TDMS_temp(filename, loaddata)
% egl_TDMS_sound - Nader Nikbakht May 2021, MIT

x =  convertTDMS(0,filename);
disp(filename);
if loaddata == 0
    x.data = [];
end

data(:,1) = x.Data.MeasuredData(4).Data; % RA peltier temp
data(:,2) = x.Data.MeasuredData(5).Data; % RA peltier set point
data(:,3) = x.Data.MeasuredData(6).Data; % RA peltier current
data(:,4) = x.Data.MeasuredData(7).Data; % HVC resistor/peltier temp
data(:,5) = x.Data.MeasuredData(8).Data; % HVC resistor/peltier setpoint
data(:,6) = x.Data.MeasuredData(9).Data; % HVC resistor/peltier current
fs           = 1/(x.Data.MeasuredData(4).Property(3).Value); %audio fs
dateandtime  = datenum(x.Data.MeasuredData(4).Property(1).Value,'dd-mmm-yyyy HH:MM:SS:FFF');
label        = strrep(filename,'_',' ');
props.Names = {};
props.Values = {};
props.Types = [];