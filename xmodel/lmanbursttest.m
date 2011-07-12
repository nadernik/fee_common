rate = 1;

T = 1000;
lman_output = zeros(1, T + burst_width);

for t = 1:1000;
    if rand <= rate
        lman_output(t + t_burst) = lman_output(t + t_burst) + burst;
    end
end

figure
plot(lman_output)