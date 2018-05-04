function y = texcolor(s, c, varargin)
%TEXCOLOR TeX string with specified color
%   TEXCOLOR(S, C) returns string S with appropriate TeX markup so it
%   appears as color C.
%   
%   TEXCOLOR(S1, C1, S2, C2, ...) returns a cell array of strings where
%   each string S1, S2, ... has TeX markup to appear as the corresponding 
%   color C1, C2, ...
%
%   Colors must be specified as either the name of a basic color or as a
%   RGB triplet with values between 0 and 1.
%
%   Example:
%       title(texcolor('This is red', 'red', 'And this is cyan', [0 .7 .7])) 

if mod(nargin, 2) ~= 0
    error('Wrong number of arguments. Must give string, color pairs')
end

y = [color2tex(c), s];

if nargin > 2
    temp = y;
    y = cell(1, nargin / 2);
    y{1} = temp;
    
    for ii = 1:nargin / 2 - 1
        y{ii+1} = [color2tex(varargin{2*ii}) varargin{2*ii-1}];
    end
end

function cstr = color2tex(c)
if ~iscolorspec(c)
    error('Not a valid colorSpec')
end
if ischar(c)
    cstr = sprintf('\\color{%s}', c);
else
    cstr = sprintf('\\color[rgb]{%g %g %g}', c(1), c(2), c(3));
end

function tf = iscolorspec(c)
colornames = {'red', 'green', 'yellow', 'magenta', 'blue', 'black', 'white', 'gray', 'darkGreen', 'orange', 'lightBlue'};
is_named_color = any(strcmp(colornames, c));
is_rgb = isvector(c) && length(c) == 3 && all(c >= 0) && all(c <= 1);
tf = is_named_color || is_rgb;