function [data fs dateandtime label props] = egl_WaveRead(filename, loaddata)
% ElectroGui file loader
% Reads wavefiles
% Extracts date and time information from the file info

% currentFolder = pwd; 
% [pathstr,name,ext] = fileparts(filename) 
if loaddata == 1
    %cd pathstr
    [data fs] = wavread(filename);
    data = mean(data,2);
    mt = dir(filename);
    dateandtime = datenum(mt(1).date);
    label = 'Sound level';
    %cd currentFolder
else
    data = [];
    fs = [];
    dateandtime = [];
    label = [];
end

props.Names = {};
props.Values = {};
props.Types = [];