function [data fs dateandtime label props] = egl_WaveRead(filename, loaddata)
% ElectroGui file loader
% Reads wavefiles
% Extracts date and time information from the file info

if loaddata == 1
    [data fs] = wavread(filename);
    mt = dir(filename);
    dateandtime = datenum(mt(1).date);
    label = 'Sound level';
else
    data = [];
    fs = [];
    dateandtime = [];
    label = [];
end

props.Names = {};
props.Values = {};
props.Types = [];