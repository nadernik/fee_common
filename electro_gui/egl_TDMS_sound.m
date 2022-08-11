function [data, fs, dateandtime, label, props] = egl_TDMS_sound(filename, loaddata)
% egl_TDMS_sound - Nader Nikbakht May 2021, MIT

x =  convertTDMS(0,filename);
disp(filename);
if loaddata == 0
    x.data = [];
end
[~,maxidx] = max([x.Data.MeasuredData.Total_Samples]); %find which channel has the highier fs
maxidx = max(maxidx);
data         = x.Data.MeasuredData(maxidx).Data; %audio
fs           = 1/(x.Data.MeasuredData(maxidx).Property(3).Value); %audio fs
dateandtime  = datenum(x.Data.MeasuredData(maxidx).Property(1).Value,'dd-mmm-yyyy HH:MM:SS:FFF');
label        = strrep(filename,'_',' ');
props.Names  = {};
props.Values = {};
props.Types  = [];