function [data, fs, dateandtime, label, props] = egl_TDMS_sound(filename, loaddata)
% egl_TDMS_sound - Nader Nikbakht May 2021, MIT

x =  convertTDMS(0,filename);
disp(filename);
if loaddata == 0
    x.data = [];
end

data         = x.Data.MeasuredData(10).Data; %audio
fs           = 1/(x.Data.MeasuredData(10).Property(3).Value); %audio fs
dateandtime  = datenum(x.Data.MeasuredData(10).Property(1).Value,'dd-mmm-yyyy HH:MM:SS:FFF');
label        = strrep(filename,'_',' ');
props.Names  = {};
props.Values = {};
props.Types  = [];