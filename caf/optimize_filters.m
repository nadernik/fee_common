% Make the perfect filters

%% Parameters
rules_file = 'c:\stetner\data\2558\2011-10-19\rules.mat';
audio_file_numbers = 1:100;
exper = loadExper('2558', '2011-10-19');
N = 50; % number of different tweaks
parameters_to_tweak = {'nudge', 'width', 'overlap', 'passIn'}
parameter_ranges = {[0 100], [140 240], [.7 .99], [0 200]}
% Start with rules from file

load(rules_file)
r = find([handles.rules.condition] == 3);
if ~isscalar(r)
    error('More than one pitch rule found')
end

% load audio from files to test
for f = 1:length(audio_file_numbers)
    [a, timeFileCreated, startTime, startSamp, names, values, info] = loadAudio(exper,num,whichSamples)
    audio{f} = a;
end

% find target syllables in test data


% get pitch in target interval for target syllables in test data

%%



    

%%
for p = 1:length(parameters_to_tweak)
    for n = 1:N
        handles.rules(r).params = tweak_parameters(p,n);
        for f = 1:total_files
            noise = testRulesOnFile(handles, audio{f});
            hits_by_syllable(p,n,:) = hits_by_syllable(p,n,:) + get_hits_in_syllable(f, noise);
        end
    end
end
        
        
    
% randomly tweak parameters
% test clustered syllables
% measure accuracy
% probability of noise as a function of pitch
% hits P(noise & pitch_above_threshold)
% misses
% correct rejections
% false alarms

function hits_by_syllable = get_hits_in_syllable(noise, syllable_start_times, syllable_end_times)
for 