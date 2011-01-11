function density = vc_feat_syllableDensity( segmentTimes,Fs )

% convert segment times into seconds
segmentTimes = segmentTimes ./ Fs;

% Parameters
sd = 0.2; %seconds

timescale = sd*3;

N_segments = size(segmentTimes,1);

% for each syllable
for nSegment = 1:N_segments
	
	segStart = segmentTimes(nSegment,1);
	segEnd   = segmentTimes(nSegment,2);
	segMid   = mean([segStart segEnd]);
	
	% select other syllables within range
	otherTimes = [segmentTimes(1:nSegment,2); segmentTimes(nSegment+1:end,1)];
	nearby_before = (segStart - otherTimes)>0 & (segStart - otherTimes)<timescale; % for syllabels after look at beginnings
	nearby_after  = (otherTimes - segEnd)>0 & (otherTimes - segEnd)<timescale;% for syllabels before look at endings
	nearby = nearby_before | nearby_after;


	% for each of those syllables calculate distance from the other syllable boundary to the center of the current syllable
	Dt = abs( segMid - otherTimes(nearby) );

	% plug that distance into a gaussian or exponential and add all the
	% contributions
    density(nSegment) = sum( normpdf(Dt, 0, sd) );
end
end
