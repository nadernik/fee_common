function [events, labels] = ege_Video_yaw_right(varargin)

varargin{3} = 'Yaw - Right';

[events, labels] = anvil_event_times_for_electro_gui(varargin{:});
