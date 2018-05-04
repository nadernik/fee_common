competition_strength = .12;
competition_scale = -log(1e-4/competition_strength) / 0.04;

figure
w = linspace(0, globalmax(weights_on_msn_from_hvc));
f = exp(-competition_scale .* w);
comp = f .* competition_strength;
plot(w, comp)