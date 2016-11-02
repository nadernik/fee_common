function [events, labels] = ege_Video_pecking(varargin)

varargin{3} = 'Pecking';

[events, labels] = anvil_event_times_for_electro_gui(varargin{:});
