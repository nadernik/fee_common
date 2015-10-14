function [events, labels] = ege_Video_pitch_up(varargin)

varargin{3} = 'Pitch - Up';

[events, labels] = anvil_event_times_for_electro_gui(varargin{:});
