function [data, fs, dateandtime, label, props] = egl_CaRead_elm(filename, loaddata)

if loaddata == 1
    variableInfo = who('-file', filename);
    if ismember('info', variableInfo) 
        load(filename, 'info')
        data = info.SOUND; 
        fs = info.SOUNDfs; 
    else 
        load(filename, 'SOUND', 'SOUNDfs'); 
        data = SOUND;
        fs = SOUNDfs;
    end
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