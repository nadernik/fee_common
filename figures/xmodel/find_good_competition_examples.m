% Find good example units for competition figure

close all

pre = load(fcomp1, 'msn_output', 'weights_on_msn_from_hvc');
post = load(fcomp2, 'msn_output', 'weights_on_msn_from_hvc');

good_pre = count_msn_peaks(pre.msn_output) == 1;
good_post = count_msn_peaks(post.msn_output) == 1;

good_units = good_pre & good_post;
total_good_units = sum(good_units)

[wsorted, ord] = sortbybursttime(pre.weights_on_msn_from_hvc, 0.2);
oldunit = find(good_units);
for u = 1:total_good_units
    good_units_after_reordering(u) = find(ord == oldunit(u));
end
good_units_after_reordering = sort(good_units_after_reordering);

figure
hold all
offset = 0;
for u = 1:total_good_units
    plot(pre.msn_output(oldunit(u), :, end)-offset)
    plot(post.msn_output(oldunit(u), :, end)-offset)
    offset = offset + 1;
end

figure
imagesc(wsorted(good_units_after_reordering,:))