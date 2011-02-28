function h = plot_vf(vcdb, vfname, varargin)
P.mask = ones(size(vcdb.d.v));
P = parseargs(P, varargin{:});

vf = mapFeatureName2Number(vcdb.f.vfname, vfname);
was_held = ishold(gca);
hold on
try
    vft = mapFeatureName2Number(vcdb.f.vfname, 'pitchTime');
    T = vcdb.d.vf{vft}(P.mask);
    Y = vcdb.d.vf{vf}(P.mask);
    h = cellfun(@plot, T, Y);
catch
    Y = vcdb.d.vf{vf}(P.mask);
    h = cellfun(@plot, Y);
end
if ~was_held
    hold off
end