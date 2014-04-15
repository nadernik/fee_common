% Used on my SfN 2011 poster in the section "Hypothesis: HVCX synapses are
% strengthened when LMAN fluctuations are correlated with reward"

clear all
close all


total_hvc_units = 5;
total_steps = 1002;
rewarded_unit = 3;
steps_per_hvc_unit = floor(total_steps / total_hvc_units);
line_width = 4;

sig = 1*steps_per_hvc_unit;
x = -4*sig:4*sig;
kernel = 1/sqrt(2*pi*sig^2) * exp(-(x).^2/2/sig^2);

lman = zeros(total_steps, 1);
reward = zeros(total_steps, 1);
hvc = zeros(total_steps, total_hvc_units);

for hvc_unit = 1:total_hvc_units
    steps = (hvc_unit-1) * steps_per_hvc_unit + (1:steps_per_hvc_unit) + 1;
    hvc(steps, hvc_unit) = 1;
    if hvc_unit == rewarded_unit
        lman(steps, 1) = 1;
    end

end
reward = conv(kernel, lman);
reward = reward / max(reward);

for hvc_unit = 1:total_hvc_units
    eligibility_trace(:, hvc_unit) = conv(hvc(:,hvc_unit) .* lman, kernel);
end
eligibility_trace = eligibility_trace ./ max(max(eligibility_trace));

% figure
% plot(lman)
% hold all
% plot(reward)
% 
% figure
% plot(hvc)
% hold all
% plot(eligibility_trace)

figure
hold all
offset = 0;
plot(lman - offset, 'Color', [0 .6 0], 'LineWidth', line_width)
offset = offset + 1.5;
plot(reward - offset, 'Color', [0 0 .6], 'LineWidth', line_width)
offset = offset + 1.5;
for hvc_unit = 1:total_hvc_units
    plot(hvc(:, hvc_unit) - offset, 'Color', [.6 .6 0], 'LineWidth', line_width)
    plot(eligibility_trace(:, hvc_unit) - offset, '--', 'Color', [.6 0 0], 'LineWidth', line_width)
    offset = offset + 1.5;
end
ylim([-offset, 1.5])