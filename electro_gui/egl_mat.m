function [data, fs, dateandtime, label, props] = egl_mat(filename, loaddata)
% egl_mat - Nader Nikbakht Feb 2023, MIT

x =  load(filename);
disp(filename);
if loaddata == 0
    x.data = [];
end
data         = x.data; %audio
fs           = x.fs; %audio fs
dateandtime  = x.dateandtime;
label        = strrep(filename,'_',' ');
props.Names  = {};
props.Values = {};
props.Types  = [];