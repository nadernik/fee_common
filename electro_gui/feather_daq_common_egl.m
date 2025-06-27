function [fs, dateandtime, label, Props] = feather_daq_common_egl(filename)
label = 'Voltage (V)';
dateandtime = feather_daq_dt_from_filename(filename);
fs = 48000;
Props.Names = {'Comment'};%made up properties because I don't understand what they should be
Props.Types = 1;
Props.Values = {''};
end
