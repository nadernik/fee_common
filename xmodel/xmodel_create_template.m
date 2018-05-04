% XMODEL_CREATE_TEMPLATE creates template from a bird's song

% Gaps are not included
% Must be clustered in vectorClust, with syllables numbered in the order
% that they occur (i.e. song is like syllables 1-2-3-1-2-3-1-2-3)

bird_name = '2463';
exper_name = '2011-09-02';

% Calculate durations of all syllables and the template
[pitch, absTime, syllable_labels, duration] = getProcessedPitchTrajectories(birdName, 'experNames', exper_name);
syllables = sort(unique(syllable_labels));
syllables = syllables(syllables ~= -1); % Leave out unlabeled syllables

for n = 1:length(syllables) % for each syllable in the motif
    selected = syllable_labels == syllable; % select all syllables of this type
    % find the average length of the syllable
    average_duration(n) = mean(duration(selected));
    
    % stretch all syllables of this type to match the average length
    stretched_pitch{n} = cellfun(@resample, pitch(selected), ...
        repmat(average_duration(n), sum(selected)), ...
        cellfun(@length, pitch(selected)));
    
    % average the stretched pitch trajectories
    mean_pitch{n} = mean(stretched_pitch{n});
    
    % add average pitch trajectory for this syllable to the template
    template = [template mean_pitch{n}];
end