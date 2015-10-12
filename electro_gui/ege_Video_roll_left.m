function [events, labels] = ege_Video_roll_left(varargin)

varargin{3} = 'Roll - Left'; % event name

[events, labels] = anvil_event_times_for_electro_gui(varargin{:});
