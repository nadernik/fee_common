function figure_example_model_pitch_fluctuations(do_simulation)

total_traces = 3;

%% example randomly generated pitch traces
offset     = 5;
pitch_up   =  max(generate_lman_noise_mes010(50, total_traces) + offset,0);
pitch_down = max(generate_lman_noise_mes010(50, total_traces) + offset,0);
song = pitch_up - pitch_down;

% Example traces from pitch-up channel
a(1) = subplot(1,3,1);
plot(pitch_up,'k', 'LineWidth', 1)
hold on
plot(xlim, [0 0],'k','LineWidth', 2)
hold off
ylim([-15, 15])
axis off

% Example traces from pitch-down channel
a(2) = subplot(1,3,2);
plot(pitch_down,'k', 'LineWidth', 1)
hold on
plot(xlim, [0 0], 'k','LineWidth', 2)
hold off
ylim([-15, 15])
axis off

% Example traces of "pitch" (sum of the two channels)
a(3) = subplot(1,3,3);
plot(song,'k', 'LineWidth', 1)
hold on
plot(xlim, [0 0],'k','LineWidth', 2)
axis off

% scale bar (x)
fill([50 50 40 40], -[15 14.7 14.7 15],'k')
text(55,-14,'10 ms')
% 
% % scale bar (y)
fill([0 0 2 2],[-15, -10, -10, -15], 'k') 
text(5,-12,'5% \Delta pitch')
ylim([-15, 15])
hold off