function [data, fs, dateandtime, label, Props] = egl_Open_Ephys(filename, loadData)

label = 'Voltage (mV)';
[data, timestamps, info] = load_open_ephys_data_faster(filename);
data = data.*info.header.bitVolts;
if loadData ~= 1
    data = [];
end
fs = info.header.sampleRate;
dateandtime = datenum(info.header.date_created, 'dd-mmm-yyyy HHMMSS');
Props.Names = {'Comment'};%made up properties because I don't understand what they should be
Props.Types = 1;
Props.Values = {''};