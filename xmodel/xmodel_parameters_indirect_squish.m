% Length of simulation
baseline_motifs = 500; % number of motifs before learning starts
learning_motifs = 2000; % number of motifs where learning happens!
ending_motifs = 500; % number of motifs without learning at end of sim
total_motifs = baseline_motifs + learning_motifs + ending_motifs;

% Size of the network
hvc_units = 50; % number of units in hvc - change this to control length of song

% There is one RA unit representing the output of the system. It might be
% better to think of it as "pitch"
ra_units = 1;
% There are two LMAN units. One increases pitch and one decreases pitch.
lman_units = 2; 
% There is also one pallidal and one DLM unit for each LMAN unit
msn_units = lman_units * hvc_units; % Medium Spiny Neurons in each pathway

% Time
hvc_burst_shift = 4; %number of time steps in hvc burst
motif_steps = hvc_burst_shift * hvc_units; 
% Length of motif is the length of one HVC burst times the number of HVC
% neurons

% Learning rates
msn_learning_rate = 5e-4; % learning rate in HVC->X synapse
reward_learning_rate = .2; % learning rate of state value function V(s)

% Other
msn_threshold = 0;
lman_offset = 2;

% Synaptic eligibility trace and reward signal are both Gaussians with 4
% standard deviations before and after the mean. That puts a 4 standard
% deviation delay to peak of response
std_etrace = 50/4; % Eligibility trace
std_rkernel = 50/4; % Reward

% The template, aka the sequence we are trying to learn.
% template = 10*sin(linspace(0, 4*pi, motif_steps));
template = zeros(1, motif_steps);

% conditional auditory feedback
caf_target_time1 = 100; % time steps
caf_target_time2 = 100;
caf_pitch_threshold1 = 1; % hits if above this
caf_pitch_threshold2 = -1; % hits if below this
caf_random_hit_probability = 0;
caf_error_value = 400;
caf_noise_duration = 2; % time steps
