% In a model that contains RA->DLM connection, there is a recurrent loop
% from LMAN->RA->DLM->LMAN. This makes calculating the activity of LMAN
% difficult because it depends on the past history of LMAN activity. My
% goal is to do this without using a for loop so that the code remains
% fast. In this file, I test to see if my method for computing LMAN
% activity in this circuit gives the same answer as a more straightforward
% method using a for loop.
%
% One particular weakness of the convolution approach is that the system
% must be linear. I had to remove the threshold nonlinearity on the output
% of LMAN neurons. In the  convolution version, LMAN activity can be
% positive or negative. In the for loop version (as in all of the other
% models in this project), LMAN activity is restricted to be non-negative.
%% for loop method
motif = 1;
tic
for t = 1:motif_steps
    % MSN activity is determined by input from HVC. LMAN has no
    % effect.
    msn_input = weights_on_msn_from_hvc * hvc_output(:,t);
    msn_output(:,t) = max(msn_input - msn_threshold, 0);

    pallidal_output(:,t) = weights_on_pallidus_from_msn * msn_output(:,t);
    
    if t == 1
        dlm_output(:,t,motif) = weights_on_dlm_from_pallidus * pallidal_output(:,t);
    else
        dlm_output(:,t,motif) = weights_on_dlm_from_pallidus * pallidal_output(:,t) + ...
            weights_on_dlm_from_ra * ra_output(:,t-1);
    end
 
    lman_output(:,t,motif) = lman_offset + lman_noise(:,t,motif) + weights_on_lman_from_dlm * dlm_output(:,t,motif);
    ra_output(:,t,motif) = weights_on_ra_from_lman * lman_output(:,t) + ...
        weights_on_ra_from_hvc * hvc_output(:,t);
    pitch(t,motif) = weights_on_song_from_ra * ra_output(:,t);
end
fprintf('For loop method takes %g milliseconds.\n', toc * 1000)
figure(1)
plot(pitch(:,motif))
return
%% convolution method
w_recur = weights_on_lman_from_dlm * weights_on_dlm_from_ra * weights_on_ra_from_lman;
kernel = w_recur(1).^(1:motif_steps);

tic
% MSN activity is determined by input from HVC. LMAN has no
% effect.
msn_input = weights_on_msn_from_hvc * hvc_output;
msn_output = max(msn_input - msn_threshold, 0);

% Each LMAN unit has a corresponding pallidal unit. The
% pallidal unit sums the activity
pallidal_output = weights_on_pallidus_from_msn * msn_output;

% LMAN activity is the sum of intrinsic noise and input from DLM. LMAN
% firing rates cannot be negative but have a baseline rate.
lman_no_recur(:,1) = lman_offset + lman_noise(:,1,motif) + ...
    weights_on_lman_from_dlm * weights_on_dlm_from_pallidus * pallidal_output(:,1);
lman_no_recur(:,2:end) = lman_offset + lman_noise(:,2:end,motif) + ...
    weights_on_lman_from_dlm * weights_on_dlm_from_pallidus * pallidal_output(:,2:end,motif) + ...
    weights_on_lman_from_dlm * weights_on_dlm_from_ra * weights_on_ra_from_hvc * hvc_output(:,1:end-1) + ...
    weights_on_lman_from_dlm * weights_on_dlm_from_ra * ra_noise(:,1:end-1,motif);

% had to remove nonlinearity (thresholding at zero)
temp = conv(lman_no_recur, kernel);
lman_output = temp(:,1:motif_steps);

% RA activity is the sum of inputs from HVC and intrinsic
% noise. LMAN-RA pathway is turned off.
ra_input = weights_on_ra_from_hvc * hvc_output + ...
    weights_on_ra_from_lman * lman_output + ...
    ra_noise(:, :, motif);
ra_output = max(ra_input + lman_offset, 0);

% The vocal output of the model is determined by RA activity
pitch = weights_on_song_from_ra * ra_output;
fprintf('Convolution method takes %g milliseconds.\n', toc * 1000)
figure(2)
plot(pitch)