function [data, fs, dateandtime, label, props] = egl_CaRead_elm(filename, loaddata)
% ElectroGui file loader
% Reads wavefiles
% Extracts date and time information from the file info
if loaddata == 1
    load(filename, 'SOUND', 'SOUNDfs'); 
    data = SOUND;
    mt = dir(filename);
    dateandtime = datenum(mt(1).date);
    label = 'Sound level';
    fs = SOUNDfs; 
else
    data = [];
    fs = [];
    dateandtime = [];
    label = [];
end

props.Names = {};
props.Values = {};
props.Types = [];