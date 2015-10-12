function [events, labels] = ege_Video_yaw_left(data, fs, ~, params)

event_name = 'Yaw - Left';

[events, labels] = anvil_event_times_for_electro_gui( ...
    data, fs, event_name, params);

