function owprint(txt, varargin)
%OWPRINT Write formatted data to screen, overwriting previous.
%
%This function is intended to be used to print out an updating status
%message where each message replaces the previous. To work as intended,
%nothing else should write to the screen between calls to this function.
%
%Example:
%    OWPRINT() % resets internal memory of this function
%    for ii = 1:1000
%        OWPRINT('Iteration %d', ii)
%        % do something
%    end
%
%OWPRINT(FORMAT, ...) calls FPRINTF(FORMAT, ...) to write formatted data to
%the screen. If OWPRINT has written something to the screen since the last
%time its memory was cleared, it first deletes characters equal to the
%number of bytes it last wrote to the screen. 
%
%OWPRINT() clears the memory of this function. The memory can also be
%cleared by "clear owprint" or "clear all".
%
%See also: FPRINTF

persistent n
% If called without arguments, reset the memory of how many characters we
% last printed.
if nargin == 0
    n = [];
    return;
end
% If this is the first time we are calling this function since its memory
% has been cleared, set the number of characters printed to zero.
if isempty(n)
    n = 0;
end
% Delete characters equal to the number of bytes we printed last time
fprintf(repmat('\b', 1, n));
% Print the formatted data and store the number of bytes printed for next
% time.
n = fprintf(txt, varargin{:});
end