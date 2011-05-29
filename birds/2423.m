%% 2011-05-29
% Switched from Aardvark to TDT microphone amplifier yesterday to hopefully
% get better sound quality. I missed the first few hours of recording
% (until 00:30) because I forgot to put a battery in the microphone. The
% TDT amplifier does not supply phantom power like the Aardvark does.
%
% I set the recording settings very low so I would capture all the sound.

ii = 1;
expers{ii} = loadExper('2423', '2011-05-28', 'c:\stetner\data');
Bout_detect_TO(expers{ii}.dir, expers{ii}.audioCh, [])
combine_boutfiles([expers{ii}.dir filesep 'bouts\analysis_bout.mat'])
Parse_segments
% bout file 721 first singing. everything before this is just calls.
Batch_song_rhythm('2423','2011-05-28',1, 721:851)
% Distributions look exponential. This guy is still subsong. Wait until he
% has a bump in his syllable distribution before lesioning.

% New settings for aquisitionGui:
%   Song Density: 0.5
%   Power Thres:  1
%   Song Length:  0.5