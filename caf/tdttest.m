% Tests the speed of data transfer to and from the TDT

total_trials = 1000;
fs = 24414;
% Start by putting a bunch of data on the TDT. In a real experiment, this
% data would be recorded from a bird.

tic % start timing
for trial = 1:total_trials
    % get latest index
    curindex=RP.GetTagVal(tags.testIndex);
    % pull data from TDT
    startidx = curindex - bufpts;
    d = RP.ReadTagV(tags.testData,startidx,bufpts);
    % calculate pitch
    [pitch, pitchGoodness, harmonicPower, time, entropy] = estimatePitch(audio, fs, varargin);
    mean_pitch = mean(pitch);
    mean_pitchGoodness = mean(pitchGoodness);
    % decide on noise
    if mean_pitch > pitch_lo && mean_pitch < pitch_hi && mean_pitchGoodness > goodess_thresh
        RP.SetTagVal(tags.noise, 1);
    end
end

% stop timing
total_time = toc; % seconds

fprintf(1, 'Average trial time is %s milliseconds', total_time/total_trials*1000)