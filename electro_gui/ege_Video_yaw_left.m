function [events, labels] = ege_Video_yaw_left(varargin)

varargin{3} = 'Yaw - Left';

[events, labels] = anvil_event_times_for_electro_gui(varargin{:});
