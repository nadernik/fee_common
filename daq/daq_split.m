function daq_split(filename, output_dir, seconds_per_part)
%DAQ_SPLIT Split a daq data file into smaller parts
%
% Usage:
%   DAQ_SPLIT(FILENAME, OUTPUT_DIR, SECONDS_PER_PART)
%
% Parameters:
%   FILENAME [string]
%     Name of the daq data file to be split
%   OUTPUT_DIR [string]
%     Name of the directory where the parts will be saved. This directory
%     must already exist.
%   SECONDS_PER_PART [double]
%     Duration of each part, in seconds. The final part may be shorter than
%     this.
%
% Returns:
%   None

[data, info] = daq_readDatafile(filename, true, []);

[~, old_name, ~] = fileparts(filename);

samples_per_part = floor(seconds_per_part * info.fs);
total_parts = ceil(length(data) / samples_per_part);

for part_num = 1:total_parts
    sample_start = (part_num - 1) * samples_per_part + 1;
    sample_end = min(sample_start + samples_per_part, length(data));
    part.data = data(sample_start:sample_end);
    part.info.fs = info.fs;
    part.info.absStartTime = info.absStartTime + sample_start / info.fs / 60 / 60 / 24;
    part.info.propertyNames = info.propertyNames;
    part.info.propertyTypes = info.propertyTypes;
    part.info.propertyValues = info.propertyValues;
    
    part_filename = sprintf('%s_part%06d', old_name, part_num);
    save(fullfile(output_dir, part_filename), '-struct', 'part');
end