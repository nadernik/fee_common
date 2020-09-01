function [data, fs, dateandtime, label, Props] = egl_feather_daq(filename, loadData)

label = 'Voltage (V)';
toks = regexp(filename, '^.*audioOut_(\d{4}-\d{2}-\d{2}T\d{2}_\d{2}_\d{2}\.\d{7}).*$', 'tokens', 'once');
if isempty(toks)
    toks = regexp(filename, '^.*audioOut_(\d{4}-\d{2}-\d{2}T\d{2}_\d{2}_\d{2})\.bin$', 'tokens', 'once');
    if isempty(toks)
        error("unable to parse file name %s for date and time", filename);
    else
        millis = false;
    end
else
    millis = true;
end
if millis
    dt = datetime(toks{1}, 'InputFormat', 'yyyy-MM-dd''T''HH_mm_ss.SSSSSSS');
else
    dt = datetime(toks{1}, 'InputFormat', 'yyyy-MM-dd''T''HH_mm_ss');
end
dateandtime = datenum(dt);

if loadData ~= 1
    data = [];
else
    fid = fopen(filename, 'r');
    rawdata = fread(fid, [3, Inf], 'double');
    data = rawdata(1, :);
end
fs = 48000;
Props.Names = {'Comment'};%made up properties because I don't understand what they should be
Props.Types = 1;
Props.Values = {''};
