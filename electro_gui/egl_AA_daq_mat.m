function [data, fs, dateandtime, label, props] = egl_AA_daq_mat(filename, loaddata)
% egl_AA_daq_mat electro_gui loader for .mat files
%
% The .mat file must contain these variables:
%   data = a vector of data
%   info.fs = sampling rate for data, in Hz
%   info.absStartTime = start time for this data file in datenum format
%   info.propertyNames = cell array of property names
%   info.propertyTypes = array of property values. Type can be:
%                          1 for any string
%                          2 for boolean
%                          3 for a string chosen from a list
%   info.propertyValues = cell array of property values
%   info.label = OPTIONAL string ylabel for this data. If omitted, label 
%                will be 'Voltage (mV)'

x = load(filename);

% In this format, it is optional to specify a label in the info struct. If
% no label is specified, use the following default label.
if ~isfield(x.info, 'label')
    x.info.label = 'Voltage (mV)';
end

if loaddata == 0
    x.data = [];
end

data         = x.data;
fs           = x.info.fs;
dateandtime  = x.info.absStartTime;
label        = x.info.label;
props.Names  = x.info.propertyNames;
props.Types  = x.info.propertyTypes;
props.Values = x.info.propertyValues;