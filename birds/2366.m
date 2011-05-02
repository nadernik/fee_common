%%
% MMAN Lesion
% Is MMAN required for the song rhythmicity that develops at the end of
% subsong? Lesion MMAN just after rhythmicity starts to develop and see if:
% (1) Existing rhythmicity disappears, implying that MMAN is storing
%       rhythmicity "bias"
% (2) Further rhytmicity does not develop, implying that MMAN is required
%       for learning rhythmicity.
% Isolate while in subsong and analyze song daily to look for rhythmicity
% developing using analysis code written by Tatsuo. A day or two after
% rhythmicity is visible, lesion MMAN and continue analyzing rhythmicity
% every few days.
%
% Need objective measure for when to lesion
% How long to track?

%% 2011-04-30
Bout_detect_SAP_TO('C:\stetner\data\2366\2289')
% Only 129 bouts, and most of those don't even contain song. Did not sing
% enough. Try rhytmicity analysis anyway:
Parse_segments % all the files
Batch_song_rhythm('2366','2289',1)
% Looks like subsong
