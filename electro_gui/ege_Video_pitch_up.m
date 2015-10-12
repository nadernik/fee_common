function [events, labels] = ege_Video_pitch_up(data, fs, ~, params)

event_name = 'Pitch - Up';

[events, labels] = anvil_event_times_for_electro_gui( ...
    data, fs, event_name, params);

