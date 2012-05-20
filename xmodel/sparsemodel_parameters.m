DEBUG_FLAG = 0;

% Length of simulation
baseline_motifs = 25; % number of motifs before learning starts
learning_motifs = 5000; % number of motifs where learning happens!
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
msn_units = 300; % Medium Spiny Neurons

% Time
hvc_burst_shift = 4; % Time between starts of consecutive HVC bursts
motif_steps = hvc_burst_shift * hvc_units; 
% Length of motif is the length of one HVC burst times the number of HVC
% neurons

% Learning rates
msn_learning_rate = 1e-5; % learning rate in HVC->X synapse
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
t = linspace(0, 2*pi, motif_steps);
template = 2*sin(t);

% Heterosynaptic competition
msn_burst_activity_threshold = .005;
msn_burst_time_threshold = 10;%motif_steps+1;
competition_strength = 1e-2;


% Inhibition
inhibition_strength = 0.0002;

% Synapse stability
% Stronger synapses are more stable and less sensitive to the effects of
% heterosynaptic competition and lateral inhibition. Stability is
% calculated for each synapse on every motif and is equal to
% exp(stability_factor * weight)
stability_factor = 300;

% LMAN -> MSN connections are drawn randomly on each motif. The weights are
% distributed between 1/lman_rand and lman_rand
lman_rand = 10;

msn_initial_weight = msn_burst_activity_threshold/hvc_units;

% conditional auditory feedback
caf_target_time1 = 5; % time steps
caf_target_time2 = 100;
caf_pitch_threshold1 = nan; % hits if above this
caf_pitch_threshold2 = nan; % hits if below this
caf_random_hit_probability = 0;
caf_error_value = 800;
caf_noise_duration = 20; % time steps
