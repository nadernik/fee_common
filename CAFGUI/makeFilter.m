function [bandFilters] = makeFilter(varargin)
% make filters for conditional auditory feedback
% used in CAFGUI
% Tatsuo Okubo, based on caf_program (Aaron Andalman)
% 2009/09/25

P.fs = 40000; % sampling frequency of the audio
P.tdt_fs = 24414; % sampling frequency of the TDT

P.bUp = true; % push up or down
P.pitchTarget = 1400;  %the pitch threshold
P.nudge = 50; %shift everything by nudge hertz
P.width = 150; %distance from pass to stop band (hz)
P.filterOverlap = .8; % NOT-CLASSIC: fraction of width that overlaps between in and out band filters.
P.bottomFreq = 1000; %NOT-CLASSIC
P.passIn = 100; %Size beyond width of the in band region.
P.dbDown = 40; %how supressed is power at 1 width from pass band.
P.harmonics = [1,2,3]; %which harmonics to target.

P = parseargs(P, varargin{:});

%get band filters
xS = P.width*(1-P.filterOverlap);
for(nharm = P.harmonics)
    if(~P.bUp) % pushing down
        bpStart = P.pitchTarget*P.harmonics(nharm) + xS - P.nudge;
        bpEnd = P.pitchTarget*P.harmonics(nharm) + (2*xS+P.passIn)*P.harmonics(nharm) - xS - P.nudge;
        bandFilters.in(nharm) = v3strong(max(P.bottomFreq+P.width, bpStart), P.tdt_fs, P.width, P.dbDown, bpEnd);

        bpStart = P.pitchTarget*(P.harmonics(nharm)-1) + (2*xS+P.passIn)*(P.harmonics(nharm)-1) + xS - P.nudge;
        bpEnd = P.pitchTarget*P.harmonics(nharm) - xS - P.nudge;
        bandFilters.out(nharm) = v3strong(max(P.bottomFreq+P.width, bpStart), P.tdt_fs, P.width, P.dbDown, bpEnd);
    else % pushing up
        bpStart = P.pitchTarget*P.harmonics(nharm) - (2*xS+P.passIn)*P.harmonics(nharm) + xS + P.nudge;
        bpEnd = P.pitchTarget*P.harmonics(nharm) - xS + P.nudge;
        bandFilters.in(nharm) = v3strong(max(P.bottomFreq+P.width, bpStart), P.tdt_fs, P.width, P.dbDown, bpEnd);

        bpStart = P.pitchTarget*P.harmonics(nharm) + xS + P.nudge;
        bpEnd = P.pitchTarget*(P.harmonics(nharm)+1) - (2*xS+P.passIn)*(P.harmonics(nharm)+1) - xS + P.nudge;
        bandFilters.out(nharm) = v3strong(max(P.bottomFreq+P.width, bpStart), P.tdt_fs, P.width, P.dbDown, bpEnd);
    end
end