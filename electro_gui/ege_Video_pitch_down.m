function [events, labels] = ege_Video_pitch_down(varargin)

varargin{3} = 'Pitch - Down';

[events, labels] = anvil_event_times_for_electro_gui(varargin{:});
