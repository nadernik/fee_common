% hvc_units = 50;
% motif_steps = 250;
% hvc_steps = 10;
% hvc_output = zeros(hvc_units, motif_steps);

% figure
% x = linspace(0, 2*pi, hvc_steps * 4);
% burst(:, 1) = sin(x).^2;
% x = linspace(pi/2, 2*pi + pi/2, hvc_steps * 4);
% burst(:, 2) = sin(x).^2;
% plot(burst)
% hold all
% plot(sum(burst, 2))

% 
x = linspace(0, pi, hvc_steps * 2);
cosburst = cos(x).^2;
cosburst = cosburst([6:10, 1:5]);
sinburst = sin(x).^2;

for u = 1:hvc_units
    offset = (u - 1) * hvc_steps;
    t = modnonzero((1:2*hvc_steps) + offset, motif_steps);
    if mod(u, 2) == 1 % odd bursts are cosine
        hvc_output(u, t) = cosburst;
    else
        hvc_output(u, t) = sinburst;
    end
end

figure
plot(hvc_output')
hold all
plot(sum(hvc_output))