figure
for h = 1:hvc_units
    plot(weights_on_msn_from_hvc(:,h))
    title(int2str(h))
    pause
end