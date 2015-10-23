function [events, labels] = ege_Video_grooming(varargin)

varargin{3} = 'Grooming';

[events, labels] = anvil_event_times_for_electro_gui(varargin{:});
