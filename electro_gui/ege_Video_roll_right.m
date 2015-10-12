function [events, labels] = ege_Video_roll_right(varargin)

varargin{3} = 'Roll - Right';

[events, labels] = anvil_event_times_for_electro_gui(varargin{:});
