%%
% This bird has a syllable with two harmonic stacks at different pitches. 
% Is the variability different between these two stacks?

birdname = 'mes021';
expername = '2011-05-03';
targetsyllable = 1;
timerange1 = [.020 .050];
timerange2 = [.105 .135]; %[.100 .145];

savefile1 = 'c:\stetner\data\pitchfluctuations\mes021_stack1.mat';
savefile2 = 'c:\stetner\data\pitchfluctuations\mes021_stack2.mat';

%% Do analysis
pitchfluctuations(birdname, expername, targetsyllable, timerange1, ...
    'Save', savefile1)
pitchfluctuations(birdname, expername, targetsyllable, timerange2, ...
    'Save', savefile2)

%% Are DC offsets correlated between two stacks in same syllables?

% Load data
d1 = load(savefile1);
d2 = load(savefile2);

% Match up syllables from the two data files. The syllables match if they
% have the same value for t since this is the start of the syllable.
syllpairs = zeros(0, 2);
totalpairs = 0;
for syll1 = 1:size(d1.pitches, 2)
    syll2 = find(d1.t(syll1) == d2.t);
    if length(syll2) > 1
        warning('Two matching syllables??? WTF?')
        keyboard
    end
    syllpairs(totalpairs+1, :) = [syll1 syll2];
    totalpairs = totalpairs + 1;
end

matchedoffsets1 = d1.offset(syllpairs(:, 1));
matchedoffsets2 = d2.offset(syllpairs(:, 2));

figure
scatter(matchedoffsets1, matchedoffsets2)
xlabel('Offset 1')
ylabel('Offset 2')

% No, they are not correlated at all!!