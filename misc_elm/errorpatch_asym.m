function errorpatch_asym(X, Y, Elower,Eup, LC, PC)
% This function replicates the functionality of errorbar, but uses
% errorpatches instead
X = X(:);
Y = Y(:);
Elower = Elower(:);
Eup = Eup(:); 
% By Emily Mackevicius, edited by Matt Best 6/27/11
if nargin < 6
    PC = [.8 .8 .8];
end;

if nargin < 5
    LC = [.2 .2 .2];
end;


plot(X, Y, 'Color', LC)%, 'LineWidth', 2);

xa = [X; X(end:-1:1)];
%ya = [(Y + Eup); (Y(end:-1:1) - Elower(end:-1:1))];
ya = [(Eup); (Elower(end:-1:1))];

h = patch(xa, ya, PC);
set(h, ...
      'EdgeAlpha', .3, ...
      'EdgeColor', PC, ...
      'FaceAlpha', .3, ...
      'LineStyle', 'none' ...
      );
return