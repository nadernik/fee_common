function [starts, matches, bird_names, file_numbers, datetime_strs, channel_numbers] = ...
         AA_daq_file_name_info(strs)
    [starts, matches, tokens] = regexp(strs, ...
                               '([^_/\\]*)_d(\d{6})_(\d{8}T\d{6})chan(\d+)\.dat$', ...
                               'once', 'start', 'match', 'tokens');
    if iscell(strs)
        nin = numel(strs);
        bird_names = cell(nin, 1);
        file_numbers = nan(nin, 1);
        datetime_strs = cell(nin, 1);
        channel_numbers = nan(nin, 1);
        for elno = 1:nin
            bird_names{elno} = tokens{elno}{1};
            file_numbers(elno) = str2double(tokens{elno}{2});
            datetime_strs{elno} = tokens{elno}{3};
            channel_numbers(elno) = str2double(tokens{elno}{4});
        end
    else
        bird_names = tokens{1};
        file_numbers = str2double(tokens{2});
        datetime_strs = tokens{3};
        channel_numbers = str2double(tokens{4});
    end
end
