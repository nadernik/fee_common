function [data, fs, dateandtime, label, Props] = egl_feather_daq(filename, loadData)
% Requires 'featherscope_matlab' repo to work
    [fs, dateandtime, label, Props] = feather_daq_common_egl(filename);
    if loadData ~= 1
        data = [];
    else
        rawdata = feather_daq_load_data(filename);
        data = rawdata(1, :);
    end
end
