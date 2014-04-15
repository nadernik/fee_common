% Length of simulation
baseline_motifs = 1000; % number of motifs before learning starts
learning_motifs = 0; % number of motifs where learning happens!
ending_motifs = 0; % number of motifs without learning at end of sim
total_motifs = baseline_motifs + learning_motifs + ending_motifs;

% Size of the network
hvc_units = 6; % number of units in hvc - change this to control length of song

% There is one RA unit representing the output of the system. It might be
% better to think of it as "pitch"
ra_units = 1;
% There are two LMAN units. One increases pitch and one decreases pitch.
lman_units = 2; 
% There is also one pallidal and one DLM unit for each LMAN unit
msn_units = lman_units * hvc_units; % Medium Spiny Neurons

% Time
hvc_burst_shift = 4; %number of time steps in hvc burst
motif_steps = hvc_burst_shift * hvc_units; 
% Length of motif is the length of one HVC burst times the number of HVC
% neurons

% Learning rates
msn_learning_rate = 1e-7; % learning rate in HVC->X synapse
reward_learning_rate = 1/25; % learning rate of state value function V(s)

% Other
msn_threshold = 0;
lman_offset = 0;

% Synaptic eligibility trace and reward signal are both Gaussians with 4
% standard deviations before and after the mean. That puts a 4 standard
% deviation delay to peak of response
std_etrace = 3; % Eligibility trace
std_rkernel = 3; % Reward

% The template, aka the sequence we are trying to learn.
template = 5 * ones(1, motif_steps);

% conditional auditory feedback
caf_target_time1 = 1; % time steps
caf_target_time2 = 1;
caf_pitch_threshold1 = nan; % hits if above this
caf_pitch_threshold2 = nan; % hits if below this
caf_random_hit_probability = 0;
caf_error_value = 800;
caf_noise_duration = 20; % time steps
