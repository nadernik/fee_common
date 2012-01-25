DEBUG_FLAG = 0;

% Length of simulation
baseline_motifs = 25; % number of motifs before learning starts
learning_motifs = 200; % number of motifs where learning happens!
ending_motifs = 0; % number of motifs without learning at end of sim
total_motifs = baseline_motifs + learning_motifs + ending_motifs;

% Size of the network
hvc_units = 50; % number of units in hvc - change this to control length of song

% There is one RA unit representing the output of the system. It might be
% better to think of it as "pitch"
ra_units = 1;
% There are two LMAN units. One increases pitch and one decreases pitch.
lman_units = 2; 
% There is also one pallidal and one DLM unit for each LMAN unit
msn_units = 400; % Medium Spiny Neurons

% Time
hvc_burst_shift = 4; %number of time steps in hvc burst
motif_steps = hvc_burst_shift * hvc_units; 
% Length of motif is the length of one HVC burst times the number of HVC
% neurons

% Learning rates
msn_learning_rate = 100e-6; % learning rate in HVC->X synapse
reward_learning_rate = .2; % learning rate of state value function V(s)

msn_initial_weight = 0.5;

% Other
msn_threshold = .2;
lman_offset = 5;

% Synaptic eligibility trace and reward signal are both Gaussians with 4
% standard deviations before and after the mean. That puts a 4 standard
% deviation delay to peak of response
std_etrace = 7; % Eligibility trace
std_rkernel = 7; % Reward

% Heterosynaptic competition
max_total_synaptic_weight = 6;
max_single_synaptic_weight = Inf;
min_single_synaptic_weight = 0.1;
competition = 100 * msn_learning_rate;

% The template, aka the sequence we are trying to learn.
t = linspace(0, 2*pi, motif_steps);
template = 10*sin(t);

% conditional auditory feedback
caf_target_time1 = 5; % time steps
caf_target_time2 = 100;
caf_pitch_threshold1 = nan; % hits if above this
caf_pitch_threshold2 = nan; % hits if below this
caf_random_hit_probability = 0;
caf_error_value = 800;
caf_noise_duration = 20; % time steps
