function [events, labels] = ege_Video_chewing(varargin)

varargin{3} = 'Chewing';

[events, labels] = anvil_event_times_for_electro_gui(varargin{:});
