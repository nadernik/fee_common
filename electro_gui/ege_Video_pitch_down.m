function [events, labels] = ege_Video_pitch_down(data, fs, ~, params)

event_name = 'Pitch - Down';

[events, labels] = anvil_event_times_for_electro_gui( ...
    data, fs, event_name, params);

