function [events, labels] = ege_Video_roll_right(data, fs, ~, params)

event_name = 'Roll - Right';

[events, labels] = anvil_event_times_for_electro_gui( ...
    data, fs, event_name, params);

