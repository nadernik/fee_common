function mse = xmodel_calculate_mse(song, template)
total_motifs = size(song, 3);
e = song - repmat(template, [1,1,total_motifs]); % error is the difference between song output and the template
se = e.^2; % squared error
mse = squeeze(mean(mean(se,1),2)); % Mean across song features (dim 1) and length of song (dim 2)