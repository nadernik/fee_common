function h = vfplot(vcdb, vfname, varargin)
P.mask = true(size(vcdb.d.v));
P = parseargs(P, varargin{:});

Y = getvf(vcdb, vfname, P.mask);
was_held = ishold(gca);
hold on
try
	T = getvf(vcdb, 'pitchTime', P.mask);
    h = cellfun(@plot, T, Y);
catch
    h = cellfun(@plot, Y);
end
if ~was_held
    hold off
end